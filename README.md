# autoABC

**autoABC** automatically selects Blu-ray **Region A/B/C** on supported **OPPO UDP-203 players with RU-JB 65-0131**. It works with physical HDMV and BD-J discs (including PSR20 checks), optionally ISO/BDMV, and includes **[UOPfree](https://github.com/DamnFine815/UOPfree)**.

**New in v1.1.3:** exact, verified boot-wrapper fingerprints for **oppo-dv-mkv v2.1.x, v2.2.0-beta and v2.3.0-beta**, while retaining all previously recognized v1.5–v2.0 wrapper families. ARM helpers, region algorithms, PSR20, Earlyboot and UOPfree are unchanged. The new wrapper families passed offline tests; **autoABC 1.1.3 with oppo-dv-mkv v2.3.0-beta has also been confirmed working on real hardware.**

> **Release:** [autoABC v1.1.3](https://github.com/DamnFine815/autoABC/releases/tag/v1.1.3). Use only a recognized OPPO UDP-203 RU-JB 65-0131 environment and run **CHECKONLY first**. If an earlier autoABC is installed, uninstall it safely before upgrading. See the [1.1.3 release notes](docs/RELEASE_NOTES_1.1.3.md) and special 1.1.2 recovery note below.
>
> **Warning:** This unofficial modification changes the running player's memory and integrates with its jailbreak boot chain. Back up your setup and have a recovery method. A successful compatibility check cannot guarantee every future boot or disc.

## For developers and oppo-dv-mkv integration

The original autoABC code and documentation are [MIT-licensed](LICENSE), and integration into oppo-dv-mkv is expressly permitted. The independently authored [UOPfree](https://github.com/DamnFine815/UOPfree) scripts are also MIT-licensed and may be integrated as a separate option.

**Native source note:** The original C/assembly source and exact build commands for the four compiled ARM helpers have not been recovered. The shipped binaries retain useful function symbols; the three hook blobs have byte-reproducible **machine-word transcriptions**, not original assembly. See [Native source status and integration handoff](docs/NATIVE_SOURCE_STATUS.md) and [hook wordlist tool](tools/reconstruct_hook_wordlists.py). Do not describe the release as fully buildable from source yet.

## Features

- Automatic Region **A/B/C** selection for physical **HDMV** and **BD-J** Blu-rays, including **PSR20-aware** behavior; all seven non-empty A/B/C allowed-region combinations are handled.
- Optional automatic region selection for **Blu-ray ISO and BDMV folders**.
- **Earlyboot** support to initialize autoABC in time for discs already inserted when the player starts.
- **[UOPfree](https://github.com/DamnFine815/UOPfree) included since 1.1.0:** bypass applicable disc-authored restrictions.
- Safe return toward the normal stock region after a playback session, no persistent per-disc region cache.
- Separate **CHECKONLY**, **INSTALL** and **UNINSTALL** USB packages, exact signature checks, guarded boot-file backup/restore and readable result logs.

## Installation (1.1.3)

**Release files:** [CHECKONLY](https://github.com/DamnFine815/autoABC/releases/download/v1.1.3/autoABC-1.1.3-CHECKONLY.zip), [INSTALL](https://github.com/DamnFine815/autoABC/releases/download/v1.1.3/autoABC-1.1.3-install.zip), [UNINSTALL](https://github.com/DamnFine815/autoABC/releases/download/v1.1.3/autoABC-1.1.3-uninstall.zip) and [SHA256SUMS](https://github.com/DamnFine815/autoABC/releases/download/v1.1.3/SHA256SUMS). Download the official assets; **do not use GitHub’s automatically generated “Source code” ZIP** as an installer. Verify your downloads against `SHA256SUMS`.

1. **Uninstall any older autoABC first, using that version's matching uninstaller.** Remove its USB stick and fully power-cycle the player. Never install 1.1.3 over an earlier version.
   **Important for autoABC 1.1.2 + oppo-dv-mkv 2.1–2.3:** if the matching 1.1.2 uninstaller rejects Vitor's new wrapper, use the [verified 1.1.2 recovery uninstaller](https://github.com/DamnFine815/autoABC/releases/download/v1.1.3/autoABC-1.1.2-v2.3-rescue-uninstall.zip) **only for an installed 1.1.2**. Never use the 1.1.3 uninstaller on 1.1.2 or the rescue uninstaller on other versions. Then fully power-cycle, run 1.1.3 CHECKONLY and only install if it reports COMPATIBLE.
2. **Uninstall standalone [UOPfree](https://github.com/DamnFine815/UOPfree) first** if you want integrated `UOPFREE=1` (the default). The installer will reject a duplicate standalone [UOPfree](https://github.com/DamnFine815/UOPfree) setup.
3. Extract **CHECKONLY only** to the root of a clean, player-readable USB stick, so that `AutoScript/AutoScript.TSS` is directly under the USB root. Adjust `AutoScript/config.ini` and `AutoScript/uopfree.ini` as desired. Start the player with the USB inserted.
4. Check **`autoABC-result.txt`** on the USB stick: it must say **`COMPATIBLE`**. Read `autoABC.log` for details. CHECKONLY performs compatibility checks **without installing autoABC**. Remove the stick and fully power-cycle.
5. Extract **INSTALL only** to a clean USB root. Use **the same configuration values** as CHECKONLY; save both INI files. Boot with the stick and confirm **`INSTALLED`** (or `ALREADY_INSTALLED` for a verified identical 1.1.3 installation) in `autoABC-result.txt`. If it says `FAILED`, stop and examine `autoABC.log`.
6. Remove the USB stick, **fully power-cycle**, and confirm normal startup and disc playback. For removal, use **only the matching 1.1.3 UNINSTALL** package and reboot again.

**Use only one AutoScript ZIP at a time.** Ejecting the tray is a convenience, **not proof of success**. The EJECT result is logged separately; the USB result file is authoritative. CHECKONLY can reject an unsupported or modified setup, but cannot certify cold-boot timing.

## Configuration

Set the options **before running both CHECKONLY and INSTALL**:

**`AutoScript/config.ini`**
```ini
ISO_BDMV=1
EARLYBOOT=1
```

- **`ISO_BDMV=1` (default):** auto-region also examines ISO/BDMV. Complex BD-J titles may take slightly longer to open because their region information must be detected. **Set `ISO_BDMV=0`** if the extra startup delay bothers you; automatic region selection for **physical discs remains enabled**.
- **`EARLYBOOT=1` (default):** starts autoABC earlier in the verified boot sequence. This helps avoid a first-disc region screen when a Blu-ray is already inserted at power-on or autoplay starts immediately. **`EARLYBOOT=0`** uses the later startup path; an already-inserted first disc may then start before autoABC is ready.

**`AutoScript/uopfree.ini`** ([UOPfree](https://github.com/DamnFine815/UOPfree) settings)
```ini
UOPFREE=1
```

- **`UOPFREE=1` (default):** enables the integrated RAM-only [UOPfree](https://github.com/DamnFine815/UOPfree) mod (STOP/MENU/NEXT where disc-authored UOPs block them). **Remove standalone [UOPfree](https://github.com/DamnFine815/UOPfree) before enabling this.**
- **`UOPFREE=0`:** leaves [UOPfree](https://github.com/DamnFine815/UOPfree) disabled. It does not change automatic Blu-ray region handling.

These are installation-time settings. **To change the installed boot integration, uninstall the same autoABC version, reboot, and reinstall with the revised INI files.** Do not expect editing the installed INI alone to enable or disable Earlyboot.

## Supported boot setups

The installer recognizes **exact, known boot-chain and firmware signatures**; similar version names or unrelated patches are not automatically accepted.

| Boot environment | 1.1.3 recognition |
| --- | --- |
| **jb_overlay v1.7, V2, V3** | Known overlay boot chain, including verified stock `brick_monitor` and the specific recognized EJECT-to-KEY8 variant |
| **oppo-dv-mkv v1.5.0–v2.3.0-beta** without jb_overlay | Exact pinned wrapper families, with Earlyboot integration |
| **jb_overlay + oppo-dv-mkv v1.5.0–v2.3.0-beta** | Exact pinned combined boot chain |
| **oppo-dv-mkv v1.5.0** | Its recognized wrapper signature is also accepted |

Support is conditional on **CHECKONLY=COMPATIBLE**. V2 has matching known boot-file signatures; it has not been independently confirmed through a complete hardware cold-boot test. Hardware feedback exists for v1.7 Earlyboot and combined-overlay installation, plus user-reported MKV-only functionality; this is not a guarantee for every modified boot setup. See [Compatibility](docs/COMPATIBILITY.md).

## Telnet / SSH quick reference

These commands are for an **installed 1.1.3**. Read-only checks first:

```sh
# Confirm build, boot mode and configuration
cat /mnt/ubi_boot/autoABC/BUILD_ID
cat /mnt/ubi_boot/autoABC/INSTALL_MODE
sh /mnt/ubi_boot/autoABC/config.sh show
cat /mnt/ubi_boot/autoABC/uopfree.ini

# Main report: daemons, region, PSR20 gate, UOPfree and recent logs
sh /mnt/ubi_boot/autoABC/status.sh

# Current player region control (CBR/CDR)
/mnt/ubi_boot/autoABC/autoabcctl status

# UOPfree RAM status
sh /mnt/ubi_boot/autoABC/uopfree_status.sh

# Boot, Earlyboot and disc-detection logs
cat /mnt/ubi_boot/autoABC/earlyboot.log
cat /mnt/ubi_boot/autoABC/boot.log
cat /mnt/ubi_boot/autoABC/regiond.log
```

**Manually set a playback region (advanced / live RAM only):**

```sh
/mnt/ubi_boot/autoABC/autoabcctl A
/mnt/ubi_boot/autoABC/autoabcctl B
/mnt/ubi_boot/autoABC/autoabcctl C
/mnt/ubi_boot/autoABC/autoabcctl off
```

Run **one** of those commands, not all four. `off` restores the stock/off region-control value; automatic detection can change it again when playback changes. **During BD-J playback, the PSR20 gate may provide a region independently of the displayed CBR value.** Do not interpret a single CBR reading as proof that the gate is inactive. Manual overrides are for diagnostics, not persistent configuration.

## Notes, sources and credits

autoABC is **not** a DVD region patch, AACS/Cinavia bypass or universal promise for every Blu-ray. See [Region support](docs/REGION_SUPPORT.md), [Installation](docs/INSTALLATION.md), [Configuration](docs/CONFIGURATION.md), [Troubleshooting](docs/TROUBLESHOOTING.md), [Uninstallation](docs/UNINSTALLATION.md) and [Technical research](docs/research/README.md).

**BusyBox:** autoABC includes a static ARM BusyBox 1.31.0 binary. See the [official upstream source](https://busybox.net/downloads/busybox-1.31.0.tar.bz2) and [GNU GPLv2](https://www.gnu.org/licenses/old-licenses/gpl-2.0.en.html).

Special thanks to **theaxledentaldj** from AVForums for his valuable help, technical discussions, and support throughout the development.
Special thanks to **cashkey** from AVForums for testing **`EARLYBOOT=1`** with **oppo-dv-mkv**.

autoABC is independent of OPPO Digital and is not affiliated with or endorsed by the manufacturer.
