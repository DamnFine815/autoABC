#!/bin/sh
# autoABC 1.1.1 TEST: verified RU-JB 65-0131 boot environments.
# No persistent writes until complete payload + firmware + boot-owner preflight.
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
STAGE="$U/.autoabc110.stage.$$"
AUTO_NEW="$OVERLAY/.autostart.autoABC.new.$$"
AUTO_BAK="$OVERLAY/.autostart.autoABC.saved.$$"
BM_NEW="$OVERLAY/bin/.brick_monitor.autoABC.new.$$"
REAL_NEW="$OVERLAY/bin/.brick_monitor.autoABC.real.$$"
ADAPT_NEW="$U/.autoabc110.prev.$$"
FW_TEMP="/tmp/autoabc110-fw.$$"
BB_DIR="/tmp/autoabc110-bb.$$"
BB="$BB_DIR/busybox"
WRITTEN_RUNTIME=NO
WRITTEN_AUTOSTART=NO
WRITTEN_REAL=NO
WRITTEN_BM=NO
WRITTEN_PREV=NO
S=''
AMB=0
for F in /mnt/sd*/AutoScript/autoABC-release.id; do
    [ -f "$F" ] || continue
    [ "$(cat "$F" 2>/dev/null)" = "$ID" ] || continue
    C="${F%/autoABC-release.id}"
    [ -f "$C/autoABC-install.sh" ] && [ -d "$C/autoABC" ] || continue
    if [ -z "$S" ]; then S="$C"; else AMB=1; fi
done
[ -n "$S" ] || { echo 'autoABC 1.1.1: matching USB package missing' > /tmp/autoABC110-boot-error.txt; exit 1; }
[ -f "$S/CHECKONLY" ] && [ ! -L "$S/CHECKONLY" ] || exit 3
USBROOT="${S%/*}"
LOG="$USBROOT/autoABC.log"
RESULT="$USBROOT/autoABC-result.txt"
GUARD='/tmp/autoabc110-installer.ran'
[ -e "$GUARD" ] && exit 0
: > "$GUARD" 2>/dev/null || :
exec >> "$LOG" 2>&1
printf '=== autoABC %s %s ===\nUSB_SOURCE=%s\n' "$VERSION" "$(date)" "$S"
write_result(){ { echo "autoABC $VERSION - $1"; echo "$2"; echo 'Details: autoABC.log'; } > "$RESULT"; sync 2>/dev/null || :; }
checksum(){ "$BB" sha256sum "$1" 2>/dev/null | "$BB" awk '{print $1}'; }
BM_STOCK_SHA='9e7d885aa8f73c5c47a9a3bcd5dfe1d76faf28585232a9a068bb3116b5eede2f'
BM_KEY8_SHA='b128bf89c2adcd76b386eeda1e1448b6c508f0db531eae138f56a7514acc0b6a'
BM_SOURCE_SHA=''
MKV_WRAPPER_OLD_SHA='ceb256ccd233e5c6f19d59b9a90a1b31a230c732b48637aa43a5eb8bbea1cb6a'
MKV_WRAPPER_170_SHA='bcda04fbc464df8bd98b9ca57df0cec06d84a6f371519873f03241371f2b4dbc'
MKV_BOOT_SHA=''
mkv_wrapper_known(){
    # Both hashes are taken from the two exact upstream tagged wrapper scripts.
    # Refuse symlinks, non-executable files and every unknown launcher.
    [ -f "$MKV" ] && [ -x "$MKV" ] && [ ! -L "$MKV" ] || return 1
    MKV_CHECKED_SHA="$(checksum "$MKV")"
    case "$MKV_CHECKED_SHA" in
      "$MKV_WRAPPER_OLD_SHA") MKV_KNOWN_VERSION='1.5.0/1.6.0'; return 0 ;;
      "$MKV_WRAPPER_170_SHA") MKV_KNOWN_VERSION='1.7.0'; return 0 ;;
      *) return 1 ;;
    esac
}

OVERLAY_LAUNCHER_SHA='cfe0d2aab573f92c8a054018a7e9419590ae572adbcec689995b9638b3f26b24'
BRICK_WRAPPER_SHA='d080667d48f2166ea633eee3dc539abe0865334828590c5d2b482cd41226cff8'
NORMAL_ADAPTER_SHA='504833a82b01e0d87819b50f2e0736739646c67cccc1d89ccb3e080dd90c0bfa'
EARLY_ADAPTER_SHA='aabdc8c78c67449c1751909c47d0434569a31d021887caa39807b5aa52ae579e'
cleanup(){
    rm -f "$FW_TEMP" 2>/dev/null || :
    rm -rf "$BB_DIR" 2>/dev/null || :
}
rollback(){
    echo 'ROLLBACK=NOT_NEEDED_READONLY'
    return 0
}
fail(){
    echo "FAILED: $*"
    if rollback; then
        write_result FAILED "$*"
        cleanup
    else
        # Never discard recovery originals if we cannot safely restore a foreign-mod file.
        echo "RECOVERY_FILES_PRESERVED=$AUTO_BAK $REAL $D"
        write_result FAILED "$*; rollback incomplete, preserve logs and seek manual review"
        rm -f "$FW_TEMP" 2>/dev/null || :
        rm -rf "$BB_DIR" 2>/dev/null || :
    fi
    exit 1
}
eject_after_success(){ :; }

verify_existing_install(){
    # Read-only idempotence: only the EXACT same healthy build and config
    # may return ALREADY_INSTALLED. Older builds are never adopted/overwritten.
    [ ! -L "$D" ] && [ -d "$D" ] || fail 'existing autoABC directory is unsafe'
    [ ! -L "$D/BUILD_ID" ] && [ "$(cat "$D/BUILD_ID" 2>/dev/null)" = "$ID" ] || fail 'existing autoABC is another build; use its matching uninstaller'
    [ ! -L "$D/INSTALL_MODE" ] && [ -f "$D/INSTALL_MODE" ] || fail 'existing autoABC install owner unavailable'
    EXISTING_MODE="$(cat "$D/INSTALL_MODE" 2>/dev/null)"
    case "$EXISTING_MODE" in
      OPPODV_PREV_110|OPPODV_PREV_EARLY_110|OVERLAY_AUTOSTART_110|OVERLAY_EARLYBOOT_110|OVERLAY_MKV_AUTOSTART_110|OVERLAY_MKV_EARLYBOOT_110) ;;
      *) fail 'existing autoABC installation has unknown mode' ;;
    esac
    [ -f "$D/config.ini" ] && [ ! -L "$D/config.ini" ] && [ -f "$D/uopfree.ini" ] && [ ! -L "$D/uopfree.ini" ] || fail 'installed config missing or linked'
    EXISTING_ISO="$(AUTOABC_BOOTSTRAP_BB="$BB" sh "$S/autoABC/config.sh" get-iso "$D/config.ini" 2>/dev/null)" || fail 'installed ISO config invalid'
    EXISTING_EARLY="$(AUTOABC_BOOTSTRAP_BB="$BB" sh "$S/autoABC/config.sh" get-earlyboot "$D/config.ini" 2>/dev/null)" || fail 'installed Earlyboot config invalid'
    [ "$EXISTING_ISO" = "$ISO" ] && [ "$EXISTING_EARLY" = "$EARLY" ] && [ "$(cat "$D/uopfree.ini" 2>/dev/null)" = "UOPFREE=$UOP" ] || fail 'already installed with different configuration; uninstall the same build before changing options'
    [ -f "$D/SHA256SUMS" ] && [ ! -L "$D/SHA256SUMS" ] && [ "$(checksum "$D/SHA256SUMS")" = "$(checksum "$MANIFEST")" ] || fail 'installed sealed runtime manifest changed'
    EXISTING_COUNT=0
    while read -r EXISTING_SUM EXISTING_FILE; do
        [ -n "$EXISTING_SUM" ] || continue
        [ -f "$D/$EXISTING_FILE" ] && [ ! -L "$D/$EXISTING_FILE" ] && [ "$(checksum "$D/$EXISTING_FILE")" = "$EXISTING_SUM" ] || fail "installed runtime modified: $EXISTING_FILE"
        EXISTING_COUNT=$((EXISTING_COUNT + 1))
    done < "$MANIFEST"
    [ "$EXISTING_COUNT" = 49 ] || fail 'installed runtime manifest count wrong'
    case "$EXISTING_MODE" in
      OVERLAY_EARLYBOOT_110|OVERLAY_MKV_EARLYBOOT_110|OVERLAY_AUTOSTART_110|OVERLAY_MKV_AUTOSTART_110)
        [ -d "$OVERLAY" ] && [ ! -L "$OVERLAY" ] || fail 'existing overlay absent/unsafe'
        [ -f "$D/BRICK_MONITOR_SOURCE_SHA" ] && [ ! -L "$D/BRICK_MONITOR_SOURCE_SHA" ] || fail 'existing monitor owner marker unavailable'
        EXISTING_BM_SHA="$(cat "$D/BRICK_MONITOR_SOURCE_SHA" 2>/dev/null)"
        case "$EXISTING_BM_SHA" in "$BM_STOCK_SHA"|"$BM_KEY8_SHA") ;; *) fail 'existing monitor owner unknown';; esac ;;
    esac
    case "$EXISTING_MODE" in
      OVERLAY_EARLYBOOT_110|OVERLAY_MKV_EARLYBOOT_110)
        [ ! -L "$BM" ] && [ -x "$BM" ] && [ "$(checksum "$BM")" = "$BRICK_WRAPPER_SHA" ] || fail 'existing earlyboot wrapper modified'
        [ ! -L "$REAL" ] && [ -x "$REAL" ] && [ "$(checksum "$REAL")" = "$EXISTING_BM_SHA" ] || fail 'existing original monitor backup changed' ;;
      OVERLAY_AUTOSTART_110|OVERLAY_MKV_AUTOSTART_110)
        [ ! -L "$BM" ] && [ "$(checksum "$BM")" = "$EXISTING_BM_SHA" ] && [ ! -e "$REAL" ] && [ ! -L "$REAL" ] || fail 'existing autostart monitor ownership altered'
        [ -f "$AUTO" ] && [ ! -L "$AUTO" ] && [ -x "$AUTO" ] || fail 'existing overlay autostart missing/unsafe'
        [ "$("$BB" grep -c '^# AUTOABC_AUTOSTART_BEGIN_110$' "$AUTO")" = 1 ] && [ "$("$BB" grep -c '^# AUTOABC_AUTOSTART_END_110$' "$AUTO")" = 1 ] || fail 'installed autostart marker missing/duplicate'
        EXISTING_ENTRY="$("$BB" sed -n '/^# AUTOABC_AUTOSTART_BEGIN_110$/,/^# AUTOABC_AUTOSTART_END_110$/p' "$AUTO")"
        EXPECTED_ENTRY="$(printf '# AUTOABC_AUTOSTART_BEGIN_110\nsh /mnt/ubi_boot/autoABC/start.sh >> /mnt/ubi_boot/autoABC/boot.log 2>&1 &\nsh /mnt/ubi_boot/autoABC/uopfree_launch.sh >> /mnt/ubi_boot/autoABC/uopfree.log 2>&1 &\n# AUTOABC_AUTOSTART_END_110\n')"
        [ "$EXISTING_ENTRY" = "$EXPECTED_ENTRY" ] || fail 'existing autostart entry modified' ;;
    esac
    case "$EXISTING_MODE" in
      OVERLAY_MKV_EARLYBOOT_110|OVERLAY_MKV_AUTOSTART_110)
        [ ! -L "$MKV" ] && mkv_wrapper_known && [ ! -L "$PREV" ] && [ "$(checksum "$PREV")" = "$OVERLAY_LAUNCHER_SHA" ] && [ -d "$MKVD" ] && [ ! -L "$MKVD" ] || fail 'installed dual MKV/overlay predecessor changed' ;;
      OPPODV_PREV_110|OPPODV_PREV_EARLY_110)
        [ ! -e "$OVERLAY" ] && [ ! -L "$OVERLAY" ] && [ ! -L "$MKV" ] && mkv_wrapper_known && [ -d "$MKVD" ] && [ ! -L "$MKVD" ] || fail 'installed MKV owner changed'
        case "$EXISTING_MODE" in
            OPPODV_PREV_EARLY_110) EXISTING_ADAPTER_SHA="$EARLY_ADAPTER_SHA" ;;
            *) EXISTING_ADAPTER_SHA="$NORMAL_ADAPTER_SHA" ;;
        esac
        [ ! -L "$PREV" ] && [ "$(checksum "$PREV")" = "$EXISTING_ADAPTER_SHA" ] || fail 'installed MKV predecessor modified' ;;
    esac
    case "$EXISTING_MODE" in
      OPPODV_PREV_EARLY_110|OVERLAY_EARLYBOOT_110|OVERLAY_MKV_EARLYBOOT_110) [ "$EARLY" = 1 ] || fail 'installed mode and EARLYBOOT differ' ;;
      *) [ "$EARLY" = 0 ] || fail 'installed mode and EARLYBOOT differ' ;;
    esac
    echo "EXISTING_INSTALL=VERIFIED MODE=$EXISTING_MODE FILES=$EXISTING_COUNT CONFIG=MATCH"
    if [ -f "$S/CHECKONLY" ]; then
        echo "CHECKONLY=PASS EXISTING_INSTALL=VERIFIED MODE=$EXISTING_MODE"
        write_result COMPATIBLE "Existing autoABC $VERSION installation verified. Nothing changed."
    else
        echo "INSTALL=ALREADY_INSTALLED MODE=$EXISTING_MODE"
        write_result ALREADY_INSTALLED "Exact autoABC $VERSION install and config already verified. No files changed."
        eject_after_success
    fi
    cleanup
    exit 0
}

[ "$AMB" = 0 ] || fail 'multiple installer USB payloads found'
[ -d "$U" ] && [ ! -L "$U" ] || fail 'ubi_boot missing or symlink'
[ -f "$S/autoABC/bin/busybox" ] || fail 'bundled BusyBox missing'
mkdir -p "$BB_DIR" || fail 'cannot create BusyBox temporary directory'
cp "$S/autoABC/bin/busybox" "$BB" && chmod 755 "$BB" || fail 'cannot stage BusyBox'
[ "$(checksum "$BB")" = 'cd04052b8b6885f75f50b2a280bfcbf849d8710c8e61d369c533acf307eda064' ] || fail 'bundled BusyBox checksum mismatch'
[ -n "$("$BB" --help 2>&1 | "$BB" head -n 1)" ] || fail 'bundled BusyBox cannot execute'
echo 'BUSYBOX=VERIFIED'
MANIFEST="$S/autoABC/SHA256SUMS"
[ -f "$MANIFEST" ] && [ "$(checksum "$MANIFEST")" = '639445e7b785dab534ae2c13752598df2dc57d615cdfcb1306351aba72a4a5f7' ] || fail 'sealed runtime manifest mismatch'
COUNT=0
while read -r SUM FILE; do
    [ -n "$SUM" ] || continue
    case "$FILE" in bin/busybox|hook/*) ;; */*|.*|*..*|*\\*|*' '*) fail "unsafe manifest path: $FILE";; esac
    [ -f "$S/autoABC/$FILE" ] && [ "$(checksum "$S/autoABC/$FILE")" = "$SUM" ] || fail "runtime hash mismatch: $FILE"
    COUNT=$((COUNT+1))
done < "$MANIFEST"
[ "$COUNT" = '49' ] || fail "runtime file count differs: $COUNT"
CONFIG="$S/config.ini"
[ -f "$CONFIG" ] || fail 'AutoScript/config.ini missing'
CONFIG_DIAG="$(AUTOABC_BOOTSTRAP_BB="$BB" sh "$S/autoABC/config.sh" check "$CONFIG" 2>&1)" || {
    echo "$CONFIG_DIAG"
    echo "CONFIG_PREFIX_HEX=$("$BB" head -c 8 "$CONFIG" 2>/dev/null | "$BB" hexdump -v -e '1/1 "%02x"')"
    fail 'invalid config.ini (exactly ISO_BDMV=0/1 and EARLYBOOT=0/1)'
}
ISO="$(AUTOABC_BOOTSTRAP_BB="$BB" sh "$S/autoABC/config.sh" get-iso "$CONFIG")" || fail 'ISO_BDMV parser failed'
EARLY="$(AUTOABC_BOOTSTRAP_BB="$BB" sh "$S/autoABC/config.sh" get-earlyboot "$CONFIG")" || fail 'EARLYBOOT parser failed'
UOPCONFIG="$S/uopfree.ini"
[ -f "$UOPCONFIG" ] && [ ! -L "$UOPCONFIG" ] || fail 'uopfree.ini missing or linked'
UOPLINE="$(cat "$UOPCONFIG" 2>/dev/null)" || fail 'uopfree.ini unreadable'
case "$UOPLINE" in
    'UOPFREE=0') UOP=0 ;;
    'UOPFREE=1') UOP=1 ;;
    *) fail 'invalid uopfree.ini (expected exactly UOPFREE=0/1)' ;;
esac
echo "CONFIG=VALID ISO_BDMV=$ISO EARLYBOOT=$EARLY UOPFREE=$UOP"
# The user's USB config is mutable and intentionally not in runtime SHA256SUMS.
CONFIG_SHA="$(checksum "$CONFIG")"
[ -n "$CONFIG_SHA" ] || fail 'cannot fingerprint user config.ini'
CONFIG_TEST_FILE="$BB_DIR/config-edit-selftest.ini"
for TEST_ISO in 0 1; do
    for TEST_EARLY in 0 1; do
        printf 'ISO_BDMV=%s
EARLYBOOT=%s
' "$TEST_ISO" "$TEST_EARLY" > "$CONFIG_TEST_FILE" || fail 'config edit self-test file unavailable'
        AUTOABC_BOOTSTRAP_BB="$BB" sh "$S/autoABC/config.sh" check "$CONFIG_TEST_FILE" >/dev/null 2>&1 || fail "config parser self-test failed check ISO=$TEST_ISO EARLY=$TEST_EARLY"
        TEST_PARSED_ISO="$(AUTOABC_BOOTSTRAP_BB="$BB" sh "$S/autoABC/config.sh" get-iso "$CONFIG_TEST_FILE")" || fail 'config ISO self-test parser error'
        TEST_PARSED_EARLY="$(AUTOABC_BOOTSTRAP_BB="$BB" sh "$S/autoABC/config.sh" get-earlyboot "$CONFIG_TEST_FILE")" || fail 'config EARLYBOOT self-test parser error'
        [ "$TEST_PARSED_ISO" = "$TEST_ISO" ] && [ "$TEST_PARSED_EARLY" = "$TEST_EARLY" ] || fail "config edit self-test mismatch ISO=$TEST_ISO EARLY=$TEST_EARLY"
    done
done
rm -f "$CONFIG_TEST_FILE"
echo 'CONFIG_EDIT_SELFTEST=PASS ISO_BDMV=0/1 EARLYBOOT=0/1 COMBINATIONS=4'
[ "$(checksum "$CONFIG")" = "$CONFIG_SHA" ] || fail 'config.ini changed during preflight'
echo 'USER_CONFIG_MUTABLE=YES USER_CONFIG_INTEGRITY=PASS'
# A standalone UOPfree installation must never be launched twice.
if [ "$UOP" = 1 ]; then
    for OLD_UOP in "$U/UOPfree" "$U/bluray_uop"; do
        [ ! -e "$OLD_UOP" ] && [ ! -L "$OLD_UOP" ] || fail 'standalone UOPfree detected; set UOPFREE=0 or uninstall standalone first'
    done
    if [ -f "$AUTO" ]; then
        if "$BB" grep -Eq '^#UOPfree$|^#UOPFree$|/mnt/ubi_boot/(UOPfree|bluray_uop)/start[.]sh' "$AUTO"; then
            fail 'standalone UOPfree autostart detected; set UOPFREE=0 or uninstall standalone first'
        fi
    fi
fi
if [ -e "$D" ] || [ -L "$D" ]; then verify_existing_install; fi
[ ! -e "$U/region_auto" ] && [ ! -L "$U/region_auto" ] || fail 'existing legacy RegionAuto installation'
[ ! -e "$STAGE" ] && [ ! -e "$ADAPT_NEW" ] || fail 'stale installer staging exists'
# Only verified boot chains: original overlay, MKV-only, or MKV chaining to original overlay.
# Dual mode NEVER creates or changes bdpprog.prev: it already belongs to jb_overlay.
if [ -d "$OVERLAY" ] && [ ! -L "$OVERLAY" ]; then
    if [ -e "$MKVD" ] || [ -L "$MKVD" ]; then
        [ -d "$MKVD" ] && [ ! -L "$MKVD" ] || fail 'combined MKV runtime directory is unsafe'
        [ -f "$MKV" ] && [ -x "$MKV" ] && [ ! -L "$MKV" ] && mkv_wrapper_known || fail 'combined MKV launcher unknown (supported: exact v1.5/1.6 or v1.7.0 hashes)'
        [ -f "$PREV" ] && [ -x "$PREV" ] && [ ! -L "$PREV" ] && [ "$(checksum "$PREV")" = 'cfe0d2aab573f92c8a054018a7e9419590ae572adbcec689995b9638b3f26b24' ] || fail 'combined bdpprog.prev is not the pristine jb_overlay launcher'
        [ -f "$MKVD/dvmkv.sh" ] && [ ! -L "$MKVD/dvmkv.sh" ] && { [ ! -e "$MKVD/fpage.sh" ] || { [ -f "$MKVD/fpage.sh" ] && [ ! -L "$MKVD/fpage.sh" ]; }; } && [ ! -e "$MKVD/disable" ] && [ ! -L "$MKVD/disable" ] || fail 'combined MKV runtime missing, unexpected or disabled'
        BOOT_CHAIN='OVERLAY_VIA_MKV'
    else
        [ -f "$MKV" ] && [ -x "$MKV" ] && [ ! -L "$MKV" ] && [ "$(checksum "$MKV")" = 'cfe0d2aab573f92c8a054018a7e9419590ae572adbcec689995b9638b3f26b24' ] || fail 'unknown jb_overlay player boot launcher'
        [ ! -e "$PREV" ] && [ ! -L "$PREV" ] || fail 'orphaned bdpprog.prev without MKV runtime'
        BOOT_CHAIN='OVERLAY_DIRECT'
    fi
    [ -f "$U/.nobrick" ] || fail 'jb_overlay .nobrick guard missing'
    [ -f "$OVERLAY/etc/init.sh" ] && [ -x "$OVERLAY/etc/init.sh" ] && [ ! -L "$OVERLAY/etc/init.sh" ] || fail 'jb_overlay init.sh unavailable'
    grep -Fq 'bin/brick_monitor' "$OVERLAY/etc/init.sh" && grep -Fq 'autostart_wrap.sh' "$OVERLAY/etc/init.sh" || fail 'jb_overlay init.sh boot path differs'
    [ -f "$OVERLAY/etc/autostart_wrap.sh" ] && [ -x "$OVERLAY/etc/autostart_wrap.sh" ] || fail 'jb_overlay autostart launcher missing'
    [ -f "$AUTO" ] && [ ! -L "$AUTO" ] && [ ! -d "$AUTO" ] || fail 'jb_overlay autostart.sh missing or unsafe'
    [ -f "$BM" ] && [ -x "$BM" ] && [ ! -L "$BM" ] || fail 'brick_monitor not a regular executable or symlinked'
    BM_SOURCE_SHA="$(checksum "$BM")"
    case "$BM_SOURCE_SHA" in
      "$BM_STOCK_SHA") echo 'BRICK_MONITOR=VERIFIED_STOCK' ;;
      "$BM_KEY8_SHA") echo 'BRICK_MONITOR=VERIFIED_EJECT_TO_KEY8' ;;
      *) fail 'unsupported modified brick_monitor; refusing unknown boot owner' ;;
    esac
    [ ! -e "$REAL" ] && [ ! -L "$REAL" ] || fail 'autoABC brick_monitor backup already exists'
    [ "$("$BB" grep -Ec '^# AUTOABC_AUTOSTART_(BEGIN|END)_[0-9]+$' "$AUTO" 2>/dev/null)" = 0 ] || fail 'autostart.sh contains autoABC marker already'
    if [ "$EARLY" = 1 ]; then
        if [ "$BOOT_CHAIN" = OVERLAY_VIA_MKV ]; then MODE='OVERLAY_MKV_EARLYBOOT_110'; else MODE='OVERLAY_EARLYBOOT_110'; fi
    else
        if [ "$BOOT_CHAIN" = OVERLAY_VIA_MKV ]; then MODE='OVERLAY_MKV_AUTOSTART_110'; else MODE='OVERLAY_AUTOSTART_110'; fi
        AUTO_ORIG_MODE="$("$BB" stat -c '%a' "$AUTO" 2>/dev/null)"
        case "$AUTO_ORIG_MODE" in 644|755|775|744|754|764|700|750|770|777|664) ;; *) fail "unsupported autostart.sh permissions: $AUTO_ORIG_MODE";; esac
        AUTO_ORIG_LAST_HEX="$("$BB" tail -c 1 "$AUTO" | "$BB" hexdump -v -e '1/1 "%02x"')"
        case "$AUTO_ORIG_LAST_HEX" in 0a) AUTO_ORIG_EOF='LF' ;; *) AUTO_ORIG_EOF='NO_LF' ;; esac
    fi
elif [ ! -e "$OVERLAY" ] && [ ! -L "$OVERLAY" ]; then
        [ ! -e "$PREV" ] && [ ! -L "$PREV" ] || fail 'bdpprog.prev belongs to another mod'
    [ -f "$MKV" ] && [ -x "$MKV" ] && [ ! -L "$MKV" ] && mkv_wrapper_known || fail 'oppo-dv-mkv launcher unknown (supported: exact v1.5/1.6 or v1.7.0 hashes)'
    [ -f "$MKVD/dvmkv.sh" ] && [ ! -L "$MKVD/dvmkv.sh" ] && { [ ! -e "$MKVD/fpage.sh" ] || { [ -f "$MKVD/fpage.sh" ] && [ ! -L "$MKVD/fpage.sh" ]; }; } && [ ! -e "$MKVD/disable" ] || fail 'oppo-dv-mkv installation incomplete or disabled'
    [ -x /usr/local/bin/bdpprog.1 ] || fail 'original player missing'
    if [ "$EARLY" = 1 ]; then
        MODE='OPPODV_PREV_EARLY_110'
        ADAPTER_FILE='autoABC-prev-early.sh'
        ADAPTER_EXPECTED_SHA='aabdc8c78c67449c1751909c47d0434569a31d021887caa39807b5aa52ae579e'
    else
        MODE='OPPODV_PREV_110'
        ADAPTER_FILE='autoABC-prev.sh'
        ADAPTER_EXPECTED_SHA='504833a82b01e0d87819b50f2e0736739646c67cccc1d89ccb3e080dd90c0bfa'
    fi
    [ "$(checksum "$S/$ADAPTER_FILE")" = "$ADAPTER_EXPECTED_SHA" ] || fail 'autoABC MKV adapter checksum differs'
else
    fail 'unknown/symlinked jb_overlay setup'
fi
# Pin the recognized foreign boot wrapper before checking firmware and staging.
if [ -n "$MKV_KNOWN_VERSION" ]; then
    MKV_BOOT_SHA="$MKV_CHECKED_SHA"
    echo "MKV_WRAPPER=VERIFIED VERSION=$MKV_KNOWN_VERSION SHA256=$MKV_BOOT_SHA"
fi
echo "BOOT_MODE=$MODE BOOT_CHAIN=${BOOT_CHAIN:-MKV_ONLY} BOOT_OWNER=VERIFIED"
# Code signatures are checked against the LIVE running player, before any persistent write.
P_COUNT=0; PLAYER_PID=''
for PP in /proc/[0-9]*; do
    [ -r "$PP/comm" ] || continue
    if [ "$(cat "$PP/comm" 2>/dev/null)" = bdpprog.1 ]; then P_COUNT=$((P_COUNT+1)); PLAYER_PID="${PP##*/}"; fi
done
[ "$P_COUNT" = 1 ] || fail "expected one running bdpprog.1; found $P_COUNT"
[ -r "/proc/$PLAYER_PID/mem" ] || fail 'cannot inspect running player memory'
firmware_sig(){
    "$BB" dd if="/proc/$PLAYER_PID/mem" of="$FW_TEMP" bs=1 skip="$1" count="$2" 2>/dev/null || return 1
    "$BB" cmp -s "$FW_TEMP" "$S/autoABC/hook/$3"
}
firmware_sig 198392 12 sig_access_plt_12.bin || fail 'unsupported player: access PLT'
firmware_sig 207180 12 sig_usleep_plt_12.bin || fail 'unsupported player: usleep PLT'
firmware_sig 10615650 20 sig_bdmv_real_ln_call.bin || fail 'unsupported player: BDMV call'
firmware_sig 29378036 26 sig_iso_mount.bin || fail 'unsupported player: ISO mount'
firmware_sig 2813888 16 sig_ngetpsr_16.bin || fail 'unsupported player: PSR20 getter'
rm -f "$FW_TEMP"
echo 'FIRMWARE_PREFLIGHT=PASS SIGNATURES=5'
if [ "$UOP" = 1 ]; then
    # A separate 12-byte read-only check of the proven UOPfree code site.
    firmware_sig 1386400 12 sig_uopfree_stock_code_12.bin || fail 'UOPfree unsupported player/code signature'
    echo 'UOPFREE_PREFLIGHT=PASS SIGNATURES=1 (RAM NOT WRITTEN)'
else
    echo 'UOPFREE_PREFLIGHT=DISABLED'
fi
# CHECKONLY-ONLY BUILD: NO INSTALL, ACTIVATION OR PERSISTENT ROLLBACK CODE.
[ -f "$S/CHECKONLY" ] && [ ! -L "$S/CHECKONLY" ] || fail 'READONLY marker missing'
echo "CHECKONLY=PASS MODE=$MODE EARLYBOOT=$EARLY"
write_result COMPATIBLE "Read-only 1.1.1 compatibility passed ($MODE, MKV=${MKV_KNOWN_VERSION:-none}). Nothing installed."
cleanup
exit 0
