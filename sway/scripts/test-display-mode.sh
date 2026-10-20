#!/usr/bin/env bash
# Uji logika display-mode.sh tanpa sway sungguhan: pakai swaymsg/notify-send
# palsu di PATH. Jalankan: ./test-display-mode.sh
set -u

DIR=$(cd "$(dirname "$0")" && pwd)
TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT
export PATH="$TMP:$PATH"

printf '#!/bin/sh\nexit 0\n' > "$TMP/notify-send"
chmod +x "$TMP/notify-send"

# stub <output_workspace_terfokus> <hdmi_aktif: true|false>
stub() {
    cat > "$TMP/swaymsg" <<EOF
#!/usr/bin/env bash
case "\$*" in
*get_workspaces*)
    echo '[{"name":"6","output":"$1","focused":true,"visible":true}]' ;;
*get_outputs*)
    echo '[{"name":"eDP-1","active":true,"current_mode":{"width":1920,"height":1080,"refresh":144003}},
           {"name":"HDMI-A-1","active":$2,"current_mode":{"width":1360,"height":768,"refresh":60015}}]' ;;
*)
    echo "\$*" >> "$TMP/log" ;;
esac
EOF
    chmod +x "$TMP/swaymsg"
}

# cek <nama> <harusan_ada> <harus_tidak_ada>
cek() {
    : > "$TMP/log"
    "$DIR/display-mode.sh" "$MODE" >/dev/null 2>&1
    if grep -qxF "$2" "$TMP/log" && ! grep -qF "$3" "$TMP/log"; then
        echo "ok   - $1"
    else
        echo "FAIL - $1 (perintah: $(tr '\n' '|' < "$TMP/log"))"
        exit 1
    fi
}

# --- mode: workspace-toggle ---------------------------------------------
MODE=workspace-toggle
stub eDP-1 true
cek "workspace di laptop, HDMI nyala -> pindah tanpa re-enable" \
    "move workspace to output HDMI-A-1" "output HDMI-A-1 enable"

stub HDMI-A-1 true
cek "workspace di HDMI -> balik ke laptop" \
    "move workspace to output eDP-1" "output HDMI-A-1 enable"

stub eDP-1 false
cek "HDMI mati -> tidak ada output eksternal, toggle jadi no-op" \
    "output eDP-1 enable" "move workspace to output HDMI-A-1"

# --- mode: mirror --------------------------------------------------------
MODE=mirror
stub eDP-1 true
cek "mirror -> kedua output di posisi 0 0" \
    "output HDMI-A-1 position 0 0" "move workspace to output"

# --- mode: laptop --------------------------------------------------------
MODE=laptop
stub eDP-1 true
cek "laptop -> output eksternal dimatikan" \
    "output HDMI-A-1 disable" "output HDMI-A-1 position"

echo "semua cek lolos"
