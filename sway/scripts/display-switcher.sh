#!/usr/bin/env bash
# Display mode switcher untuk i3 (X11/xrandr)
INTERNAL="eDP-1"
EXTERNAL=$(xrandr | grep " connected" | grep -v "$INTERNAL" | awk '{print $1}')

notify() {
    notify-send "Display" "$1"
}

if [ -z "$EXTERNAL" ]; then
    xrandr --output "$INTERNAL" --auto --primary
    notify "Tidak ada display eksternal, hanya laptop"
    exit 0
fi

EXT_MODE=$(xrandr | grep -A 1 "^$EXTERNAL connected" | tail -1 | grep -oP '\d+x\d+' | head -1)
[ -z "$EXT_MODE" ] && EXT_MODE="1920x1080"

case "$1" in
    "mirror")
        xrandr --output "$INTERNAL" --mode "$EXT_MODE" --primary --output "$EXTERNAL" --mode "$EXT_MODE" --same-as "$INTERNAL"
        notify "Mirror ke $EXTERNAL ($EXT_MODE)"
        ;;
    "extend-right")
        xrandr --output "$INTERNAL" --auto --primary --output "$EXTERNAL" --auto --right-of "$INTERNAL"
        notify "Extend ke kanan: $EXTERNAL"
        ;;
    "extend-left")
        xrandr --output "$INTERNAL" --auto --primary --output "$EXTERNAL" --auto --left-of "$INTERNAL"
        notify "Extend ke kiri: $EXTERNAL"
        ;;
    "external-only")
        xrandr --output "$INTERNAL" --off --output "$EXTERNAL" --auto --primary
        notify "Proyektor only: $EXTERNAL"
        ;;
    "internal-only")
        xrandr --output "$INTERNAL" --auto --primary --output "$EXTERNAL" --off
        notify "Laptop only"
        ;;
    *)
        xrandr --output "$INTERNAL" --mode "$EXT_MODE" --primary --output "$EXTERNAL" --mode "$EXT_MODE" --same-as "$INTERNAL"
        notify "Auto Mirror ke $EXTERNAL ($EXT_MODE)"
        ;;
esac
