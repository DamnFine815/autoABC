# autoABC 1.1.1 - Release Notes

Automatic Blu-ray Region A/B/C selection for OPPO UDP-203 (RU-JB 65-0131).

### What's new

- Added support for **oppo-dv-mkv v1.7.0**, both standalone and combined with supported jb_overlay installations.
- **oppo-dv-mkv v1.5.0 / v1.6.0 remain supported.** The existing Region A/B/C, PSR20, Earlyboot and integrated [UOPfree](https://github.com/DamnFine815/UOPfree) functionality is unchanged.

### Important: uninstall before upgrading

**Uninstall any older autoABC using that version's matching uninstaller, then fully power-cycle before running 1.1.1 CHECKONLY. Never install 1.1.1 over an older build.** Uninstall standalone [UOPfree](https://github.com/DamnFine815/UOPfree) before enabling integrated `UOPFREE=1`.

**Note:** If you upgraded oppo-dv-mkv to v1.7.0 while autoABC 1.1.0 was still installed, the old autoABC uninstaller may reject the updated MKV launcher. Do not bypass its safety checks or use the 1.1.1 uninstaller on 1.1.0.

### Installation

1. Extract `autoABC-1.1.1-CHECKONLY.zip` alone to a clean USB root. Edit `AutoScript/config.ini` and `AutoScript/uopfree.ini` if needed; boot and confirm `COMPATIBLE` in `autoABC-result.txt`.
2. Extract `autoABC-1.1.1-install.zip` alone to a clean USB root with the **same settings**. Boot and confirm `INSTALLED` (or verified `ALREADY_INSTALLED`).
3. Remove USB and fully power-cycle the player. See the [README](https://github.com/DamnFine815/autoABC) for status commands.
4. To remove 1.1.1, use its **matching** `autoABC-1.1.1-uninstall.zip` and reboot.

Tray movement is not proof of success; always read the USB result file. CHECKONLY does not change the installed boot chain.

### Defaults

`ISO_BDMV=1`, `EARLYBOOT=1`, `UOPFREE=1`.

### Download assets

- `autoABC-1.1.1-CHECKONLY.zip`
- `autoABC-1.1.1-install.zip`
- `autoABC-1.1.1-uninstall.zip`
- `SHA256SUMS` (SHA-256 of exactly the three ZIP files)
