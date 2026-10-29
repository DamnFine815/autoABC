# Compatibility and limitations — autoABC 1.1.1

**Target:** OPPO UDP-203, RU-JB 65-0131, USB AutoScript and a matching live `bdpprog.1` layout. A firmware number alone is **not** proof of compatibility.

| Boot environment | 1.1.1 status |
| --- | --- |
| `jb_overlay v1.7` | Supported for exact recognized launcher and monitor signatures, including the known KEY8 variant |
| `jb_overlay V2` | Known launcher/monitor signatures recognized; **separate real-device cold-boot confirmation is not documented** |
| `jb_overlay V3` | Supported for recognized launcher and monitor signatures |
| `oppo-dv-mkv v1.5.0 / v1.6.0 / v1.7.0` without jb_overlay | Supported for the known wrapper signature, including `EARLYBOOT=1` |
| `jb_overlay` + `oppo-dv-mkv v1.5.0 / v1.6.0 / v1.7.0` | Supported for the verified combined boot-chain signatures |
| Other oppo-dv-mkv signatures | May be accepted only when the **exact** known wrapper and player signatures match |

Every mode requires **[CHECKONLY](https://github.com/DamnFine815/autoABC/releases/download/v1.1.1/autoABC-1.1.1-CHECKONLY.zip)** to report **`COMPATIBLE`** on the actual player before installation. Unknown `brick_monitor` modifications, unexpected player-code bytes, incompatible boot ownership, duplicate standalone [UOPfree](https://github.com/DamnFine815/UOPfree) (with `UOPFREE=1`), and existing older autoABC installations are intentionally rejected.

**Earlyboot:** `EARLYBOOT=1` is the default to catch discs inserted before powering on. `EARLYBOOT=0` keeps a later startup path which may miss the first disc. See [Configuration](CONFIGURATION.md).

**Playback:** Physical HDMV and BD-J Blu-ray region detection are included. ISO and BDMV are optional and default to enabled. The detector supports all seven A/B/C allowed-region combinations, but individual publisher-authored discs are not universally guaranteed; see [Region support](REGION_SUPPORT.md) and [Evidence](research/TEST_EVIDENCE.md). The PSR20 gate's value during BD-J playback can differ from the regular displayed region.

**Not provided:** DVD region unlocks, AACS/Cinavia/UHD copy-protection bypass, or a full firmware replacement. Installation hooks runtime process memory and the verified boot chain; keep a recovery method. Offline tests are not equivalent to a full hardware regression test.
