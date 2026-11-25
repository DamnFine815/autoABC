#!/usr/bin/env python3
"""Rebuild the 25-Nov-2026 autoABC native technical handoff from pinned v1.1.2 assets.

Only the original public release content is repackaged. Original ARM C/ASM sources are
NOT present. Machine-word hook listings are reconstructed code bytes, not developer source.
"""
from pathlib import Path
from zipfile import ZipFile, ZIP_DEFLATED, ZipInfo
from argparse import ArgumentParser
import subprocess, hashlib, json, tempfile, sys

INSTALL_SHA = '2913ab8a655c77a1a5b284dfd27409c02af6aa792269a520ed38012632200d9a'
EXPECTED_HANDOFF_SHA = '2213f6aa66d9e7af7cd73d5d655202ce8eb6680ee08fa7687e0f3720a06d3824'
STAMP = (2026, 11, 25, 21, 35, 12)
# Preserve original disassembly header for bit-identical handoff regeneration.
ORIGINAL_BINARY_DIR = '/mnt/data/autoabc_vitor_source_audit/binaries/'

README = '''# autoABC native integration handoff for Vitor — 2026-11-25

This is an evidence/analysis handoff, NOT the missing original ARM C/ASM source.

Original autoABC shell scripts and installer source are public in:
https://github.com/DamnFine815/autoABC
Original UOPfree shell source and its reproducible release builder:
https://github.com/DamnFine815/UOPfree
Both projects now have an MIT LICENSE covering original project code and documentation.

The original C/ASM for autoabc_detect, autoabc_hdmv, autoabc_bdj and autoabc_folder,
plus the original authored ARM hook assembly and complete original compiler flags,
were NOT present in the available handoff/source archives. Do not claim a full
native rebuild is possible from this material.

What is in this ZIP:
- source_shell/: actual readable, released 1.1.2 AutoScript/runtime source scripts.
- native/: the four original unstripped ARM ELF binaries, full ARM disassembly,
  symbol tables, ELF section tables and .comment toolchain evidence. These are
  REFERENCE binaries, NOT C source. The ELF .comment says Clang 17 / LLD 17.
- hook_blobs/: all released hook/signature/patch blobs, as-is, for audit.
- hook_wordlists/: three exact 512-byte machine-word transcriptions as .S.
  These reproduce the exact released bytes using Clang 17 + llvm-objcopy,
  but they are NOT the original symbolic hook implementation.
- tools/: tested reconstruction script.
- MANIFEST_SHA256.txt, PROVENANCE.json: hashes and input metadata.

Reassemble example (Clang 17 and llvm-objcopy):
  clang --target=armv7-linux-gnueabi -c hook_wordlists/psr20_gate.S -o psr20_gate.o
  llvm-objcopy -O binary -j .text psr20_gate.o psr20_gate.bin
  sha256sum psr20_gate.bin
Expected psr20_gate.bin SHA256:
  02c80ab1477c39e3e186ae2e95859b842740a9447a93ce044b8fc6411cc9d09a

No exact compile commands for the four native executables were recovered.
Use the full disassembly/symbols as references for independent implementation.
Avoid unverified changes to OPPO firmware- and boot-specific addresses.

Crucial behavioral integration detail: initialize region and BD-J PSR20
hooks before physical Blu-ray autoplay when a disc is already inserted at
cold boot. The old jb_overlay brick_monitor earlyboot wrapper is a possible
reference, but Vitor can implement equivalent timing in oppo-dv-mkv's own
startup path. The two projects should avoid competing for the same boot chain.

UOPfree can be integrated separately under its own MIT license with optional
On/Off. Apply it only after checking the known firmware signature and avoid
running two copies (standalone + integrated) concurrently.

Copyright in original project code: Florian Kecht 2026, MIT. No rights to
OPPO firmware, proprietary data or third-party components are granted.
BusyBox remains GPLv2 and is not MIT-licensed by this release.
'''

def sha256(data: bytes) -> str:
    return hashlib.sha256(data).hexdigest()


def build(install: Path, repo: Path, output: Path, strict_hash: bool):
    if sha256(install.read_bytes()) != INSTALL_SHA:
        raise RuntimeError('Official autoABC v1.1.2 INSTALL ZIP SHA-256 mismatch')
    files = {}
    def add(name, data):
        if not isinstance(data, bytes) or name in files:
            raise RuntimeError('duplicate or non-bytes: ' + name)
        files[name] = data
    add('README_FIRST.md', README.encode('utf-8'))
    with tempfile.TemporaryDirectory(prefix='autoabc-handoff-') as directory:
        dirpath = Path(directory)
        with ZipFile(install) as z:
            if z.testzip() is not None:
                raise RuntimeError('INSTALL zip CRC failure')
            for name in z.namelist():
                if name.startswith('/') or '..' in name.split('/') or name.endswith('/'):
                    raise RuntimeError('invalid release entry: ' + name)
                data = z.read(name)
                sub = name.removeprefix('AutoScript/')
                if sub.startswith('autoABC/hook/') and name.endswith('.bin'):
                    add('hook_blobs/' + sub.removeprefix('autoABC/hook/'), data)
                elif sub in {'autoABC/autoabc_detect', 'autoABC/autoabc_hdmv', 'autoABC/autoabc_bdj', 'autoABC/autoabc_folder'}:
                    stem = sub.split('/')[-1]
                    add('native/' + stem, data)
                    binary = dirpath / stem
                    binary.write_bytes(data)
                    for kind, cmd in [
                        ('symbols', ['readelf', '-sW', str(binary)]),
                        ('sections', ['readelf', '-SW', str(binary)]),
                        ('toolchain', ['readelf', '-p', '.comment', str(binary)]),
                        ('disassembly', ['llvm-objdump', '-d', '--print-imm-hex', str(binary)]),
                    ]:
                        content = subprocess.run(cmd, check=True, capture_output=True).stdout
                        if kind == 'disassembly':
                            content = content.replace(str(binary).encode(), (ORIGINAL_BINARY_DIR + stem).encode())
                        add(f'native/{stem}.{kind}.txt', content)
                elif name.endswith(('.sh', '.ini', '.id', '.TSS')) or name.endswith('/CHECKONLY'):
                    add('source_shell/' + sub, data)
    for stem in ('got_hook_base','got_hook_extended','psr20_gate'):
        source = repo / 'src/native/reconstructed_hooks' / f'{stem}.S'
        add('hook_wordlists/' + source.name, source.read_bytes())
    tool = repo / 'tools/reconstruct_hook_wordlists.py'
    add('tools/reconstruct_hook_wordlists.py', tool.read_bytes())
    metadata={
        'date': '2026-11-25', 'base_release': 'autoABC v1.1.2',
        'install_release_zip_sha256': INSTALL_SHA,
        'license':'Original project-authored source MIT; third-party exceptions',
        'original_native_sources_present': False,
        'exact_compiler_commands_present': False,
        'hook_wordlist_type':'exact machine-word transcription, NOT original assembly',
        'included_native': {key:sha256(value) for key,value in files.items() if key.startswith('native/') and not key.endswith('.txt')},
        'included_hook_blobs':len([k for k in files if k.startswith('hook_blobs/')]),
    }
    add('PROVENANCE.json', (json.dumps(metadata,indent=2,sort_keys=True)+'\n').encode())
    manifest=''.join(sha256(data)+'  '+path+'\n' for path,data in sorted(files.items()))
    add('MANIFEST_SHA256.txt',manifest.encode('ascii'))
    if len(files)!=73:
        raise RuntimeError(f'Expected exactly 73 files, found {len(files)}')
    output.parent.mkdir(parents=True,exist_ok=True)
    with ZipFile(output,'w',ZIP_DEFLATED,compresslevel=7) as z:
        for path,data in sorted(files.items()):
            info=ZipInfo(path,date_time=STAMP)
            info.compress_type=ZIP_DEFLATED
            info.external_attr=0o600 << 16
            z.writestr(info, data, compresslevel=7)
    with ZipFile(output) as z:
        assert z.testzip() is None
        for line in z.read('MANIFEST_SHA256.txt').decode().splitlines():
            checksum,path=line.split('  ',1)
            if sha256(z.read(path))!=checksum:
                raise RuntimeError('Manifest mismatch: '+path)
    digest=sha256(output.read_bytes())
    print(f'HANDOFF=PASS file={output} size={output.stat().st_size} members={len(files)} sha256={digest}')
    if strict_hash and digest!=EXPECTED_HANDOFF_SHA:
        raise RuntimeError(f'Handoff ZIP does not reproduce original digest; expected {EXPECTED_HANDOFF_SHA}, got {digest}')

if __name__ == '__main__':
    p=ArgumentParser(description=__doc__)
    p.add_argument('install_zip',type=Path)
    p.add_argument('repo_root',type=Path)
    p.add_argument('output_zip',type=Path)
    p.add_argument('--strict-hash',action='store_true',help='require byte-exact handoff ZIP SHA-256')
    a=p.parse_args()
    build(a.install_zip,a.repo_root,a.output_zip,a.strict_hash)
