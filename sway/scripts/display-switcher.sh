#!/usr/bin/env bash
# Display mode switcher untuk Sway (Wayland/swaymsg)
# Menggantikan versi i3/xrandr yang hanya jalan di X11.

INTERNAL="eDP-1"

get_external() {
    # Ambil output aktif yang bukan internal
    swaymsg -t get_outputs | python3 -c "
import sys, json
for o in json.load(sys.stdin):
    if o.get('name') != '$INTERNAL' and o.get('active'):
        print(o['name'])
        break
"
}

notify() {
    notify-send "Display" "$1"
}

EXTERNAL=$(get_external)

if [ -z "$EXTERNAL" ]; then
    swaymsg output "$INTERNAL" enable mode --get-preferred
    notify "Tidak ada display eksternal, hanya laptop"
    exit 0
fi

case "$1" in
    "mirror")
        swaymsg output "$EXTERNAL" mode --get-preferred
        swaymsg output "$EXTERNAL" enable
        # Sway tidak punya 'same-as'; gunakan posisi yang sama (atas kiri)
        swaymsg output "$EXTERNAL" position 0 0
        swaymsg output "$INTERNAL" position 0 0
        notify "Mirror ke $EXTERNAL"
        ;;
    "extend-right")
        swaymsg output "$EXTERNAL" enable mode --get-preferred
        swaymsg output "$EXTERNAL" position 1920 0
        swaymsg output "$INTERNAL" enable mode --get-preferred position 0 0
        notify "Extend ke kanan: $EXTERNAL"
        ;;
    "extend-left")
        swaymsg output "$EXTERNAL" enable mode --get-preferred
        swaymsg output "$INTERNAL" position 1920 0
        swaymsg output "$EXTERNAL" position 0 0
        notify "Extend ke kiri: $EXTERNAL"
        ;;
    "external-only")
        swaymsg output "$INTERNAL" disable
        swaymsg output "$EXTERNAL" enable mode --get-preferred position 0 0
        notify "Proyektor only: $EXTERNAL"
        ;;
    "internal-only")
        swaymsg output "$EXTERNAL" disable
        swaymsg output "$INTERNAL" enable mode --get-preferred position 0 0
        notify "Laptop only"
        ;;
    *)
        swaymsg output "$EXTERNAL" mode --get-preferred
        swaymsg output "$EXTERNAL" enable
        swaymsg output "$EXTERNAL" position 0 0
        swaymsg output "$INTERNAL" position 0 0
        notify "Auto Mirror ke $EXTERNAL"
        ;;
esac
