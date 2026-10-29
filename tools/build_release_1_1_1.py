#!/usr/bin/env python3
"""Rebuild autoABC 1.1.1 byte-for-byte from verified official v1.1.0 assets.

Pinned to the tested 1.1.1 ZIPs. Every input and output SHA-256 is verified.
This does not execute any OPPO code.
"""
from pathlib import Path
from zipfile import ZipFile
from copy import copy
from hashlib import sha256
from io import BytesIO
import base64, zlib, json, sys

BASE = {
    'CHECKONLY': 'd8896b250dd072a86ce8df7ed007e0e980c01deda520df9ec43f6546dfd90b8f',
    'install':   '10ed41939612614cf6d7c8c43f20ddaf0e007ec73eb9a584916c057debd00a2d',
    'uninstall': '92c8a3bef287a25795739447253654e0db3938badc63314f80bc684f8915f444',
}
FINAL = {
    'CHECKONLY': '89c00918876474a27584e12d6a4654c76fe6db1264d2cd0cc443bd596319a019',
    'install':   'e7f568ccd430b430b3395b0c517df8f92a1624907ecdb00e0e8e092de90e012d',
    'uninstall': '66df415b7f65183ec0ed349548e9e1a8e2edf9a988f0ba242132b99a37d033f1',
}
OLD_SCRIPT_SHA = {'CHECKONLY': 'f4382c0655cc737b68af0bae010f997eac57ac0e9a1e43903fdc5c385f5a45f8', 'install': 'f4382c0655cc737b68af0bae010f997eac57ac0e9a1e43903fdc5c385f5a45f8', 'uninstall': 'a667fa2c52cae8fbd47d9d341139894585b31e87c77a95c5c1a046da33e60e58'}
NEW_SCRIPT_SHA = {'CHECKONLY': 'bf0142856393dcce30f01e3e8205f765d621f08ec4cc391c950453c7406c93af', 'install': '8f3ee2c1094b5c2b8be251d9a092d981e929fd439af7f981cccca9e804ae21fa', 'uninstall': '9974afbaef11bcce2177d23b9a688d4b4b4a1679643980c5dada41abebb63d91'}
PATCH_B64 = {'CHECKONLY': 'eNq1Vgtv2kgQ/itzpCrJyQYb2xiIqATBVbkQQIY0qkKE1us1uJg18oMk1/a/36wfJA2JTorugoLw7Pib1zcze3urSg2pcgIkTcJe/wLUGn5gbs3mHdizyPd85oJ9Lf/Vh6YhK6qmghOGCTC+96OQbxlP4tqCV+6kW00ypMpXy54NJ+NuNQOqLvhw8PQ70zIlrSVVbkHmsKh8mC0qcAc/f8IPYHQdQvU3RzqwJQld+3wF17M+7AjdkBWDrR/HKKvCJ6gn2129eEdVFVk4J7MoCqNa8pCcA3vwE1DP4deCo0kvM1m/+GJdXE7Go2+Z8Y8f4Rb+AHn02iF6lkFoufeGKhmYr6vLr8sbuzedWvZyMhosZ1963SplTsNoUuo2NI0ZtOmpbddoO23SVojqaCppaAo1tYajt5qaSYiuEYM5LcdhRKVOk2CCnuOqppLjOtQliu45VG/qrtdy3HbLaVNimK6nUEaVptvSSdPTTNVQ2y1T8xStoav46KEp16EFbn8ymeeAKNhu9sv7iOx2LFpueHjPT89+LDjg3wn0w2QNaxKvWQwkYpCQDePgReEWkjU+3oeYEkITSHdxEjGCYrJaIU0KQIhp5O8yWuSANvPSmEH8uA18vokl4CGX2QOjaUKcgIHnB8IUd4Eh5R4h5ZlLEJCU0zWLCqCyfhjMU93khyNRWcpSiCWMWJJGHNQcSGQjq7KVVw51T9EO3cTp9vDi2aKSa1OCvufS528htM9zDSiPX1ACQTJbl+PJzXj5rDOMmlJXa82aUj0vXVPg/PwNtIIIb6KZb+H8eXYI/CBlMaELjt1Q8NmUjLZUESfRtsjv55vl3LqaYoCNT3WX7es8DQKRxU4OIRSjTLPfXw6G9quKArypSi0zB897256MRv3exWV3jFQcW9YAU2lbvYHotmoBXoSRI6hKQ1I1Raqw74wmS+IlyNc4pZTFMTIWOlljZ5qmIalmM7eWs+UlD5AcR7T/nTFT23rGo5e0yE+RF9AVjxMswaj3bTnqXY+RF3ZBipKXbmF68CoxByUzPeIHUPV5nJAgwB5yUxKIMtdDbIWAPMIuYi4T8YYR0DXh2GjVrJp51CZG3XoRNXvm3rH1Nw/+PU/vDQrPAEHYUwS5+w0sWuP3or2vxV91+eAIDbeOzws/yqFymDKncbrbhVHC3E4x1/bYoaI/AVO+z/qrGIdn5Q5T2pKmKrnf/4/PIfoku3sZVf4blxu6JP4rnr/gJzD1eTbMI0bDFff/xuR4YcT8Fc/XeznKHSbEkLWB2MKeH23vxVIQ0xrLu0Ihjmffg3KhH40oEey5MMafpu9hF702V4tBJSbG4vmm7SLg8PPQGkA5/I6NASLgEs5PSisCMssBrm5db4nrzmHJy+IL+tfD0aAD4wkMx7N5bzSSoHcxH37tzQXmxIapgJ/NrfEcyiEGF5OBVXv/tSKvczn+8KITbTDh5dVmwYsEHN7rTnuzGVyhUYwOv8Hq2aNvIsbuh+ynCPM+8hO2jFicBgk6eDXFCPojC3FsRlw55MFjccXDptiRxHf8wE9wypA4Rg6cZsiSqFH3w4+j7HZk3Nzs11kNxnhHEHw49HitTLKutyXdQKJV7u7+AZ1MAA0=', 'install': 'eNq1Vgtv4kYQ/itTUp2TyhCv3w5KJRKoLg0NiDyupxCh9XoNFrBGtiFJL/3vnfWDkBCaNr2CkNjZ9ezM981849tboupqbQ/oMotbJ6dAGviFq87l1RGseBKFEQ9gcF3/9QRsq64Rg4AfxxlwsYqSWMy5yNLGUNTu1FtDtdTaTWdweda7OFZyR8pQnLWf/+enHNVw1dot1AUMaz9eDmtwB09P8A04m8SgvAjkCOY0Y5NIjOH68gQWlE3pmMM8SlO0KfAzHGbzxWH5DCFaXQZX50kSJ43sIWsCf4gyIE34s7jdIqqF+f52fjP6Mmj1+53BqNdtjy4/t44Vxn3dshkLdMPgFrND4gWW53vU0yjxDUJ1Q2OOofumaxsOpaZBLe67vs8pYb5NMcFNv8TRCr8+C6hmhj4zbTMIXT/wXN9j1HKCUGOcaXbgmtQODYdYxHMdI9QM3SS4DPGqwGel35Ne76pwiIb5dDW6T+hiwZPRVMT3Yv/g21AAfvbgJM4mMKHphKdAEw4ZnXIBYRLPIZvg8j5GVCjLYLlIs4RTNNPxGGkuHULKkmiR01o4HPBwmXJIH+ezSExTFUQs6vyBs2VG/RmHMJrJq0QAHEvmEZYiDwlmdCnYhCelI6Q8lJRjMjnpnz5J08OW6QeodzeNWBwJz5aJAFI4kmicfu6cnncK5vDsPt7Dpulyvn7wYFgrTjOKsRfWzafQdSSKE1BtvyoJdJLfdX7R+3Ix2qhsq6Edkobd0JRmFZoGzeYOb2Uh7PTm7PLz08E68bWVp5QNBVZzUc/EsVTi2GoNys82fIjpVrW8BLo/6GzA/xrNYhfhhGO57GHk3dbXUbd1fYFwDkosKzqD8ur2m3y2K0JDGs1AiUSa0dkMSy9Y0plE5zDGCprRR1gkPOCMp2mcAJtQgfWp5CAUWTuYtfsqa74R3vbtOzfex+mjSeEeoBP+nEERvo6k6S9J+1hnvBnyOhAWz/1IlHFUvbhuzv10uVjEScaDo1IOVljYsqwBIV/lZVmqyEEl3ZqnGkQr4v5/Yo4xpnqwquOR7xOybqryVwujodiDfiRyDUw4i8ci+gPBCeOER2NRTLVKAX0uzZC3gRw+YZTM76WWSpFDesdoRFWLQqjm2FZny2Sb8jLxLFprCX9Ljsr+lkNwuDmgjtHh2S9nnTZUmrF9GaAHnF3FTnWLdCkxMAlRTaJXtO1Sy6K9XzpY8xpu68Tb6lFUwD9XFIWFXAt0Sn0LJ5+nM5dqlqkRlzrcM4ln4fDllqNTHISc2a7neZbv2YbrG6Fu+7qp7JCe7TbIGcZOxBoo+xFlJ5H0lowqFV4O4pWrS6/f77VvRjLgEb5dPG2uO61B96u0HnwQ1Eqy3oF1nYhs478Nf62PpqGppkF2Mf5K0VvtVv8Khbzze79zerWejjvIeyezF9HmiEci4+OEZlEsyjdKVizkuU1VN01TNU3rv9Tpv59o36X+tmut4GkeB8ULdEkUSla0ypPPS+3uL2PzSsE=', 'uninstall': 'eNq1Vgtv2kgQ/itzXFU3J0O8fmEX5SQHfCoKBwic9qIQod31OlgBG9kmTdTcf7/xAxcCXKvoDmPJnvfMNzPr21si63LjV6CbLHYuu0BaeIHnTr2PkIhV/ChgNBzcQBilGV0uRSKl8CiSMAiFDyyOM+Rk4j6hWRhHrVn02Z1M+6PhhVQYkmZRv/f9uXEn36qGrJpy4xaaEcwa76azBtzBywt8A8EXMUj7gWyiyvFHWNGML8LoHq6nl7AK0xSfJfgdzrPV+jzXoowTojRrlaZIkjhpZU9ZB8RTmAHpwN9lEJot47/x59Xn+ZeJMx67k/lo0JtPPzkXEhdMNUzOfVXThMHNgNi+YTOb2golTCNU1RTe1lSmW6bWplTXqCGYxZighDOTYp67dklbKe0y7lNFDxjXTd0PLObbFrM5Ndp+oHDBFdO3dGoGWpsYxLbaWqBoqk7wNUBXPuOV3cvRyCsNImH18Dj/mtD1WiTzhyj+Gn04+zaLAH9Y3yCvL6oUFX7/Pic9HZB+geZgl4hIJCLbJBGQ0lDus/vJ7V65ZX1Q9gNfCP6Qbla14tmsUUpzmoqKuquFpsOolIAt+1Xh0Ujh62o4+jKc77SR0VLOSctsKVJnG5oCnc4Ja1W5T1prn7Lz21mdeE0VKeWzqOoZ25aJQuRGzgiDI6U7XuIDiCo5v5LrHcXiCHU8cQ/87NNeQ1NyERu4AIkHQvFVSpmBrWWr3KKKoSvEom1h68Q2sLuF0VYpdprgpmXbtsFsU7OYFqgmU3UJ7jqQLUQN414zHoN8K1jM9azRu3YGKOD0hxf9oed0vXmu4Qx78xHiM3BuYAvTuwPkAA3iUJacrdPcQw4MIUQmRK2ROaj4Nu5SWJPzu/G2JGr5MhEMr/9H3+29OXTNkPMbF/BENIu9+gxBnIjwPgIer1gYCb+5in0BmIdI0kW4BiZyCaDRM/gizZINz0Jc03wpaLRZ4w6uh3DUc+vJq4pcFv3aG009Z+LNcWG+7HJcZzK4KaJEzlmZfNHs5bbez+F1R5wYiVMbA7vyiEnUObT3g97/rvB/j8Ces5+aYVyoAQ2X6L2CM+85WNJNhHEmECewToQvuEhTfOYLGt3nJ2uJcXEC06VUraNlKk6nulPW/zxTzEoc4nAEnUOVny3POolXcYap4ydHsqTP/16KICyWdLmgi0nSTZno7e1c/6gX8NXpOWMPTwz3r7Hb9epz6m1NW6eRg4uRh1Edv79J8q+WajyLr6C7fwDmlKaa'}
OLD_ID = b'1.1.0\n'
NEW_ID = b'1.1.1\n'

def sha(b): return sha256(b).hexdigest()
def chk(ok,msg):
    if not ok: raise ValueError(msg)

def transform(kind,data):
    chk(sha(data)==OLD_SCRIPT_SHA[kind], 'unrecognized source script '+kind)
    lines=data.decode('utf-8').splitlines(keepends=True)
    ops=json.loads(zlib.decompress(base64.b64decode(PATCH_B64[kind])).decode())
    for start,end,new in reversed(ops):
        lines[start:end]=new.splitlines(keepends=True)
    result=''.join(lines).encode('utf-8')
    chk(sha(result)==NEW_SCRIPT_SHA[kind],'script patch mismatched '+kind)
    return result

def build(base_dir, dest_dir):
    dest_dir.mkdir(parents=True,exist_ok=True)
    for kind in ['CHECKONLY','install','uninstall']:
        name='autoABC-1.1.0-'+kind+'.zip'
        old=base_dir/name
        chk(old.is_file() and sha(old.read_bytes())==BASE[kind], 'v1.1.0 input mismatch: '+name)
        with ZipFile(old) as z:
            chk(z.testzip() is None, 'bad ZIP CRC '+name)
            members=z.infolist()
            patch_name='AutoScript/autoABC-uninstall.sh' if kind=='uninstall' else 'AutoScript/autoABC-install.sh'
            id_name='AutoScript/autoABC-uninstall.id' if kind=='uninstall' else 'AutoScript/autoABC-release.id'
            changes={patch_name:transform(kind,z.read(patch_name)),id_name:NEW_ID}
            chk(z.read(id_name)==OLD_ID, 'old USB identity mismatch '+kind)
            man=z.read('SHA256SUMS_RELEASE').decode('ascii')
            for member,new_content in changes.items():
                old_line=sha(z.read(member))+'  '+member
                new_line=sha(new_content)+'  '+member
                chk(man.count(old_line)==1,'manifest missing exactly one '+member)
                man=man.replace(old_line,new_line)
            changes['SHA256SUMS_RELEASE']=man.encode('ascii')
            out=BytesIO()
            with ZipFile(out,'w') as w:
                for meta in members: w.writestr(copy(meta),changes.get(meta.filename,z.read(meta.filename)))
        content=out.getvalue()
        chk(sha(content)==FINAL[kind], 'final ZIP mismatch: '+kind)
        result=dest_dir/('autoABC-1.1.1-'+kind+'.zip')
        result.write_bytes(content)
        print('VERIFIED',kind,result.name,len(content),sha(content))
    lines=[]
    for kind in ['install','CHECKONLY','uninstall']:
        lines.append(FINAL[kind]+'  autoABC-1.1.1-'+kind+'.zip\n')
    checksums=''.join(lines).encode('ascii')
    (dest_dir/'SHA256SUMS').write_bytes(checksums)
    print('RELEASE=PASS assets=4')

if __name__=='__main__':
    if len(sys.argv)!=3: raise SystemExit('Usage: build_release_1_1_1.py /path/to/110_zips /outdir')
    try: build(Path(sys.argv[1]),Path(sys.argv[2]))
    except Exception as ex: print('RELEASE=FAIL '+str(ex),file=sys.stderr); raise SystemExit(1)
