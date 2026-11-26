# Source availability and build provenance — autoABC 1.1.0

## Published release versus repository sources

- The official [v1.1.0 GitHub release](https://github.com/DamnFine815/autoABC/releases/tag/v1.1.0) supplies **three separate checksum-pinned USB AutoScript ZIPs** (CHECKONLY, INSTALL and UNINSTALL) plus SHA256SUMS.
- The **readable shell scripts**, AutoScript launchers, editable INI templates and release hashes are mirrored under `src/runtime/` and `installer/` from those **exact** published assets. `tools/sync_release_sources.py` verifies their hash manifests and byte equivalence.
- The release ZIPs also include **compiled ARM executables**, firmware-specific hook bytes and BusyBox. This repository does **not** provide an independent source-to-binary build chain for every native helper. Do not confuse source scripts with a ready-to-install USB package.

## Audit and stage sealed official assets

Download all **four** v1.1.0 Release assets into one directory. Run:

```sh
python3 tools/verify_release.py /path/to/release-assets
sh mkrelease.sh /path/to/release-assets
```

The verifier checks **exact released outer SHA-256 values, ZIP CRCs, inner hash manifests and byte-for-byte parity with the published shell sources and installer templates**. `mkrelease.sh` copies verified archives to `dist/` and rechecks `SHA256SUMS`. **Neither command compiles a native ARM executable or rebuilds a new installer.**

The corresponding published outer SHA-256 values are preserved in [verification](VERIFICATION.md) and [research/RELEASE_1.1.0_SHA256SUMS.txt](research/RELEASE_1.1.0_SHA256SUMS.txt).

## Sources, tags and archival history

The v1.0.0 scripts and archived research retain value as **history**, but should not be used to install v1.1.0. Some older research pages and historical v1.0.0 source archives correctly describe their original version.

**Note on GitHub tag snapshots:** GitHub's auto-generated “Source code (zip/tar.gz)” is a snapshot of the release *tag*, not one of the verified USB release ZIPs. Updating `main` does not retroactively modify an existing `v1.1.0` tag snapshot. Users should install from the v1.1.0 **Release assets**, never the automatic source snapshot.

## Licensing and provenance

The bundled static ARM BusyBox v1.31.0 is separately governed by GPLv2. [Official upstream source](https://busybox.net/downloads/busybox-1.31.0.tar.bz2) · [GPLv2](https://www.gnu.org/licenses/old-licenses/gpl-2.0.en.html). Linking upstream source is informational; complete binary-corresponding build inputs are not verified. The native OPPO-specific compiled helpers are not rebuilt by this repository's shell verification tools.

## Update for the 1.1.2 integration request (November 2026)

A separate [native-source status report](NATIVE_SOURCE_STATUS.md) now documents the missing original C/assembly, Clang 17/LLD 17 ELF evidence, exact compiled-helper hashes, and a byte-verified way to reconstruct the three hook blobs as **machine-word assembly listings**. Running this reconstruction is **not** equivalent to rebuilding the four ARM executables. No original compiler/linker command line for those programs has been recovered.

## Reproducible 1.1.3 compatibility release from 1.1.2

The [1.1.3 packager](../tools/build_release_1_1_3.py) verifies the three exact published 1.1.2 USB release ZIPs and the official oppo-dv-mkv 2.1.2-beta / 2.2.0-beta / 2.3.0-beta FULL ZIPs by SHA-256. It changes only each top-level install/check/uninstall shell script's version and exact known boot-wrapper fingerprints, the USB identity marker and the outer manifest. The native ARM executables, firmwares signatures, hook blobs, early-boot wrappers, bundled BusyBox, user config templates and installed runtime manifest are byte-identical to v1.1.2.

The packager additionally produces a **version-specific 1.1.2 rescue uninstaller** that retains the old USB and installed 1.1.2 ID while allowing the exact verified new upstream wrappers. [1.1.3 release notes](RELEASE_NOTES_1.1.3.md) record the verified outputs, tests and the fact that real device testing with the upstream 2.3 beta is pending.

This is a reproducible ZIP repackaging update, **not** a recovered C/assembly source build of the four native helpers.
