# Troubleshooting — autoABC 1.1.1

[Back to README](../README.md) · [Installation](INSTALLATION.md)

## CHECKONLY or INSTALL appears to do nothing

Only one extracted package may be on a clean USB stick, with `AutoScript/AutoScript.TSS` **directly at its root**. Run the [1.1.1 CHECKONLY](https://github.com/DamnFine815/autoABC/releases/tag/v1.1.1) first. Find `autoABC-result.txt` and `autoABC.log` on USB. The installer can refuse ambiguous USB mounts or unknown launchers.

## Result is FAILED or NOT COMPATIBLE

Keep the exact result file and log. Common intentional refusal reasons include an older autoABC install that was not uninstalled, incompatible `brick_monitor`/oppo-dv-mkv wrapper, live player signature mismatch, altered runtime hashes, invalid INI settings or separate standalone [UOPfree](https://github.com/DamnFine815/UOPfree) when `UOPFREE=1`.

**Do not bypass safety checks or manually replace boot files.** Uninstall an older release with its matching uninstaller and reboot before running CHECKONLY again.

## EJECT/tray does not move

The EJECT command is **best effort**. Look at the `EJECT_STATUS` line in the USB result/log. `INSTALLED`, `COMPATIBLE`, `UNINSTALLED` and `FAILED` in their respective result files are authoritative, not tray movement.

## Uninstall failed

Use the **matching installed-version uninstaller**, not a newer or older package. For 1.1.1 read `autoABC-uninstall-result.txt` and `autoABC-uninstall.log`. A missing or modified original boot backup should cause a deliberate refusal. Never manually delete `/mnt/ubi_boot/autoABC` or overwrite `brick_monitor`.

## Already-inserted Blu-ray shows a region screen on first boot

Confirm `EARLYBOOT=1` in the installed configuration and the selected early boot mode with the [Telnet status commands](../README.md#telnet--ssh-quick-reference). The later `EARLYBOOT=0` path may activate too late for the first disc. Changing boot modes requires using the correct uninstaller and reinstalling with a matching CHECKONLY.

## ISO/BDMV still plays when ISO_BDMV=0

Expected: `ISO_BDMV=0` stops **autoABC virtual-media region detection**, not the stock player's ISO/BDMV playback. Complex BD-J virtual media may take longer to open when region detection is enabled. If the delay is distracting, choose `ISO_BDMV=0` during the next verified installation.

## BD-J PSR20 status appears inconsistent

During BD-J playback, the regular region-control register and the PSR20 gate can report different values. Check the full `status.sh` output instead of using the displayed CBR region alone. See [BD-J research](research/PHYSICAL_BDJ.md).

## Report a problem

Include firmware, boot environment (jb_overlay version, oppo-dv-mkv version or combined), physical-disc/ISO/BDMV source, chosen `ISO_BDMV`/`EARLYBOOT`/`UOPFREE` values, expected versus observed behavior, result file and **redacted** logs. Never post copyrighted discs, firmware dumps, private keys or unique device secrets.
