# Dopatox for personal Omarchy use

Encrypted Omarchy r59 artifact, kernel package 7.1.9-14. Requires x86_64 Omarchy with UEFI/Limine. Only the encrypted payload and bootstrap are public; the download password remains unchanged.

```bash
curl -fsSL https://raw.githubusercontent.com/dopatoxx-arch/dl-5fde59641e61d48d/main/install.sh | bash
```

The installer checks the pinned ciphertext and ISO hashes, extracts the ISO without a loop device, and verifies its signed manifest before enrollment. It preserves the signed original stock kernel for legitimate removal. The removal interface displays a busy indicator.

r59 fixes Omarchy zram initialization, boot random-seed updates, alarm configuration readability, GUI extraction permissions, and adds copy.sh to the foreground emulator catalog. Native Chromium is the personal validation target. This remains an acceptance candidate, not a production certification.

Do not install over an enforcing Dopatox instance. Use its legitimate removal interface first.
