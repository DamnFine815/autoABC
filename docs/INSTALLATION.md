# Installing autoABC 1.1.1

[Back to README](../README.md) · [Release v1.1.1](https://github.com/DamnFine815/autoABC/releases/tag/v1.1.1)

**Supported target:** OPPO UDP-203 with RU-JB 65-0131 and a compatible, recognized player/boot chain. Supported layouts include identified jb_overlay v1.7/V2/V3, oppo-dv-mkv v1.5.0/v1.6.0/v1.7.0, and recognized combined installations. **CHECKONLY must pass on the actual player.**

## Before starting

1. **Uninstall any older autoABC using the uninstaller matching that older version.** If 1.1.0 was installed before oppo-dv-mkv was updated to 1.7.0, the older uninstaller might refuse the changed launcher; do not bypass it. Fully power-cycle before trying 1.1.1. Never install a new release on top of an older one.
2. If you have standalone [UOPfree](https://github.com/DamnFine815/UOPfree), uninstall it before enabling integrated `UOPFREE=1` (the default). Otherwise, deliberately choose `UOPFREE=0`.
3. Keep a working recovery/backup method, stop playback, and remove other installer sticks. Unexpected firmware signatures or modified boot wrappers cause an intentional refusal.
4. Download **only the actual v1.1.1 release assets**, not GitHub's automatically generated source ZIP:

| File | Purpose | SHA-256 |
| --- | --- | --- |
| [CHECKONLY](https://github.com/DamnFine815/autoABC/releases/download/v1.1.1/autoABC-1.1.1-CHECKONLY.zip) | Read-only preflight before install | `89c00918876474a27584e12d6a4654c76fe6db1264d2cd0cc443bd596319a019` |
| [INSTALL](https://github.com/DamnFine815/autoABC/releases/download/v1.1.1/autoABC-1.1.1-install.zip) | Install or verify identical installation | `e7f568ccd430b430b3395b0c517df8f92a1624907ecdb00e0e8e092de90e012d` |
| [UNINSTALL](https://github.com/DamnFine815/autoABC/releases/download/v1.1.1/autoABC-1.1.1-uninstall.zip) | Matching removal and restore | `66df415b7f65183ec0ed349548e9e1a8e2edf9a988f0ba242132b99a37d033f1` |

[SHA256SUMS](https://github.com/DamnFine815/autoABC/releases/download/v1.1.1/SHA256SUMS) lists the three exact archive fingerprints. Example checksum verification on macOS: `shasum -a 256 autoABC-1.1.1-install.zip`. On Linux: `sha256sum autoABC-1.1.1-install.zip`.

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

Use **the matching `autoABC-1.1.1-uninstall.zip`** and a clean USB stick, then power-cycle. For installation-time changes (especially Earlyboot), first uninstall the same version and reboot; then repeat CHECKONLY and INSTALL with revised options. See [Uninstallation](UNINSTALLATION.md) and [Configuration](CONFIGURATION.md).

**Never manually delete `/mnt/ubi_boot/autoABC`, modify the boot monitor, or mix installers.**
