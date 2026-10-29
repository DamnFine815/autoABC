# Uninstalling autoABC

[Back to README](../README.md) · [v1.1.1 release](https://github.com/DamnFine815/autoABC/releases/tag/v1.1.1)

**Always use the uninstaller matching the version currently installed.** Do not use the 1.1.1 uninstaller against a 1.0.0 installation or vice versa. **Uninstall the older version and fully reboot before installing any newer version.**

## Uninstall autoABC 1.1.1

1. Download [autoABC-1.1.1-uninstall.zip](https://github.com/DamnFine815/autoABC/releases/download/v1.1.1/autoABC-1.1.1-uninstall.zip). Its SHA-256 is:

   `66df415b7f65183ec0ed349548e9e1a8e2edf9a988f0ba242132b99a37d033f1`

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

**Upgrading from 1.1.0:** Use its matching 1.1.0 uninstaller. If oppo-dv-mkv 1.7.0 was installed first, that older uninstaller may reject the new launcher; stop instead of forcing removal. The 1.1.1 uninstaller does not remove 1.1.0.

## Upgrading from autoABC 1.0.0

Use the **historical [autoABC-1.0.0-uninstall.zip](https://github.com/DamnFine815/autoABC/releases/download/v1.0.0/autoABC-1.0.0-uninstall.zip)** first. Confirm `UNINSTALLED` and perform a complete power cycle. Then run the v1.1.1 CHECKONLY on its own USB stick before installing.

See [Installation](INSTALLATION.md), [Troubleshooting](TROUBLESHOOTING.md) and [Compatibility](COMPATIBILITY.md).
