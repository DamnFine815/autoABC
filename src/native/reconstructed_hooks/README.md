# Reconstructed native hook machine words (autoABC 1.1.2)

The adjacent `got_hook_base.S`, `got_hook_extended.S` and `psr20_gate.S` files are **machine-word transcriptions** of the released, SHA-256-pinned 512-byte ARM hook blobs.

**These are NOT the original authored symbolic assembly sources.** Comments give byte offsets; words may contain instructions, data, pointers or blank space. Neither they nor the existing shell scripts are sufficient to rebuild the four released native ELF executables.

Generate or independently verify the three hook listings with [tools/reconstruct_hook_wordlists.py](../../../tools/reconstruct_hook_wordlists.py) using the official `autoABC-1.1.2-install.zip`. The build check uses `clang --target=armv7-linux-gnueabi -c` and `llvm-objcopy -O binary -j .text` and requires a byte-identical match to the original published blobs.

See [Native source status and integration handoff](../../../docs/NATIVE_SOURCE_STATUS.md) for the ARM ELF hashes, compiler metadata and remaining missing-source boundary.
