#!/usr/bin/env python3
"""Repack autoABC 1.1.2 from exact released 1.1.1 ZIPs and reviewed source files."""
from pathlib import Path
from zipfile import ZipFile
from hashlib import sha256
from copy import copy
import argparse,sys

BASE={'CHECKONLY':'89c00918876474a27584e12d6a4654c76fe6db1264d2cd0cc443bd596319a019',
      'install':'e7f568ccd430b430b3395b0c517df8f92a1624907ecdb00e0e8e092de90e012d',
      'uninstall':'66df415b7f65183ec0ed349548e9e1a8e2edf9a988f0ba242132b99a37d033f1'}
OUTPUT={'CHECKONLY':'7d491e447357d43594d1188a3e0701a2a206d6c8339f3c5423cf3af09df44442',
        'install':'2913ab8a655c77a1a5b284dfd27409c02af6aa792269a520ed38012632200d9a',
        'uninstall':'ab1dc00dfd77cd68a8755385853a96032fe76a8d0256a01ae36368ac08d00831'}
SCRIPT={'CHECKONLY':'d5fdad5f2ac88b631bc9890c01c6be095c7295c5d48c90440105d7259e71e819',
        'install':'257788adc3c2a8f944e1fea7f3cf9b01a75ecbc77e4c06c7ce858e5f0a81405f',
        'uninstall':'0f6e9f567195c5ad8bd9059fc266804b82cda3998fd7948fde8943d1c6b472bf'}
def h(data):return sha256(data).hexdigest()
def assert_ok(b,msg):
    if not b:raise RuntimeError(msg)
def validate(z):
    assert_ok(z.testzip() is None,'CRC error')
    names=z.namelist()
    assert_ok(len(names)==len(set(names)),'duplicate names')
    listed=set()
    for row in z.read('SHA256SUMS_RELEASE').decode('ascii').splitlines():
        digest,sep,path=row.partition('  ')
        assert_ok(sep and path in names and path not in listed and h(z.read(path))==digest,'manifest mismatch '+path)
        listed.add(path)
    assert_ok(listed==set(names)-{'SHA256SUMS_RELEASE'},'missing member in manifest')
def build(base,repo,out):
    out.mkdir(parents=True,exist_ok=True)
    sums=[]
    for mode in ('CHECKONLY','install','uninstall'):
        old=base/f'autoABC-1.1.1-{mode}.zip'
        assert_ok(old.is_file() and h(old.read_bytes())==BASE[mode],'incorrect v1.1.1 base '+mode)
        folder=repo/'installer'/mode.lower()
        script='AutoScript/autoABC-uninstall.sh' if mode=='uninstall' else 'AutoScript/autoABC-install.sh'
        id='AutoScript/autoABC-uninstall.id' if mode=='uninstall' else 'AutoScript/autoABC-release.id'
        fresh=(folder/script.split('/')[-1]).read_bytes()
        assert_ok(h(fresh)==SCRIPT[mode],'unexpected source script '+mode)
        assert_ok((folder/id.split('/')[-1]).read_bytes()==b'1.1.2\n','version identity mismatch '+mode)
        changes={script:fresh,id:b'1.1.2\n'}
        with ZipFile(old) as src:
            validate(src)
            man=src.read('SHA256SUMS_RELEASE').decode('ascii')
            for name,value in changes.items():
                before=h(src.read(name))+'  '+name
                assert_ok(man.count(before)==1,'source manifest does not match '+name)
                man=man.replace(before,h(value)+'  '+name)
            changes['SHA256SUMS_RELEASE']=man.encode('ascii')
            dest=out/f'autoABC-1.1.2-{mode}.zip'
            with ZipFile(dest,'w') as target:
                for meta in src.infolist():target.writestr(copy(meta),changes.get(meta.filename,src.read(meta.filename)))
            with ZipFile(dest) as check:
                validate(check)
                diff={name for name in src.namelist() if src.read(name)!=check.read(name)}
                assert_ok(diff==set(changes),'unexpected changed members '+str(diff))
        assert_ok(h(dest.read_bytes())==OUTPUT[mode],'output ZIP differs from pretested candidate '+mode)
        sums.append((dest.name,OUTPUT[mode]))
        print('ASSET_PASS',mode,OUTPUT[mode])
    (out/'SHA256SUMS').write_text(''.join(f'{sha}  {name}\n' for name,sha in sums),encoding='ascii')
    print('RELEASE_BUILD=PASS files=4')
if __name__=='__main__':
    p=argparse.ArgumentParser();p.add_argument('base',type=Path);p.add_argument('repo',type=Path);p.add_argument('out',type=Path)
    x=p.parse_args()
    try:build(x.base,x.repo,x.out)
    except Exception as e:print('RELEASE_BUILD=FAIL:',e,file=sys.stderr);sys.exit(1)
