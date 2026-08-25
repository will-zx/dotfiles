#!/bin/bash
# Waybar bluetooth module (custom, bluetoothctl-based)

powered=$(bluetoothctl show 2>/dev/null | grep -c "Powered: yes")
if [ "$powered" -eq 0 ]; then
    printf '{"text":"%s","class":"off","tooltip":"Bluetooth mati"}\n' "󰂲"
    exit 0
fi

connected=$(bluetoothctl devices Connected 2>/dev/null)
if [ -n "$connected" ]; then
    name=$(printf '%s\n' "$connected" | head -1 | cut -d' ' -f3-)
    printf '{"text":"%s","class":"connected","tooltip":"Bluetooth: %s"}\n' "󰂴" "$name"
else
    printf '{"text":"%s","class":"on","tooltip":"Bluetooth aktif"}\n' "󰂯"
fi
