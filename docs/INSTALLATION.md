# Installing autoABC 1.1.3

[Back to README](../README.md) · [Release v1.1.3](https://github.com/DamnFine815/autoABC/releases/tag/v1.1.3)

**Supported target:** OPPO UDP-203 with RU-JB 65-0131 and a compatible, recognized player/boot chain. Supported layouts include identified jb_overlay v1.7/V2/V3, oppo-dv-mkv pinned wrapper families v1.5.0 through v2.3.0-beta, and recognized combined installations. **CHECKONLY must pass on the actual player.** The v2.1–2.3 wrapper families passed offline verification, and autoABC 1.1.3 with oppo-dv-mkv v2.3.0-beta has been confirmed working on real hardware.

## Before starting

1. **Uninstall any older autoABC using the uninstaller matching that older version.** If 1.1.0 was installed before oppo-dv-mkv was updated to 1.7.0, the older uninstaller might refuse the changed launcher; do not bypass it. Fully power-cycle before trying 1.1.3. Never install a new release on top of an older one.
   **Important 1.1.2-to-1.1.3 migration:** If autoABC **1.1.2** was installed and oppo-dv-mkv was later updated to **2.1.x, 2.2.0-beta or 2.3.0-beta**, the original 1.1.2 uninstaller may refuse that new wrapper. The separately listed **1.1.2 recovery UNINSTALL** recognizes the newly verified boot wrappers **but still requires an installed BUILD_ID of exactly 1.1.2**. Run only that version-specific recovery package, confirm `UNINSTALLED`, remove USB and fully power-cycle. Then repeat 1.1.3 CHECKONLY and INSTALL. Do **not** run the 1.1.3 uninstaller on an older installation, and do not manually remove the wrapper or predecessor if any ownership check fails.
2. If you have standalone [UOPfree](https://github.com/DamnFine815/UOPfree), uninstall it before enabling integrated `UOPFREE=1` (the default). Otherwise, deliberately choose `UOPFREE=0`.
3. Keep a working recovery/backup method, stop playback, and remove other installer sticks. Unexpected firmware signatures or modified boot wrappers cause an intentional refusal.
4. Download **only the actual v1.1.3 release assets**, not GitHub's automatically generated source ZIP:

| File | Purpose | SHA-256 |
| --- | --- | --- |
| [CHECKONLY](https://github.com/DamnFine815/autoABC/releases/download/v1.1.3/autoABC-1.1.3-CHECKONLY.zip) | Read-only preflight before install | `ae5c83ef40f3271a71e83b83c675ea8cc87a274735ca06e8ce0af92ae9dc3360` |
| [INSTALL](https://github.com/DamnFine815/autoABC/releases/download/v1.1.3/autoABC-1.1.3-install.zip) | Install or verify identical installation | `fabd8ff82be72b8ac9815954264f13960112ac38d8759c82445b5545f9376ff2` |
| [UNINSTALL](https://github.com/DamnFine815/autoABC/releases/download/v1.1.3/autoABC-1.1.3-uninstall.zip) | Matching removal and restore | `ab943075d901bb0f5d16cb24078a7528d6a01517d1512563d667ab9019284064` |
| [1.1.2 recovery UNINSTALL](https://github.com/DamnFine815/autoABC/releases/download/v1.1.3/autoABC-1.1.2-v2.3-rescue-uninstall.zip) | **Only** to safely remove a previously installed 1.1.2 whose original uninstaller refuses an updated 2.1–2.3 boot wrapper | `a43db7510e507aee7b8357fa3f7f36d1c14d67d0cd391c928037ce734e7e6b11` |

[SHA256SUMS](https://github.com/DamnFine815/autoABC/releases/download/v1.1.3/SHA256SUMS) lists all four exact archive fingerprints. Example checksum verification on macOS: `shasum -a 256 autoABC-1.1.3-install.zip`. On Linux: `sha256sum autoABC-1.1.3-install.zip`.

## 1. CHECKONLY first

Extract **only** the CHECKONLY ZIP onto a clean, player-readable USB volume. The root must contain `AutoScript/AutoScript.TSS` and the following two editable configuration files:

```text
USB_ROOT/
  AutoScript/
    AutoScript.TSS
    CHECKONLY
    autoABC-install.sh
    config.ini
    uopfree.ini
    autoABC/...
```

The root must **not** contain an additional ZIP-named directory above `AutoScript`. Do not combine the contents of multiple release ZIPs.

Edit these files with a plain-text editor:

**`AutoScript/config.ini`**
```ini
ISO_BDMV=1
EARLYBOOT=1
```

**`AutoScript/uopfree.ini`**
```ini
UOPFREE=1
```

- `ISO_BDMV=1` enables region detection on ISO and BDMV folders as well as physical Blu-rays. Choose `0` to avoid optional virtual-media startup analysis.
- `EARLYBOOT=1` is the recommended default, allowing an already-inserted disc to be handled earlier during startup. `0` uses the later startup path.
- `UOPFREE=1` enables integrated RAM-only STOP/MENU/NEXT unblocking where supported. `0` disables the integrated [UOPfree](https://github.com/DamnFine815/UOPfree) feature.

Fully power the player off, connect USB and start it. Read `autoABC-result.txt` from the stick; **`COMPATIBLE`** means the read-only preflight passed. Preserve `autoABC.log` if it fails. The check does **not** install autoABC or guarantee every later boot or disc.

## 2. INSTALL

Remove the CHECKONLY USB files. Extract **only** the INSTALL ZIP to the USB root. **Set the same `config.ini` and `uopfree.ini` values** as you used in CHECKONLY.

Power on with the USB stick and read `autoABC-result.txt`:

- **`INSTALLED`:** installation completed.
- **`ALREADY_INSTALLED`:** the exact same version and configuration were verified; nothing new was installed.
- **`FAILED`:** do **not** assume it succeeded; inspect `autoABC.log` and keep the current environment intact.

**An EJECT/tray movement is not proof of success.** The tray command is best effort; the result file is authoritative.

Remove the USB stick and fully power-cycle the player before testing playback. For experienced users, [Telnet / SSH status commands](../README.md#telnet--ssh-quick-reference) show region control, PSR20, UOPfree and boot logs.

## 3. UNINSTALL or change options

Use **the matching `autoABC-1.1.3-uninstall.zip`** and a clean USB stick, then power-cycle. For installation-time changes (especially Earlyboot), first uninstall the same version and reboot; then repeat CHECKONLY and INSTALL with revised options. See [Uninstallation](UNINSTALLATION.md) and [Configuration](CONFIGURATION.md).

**Never manually delete `/mnt/ubi_boot/autoABC`, modify the boot monitor, or mix installers.**
