# Changelog

## 1.1.2

- Added verified upstream boot-wrapper fingerprints for **oppo-dv-mkv 1.7.1, 1.8.0, 1.8.1, 1.9.0 and 2.0.0-beta**, retaining 1.5.0-1.7.0.
- Existing Blu-ray region, PSR20, Earlyboot and UOPfree runtime contents remain byte-identical to 1.1.1.
- **2.0.0-beta is experimental**: wrapper compatibility is verified offline; its new Dolby Vision patches are not yet tested on an OPPO with autoABC. See [1.1.2 release notes](docs/RELEASE_NOTES_1.1.2.md).


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
