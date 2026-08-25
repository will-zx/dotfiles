#!/usr/bin/env bash
# Toggle display: laptop only <-> mirror external
INTERNAL="eDP-1"
EXTERNAL=$(xrandr | grep " connected" | grep -v "$INTERNAL" | awk '{print $1}')

if [ -z "$EXTERNAL" ]; then
    notify-send "Display" "Tidak ada display eksternal terdeteksi"
    exit 0
fi

if xrandr | grep -q "^$EXTERNAL connected [0-9]"; then
    xrandr --output "$EXTERNAL" --off --output "$INTERNAL" --primary --auto
    notify-send "Display" "Switch ke laptop only"
else
    RES=$(xrandr | grep -A 1 "^$EXTERNAL connected" | tail -1 | grep -oP '\d+x\d+' | head -1)
    [ -z "$RES" ] && RES="1920x1080"
    xrandr --output "$EXTERNAL" --mode "$RES" --same-as "$INTERNAL" --output "$INTERNAL" --mode "$RES" --primary
    notify-send "Display" "Mirror: $EXTERNAL ($RES)"
fi
