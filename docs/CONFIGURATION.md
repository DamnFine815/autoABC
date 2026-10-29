# autoABC 1.1.1 configuration

[Back to README](../README.md) · [Installation](INSTALLATION.md)

Both **CHECKONLY** and **INSTALL** contain the same default settings. Choose your values in both ZIPs **before using them**.

## `AutoScript/config.ini`

```ini
ISO_BDMV=1
EARLYBOOT=1
```

| Option | Default | Meaning |
| --- | --- | --- |
| `ISO_BDMV=1` | `1` | Automatic region detection for ISO/BDMV as well as physical Blu-rays. Complex BD-J virtual media may open slightly more slowly while examined. Set `0` if the extra delay bothers you; physical-disc auto-region stays enabled. |
| `EARLYBOOT=1` | `1` | Starts autoABC early in the verified boot sequence so a pre-inserted disc/autoplay is less likely to reach region checks first. Set `0` for the later startup path; the first disc may race ahead. |

## `AutoScript/uopfree.ini`

```ini
UOPFREE=1
```

- `UOPFREE=1` (default): enable integrated [UOPfree](https://github.com/DamnFine815/UOPfree), removing applicable disc-authored User Operation Prohibitions (STOP/MENU/NEXT) in RAM.
- `UOPFREE=0`: disable only the integrated UOPfree feature.

**Important:** Uninstall a separate standalone [UOPfree](https://github.com/DamnFine815/UOPfree) installation before using `UOPFREE=1`. The installer refuses duplicate standalone UOPfree states.

The `config.ini` parser requires exactly one `ISO_BDMV=0/1` and exactly one `EARLYBOOT=0/1`; unknown keys and duplicates are rejected. `uopfree.ini` requires exactly one valid `UOPFREE=0/1`. Neither file is executed as shell code.

**Changing installation-time options:** Use the matching version's uninstaller, fully reboot, repeat CHECKONLY with the revised values, then INSTALL using those same values. Do not assume editing an installed INI alone will remove or add the Earlyboot wrapper.

There is no permanent per-disc region cache or teach/learning mode. The physical BD-J PSR20 gate remains enabled regardless of `ISO_BDMV`, and ISO/BDMV playback itself remains available when virtual auto-region is off. See [Virtual-media timing](research/VIRTUAL_MEDIA_TIMING.md).
