# autoABC 1.1.3 — compatibility release (26 November 2026)

**Scope:** OPPO UDP-203 running the verified RU-JB 65-0131 player and recognized boot chain. This update expands the exact upstream **oppo-dv-mkv wrapper SHA-256 allowlist**, with no change to region detection, compiled ARM binaries, PSR20 hooks, UOPfree, EARLYBOOT or original boot adapters.

## What's new

- Exact SHA-256 wrapper `4054c4b7c62155adea52299cf2cedf870eccd727bc5703aa16f555c4a458d42f` — official oppo-dv-mkv 2.1.0/2.1.1/2.1.2-beta family; audited in the v2.1.2-beta FULL release.
- Exact SHA-256 wrapper `630bba8355379fe1731a28849881e5af5d39545794ea08e734d0fcbddd594321` — official oppo-dv-mkv 2.2.0-beta and **2.3.0-beta** FULL releases.
- All previously pinned 1.5–2.0 wrapper families remain recognized by CHECKONLY, INSTALL and UNINSTALL.
- A separate **1.1.2 rescue uninstaller** allows a previously installed `BUILD_ID=1.1.2` to be safely removed after Vitor's boot wrapper has been updated to an otherwise unknown v2.1–v2.3 release.

The two newer families preserve Vitor's `/mnt/ubi_boot/bdpprog.prev` predecessor chain. In a host shell test, their actual wrapper passed a test argument to a simulated predecessor and preserved its return code.

## Download the official Release assets

| Asset | SHA-256 |
| --- | --- |
| [CHECKONLY](https://github.com/DamnFine815/autoABC/releases/download/v1.1.3/autoABC-1.1.3-CHECKONLY.zip) | `ae5c83ef40f3271a71e83b83c675ea8cc87a274735ca06e8ce0af92ae9dc3360` |
| [INSTALL](https://github.com/DamnFine815/autoABC/releases/download/v1.1.3/autoABC-1.1.3-install.zip) | `fabd8ff82be72b8ac9815954264f13960112ac38d8759c82445b5545f9376ff2` |
| [UNINSTALL](https://github.com/DamnFine815/autoABC/releases/download/v1.1.3/autoABC-1.1.3-uninstall.zip) | `ab943075d901bb0f5d16cb24078a7528d6a01517d1512563d667ab9019284064` |
| [1.1.2 rescue UNINSTALL](https://github.com/DamnFine815/autoABC/releases/download/v1.1.3/autoABC-1.1.2-v2.3-rescue-uninstall.zip) | `a43db7510e507aee7b8357fa3f7f36d1c14d67d0cd391c928037ce734e7e6b11` |

The accompanying `SHA256SUMS` contains all four exact fingerprints. Install from the **Release ZIP assets**, not GitHub's auto-generated repository source snapshot. Extract **one ZIP at a time** to the root of a clean USB stick.

## Important: upgrading an existing installation

1. **Check which autoABC version is actually installed.** If it is 1.1.2 and you updated oppo-dv-mkv to v2.1–v2.3 first, its original 1.1.2 uninstaller may refuse the new upstream wrapper. Use **only** the special `autoABC-1.1.2-v2.3-rescue-uninstall.zip` to remove this **1.1.2** installation safely. The rescue leaves the `ID=1.1.2` requirement in place and does not bypass original boot-owner/firmware safety checks.
2. For autoABC 1.1.0, 1.1.1 or other prior versions, use that version's **matching uninstaller** (the 1.1.2 rescue is *not* compatible with those builds). If the matching uninstaller fails, **do not manually delete or replace boot files**; preserve the logs for review.
3. Remove the uninstall USB, power the player completely off and back on. Then run the **1.1.3 CHECKONLY** with your preferred `ISO_BDMV`, `EARLYBOOT` and `UOPFREE` settings. **Proceed only when the result file says `COMPATIBLE`.**
4. Extract the 1.1.3 INSTALL ZIP alone, use the **same config**, boot and confirm `INSTALLED`. Remove the USB and fully power-cycle again. For subsequent removal or reconfiguration use the **matching 1.1.3 UNINSTALL**.

Do not install 1.1.3 over an existing older autoABC. The new release retains the fail-closed policy for unknown/symlinked launchers, changed original code bytes, unrecognized `brick_monitor`, duplicate UOPfree or modified boot ownership.

## Verification and limitations

- Built from the original, checksum-pinned autoABC **1.1.2** CHECKONLY/INSTALL/UNINSTALL ZIPs, retaining the ZIP member order and permissions.
- **All 7 focused offline regression tests passed**, including known/unknown wrapper recognition, symlink rejection, host predecessor chaining, version-specific rescue identity, CRC/internal manifests, unchanged native ARM payloads and an intentionally corrupted input rejection.
- Build input full-ZIP and wrapper SHA-256 were checked against upstream oppo-dv-mkv **2.1.2-beta**, **2.2.0-beta** and **2.3.0-beta**.
- **autoABC 1.1.3 with oppo-dv-mkv 2.3.0-beta has been confirmed working on real hardware.**
- Cambridge Audio CXUHD and unsupported firmware layouts are **not** supported by this release. Do not bypass CHECKONLY to try other firmwares.

## Reproducible release packaging

With the exact original autoABC 1.1.2 and selected oppo-dv-mkv full ZIPs available locally:

```sh
python3 tools/build_release_1_1_3.py /path/to/autoabc112-zips /path/to/upstream-full-zips /path/to/output
```

The packager pins every input SHA-256, verifies manifests, creates the four packages and outer `SHA256SUMS`, and refuses changed/unknown inputs. See [source-to-release provenance](BUILD_AND_PROVENANCE.md). **It does not compile the four native ARM helpers or make them open-source C files.**

Original project code is MIT-licensed; bundled BusyBox retains GPLv2 and firmware-derived/third-party material is not relicensed. See [license status](../LICENSE-STATUS.md).
