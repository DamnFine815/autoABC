# Native source status and handoff for oppo-dv-mkv integration

**Scope:** autoABC 1.1.2 (the public release), OPPO UDP-203 RU-JB 65-0131. This document was created in response to the request for the compiled ARM helpers, GOT hooks, PSR20 gate and corresponding build commands.

## Source availability — important limitation

The current repository contains the **actual readable shell/runtime/USB integration sources** (`src/runtime/`, `installer/`), but it **does not contain the original C or assembly source** or the exact native compile/link commands for these native components:

- `autoabc_detect`, `autoabc_hdmv`, `autoabc_bdj`, `autoabc_folder`
- `hook/got_hook_base.bin`, `hook/got_hook_extended.bin`, `hook/psr20_gate.bin`

The 2026-10-20 development handoffs and historical release-source archives also contain the *compiled outputs*, rather than original native source files. The GitHub source-to-release verification scripts **cannot** compile these executables. This is not a newly recovered native-source release, and nothing here should be described as a complete reproducible native build.

There are two useful forms of retained evidence:

1. **The native ARM ELFs are not stripped.** `readelf -sW` identifies numerous private functions (e.g. `detect_bdj_v010_mobj`, `detect_hdmv_mask`, `zip_extract_entry`, `sim_cluster`, `psr20_cmp`, `inflate_raw`, `ref_sig`, `get_link`). Their `.comment` section records **Clang 17.0.0 and LLD 17.0.0**. This identifies the compiler family, **not** the original flags or source.
2. **The three 512-byte hooks can be transcribed as ARM machine-word assembly** and reassembled exactly with Clang/llvm-objcopy. These are *byte-equivalent machine-code listings*, **not** the original symbolic hook source. See `tools/reconstruct_hook_wordlists.py` below.

## Exact released native assets

All hashes here are of members in the official [1.1.2 INSTALL ZIP](https://github.com/DamnFine815/autoABC/releases/tag/v1.1.2), under `AutoScript/autoABC/`:

| Artifact | Bytes | SHA-256 |
| --- | ---: | --- |
| `autoabc_detect` | 22,340 | `718b7c9c3ef8dea71b5913a256eddbd5498caf51211a2981c4a957e62c5aca07` |
| `autoabc_hdmv` | 5,232 | `0ca8f79c56e856a05ffa97a62f689daf378d82f8cead9b305f8c8f09991bd675` |
| `autoabc_bdj` | 81,572 | `9518213a64ab753cc3921fb14c5b2d16994808b4ce57b16fe7f1c6c8aa73fc72` |
| `autoabc_folder` | 23,104 | `02af7bec43ea9a711d6575637ecded7cbe7822cb5c843bdd4b325e60ab3288f0` |
| `hook/got_hook_base.bin` | 512 | `f0daa2d6dba9ab06e145a11d661c5fa74eb890096e32b7b0f91373041d8e17c7` |
| `hook/got_hook_extended.bin` | 512 | `b3706b654b6bcf989b629905440fe269e03bd131d3917ac02e389f56f9f01572` |
| `hook/psr20_gate.bin` | 512 | `02c80ab1477c39e3e186ae2e95859b842740a9447a93ce044b8fc6411cc9d09a` |

The exact release also contains smaller `hook/*.bin` signature, prefix, suffix, mailbox and patch assets; **preserve those** when analyzing/restoring hooks. They are not represented by the three 512-byte files alone.

## How to inspect / reproduce *only the hook bytes*

Download and verify `autoABC-1.1.2-install.zip` and its release `SHA256SUMS`. With Python 3, Clang 17 and LLVM objcopy on a development computer:

```sh
python3 tools/reconstruct_hook_wordlists.py /path/to/autoABC-1.1.2-install.zip ./hook-wordlists
```

The script checks every input SHA-256, writes readable `.S` word listings and rebuilds all three `.bin` files, checking their SHA-256 **byte for byte**:

```sh
clang --target=armv7-linux-gnueabi -c hook-wordlists/psr20_gate.S -o hook-wordlists/psr20_gate.o
llvm-objcopy -O binary -j .text hook-wordlists/psr20_gate.o hook-wordlists/psr20_gate.rebuilt.bin
```

Repeat for `got_hook_base` and `got_hook_extended`. This is a **machine-word transcription**, not the original hook compilation recipe. To inspect the non-stripped native executables, for example:

```sh
unzip -p autoABC-1.1.2-install.zip AutoScript/autoABC/autoabc_bdj > autoabc_bdj
readelf -sW autoabc_bdj
readelf -p .comment autoabc_bdj
llvm-objdump -d --print-imm-hex autoabc_bdj
```

No exact compile/link commands for the four native ELFs can honestly be provided at present. Recompiling those programs from real source or a carefully reviewed independent reimplementation remains **open work**.

## Integration architecture and Earlyboot

- `src/runtime/start.sh` launches the physical disc and PSR20 paths and conditionally the ISO/BDMV path.
- `autoabc_detect` is the fast core/region detector; `autoabc_hdmv` validates HDMV control flow; `autoabc_bdj` handles complex BD-J/PSR20 logic; `autoabc_folder` supports folder/virtual-media observation.
- The physical disc path and BD-J PSR20 gate must initialize **before autoplay accesses the disc**, especially with a disc already in the tray at power-on. On jb_overlay setups autoABC hooks the early `brick_monitor` chain; **oppo-dv-mkv may use a different, earlier safe initialization path** instead of copying that wrapper. Preserve the timing invariant, not the exact wrapper technique.
- The PSR20 path responds with valid region A/B/C as required; do not equate “region-free” with returning 7 in PSR20. Preserve tested signature checks, original hook bytes and restore logic.
- `ISO_BDMV=1`, `EARLYBOOT=1`, `UOPFREE=1` are the released autoABC defaults. Do not assume all boot layouts or non-RU firmware variants are verified.

## UOPfree permission and source

[UOPfree](https://github.com/DamnFine815/UOPfree) is separately **MIT-licensed**. Its complete install/runtime implementation is readable shell code (`src/start.sh`) and has its own reproducible installer build (`sh mkrelease.sh`). Its one-time RAM UOP modification can be adapted to a separate On/Off option, retaining compatibility checks and the MIT notice. Do not accidentally run standalone UOPfree and integrated UOPfree simultaneously.

## Licensing boundaries

The original project code and documentation are [MIT-licensed](../LICENSE), and the author permits integration into oppo-dv-mkv. This does **not** automatically give rights to OPPO firmware, third-party modifications, or bundled **BusyBox (GPL-2.0)**. The native/source-provenance gap should remain explicit in any downstream repository.
