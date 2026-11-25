#!/usr/bin/env python3
"""Generate byte-equivalent ARM machine-word listings (NOT original source).

Input: the exact published autoABC-1.1.2-install.zip.
Output: got_hook_base.S, got_hook_extended.S, psr20_gate.S and matching .bin.
Clang and llvm-objcopy are required for independent reassembly validation.
"""
from pathlib import Path
from zipfile import ZipFile
import hashlib
import argparse
import shutil
import subprocess

INSTALL_SHA = '2913ab8a655c77a1a5b284dfd27409c02af6aa792269a520ed38012632200d9a'
HOOKS = {
    'got_hook_base': 'f0daa2d6dba9ab06e145a11d661c5fa74eb890096e32b7b0f91373041d8e17c7',
    'got_hook_extended': 'b3706b654b6bcf989b629905440fe269e03bd131d3917ac02e389f56f9f01572',
    'psr20_gate': '02c80ab1477c39e3e186ae2e95859b842740a9447a93ce044b8fc6411cc9d09a',
}

def digest(data):
    return hashlib.sha256(data).hexdigest()

def verify(ok, msg):
    if not ok:
        raise ValueError(msg)

def build(archive: Path, dest: Path):
    verify(archive.is_file(), 'Input ZIP not found')
    verify(digest(archive.read_bytes()) == INSTALL_SHA, 'Unexpected input ZIP SHA-256')
    for exe in ('clang', 'llvm-objcopy'):
        verify(shutil.which(exe) is not None, f'Required executable missing: {exe}')
    dest.mkdir(parents=True, exist_ok=True)
    with ZipFile(archive) as z:
        verify(z.testzip() is None, 'CRC failure in release ZIP')
        for stem, expected in HOOKS.items():
            key = f'AutoScript/autoABC/hook/{stem}.bin'
            blob = z.read(key)
            verify(len(blob) == 512 and digest(blob) == expected, f'Wrong original blob: {key}')
            source = dest / f'{stem}.S'
            lines = [
                f'/* Machine-word transcription of released {key} */',
                '/* THIS IS NOT THE ORIGINAL ASSEMBLY SOURCE. It contains pinned machine code/data. */',
                '    .syntax unified',
                '    .section .text,"ax",%progbits',
                '    .balign 4',
                f'    .global {stem}_blob',
                f'{stem}_blob:',
            ]
            for offset in range(0, 512, 4):
                value = int.from_bytes(blob[offset:offset+4], 'little')
                lines.append(f'    .word 0x{value:08x}   /* +0x{offset:03x} */')
            source.write_text('\n'.join(lines) + '\n', encoding='ascii')
            obj = dest / f'{stem}.o'
            target = dest / f'{stem}.rebuilt.bin'
            subprocess.run(['clang', '--target=armv7-linux-gnueabi', '-c', str(source), '-o', str(obj)], check=True)
            subprocess.run(['llvm-objcopy', '-O', 'binary', '-j', '.text', str(obj), str(target)], check=True)
            verify(target.read_bytes() == blob, f'Reassembly differs: {stem}')
            print(f'PASS {stem}: {expected} (512 bytes)')
    print('ALL_HOOK_WORDLISTS_REASSEMBLED_BYTE_IDENTICAL=PASS')

if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('install_zip', type=Path)
    parser.add_argument('output_directory', type=Path)
    args = parser.parse_args()
    build(args.install_zip, args.output_directory)
