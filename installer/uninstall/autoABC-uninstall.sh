#!/bin/sh
# autoABC 1.1.1 TEST: remove ONLY installer's verified boot integration.
VERSION='1.1.1'
ID='1.1.1'
U='/mnt/ubi_boot'
D="$U/autoABC"
OVERLAY="$U/jb_overlay"
BM="$OVERLAY/bin/brick_monitor"
REAL="$OVERLAY/bin/brick_monitor.autoABC_real_v110"
AUTO="$OVERLAY/autostart.sh"
MKV="$U/bdpprog"
PREV="$U/bdpprog.prev"
MKVD="$U/oppo-dv-mkv"
BB="$D/bin/busybox"
TMP="$U/.autoabc110-uninstall.$$"
EJECT_BB="/tmp/autoabc110-eject-busybox.$$"
EJECT_READY=NO
S=''; AMB=0
for F in /mnt/sd*/AutoScript/autoABC-uninstall.id; do
    [ -f "$F" ] || continue
    [ "$(cat "$F" 2>/dev/null)" = "$ID" ] || continue
    C="${F%/autoABC-uninstall.id}"
    [ -f "$C/autoABC-uninstall.sh" ] || continue
    if [ -z "$S" ]; then S="$C"; else AMB=1; fi
done
[ -n "$S" ] || { echo 'autoABC 1.1.1 uninstall: matching USB missing' > /tmp/autoabc110-uninstall-error.txt; exit 1; }
USBROOT="${S%/*}"
LOG="$USBROOT/autoABC-uninstall.log"
RESULT="$USBROOT/autoABC-uninstall-result.txt"
GUARD='/tmp/autoabc110-uninstaller.ran'
[ -e "$GUARD" ] && exit 0
: > "$GUARD" 2>/dev/null || :
exec >> "$LOG" 2>&1
write_result(){ { echo "autoABC $VERSION - $1"; echo "$2"; echo 'Details: autoABC-uninstall.log'; } > "$RESULT"; sync 2>/dev/null || :; }
fail(){ echo "UNINSTALL=ABORTED: $*"; write_result FAILED "$*"; exit 1; }
checksum(){ "$BB" sha256sum "$1" 2>/dev/null | "$BB" awk '{print $1}'; }
BM_STOCK_SHA='9e7d885aa8f73c5c47a9a3bcd5dfe1d76faf28585232a9a068bb3116b5eede2f'
BM_KEY8_SHA='b128bf89c2adcd76b386eeda1e1448b6c508f0db531eae138f56a7514acc0b6a'
BM_SOURCE_SHA=''
MKV_WRAPPER_OLD_SHA='ceb256ccd233e5c6f19d59b9a90a1b31a230c732b48637aa43a5eb8bbea1cb6a'
MKV_WRAPPER_170_SHA='bcda04fbc464df8bd98b9ca57df0cec06d84a6f371519873f03241371f2b4dbc'
MKV_BOOT_SHA=''
mkv_wrapper_known(){
    [ -f "$MKV" ] && [ -x "$MKV" ] && [ ! -L "$MKV" ] || return 1
    MKV_CHECKED_SHA="$(checksum "$MKV")"
    case "$MKV_CHECKED_SHA" in
      "$MKV_WRAPPER_OLD_SHA") MKV_KNOWN_VERSION='1.5.0/1.6.0'; return 0 ;;
      "$MKV_WRAPPER_170_SHA") MKV_KNOWN_VERSION='1.7.0'; return 0 ;;
      *) return 1 ;;
    esac
}
cleanup(){ rm -f "$TMP" "$TMP.expected_tail" "$EJECT_BB"; }
trap cleanup 0
eject_after_success(){
    # The persistent RESULT is written first, regardless of tray state.
    # CLI success acknowledges only a sent command, not physical tray position.
    EJECT_STATE='UNAVAILABLE'
    EJECT_TRIES=0
    for EJECT_N in 1 2 3 4 5 6 7 8; do
        EJECT_TRIES="$EJECT_N"
        EJECT_FOUND=NO
        for EJECT_CLI in /usr/local/bin/cliprog /usr/bin/cliprog /bin/cliprog; do
            [ -x "$EJECT_CLI" ] || continue
            EJECT_FOUND=YES
            if printf 'drv.ir.rx.sq 0xaf000\nquit\n' | "$BB" timeout -s KILL 3 "$EJECT_CLI" >/dev/null 2>&1; then
                EJECT_STATE='REQUEST_SENT_NOT_PHYSICALLY_VERIFIED'
                echo "EJECT_CLI=$EJECT_CLI ATTEMPTS=$EJECT_N"
                break
            fi
        done
        [ "$EJECT_STATE" != 'UNAVAILABLE' ] && break
        [ "$EJECT_FOUND" != 'NO' ] && EJECT_STATE='CLI_COMMAND_FAILED'
        [ "$EJECT_N" = 8 ] && break
        # Each CLI attempt is limited to 3 seconds. The wait covers boot readiness.
        "$BB" sleep 1 2>/dev/null || sleep 1
        EJECT_STATE='UNAVAILABLE'
    done
    echo "EJECT_STATUS=$EJECT_STATE ATTEMPTS=$EJECT_TRIES"
    printf 'EJECT_STATUS=%s\n' "$EJECT_STATE" >> "$RESULT" || :
    "$BB" sync 2>/dev/null || sync
}

[ "$AMB" = 0 ] || fail 'multiple uninstall USB payloads found'
[ -d "$D" ] && [ ! -L "$D" ] && [ ! -L "$D/INSTALL_MODE" ] || fail 'autoABC installation not found / unsafe directory'
MODE="$(cat "$D/INSTALL_MODE" 2>/dev/null)"
[ ! -L "$D/BUILD_ID" ] && [ "$(cat "$D/BUILD_ID" 2>/dev/null)" = "$ID" ] || fail 'uninstaller build mismatch; use matching autoABC uninstaller'
case "$MODE" in OPPODV_PREV_110|OPPODV_PREV_EARLY_110|OVERLAY_AUTOSTART_110|OVERLAY_EARLYBOOT_110|OVERLAY_MKV_AUTOSTART_110|OVERLAY_MKV_EARLYBOOT_110) ;; *) fail "unknown installation owner $MODE";; esac
[ -x "$BB" ] && [ ! -L "$BB" ] || fail 'private BusyBox missing or symlinked'
[ "$(checksum "$BB")" = 'cd04052b8b6885f75f50b2a280bfcbf849d8710c8e61d369c533acf307eda064' ] || fail 'private BusyBox checksum mismatch'
[ -x "$D/stop.sh" ] && [ ! -L "$D/stop.sh" ] || fail 'autoABC stop.sh missing or symlinked'
echo "UNINSTALL_VERSION=$VERSION MODE=$MODE"
case "$MODE" in
  OVERLAY_AUTOSTART_110|OVERLAY_MKV_AUTOSTART_110|OVERLAY_EARLYBOOT_110|OVERLAY_MKV_EARLYBOOT_110)
    SHA_MARKER="$D/BRICK_MONITOR_SOURCE_SHA"
    [ -f "$SHA_MARKER" ] && [ ! -L "$SHA_MARKER" ] || fail 'original monitor SHA marker missing or linked'
    BM_SOURCE_SHA="$(cat "$SHA_MARKER" 2>/dev/null)"
    case "$BM_SOURCE_SHA" in
      "$BM_STOCK_SHA"|"$BM_KEY8_SHA") echo "BRICK_MONITOR_RESTORE_SHA=$BM_SOURCE_SHA" ;;
      *) fail 'unknown original monitor SHA marker' ;;
    esac ;;
esac
case "$MODE" in
    OPPODV_PREV_EARLY_110) ADAPTER_EXPECTED_SHA='aabdc8c78c67449c1751909c47d0434569a31d021887caa39807b5aa52ae579e' ;;
    OPPODV_PREV_110) ADAPTER_EXPECTED_SHA='504833a82b01e0d87819b50f2e0736739646c67cccc1d89ccb3e080dd90c0bfa' ;;
esac
# Dual install's boot chain must still have its known ownership before any changes.
# If oppo-dv-mkv was uninstalled via its own uninstaller, it safely promotes
# the original overlay predecessor to /mnt/ubi_boot/bdpprog; accept only that
# exact, untouched recovery state as well.
case "$MODE" in
  OVERLAY_MKV_AUTOSTART_110|OVERLAY_MKV_EARLYBOOT_110)
    if [ ! -L "$MKV" ] && [ -x "$MKV" ] && mkv_wrapper_known && [ -d "$MKVD" ] && [ ! -L "$MKVD" ] && [ ! -L "$PREV" ] && [ -x "$PREV" ] && [ "$(checksum "$PREV")" = 'cfe0d2aab573f92c8a054018a7e9419590ae572adbcec689995b9638b3f26b24' ]; then
      MKV_BOOT_SHA="$MKV_CHECKED_SHA"
      echo "DUAL_CHAIN=INTACT_MKV_AND_OVERLAY VERSION=$MKV_KNOWN_VERSION SHA256=$MKV_BOOT_SHA"
    elif [ ! -L "$MKV" ] && [ -x "$MKV" ] && [ "$(checksum "$MKV")" = 'cfe0d2aab573f92c8a054018a7e9419590ae572adbcec689995b9638b3f26b24' ] && [ ! -e "$MKVD" ] && [ ! -L "$MKVD" ] && [ ! -e "$PREV" ] && [ ! -L "$PREV" ]; then
      echo 'DUAL_CHAIN=MKV_UNINSTALLED_OVERLAY_RESTORED'
    else fail 'dual MKV/overlay boot chain altered; refusing uninstall'; fi ;;
esac
# PRE-VERIFY everything before stopping daemons or changing any boot file.
case "$MODE" in
  OPPODV_PREV_110|OPPODV_PREV_EARLY_110)
    [ ! -e "$OVERLAY" ] && [ ! -L "$OVERLAY" ] || fail 'overlay appeared: conflicting boot managers'
    [ ! -L "$MKV" ] && [ -f "$MKV" ] && [ -x "$MKV" ] || fail 'bdpprog missing or symlinked'
    [ ! -L "$PREV" ] || fail 'bdpprog.prev symlinked'
    if mkv_wrapper_known; then
      SUBMODE=CHAINED
      MKV_BOOT_SHA="$MKV_CHECKED_SHA"
      echo "MKV_BOOT_CHAIN=VERIFIED VERSION=$MKV_KNOWN_VERSION SHA256=$MKV_BOOT_SHA"
      [ -x "$PREV" ] && [ "$(checksum "$PREV")" = "$ADAPTER_EXPECTED_SHA" ] || fail 'MKV predecessor changed; refusing deletion'
    elif [ "$(checksum "$MKV")" = "$ADAPTER_EXPECTED_SHA" ]; then
      SUBMODE=PROMOTED
      [ ! -e "$PREV" ] && [ ! -L "$PREV" ] && [ ! -d "$MKVD" ] || fail 'promoted adapter with unexpected external owner'
    else fail 'unrecognized MKV boot owner'; fi ;;
  OVERLAY_AUTOSTART_110|OVERLAY_MKV_AUTOSTART_110)
    [ -f "$AUTO" ] && [ ! -L "$AUTO" ] && [ -x "$AUTO" ] || fail 'autostart.sh missing or not executable'
    [ "$(checksum "$BM")" = "$BM_SOURCE_SHA" ] || fail 'brick_monitor changed; refusing uninstall'
    [ ! -e "$REAL" ] && [ ! -L "$REAL" ] || fail 'unexpected earlyboot backup present'
    ORIGINAL_MODE="$(cat "$D/AUTOSTART_ORIG_MODE" 2>/dev/null)"
    case "$ORIGINAL_MODE" in 644|755|775|744|754|764|700|750|770|777|664) ;; *) fail 'original autostart permissions metadata invalid';; esac
    BEGIN_COUNT="$("$BB" grep -c '^# AUTOABC_AUTOSTART_BEGIN_110$' "$AUTO" 2>/dev/null)"
    END_COUNT="$("$BB" grep -c '^# AUTOABC_AUTOSTART_END_110$' "$AUTO" 2>/dev/null)"
    [ "$BEGIN_COUNT" = 1 ] && [ "$END_COUNT" = 1 ] || fail 'unexpected autostart markers'
    LINES="$("$BB" sed -n '/^# AUTOABC_AUTOSTART_BEGIN_110$/,/^# AUTOABC_AUTOSTART_END_110$/p' "$AUTO")"
    EXPECTED="$(printf '# AUTOABC_AUTOSTART_BEGIN_110\nsh /mnt/ubi_boot/autoABC/start.sh >> /mnt/ubi_boot/autoABC/boot.log 2>&1 &\nsh /mnt/ubi_boot/autoABC/uopfree_launch.sh >> /mnt/ubi_boot/autoABC/uopfree.log 2>&1 &\n# AUTOABC_AUTOSTART_END_110\n')"
    [ "$LINES" = "$EXPECTED" ] || fail 'installed autostart block changed'
    [ "$("$BB" stat -c '%a' "$AUTO" 2>/dev/null)" = 755 ] || fail 'autostart permissions changed; manual review required' ;;
  OVERLAY_EARLYBOOT_110|OVERLAY_MKV_EARLYBOOT_110)
    [ ! -L "$BM" ] && [ -x "$BM" ] && [ "$(checksum "$BM")" = 'd080667d48f2166ea633eee3dc539abe0865334828590c5d2b482cd41226cff8' ] || fail 'active earlyboot wrapper changed'
    [ ! -L "$REAL" ] && [ -x "$REAL" ] && [ "$(checksum "$REAL")" = "$BM_SOURCE_SHA" ] || fail 'saved original brick_monitor missing/altered' ;;
esac
# Re-verify foreign combined-mode ownership before any destructive cleanup.
case "$MODE" in
  OVERLAY_MKV_AUTOSTART_110|OVERLAY_MKV_EARLYBOOT_110)
    if [ -n "$MKV_BOOT_SHA" ]; then
      [ ! -L "$MKV" ] && [ "$(checksum "$MKV")" = "$MKV_BOOT_SHA" ] &&
      [ ! -L "$PREV" ] && [ -x "$PREV" ] &&
      [ "$(checksum "$PREV")" = 'cfe0d2aab573f92c8a054018a7e9419590ae572adbcec689995b9638b3f26b24' ] &&
      [ -d "$MKVD" ] && [ ! -L "$MKVD" ] || fail 'combined MKV launcher or predecessor changed before removal'
    else
      [ "$(checksum "$MKV")" = 'cfe0d2aab573f92c8a054018a7e9419590ae572adbcec689995b9638b3f26b24' ] &&
      [ ! -e "$PREV" ] && [ ! -L "$PREV" ] &&
      [ ! -e "$MKVD" ] && [ ! -L "$MKVD" ] || fail 'promoted overlay changed before removal'
    fi ;;
esac
# Confirm stop before unlinking anything. Abort on lingering owned processes.
"$D/stop.sh" || fail 'autoABC stop script failed'
"$BB" usleep 400000 2>/dev/null || :
for P in /proc/[0-9]*; do
    [ -r "$P/cmdline" ] || continue
    CMD="$(tr '\000' ' ' < "$P/cmdline" 2>/dev/null || :)"
    case "$CMD" in *"$D/"*) fail "autoABC process still running PID=${P##*/}";; esac
done
case "$MODE" in
  OPPODV_PREV_110|OPPODV_PREV_EARLY_110)
    if [ "$SUBMODE" = CHAINED ]; then
        [ "$(checksum "$PREV")" = "$ADAPTER_EXPECTED_SHA" ] && [ "$(checksum "$MKV")" = "$MKV_BOOT_SHA" ] || fail 'MKV chain changed during cleanup'
        rm -f "$PREV" || fail 'cannot unlink autoABC predecessor'
        [ ! -e "$PREV" ] || fail 'predecessor still present'
    else
        [ "$(checksum "$MKV")" = "$ADAPTER_EXPECTED_SHA" ] && [ ! -e "$PREV" ] || fail 'promoted adapter changed during cleanup'
        rm -f "$MKV" || fail 'cannot unlink promoted autoABC adapter'
        [ ! -e "$MKV" ] || fail 'promoted adapter still present'
    fi ;;
  OVERLAY_AUTOSTART_110|OVERLAY_MKV_AUTOSTART_110)
    BEFORE_SHA="$(checksum "$AUTO")"
    SAVED_EOF="$(cat "$D/AUTOSTART_ORIG_EOF" 2>/dev/null)"
    SAVED_SIZE="$(cat "$D/AUTOSTART_ORIG_SIZE" 2>/dev/null)"
    SAVED_SHA="$(cat "$D/AUTOSTART_ORIG_SHA" 2>/dev/null)"
    case "$SAVED_EOF" in LF|NO_LF) ;; *) fail 'original autostart EOF metadata invalid';; esac
    case "$SAVED_SIZE" in ''|*[!0-9]*) fail 'original autostart byte count invalid';; esac
    case "$SAVED_SHA" in ????????????????????????????????????????????????????????????????) ;; *) fail 'original autostart SHA marker invalid';; esac
    # Rebuild byte-identically if our block is still the final suffix.
    # If another mod appended lines, preserve them via line-based removal ONLY
    # when the pre-existing file already had a newline. Without one, abort safely.
    "$BB" head -c "$SAVED_SIZE" "$AUTO" > "$TMP" || fail 'cannot stage original autostart prefix'
    if [ "$(checksum "$TMP")" = "$SAVED_SHA" ]; then
        ORIG_BYTES="$SAVED_SIZE"
        CUR_BYTES="$("$BB" wc -c < "$AUTO" | "$BB" awk '{print $1}')"
        EXTRA_BYTES=$((CUR_BYTES - ORIG_BYTES))
        [ "$EXTRA_BYTES" -gt 0 ] || fail 'missing owned autostart suffix'
        "$BB" tail -c "$EXTRA_BYTES" "$AUTO" > "$TMP.expected_tail" || fail 'cannot check autostart suffix'
        EXPECTED_SUFFIX="$(printf '# AUTOABC_AUTOSTART_BEGIN_110\nsh /mnt/ubi_boot/autoABC/start.sh >> /mnt/ubi_boot/autoABC/boot.log 2>&1 &\nsh /mnt/ubi_boot/autoABC/uopfree_launch.sh >> /mnt/ubi_boot/autoABC/uopfree.log 2>&1 &\n# AUTOABC_AUTOSTART_END_110\n')"
        if [ "$SAVED_EOF" = NO_LF ]; then
            EXPECTED_SUFFIX="$(printf '\n%s' "$EXPECTED_SUFFIX")"
        fi
        [ "$(cat "$TMP.expected_tail")" = "$EXPECTED_SUFFIX" ] || {
            [ "$SAVED_EOF" = LF ] || fail 'later autostart edits after originally unterminated line; manual review required'
            "$BB" sed '/^# AUTOABC_AUTOSTART_BEGIN_110$/,/^# AUTOABC_AUTOSTART_END_110$/d' "$AUTO" > "$TMP" || fail 'cannot stage edited autostart cleanup'
        }
        rm -f "$TMP.expected_tail" 2>/dev/null || :
    else
        [ "$SAVED_EOF" = LF ] || fail 'originally unterminated autostart prefix changed; manual review required'
        "$BB" sed '/^# AUTOABC_AUTOSTART_BEGIN_110$/,/^# AUTOABC_AUTOSTART_END_110$/d' "$AUTO" > "$TMP" || fail 'cannot stage modified autostart cleanup'
    fi
    chmod "$ORIGINAL_MODE" "$TMP" || fail 'cannot restore autostart permissions'
    [ "$(checksum "$AUTO")" = "$BEFORE_SHA" ] || fail 'autostart changed during cleanup'
    mv -f "$TMP" "$AUTO" || fail 'cannot restore autostart.sh'
    [ "$("$BB" grep -c '^# AUTOABC_AUTOSTART_.*110$' "$AUTO" 2>/dev/null)" = 0 ] || fail 'autostart marker survived cleanup' ;;
  OVERLAY_EARLYBOOT_110|OVERLAY_MKV_EARLYBOOT_110)
    cp -p "$REAL" "$TMP" || fail 'cannot stage genuine brick_monitor'
    [ "$(checksum "$TMP")" = "$BM_SOURCE_SHA" ] || fail 'genuine monitor backup differs'
    [ "$(checksum "$BM")" = 'd080667d48f2166ea633eee3dc539abe0865334828590c5d2b482cd41226cff8' ] || fail 'earlyboot wrapper changed during cleanup'
    mv -f "$TMP" "$BM" || fail 'cannot restore genuine brick_monitor'
    [ "$(checksum "$BM")" = "$BM_SOURCE_SHA" ] || fail 'restored brick_monitor differs'
    rm -f "$REAL" || fail 'cannot remove autoABC original-monitor backup' ;;
esac
# Preserve the already-verified BusyBox in temporary RAM for the optional
# post-uninstall EJECT command. The actual installed copy is about to be deleted.
if cp "$BB" "$EJECT_BB" && chmod 755 "$EJECT_BB" &&
   [ "$(checksum "$EJECT_BB")" = 'cd04052b8b6885f75f50b2a280bfcbf849d8710c8e61d369c533acf307eda064' ]; then
    EJECT_READY=YES
else
    rm -f "$EJECT_BB" 2>/dev/null || :
    echo 'EJECT_WARNING=TEMPORARY_BUSYBOX_UNAVAILABLE'
fi
# All starting points are detached. Only now delete autoABC-owned runtime files.
rm -rf "$D" || fail 'cannot remove autoABC runtime directory'
rm -f /tmp/ra /tmp/autoabc_active_iso /tmp/autoabc_disabled /tmp/autoabc_hook.state /tmp/autoabc_bdpprog.pid /tmp/autoabc_psr20_hook.state /tmp/autoabc_psr20_request.* /tmp/autoabc_virtual.state /tmp/autoabc_virtual.seq /tmp/autoabc_preplay.lock 2>/dev/null || :
sync
echo "UNINSTALL=COMPLETE MODE=$MODE"
write_result UNINSTALLED "autoABC removed ($MODE). Other mods left untouched. Remove USB and power-cycle."
if [ "$EJECT_READY" = YES ]; then
    BB="$EJECT_BB"
    eject_after_success
else
    echo 'EJECT_STATUS=UNAVAILABLE TEMPORARY_BUSYBOX_MISSING'
    printf 'EJECT_STATUS=UNAVAILABLE\n' >> "$RESULT" || :
fi
exit 0
