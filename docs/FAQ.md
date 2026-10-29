# Frequently asked questions — autoABC 1.1.1

**What firmware do I need?** An OPPO UDP-203 running RU-JB 65-0131 with matching live player code, AutoScript and a recognized boot chain. `jb_overlay` **is not mandatory** when a supported oppo-dv-mkv-only wrapper is present. Always run CHECKONLY; see [Compatibility](COMPATIBILITY.md).

**Can I install over 1.0.0 or an older test build?** **No.** Use the matching older-version uninstaller and fully power-cycle first, then run 1.1.1 CHECKONLY.

**Do I need separate UOPfree?** **No.** [UOPfree](https://github.com/DamnFine815/UOPfree) is integrated in 1.1.1 (`UOPFREE=1` by default). Uninstall standalone UOPfree before enabling the integrated version, or deliberately choose `UOPFREE=0`.

**Why is `EARLYBOOT=1` the default?** An already-inserted disc can begin loading while the player starts. Earlyboot initializes autoABC sooner, avoiding some first-disc region-screen races. `EARLYBOOT=0` is an option for users who prefer the later startup path.

**Does ISO_BDMV=1 slow ISO/BDMV opening?** Some complex BD-J virtual media need region-analysis time; there is no guaranteed fixed delay. `ISO_BDMV=0` disables automatic virtual-media region detection, but **physical-disc auto-region and native ISO/BDMV playback remain available**. [Timing observations](research/VIRTUAL_MEDIA_TIMING.md).

**Does autoABC change the permanent region or DVD region?** No. It performs runtime Blu-ray region selection and is designed to restore the normal stock state after playback. It is not a DVD region patch.

**Are all seven A/B/C allowed-region masks supported?** The detector implements all seven nonempty combinations. Hardware and synthetic-test evidence differ by type; see [Region support](REGION_SUPPORT.md). No guarantee applies to every disc worldwide.

**What does CHECKONLY do?** It verifies firmware, known boot ownership, signatures, payload and options without installing persistent autoABC changes. A `COMPATIBLE` report is necessary but cannot prove every later hardware boot.

**Does autoABC keep a disc-region cache?** No persistent per-disc region cache exists in 1.1.1.

**The tray opened, but where is the result?** Check `autoABC-result.txt` or `autoABC-uninstall-result.txt` on USB. Tray motion alone does not prove success. See [Troubleshooting](TROUBLESHOOTING.md).
