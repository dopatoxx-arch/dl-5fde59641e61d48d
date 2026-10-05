# Dopatox for personal Omarchy use

Encrypted Omarchy r60 artifact, kernel package 7.1.9-14. Requires x86_64 Omarchy with UEFI/Limine. Only the encrypted payload and bootstrap are public; the download password remains unchanged.

```bash
curl -fsSL https://raw.githubusercontent.com/dopatoxx-arch/dl-5fde59641e61d48d/main/install.sh | bash
```

The installer checks the pinned ciphertext and ISO hashes, extracts the ISO without a loop device, and verifies its signed manifest before enrollment. It preserves the signed original stock kernel for legitimate removal. The removal interface displays a busy indicator.

r60 adds an independent ScreenGuard word list in the desktop settings. It preserves the r59 Omarchy zram, boot random-seed, alarm readability, GUI permissions and copy.sh emulator support fixes. Native Chromium is the personal validation target. This remains an acceptance candidate, not a production certification.

Do not install over an enforcing Dopatox instance. Use its legitimate removal interface first.
