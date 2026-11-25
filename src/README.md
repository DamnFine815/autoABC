# Runtime source inventory — autoABC 1.1.0

The 15 readable scripts in `src/runtime/` are byte-identical copies of the corresponding files within the sealed [v1.1.0 INSTALL release ZIP](https://github.com/DamnFine815/autoABC/releases/tag/v1.1.0). They are mirrored and checked by `tools/sync_release_sources.py`.

This includes the region and PSR20 shell-side controls, ISO/BDMV startup helpers, strict `config.sh`, `autoabcctl`, diagnostics and integrated [UOPfree](https://github.com/DamnFine815/UOPfree) runtime scripts.

The INSTALL ZIP also contains native compiled ARM executables (such as `autoabc_detect`, `autoabc_bdj`, `autoabc_hdmv` and `autoabc_folder`), binary firmware hook/signature assets and BusyBox. They are distributed with the official release assets **but not duplicated here**. This tree is **not** a complete independent native build system.

Verify source parity with `python3 tools/verify_release.py /path/to/v1.1.0/assets`. Do not construct an installer by zipping this source directory. For original byte-for-byte installed payload manifests, see [research/INSTALLED_PAYLOAD_SHA256SUMS_1.1.0.txt](../docs/research/INSTALLED_PAYLOAD_SHA256SUMS_1.1.0.txt) and [provenance](../docs/BUILD_AND_PROVENANCE.md).

## Native-source request (November 2026)

The original C/ASM sources of `autoabc_detect`, `autoabc_hdmv`, `autoabc_bdj` and `autoabc_folder` remain unavailable in this source tree. ELF function symbols and Clang/LLD 17 build metadata were recovered, but not the exact compiler commands. The three fixed-size hook payloads can be reassembled byte-identically from explicitly labeled reconstructed ARM machine-word listings using [the reconstruction tool](../tools/reconstruct_hook_wordlists.py). See [the technical handoff](../docs/NATIVE_SOURCE_STATUS.md). These listings are **not** the original symbolic ASM sources or a solution for rebuilding the four native executables.
