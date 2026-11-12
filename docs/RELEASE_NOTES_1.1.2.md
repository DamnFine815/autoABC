# autoABC 1.1.2 - Release Notes (Preview)

Automatic Blu-ray Region A/B/C selection for OPPO UDP-203 (RU-JB 65-0131).

### What's new

- Added pinned boot-wrapper compatibility for **oppo-dv-mkv v1.7.1, v1.8.0, v1.8.1, v1.9.0 and v2.0.0-beta**, including recognized combined jb_overlay installations.
- Older **oppo-dv-mkv v1.5.0 / v1.6.0 / v1.7.0** setups remain supported. The original Region A/B/C, BD-J/PSR20, ISO/BDMV, Earlyboot and integrated [UOPfree](https://github.com/DamnFine815/UOPfree) runtime payloads are unchanged.

### Important: beta and compatibility

**oppo-dv-mkv v1.9.0 is the latest stable upstream version; v2.0.0-beta is experimental.** Both use the same upstream boot-wrapper bytes as v1.8.1. autoABC identifies the *wrapper family* by SHA-256, not the full upstream runtime version. Compatibility with the new 2.0.0-beta video-driver / Dolby Vision patches has not yet been verified on real hardware. This is a preview release for testing, not a guarantee of trouble-free playback.

### Important: uninstall before upgrading

**Uninstall an older autoABC with that version's own matching uninstaller, then fully power-cycle before installing 1.1.2.** Never install this build on top of an older autoABC. If an upstream oppo-dv-mkv update has already changed its boot wrapper and the older autoABC uninstaller refuses to run, **do not force-remove boot files or use the 1.1.2 uninstaller against an older autoABC build.**

If you have separately installed UOPfree, remove it before enabling integrated `UOPFREE=1`.

### Installation

1. Extract `autoABC-1.1.2-CHECKONLY.zip` alone to a clean USB root and confirm `COMPATIBLE` in `autoABC-result.txt`.
2. Extract `autoABC-1.1.2-install.zip` alone to a clean USB root with the **same** `config.ini` and `uopfree.ini` settings. Confirm `INSTALLED` or verified `ALREADY_INSTALLED`.
3. Remove USB and fully power-cycle the player. Test a physical region-locked Blu-ray and the upstream mod's intended playback.
4. To remove 1.1.2, use the **matching** `autoABC-1.1.2-uninstall.zip` and reboot.

EJECT/tray movement is an optional status signal, not proof of success. Always check the USB result and log.

### Defaults

`ISO_BDMV=1`, `EARLYBOOT=1`, `UOPFREE=1`.

### Download assets

- `autoABC-1.1.2-CHECKONLY.zip`
- `autoABC-1.1.2-install.zip`
- `autoABC-1.1.2-uninstall.zip`
- `SHA256SUMS`
