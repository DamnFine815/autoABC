#!/usr/bin/env python3
"""Focused offline release regression checks (no OPPO player access needed)."""
from __future__ import annotations
from pathlib import Path
from zipfile import ZipFile
import os
import subprocess
import tempfile
import unittest

from tools import build_release_1_1_3 as builder


class CompatibilityReleaseTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls) -> None:
        cls.base = Path(os.environ["ABC_112_ASSETS"])
        cls.upstream = Path(os.environ["OPPODV_UPSTREAM_ASSETS"])
        cls.temp = tempfile.TemporaryDirectory()
        cls.root = Path(cls.temp.name)
        cls.dist = cls.root / "dist"
        builder.build(cls.base, cls.upstream, cls.dist)
        cls.wrapper = {}
        for tag in builder.UPSTREAM:
            p = cls.upstream / ("oppo-dv-mkv-" + tag + "-full.zip")
            with ZipFile(p) as z:
                cls.wrapper[tag] = z.read("AutoScript/oppo-dv-mkv/bdpprog")

    @classmethod
    def tearDownClass(cls) -> None:
        cls.temp.cleanup()

    def script(self, name: str) -> str:
        with ZipFile(self.dist / name) as z:
            entry = ("AutoScript/autoABC-uninstall.sh" if "uninstall" in name
                     else "AutoScript/autoABC-install.sh")
            return z.read(entry).decode()

    def test_new_version_ids_and_old_rescue_id(self) -> None:
        for kind in ("install", "CHECKONLY", "uninstall"):
            with ZipFile(self.dist / ("autoABC-1.1.3-" + kind + ".zip")) as z:
                key = ("AutoScript/autoABC-uninstall.id" if kind == "uninstall"
                       else "AutoScript/autoABC-release.id")
                self.assertEqual(z.read(key), b"1.1.3\n")
                script = self.script("autoABC-1.1.3-" + kind + ".zip")
                self.assertIn("VERSION='1.1.3'", script)
                self.assertIn("ID='1.1.3'", script)
        with ZipFile(self.dist / "autoABC-1.1.2-v2.3-rescue-uninstall.zip") as z:
            self.assertEqual(z.read("AutoScript/autoABC-uninstall.id"), b"1.1.2\n")
            script = z.read("AutoScript/autoABC-uninstall.sh").decode()
            self.assertIn("VERSION='1.1.2'", script)
            self.assertIn("ID='1.1.2'", script)

    def test_all_release_members_have_valid_manifests(self) -> None:
        for name in ("autoABC-1.1.3-install.zip",
                     "autoABC-1.1.3-CHECKONLY.zip",
                     "autoABC-1.1.3-uninstall.zip",
                     "autoABC-1.1.2-v2.3-rescue-uninstall.zip"):
            with ZipFile(self.dist / name) as z:
                self.assertIsNone(z.testzip())
                builder.validate_manifest(z, "SHA256SUMS_RELEASE")
                if "AutoScript/autoABC/SHA256SUMS" in z.namelist():
                    builder.validate_manifest(z, "AutoScript/autoABC/SHA256SUMS")
        sums = (self.dist / "SHA256SUMS").read_text().splitlines()
        self.assertEqual(len(sums), 4)
        for line in sums:
            sha, name = line.split("  ", 1)
            self.assertEqual(builder.digest((self.dist / name).read_bytes()), sha)

    def test_only_installer_script_id_and_outer_manifest_change(self) -> None:
        for kind in ("install", "CHECKONLY", "uninstall"):
            old_path = self.base / ("autoABC-1.1.2-" + kind + ".zip")
            new_path = self.dist / ("autoABC-1.1.3-" + kind + ".zip")
            with ZipFile(old_path) as old, ZipFile(new_path) as new:
                self.assertEqual(old.namelist(), new.namelist())
                allowed = {"SHA256SUMS_RELEASE",
                           "AutoScript/autoABC-install.sh",
                           "AutoScript/autoABC-uninstall.sh",
                           "AutoScript/autoABC-release.id",
                           "AutoScript/autoABC-uninstall.id"}
                changed = {f for f in old.namelist() if old.read(f) != new.read(f)}
                self.assertTrue(changed <= allowed, changed)
                self.assertEqual(len(changed), 3)
                for f in old.namelist():
                    if f.startswith("AutoScript/autoABC/"):
                        self.assertEqual(old.read(f), new.read(f), f)
                for f in ("AutoScript/autoABC-prev-early.sh",
                          "AutoScript/autoABC-prev.sh",
                          "AutoScript/autoABC-brick-wrapper.sh"):
                    if f in old.namelist():
                        self.assertEqual(old.read(f), new.read(f))

    def _run_recognizer(self, script: str, sha: str, *, symlink: bool = False) -> str:
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            executable = root / "launcher"
            executable.write_text("#!/bin/sh\nexit 0\n")
            executable.chmod(0o755)
            link = root / "link"
            link.symlink_to(executable)
            selected = link if symlink else executable
            assignments = "\n".join(
                line for line in script.splitlines() if line.startswith("MKV_WRAPPER_") and "_SHA=" in line
            )
            section = script.split("mkv_wrapper_known(){\n", 1)[1].split("\n}\n", 1)[0]
            source = (
                "MKV='" + str(selected) + "'\n"
                + "checksum(){ printf '%s\\n' \"$HASH\"; }\n"
                + assignments + "\n"
                + "mkv_wrapper_known(){\n" + section + "\n}\n"
                + "if mkv_wrapper_known; then printf 'ACCEPT:%s\\n' \"$MKV_KNOWN_VERSION\";"
                  " else printf 'REJECT\\n'; fi\n"
            )
            proc = subprocess.run(["sh", "-c", source], env={**os.environ, "HASH": sha},
                                  capture_output=True, text=True, check=True)
            return proc.stdout.strip()

    def test_pinned_upstream_wrappers_and_unknown_fail_closed(self) -> None:
        for kind in ("install", "CHECKONLY", "uninstall"):
            script = self.script("autoABC-1.1.3-" + kind + ".zip")
            for version, expected in builder.UPSTREAM.items():
                result = self._run_recognizer(script, expected["wrapper"])
                self.assertTrue(result.startswith("ACCEPT:"), (kind, version, result))
            self.assertEqual(self._run_recognizer(script, "0" * 64), "REJECT")
            self.assertEqual(self._run_recognizer(script, builder.NEW_HASH_22, symlink=True), "REJECT")
        rescue = self.script("autoABC-1.1.2-v2.3-rescue-uninstall.zip")
        self.assertTrue(self._run_recognizer(rescue, builder.NEW_HASH_22).startswith("ACCEPT:"))

    def test_upstream_wrapper_chain_on_host_with_patches_disabled(self) -> None:
        for tag, wrapper_bytes in self.wrapper.items():
            with tempfile.TemporaryDirectory() as tmp:
                root = Path(tmp)
                wrapper = root / "bdpprog"
                wrapper.write_bytes(wrapper_bytes)
                data_dir = root / "data"
                data_dir.mkdir()
                (data_dir / "disable").write_bytes(b"")
                prev = root / "prev"
                prev.write_text("#!/bin/sh\nprintf 'PREV:%s\\n' \"$1\"\nexit 7\n")
                prev.chmod(0o755)
                env = {**os.environ, "OPPODV_D": str(data_dir),
                       "OPPODV_PREV": str(prev), "OPPODV_PLAYER": str(root / "missing")}
                r = subprocess.run(["sh", str(wrapper), "hello world"], env=env,
                                   capture_output=True, text=True)
                self.assertEqual(r.returncode, 7, tag)
                self.assertIn("PREV:hello world", r.stdout, tag)
                self.assertFalse((data_dir / "bootcount").exists(), tag)

    def test_damaged_original_asset_is_rejected(self) -> None:
        p = self.base / "autoABC-1.1.2-install.zip"
        corrupted = self.root / "tampered.zip"
        data = bytearray(p.read_bytes())
        data[90] ^= 1
        corrupted.write_bytes(data)
        with self.assertRaises(ValueError):
            builder.validate_zip(corrupted, builder.BASE["install"])

    def test_current_preflight_remains_strict(self) -> None:
        install = self.script("autoABC-1.1.3-install.zip")
        check = self.script("autoABC-1.1.3-CHECKONLY.zip")
        for script in (install, check):
            self.assertIn("firmware_sig 198392 12 sig_access_plt_12.bin", script)
            self.assertIn("firmware_sig 207180 12 sig_usleep_plt_12.bin", script)
            self.assertIn("firmware_sig 2813888 16 sig_ngetpsr_16.bin", script)
            self.assertIn("FIRMWARE_PREFLIGHT=PASS SIGNATURES=5", script)
            self.assertIn("standalone UOPfree detected", script)
            self.assertIn("BRICK_MONITOR=VERIFIED_STOCK", script)
        self.assertIn("write_result COMPATIBLE", check)
        self.assertIn("CHECKONLY=PASS", check)
        self.assertIn("Nothing installed", check)


if __name__ == "__main__":
    unittest.main()
