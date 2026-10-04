#!/usr/bin/env bash
set -Eeuo pipefail
umask 077
[[ $EUID -ne 0 ]] || { echo 'Run as your normal user, not with sudo.' >&2; exit 2; }
[[ $(uname -m) == x86_64 && -d /usr/share/omarchy && -d /sys/firmware/efi ]] || { echo 'Requires x86_64 Omarchy with UEFI/Limine.' >&2; exit 2; }
for cmd in curl gpg sha256sum sudo mount umount mktemp; do command -v "$cmd" >/dev/null || { echo "Missing command: $cmd" >&2; exit 2; }; done
# The EFI partition may be accessible only to root on Omarchy.
sudo -v
sudo test -f /boot/limine.conf || { echo 'Limine configuration /boot/limine.conf is missing.' >&2; exit 2; }
free=$(df -Pk /var/tmp | awk 'NR==2 {print $4}')
[[ $free -ge 2097152 ]] || { echo 'At least 2 GiB free space in /var/tmp is required.' >&2; exit 2; }
work=$(mktemp -d /var/tmp/dopatox-download.XXXXXXXX)
mounted=0
cleanup() {
 unset password
 if (( mounted )); then sudo umount "$work/media" || { echo "Preserved mounted download: $work" >&2; return; }; fi
 rm -f -- "$work/package.gpg" "$work/package.iso"
 rmdir -- "$work/media" 2>/dev/null || true
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
curl --fail --location --retry 3 --proto '=https' --proto-redir '=https' --output "$work/package.gpg" 'https://github.com/dopatoxx-arch/dl-5fde59641e61d48d/releases/download/r56/package.gpg'
printf '%s  %s\n' '6df60945499cc49decc0f949b389ea9e1eaee33b3ee866e227612050b26431bb' "$work/package.gpg" | sha256sum --check --strict
printf '%s\n' "$password" | gpg --no-options --homedir "$work/gnupg" --batch --yes --pinentry-mode loopback --passphrase-fd 0 --output "$work/package.iso" --decrypt "$work/package.gpg"
unset password
printf '%s  %s\n' '4c38aba39871e00074dc71c06896f9e752415214f0e3de56ba32c363e9a07e8d' "$work/package.iso" | sha256sum --check --strict
rm -f -- "$work/package.gpg"
sudo -v
sudo mount -o loop,ro,nodev,nosuid "$work/package.iso" "$work/media"
mounted=1
sudo bash "$work/media/install-omarchy.sh"
