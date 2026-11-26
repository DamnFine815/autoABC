# Changelog

## 1.1.3 — 2026-11-26

- Recognizes two newly verified upstream `/mnt/ubi_boot/bdpprog` SHA-256 families: oppo-dv-mkv **v2.1.0–v2.1.2-beta** and **v2.2.0-beta/v2.3.0-beta**. Previous v1.5–v2.0 families remain accepted when their exact bytes match.
- Updates CHECKONLY, INSTALL and matching UNINSTALL, retaining unknown-wrapper fail-closed behavior, exact firmware-memory signature checks, Earlyboot integration and conservative boot-chain ownership.
- Adds **`autoABC-1.1.2-v2.3-rescue-uninstall.zip`** for installations with `BUILD_ID=1.1.2` whose original matching uninstaller cannot recognize a newly updated oppo-dv-mkv 2.1–2.3 wrapper. The rescue preserves the 1.1.2 installation identity and changes only wrapper acceptance in the original uninstaller. Not for other autoABC versions.
- **No changes** to the ARM region detectors, PSR20 hook/logic, UOPfree runtime or boot adapters. Built from SHA-256 pinned original 1.1.2 release ZIPs with sealed manifest and unrelated-member parity.
- Seven focused offline regression tests passed, including a live POSIX-shell handoff of the actual oppo-dv-mkv v2.3 boot wrapper to a simulated predecessor. Run CHECKONLY and maintain a recovery route.
- [Full release notes](docs/RELEASE_NOTES_1.1.3.md) · [Reproducible packager](tools/build_release_1_1_3.py).

## 1.1.2 — 2026-11-12

- Extended pinned boot-wrapper recognition to the exact v1.8.1/v1.9.0/v2.0.0-beta family (also shared by v2.0.1–v2.0.2-beta), preserving core runtime and previous wrapper support.
- The released 1.1.2 packages, rather than historical source-only installer snapshots, are the base inputs for the 1.1.3 reproducible packager.

## 1.1.1

- Added compatibility with the **oppo-dv-mkv v1.7.0** boot wrapper, including supported jb_overlay + MKV combinations.
- Retained support for **oppo-dv-mkv v1.5.0 and v1.6.0**. The Blu-ray region hooks, PSR20, Earlyboot and integrated UOPfree are unchanged.
- CHECKONLY, INSTALL and UNINSTALL recognize the pinned old/new MKV wrapper hashes; no universal/unchecked launcher acceptance. See [1.1.1 release notes](docs/RELEASE_NOTES_1.1.1.md).

## 1.1.0

- Unified support for verified jb_overlay v1.7, V2 and V3 boot chains, compatible oppo-dv-mkv v1.5.0/v1.6.0 wrappers, and recognized combined installations.
- Earlyboot enabled by default (`EARLYBOOT=1`) for timely first-disc region detection; later startup remains available (`EARLYBOOT=0`).
- Integrated UOPfree (`UOPFREE=1` by default); remove standalone UOPfree before using the integrated version.
- Independent CHECKONLY compatibility preflight, verified existing-install detection and guarded uninstall/restore.
- Verified stock and specific KEY8 brick_monitor support with preserved original monitor restoration.
- USB installation result synchronized before the bounded EJECT request; EJECT status is reported separately.
- Physical-disc PSR20 gate, optional ISO/BDMV detection and underlying native hooks remain unchanged from the validated test series.
- All public packages passed offline verification; see [1.1.0 release notes](docs/RELEASE_NOTES_1.1.0.md).

## 1.0.0 — outdated

**Do not install this release.** It was intended for the original jb_overlay v1.7 test environment only. Use its matching 1.0.0 uninstaller before installing 1.1.0.

- Initial physical HDMV / BD-J automatic region handling, optional ISO / BDMV and PSR20 support.

See [historical 1.0.0 notes](docs/RELEASE_NOTES_1.0.0.md).
