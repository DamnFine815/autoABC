# Compatibility and limitations — autoABC 1.1.3

**Target:** OPPO UDP-203, RU-JB 65-0131, USB AutoScript and a matching live `bdpprog.1` layout. A firmware number alone is **not** proof of compatibility.

| Boot environment | 1.1.3 status |
| --- | --- |
| `jb_overlay v1.7` | Supported for exact recognized launcher and monitor signatures, including the known KEY8 variant |
| `jb_overlay V2` | Known launcher/monitor signatures recognized; **separate real-device cold-boot confirmation is not documented** |
| `jb_overlay V3` | Supported for recognized launcher and monitor signatures |
| `oppo-dv-mkv v1.5.0–v2.3.0-beta` without jb_overlay | Supported for the known wrapper signature, including `EARLYBOOT=1` |
| `jb_overlay` + `oppo-dv-mkv v1.5.0 / v1.6.0 / v1.7.0` | Supported for the verified combined boot-chain signatures |
| Other oppo-dv-mkv signatures | May be accepted only when the **exact** known wrapper and player signatures match |

**Newly recognized upstream wrapper families:** v2.1.0–v2.1.2-beta (SHA-256 `4054c4b7c62155adea52299cf2cedf870eccd727bc5703aa16f555c4a458d42f`), v2.2.0-beta/v2.3.0-beta (SHA-256 `630bba8355379fe1731a28849881e5af5d39545794ea08e734d0fcbddd594321`). These match the boot-wrapper bytes in Vitor's official full ZIPs; Vitor's earlier player-and-patch code paths still require the exact live firmware checks below.

Every mode requires **[CHECKONLY](https://github.com/DamnFine815/autoABC/releases/download/v1.1.3/autoABC-1.1.3-CHECKONLY.zip)** to report **`COMPATIBLE`** on the actual player before installation. Unknown `brick_monitor` modifications, unexpected player-code bytes, incompatible boot ownership, duplicate standalone [UOPfree](https://github.com/DamnFine815/UOPfree) (with `UOPFREE=1`), and existing older autoABC installations are intentionally rejected.

**Earlyboot:** `EARLYBOOT=1` is the default to catch discs inserted before powering on. `EARLYBOOT=0` keeps a later startup path which may miss the first disc. See [Configuration](CONFIGURATION.md).

**Playback:** Physical HDMV and BD-J Blu-ray region detection are included. ISO and BDMV are optional and default to enabled. The detector supports all seven A/B/C allowed-region combinations, but individual publisher-authored discs are not universally guaranteed; see [Region support](REGION_SUPPORT.md) and [Evidence](research/TEST_EVIDENCE.md). The PSR20 gate's value during BD-J playback can differ from the regular displayed region.

**Upgrade from 1.1.2 after updating oppo-dv-mkv:** the [version-specific 1.1.2 rescue uninstaller](https://github.com/DamnFine815/autoABC/releases/download/v1.1.3/autoABC-1.1.2-v2.3-rescue-uninstall.zip) accepts the newly pinned wrappers while requiring the original installed `BUILD_ID=1.1.2`. Do not use it for 1.1.0, 1.1.1 or 1.1.3. Fully restart between uninstall, CHECKONLY and INSTALL. **Never bypass a failed CHECKONLY or a rejected ownership check.**

**Not provided:** DVD region unlocks, AACS/Cinavia/UHD copy-protection bypass, or a full firmware replacement. Installation hooks runtime process memory and the verified boot chain; keep a recovery method. Offline tests are not equivalent to a full hardware regression test.
