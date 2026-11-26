# Uninstalling autoABC

[Back to README](../README.md) · [v1.1.3 release](https://github.com/DamnFine815/autoABC/releases/tag/v1.1.3)

**Always use the uninstaller matching the version currently installed.** Do not use the 1.1.3 uninstaller against a 1.0.0 installation or vice versa. **Uninstall the older version and fully reboot before installing any newer version.**

## Recovery: installed autoABC 1.1.2 with oppo-dv-mkv v2.1–v2.3

If autoABC **1.1.2** was installed before the oppo-dv-mkv boot wrapper changed, the original 1.1.2 uninstaller might refuse the now-unknown wrapper. Use the special **[1.1.2 rescue uninstaller](https://github.com/DamnFine815/autoABC/releases/download/v1.1.3/autoABC-1.1.2-v2.3-rescue-uninstall.zip)** (SHA-256: `a43db7510e507aee7b8357fa3f7f36d1c14d67d0cd391c928037ce734e7e6b11`) **only for an installed BUILD_ID of 1.1.2**. It expands the exact upstream-wrapper allowlist, but preserves the 1.1.2 ID and all original safety checks. Confirm `UNINSTALLED` before rebooting, then use the new 1.1.3 CHECKONLY.

Never run this rescue on 1.1.0, 1.1.1 or 1.1.3. If it still reports `FAILED`, preserve the logs and stop; do not force changes to the boot chain.

## Uninstall autoABC 1.1.3

1. Download [autoABC-1.1.3-uninstall.zip](https://github.com/DamnFine815/autoABC/releases/download/v1.1.3/autoABC-1.1.3-uninstall.zip). Its SHA-256 is:

   `ab943075d901bb0f5d16cb24078a7528d6a01517d1512563d667ab9019284064`

2. Stop playback, power the OPPO UDP-203 completely off, and remove other installation sticks.
3. Extract **only** the uninstaller ZIP into the root of a clean, player-readable USB volume. Its layout begins:

   ```text
   USB_ROOT/
     AutoScript/
       AutoScript.TSS
       autoABC-uninstall.id
       autoABC-uninstall.sh
     SHA256SUMS_RELEASE
   ```

4. Insert USB, switch on, and check **`autoABC-uninstall-result.txt`** on the stick for **`UNINSTALLED`**. If it says `FAILED`, inspect `autoABC-uninstall.log`. Tray motion is not sufficient proof.
5. Remove the USB stick and **fully power-cycle** the player.

The uninstaller verifies its owned runtime and boot-chain markers, restores only recognized backed-up files, and avoids overwriting unknown third-party changes. It is intended to preserve unrelated jb_overlay and oppo-dv-mkv files and configurations. If ownership or the backup cannot be verified, the safe result is **`FAILED`**, not a forced removal.

**Do not manually delete `/mnt/ubi_boot/autoABC` or replace `brick_monitor`.**

**Upgrading from 1.1.0:** Use its matching 1.1.0 uninstaller. If oppo-dv-mkv 1.7.0 was installed first, that older uninstaller may reject the new launcher; stop instead of forcing removal. The 1.1.3 uninstaller does not remove 1.1.0.

## Upgrading from autoABC 1.0.0

Use the **historical [autoABC-1.0.0-uninstall.zip](https://github.com/DamnFine815/autoABC/releases/download/v1.0.0/autoABC-1.0.0-uninstall.zip)** first. Confirm `UNINSTALLED` and perform a complete power cycle. Then run the v1.1.3 CHECKONLY on its own USB stick before installing.

See [Installation](INSTALLATION.md), [Troubleshooting](TROUBLESHOOTING.md) and [Compatibility](COMPATIBILITY.md).
