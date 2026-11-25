# Project origin and distribution

autoABC is an independently developed community modification based on studying the OPPO UDP-203 RU-JB firmware environment.

**License:** Original project-authored software, scripts and documentation are available under the [MIT License](../LICENSE). The author explicitly permits integration into oppo-dv-mkv under these terms, retaining the MIT copyright and permission notice. This does not convey a license to any third-party or firmware-derived material.

The USB release packages include compiled ARM helpers and firmware-specific hook/signature bytes and **do not** include a complete OPPO firmware image. These native helpers and code-cave snippets have no recovered original source files or full source-to-binary build recipe in the current repository. They are **not** independently buildable by the published release packagers; details are in [Native source status and integration handoff](NATIVE_SOURCE_STATUS.md).

**Third parties:** Bundled ARM BusyBox 1.31.0 is GPL-2.0 and retains its own licensing/source obligations. OPPO firmware and trademarks belong to their respective owners. No affiliation with or endorsement by OPPO Digital is claimed. See [License status](../LICENSE-STATUS.md), [Source/build provenance](BUILD_AND_PROVENANCE.md) and [References](SOURCES.md).
