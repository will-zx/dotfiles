#!/usr/bin/env bash
# Toggle display: laptop only <-> mirror external (Sway/Wayland)

INTERNAL="eDP-1"

get_external() {
    swaymsg -t get_outputs | python3 -c "
import sys, json
for o in json.load(sys.stdin):
    if o.get('name') != '$INTERNAL' and o.get('active'):
        print(o['name'])
        break
"
}

EXTERNAL=$(get_external)

if [ -z "$EXTERNAL" ]; then
    notify-send "Display" "Tidak ada display eksternal terdeteksi"
    exit 0
fi

# Cek apakah external sedang aktif (bits >= 2 artinya aktif dengan resolusi)
# swaymsg output state sederhana: cek active langsung via get_outputs
EXT_ACTIVE=$(swaymsg -t get_outputs | python3 -c "
import sys, json
for o in json.load(sys.stdin):
    if o.get('name') == '$EXTERNAL':
        print('yes' if o.get('active') and o.get('current_mode') else 'no')
        break
")

if [ "$EXT_ACTIVE" = "yes" ]; then
    # External aktif → matikan, kembali ke laptop only
    swaymsg output "$EXTERNAL" disable
    swaymsg output "$INTERNAL" enable position 0 0
    notify-send "Display" "Switch ke laptop only"
else
    # External tidak aktif → mirror
    swaymsg output "$EXTERNAL" enable position 0 0
    swaymsg output "$INTERNAL" position 0 0
    notify-send "Display" "Mirror: $EXTERNAL"
fi
