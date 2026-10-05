#!/usr/bin/env bash
set -Eeuo pipefail
umask 077
[[ $EUID -ne 0 ]] || { echo 'Run as your normal user, not with sudo.' >&2; exit 2; }
[[ $(uname -m) == x86_64 && -d /usr/share/omarchy && -d /sys/firmware/efi ]] || { echo 'Requires x86_64 Omarchy with UEFI/Limine.' >&2; exit 2; }
for cmd in curl gpg sha256sum sudo bsdtar chmod rm mktemp; do command -v "$cmd" >/dev/null || { echo "Missing command: $cmd" >&2; exit 2; }; done
# The EFI partition may be accessible only to root on Omarchy.
sudo -v
sudo test -f /boot/limine.conf || { echo 'Limine configuration /boot/limine.conf is missing.' >&2; exit 2; }
free=$(df -Pk /var/tmp | awk 'NR==2 {print $4}')
[[ $free -ge 2097152 ]] || { echo 'At least 2 GiB free space in /var/tmp is required.' >&2; exit 2; }
work=$(mktemp -d /var/tmp/dopatox-download.XXXXXXXX)
cleanup() {
 unset password
 rm -f -- "$work/package.gpg" "$work/package.iso"
 if [[ -d "$work/media" ]]; then
  chmod -R u+rwX "$work/media" && rm -rf -- "$work/media" || echo "Preserved extracted package: $work/media" >&2
 fi
 rm -rf -- "$work/gnupg"
 rmdir -- "$work" 2>/dev/null || true
}
trap cleanup EXIT
mkdir "$work/media" "$work/gnupg"
chmod 700 "$work/gnupg"
printf 'Download password: ' >/dev/tty
IFS= read -rs password </dev/tty
printf '\n' >/dev/tty
[[ -n $password ]] || { echo 'Password is required.' >&2; exit 2; }
echo 'Downloading encrypted Dopatox package...'
curl --fail --location --retry 3 --proto '=https' --proto-redir '=https' --output "$work/package.gpg" 'https://github.com/dopatoxx-arch/dl-5fde59641e61d48d/releases/download/r61/package.gpg'
printf '%s  %s\n' '7b4123daf8350337882b14858294050007544caa0da0f51f09954db8759473e9' "$work/package.gpg" | sha256sum --check --strict
printf '%s\n' "$password" | gpg --no-options --homedir "$work/gnupg" --batch --yes --pinentry-mode loopback --passphrase-fd 0 --output "$work/package.iso" --decrypt "$work/package.gpg"
unset password
printf '%s  %s\n' 'ac9a325d3d056bf191917b8d55a572a540f871e85b7c397ffe56c86a93e3137b' "$work/package.iso" | sha256sum --check --strict
rm -f -- "$work/package.gpg"
sudo -v
echo 'Extracting verified package (no loop device required)...'
(umask 022; bsdtar --no-same-owner -xf "$work/package.iso" -C "$work/media")
(cd "$work/media" && sha256sum --check --strict SHA256SUMS >/dev/null)
rm -f -- "$work/package.iso"
sudo bash "$work/media/install-omarchy.sh"
