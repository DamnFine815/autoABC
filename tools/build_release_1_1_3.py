#!/usr/bin/env python3
"""Build autoABC 1.1.3 and the optional 1.1.2 recovery uninstaller.

Requires pinned official autoABC v1.1.2 release assets and selected upstream
oppo-dv-mkv FULL release archives; does not compile/change ARM firmware hooks.
No player or firmware is modified by running this build script.
"""
from __future__ import annotations

import argparse
from copy import copy
from hashlib import sha256
from io import BytesIO
from pathlib import Path, PurePosixPath
from zipfile import ZipFile
import sys

BASE = {
    "CHECKONLY": "7d491e447357d43594d1188a3e0701a2a206d6c8339f3c5423cf3af09df44442",
    "install": "2913ab8a655c77a1a5b284dfd27409c02af6aa792269a520ed38012632200d9a",
    "uninstall": "ab1dc00dfd77cd68a8755385853a96032fe76a8d0256a01ae36368ac08d00831",
}
BASE_SCRIPT_SHA = {
    "CHECKONLY": "d5fdad5f2ac88b631bc9890c01c6be095c7295c5d48c90440105d7259e71e819",
    "install": "257788adc3c2a8f944e1fea7f3cf9b01a75ecbc77e4c06c7ce858e5f0a81405f",
    "uninstall": "0f6e9f567195c5ad8bd9059fc266804b82cda3998fd7948fde8943d1c6b472bf",
}
UPSTREAM = {
    "v2.1.2-beta": {
        "archive": "930a26f9c4b22e26b733e8c5aae4cdbce692863c00ed0bb364ee6096b8f8d238",
        "wrapper": "4054c4b7c62155adea52299cf2cedf870eccd727bc5703aa16f555c4a458d42f",
    },
    "v2.2.0-beta": {
        "archive": "1d65cf94bb565ae3a88691223cd2c83f0df08d05d6d0b3279aadc9c9345f77b8",
        "wrapper": "630bba8355379fe1731a28849881e5af5d39545794ea08e734d0fcbddd594321",
    },
    "v2.3.0-beta": {
        "archive": "b94e50fe513fb664a290c24eaf474413affdb902fe050e000aeadf5ba717d8d8",
        "wrapper": "630bba8355379fe1731a28849881e5af5d39545794ea08e734d0fcbddd594321",
    },
}
NEW_HASH_21 = UPSTREAM["v2.1.2-beta"]["wrapper"]
NEW_HASH_22 = UPSTREAM["v2.3.0-beta"]["wrapper"]
OLD_SHA_DECL = "MKV_WRAPPER_181_SHA='54ab24595a1b254e1bf45aa8f9578a4f70d883374e80d13e0a32fc00ad3ea4cd'"
OLD_CASE = """      "$MKV_WRAPPER_181_SHA") MKV_KNOWN_VERSION='1.8.1/1.9.0/2.0.0-beta'; return 0 ;;"""
OLD_ID = b"1.1.2\n"
NEW_ID = b"1.1.3\n"


def digest(data: bytes) -> str:
    return sha256(data).hexdigest()


def demand(condition: bool, message: str) -> None:
    if not condition:
        raise ValueError(message)


def replace_once(text: str, before: str, after: str) -> str:
    demand(text.count(before) == 1, "expected single occurrence: " + repr(before[:90]))
    return text.replace(before, after, 1)


def validate_zip(path: Path, pinned_hash: str) -> ZipFile:
    demand(path.is_file(), "missing release asset: " + str(path))
    demand(digest(path.read_bytes()) == pinned_hash, "release asset SHA-256 mismatch: " + str(path))
    z = ZipFile(path)
    names = z.namelist()
    demand(len(names) == len(set(names)), "duplicate ZIP entry: " + str(path))
    demand(z.testzip() is None, "bad ZIP CRC: " + str(path))
    for name in names:
        demand(not name.startswith("/") and "\\" not in name and
               all(p not in ("", ".", "..") for p in PurePosixPath(name).parts),
               "unsafe ZIP member: " + name)
    return z


def validate_manifest(z: ZipFile, name: str) -> None:
    lines = z.read(name).decode("ascii").splitlines()
    demand(bool(lines), "empty archive manifest: " + name)
    for line in lines:
        parts = line.split("  ", 1)
        demand(len(parts) == 2 and len(parts[0]) == 64, "bad manifest line " + line)
        want, member = parts
        demand(member in z.namelist(), "manifest member missing: " + member)
        demand(digest(z.read(member)) == want, "manifest digest mismatch: " + member)


def inspect_upstream(directory: Path) -> dict[str, bytes]:
    output = {}
    for tag, expected in UPSTREAM.items():
        path = directory / ("oppo-dv-mkv-" + tag + "-full.zip")
        with validate_zip(path, expected["archive"]) as z:
            key = "AutoScript/oppo-dv-mkv/bdpprog"
            payload = z.read(key)
            demand(digest(payload) == expected["wrapper"], "unexpected boot wrapper: " + tag)
            text = payload.decode("utf-8")
            for invariant in (
                "# oppo-dv-mkv boot wrapper",
                "[ -f $PREV ] && PLAYER=$PREV",
                '$PLAYER "$@"',
                "RC=$?",
                "exit $RC",
            ):
                demand(invariant in text, "missing predecessor or exit behavior: " + tag)
            output[tag] = payload
            print("UPSTREAM_WRAPPER=VERIFIED", tag, expected["wrapper"])
    demand(output["v2.2.0-beta"] == output["v2.3.0-beta"],
           "unexpected v2.2/v2.3 wrapper difference")
    return output


def transform(kind: str, source: bytes, *, rescue: bool = False) -> bytes:
    demand(digest(source) == BASE_SCRIPT_SHA[kind], "unrecognized 1.1.2 source script: " + kind)
    text = source.decode("utf-8")
    text = replace_once(text, OLD_SHA_DECL,
        OLD_SHA_DECL + "\n" +
        "MKV_WRAPPER_21_SHA='" + NEW_HASH_21 + "'\n" +
        "MKV_WRAPPER_22_SHA='" + NEW_HASH_22 + "'")
    text = replace_once(text, OLD_CASE,
        OLD_CASE + "\n" +
        """      "$MKV_WRAPPER_21_SHA") MKV_KNOWN_VERSION='2.1.0/2.1.1/2.1.2-beta'; return 0 ;;\n""" +
        """      "$MKV_WRAPPER_22_SHA") MKV_KNOWN_VERSION='2.2.0/2.3.0-beta'; return 0 ;;""")
    if rescue:
        demand(kind == "uninstall", "rescue applies to 1.1.2 uninstaller only")
        text = replace_once(text, "#!/bin/sh\n",
            "#!/bin/sh\n# 1.1.2 RECOVERY UNINSTALLER: exact 2.1/2.2/2.3 wrapper hashes added.\n")
    else:
        text = replace_once(text, "VERSION='1.1.2'", "VERSION='1.1.3'")
        text = replace_once(text, "ID='1.1.2'", "ID='1.1.3'")
        demand("autoABC 1.1.2" in text, "expected old user-facing version label")
        text = text.replace("autoABC 1.1.2", "autoABC 1.1.3")
        if kind != "uninstall":
            text = text.replace("supported: pinned v1.5-v2.0-beta wrapper families",
                                "supported: pinned v1.5-v2.3.0-beta wrapper families")
    result = text.encode("utf-8")
    demand("MKV_WRAPPER_21_SHA" in text and "MKV_WRAPPER_22_SHA" in text,
           "new hashes absent in transformed script")
    return result


def repack(old: ZipFile, transformed: dict[str, bytes]) -> bytes:
    manifest = old.read("SHA256SUMS_RELEASE").decode("ascii")
    for member, payload in transformed.items():
        old_payload = old.read(member)
        old_line = digest(old_payload) + "  " + member
        new_line = digest(payload) + "  " + member
        demand(manifest.count(old_line) == 1, "original release manifest not found once: " + member)
        manifest = manifest.replace(old_line, new_line)
    transformed = dict(transformed)
    transformed["SHA256SUMS_RELEASE"] = manifest.encode("ascii")
    buf = BytesIO()
    with ZipFile(buf, "w") as z:
        for info in old.infolist():
            z.writestr(copy(info), transformed.get(info.filename, old.read(info.filename)))
    result = buf.getvalue()
    with ZipFile(BytesIO(result)) as verify:
        demand(verify.testzip() is None, "repacked ZIP CRC mismatch")
        demand(verify.namelist() == old.namelist(), "member names/order changed")
        validate_manifest(verify, "SHA256SUMS_RELEASE")
        if "AutoScript/autoABC/SHA256SUMS" in verify.namelist():
            validate_manifest(verify, "AutoScript/autoABC/SHA256SUMS")
        for name in old.namelist():
            if name not in transformed:
                demand(verify.read(name) == old.read(name), "unrelated member changed: " + name)
        for name, payload in transformed.items():
            demand(verify.read(name) == payload, "replacement bytes mismatched: " + name)
    return result


def build(base_dir: Path, upstream_dir: Path, destination: Path) -> None:
    inspect_upstream(upstream_dir)
    destination.mkdir(parents=True, exist_ok=True)
    outputs: dict[str, bytes] = {}
    for kind, hash_ in BASE.items():
        with validate_zip(base_dir / ("autoABC-1.1.2-" + kind + ".zip"), hash_) as old:
            validate_manifest(old, "SHA256SUMS_RELEASE")
            if kind == "uninstall":
                script = "AutoScript/autoABC-uninstall.sh"
                ident = "AutoScript/autoABC-uninstall.id"
            else:
                script = "AutoScript/autoABC-install.sh"
                ident = "AutoScript/autoABC-release.id"
            demand(old.read(ident) == OLD_ID, "unexpected 1.1.2 USB identity: " + kind)
            updated = transform(kind, old.read(script))
            outputs["autoABC-1.1.3-" + kind + ".zip"] = repack(old, {script: updated, ident: NEW_ID})
            if kind == "uninstall":
                rescued = transform(kind, old.read(script), rescue=True)
                outputs["autoABC-1.1.2-v2.3-rescue-uninstall.zip"] = repack(old, {script: rescued})
    for name, data in outputs.items():
        (destination / name).write_bytes(data)
        print("BUILT=PASS", name, "bytes=" + str(len(data)), "sha256=" + digest(data))
    order = [
        "autoABC-1.1.3-install.zip",
        "autoABC-1.1.3-CHECKONLY.zip",
        "autoABC-1.1.3-uninstall.zip",
        "autoABC-1.1.2-v2.3-rescue-uninstall.zip",
    ]
    checksums = "".join(digest(outputs[name]) + "  " + name + "\n" for name in order).encode("ascii")
    (destination / "SHA256SUMS").write_bytes(checksums)
    print("RELEASE=PASS VERSION=1.1.3 zip_assets=4 manifests=PASS crc=PASS no_native_changes=YES")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("base", type=Path, help="directory with official 1.1.2 CHECKONLY/install/uninstall ZIPs")
    parser.add_argument("upstream", type=Path, help="directory with official 2.1.2/2.2/2.3 FULL ZIPs")
    parser.add_argument("output", type=Path)
    args = parser.parse_args()
    try:
        build(args.base, args.upstream, args.output)
    except (ValueError, OSError, KeyError, AssertionError) as exc:
        print("RELEASE=FAIL", str(exc), file=sys.stderr)
        raise SystemExit(1)
