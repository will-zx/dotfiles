#!/bin/bash
# Waybar custom network module — auto-switch WiFi/Ethernet

get_wifi() {
    local line ssid signal
    line=$(nmcli -t -f IN-USE,SSID,SIGNAL dev wifi list 2>/dev/null | grep '^\*:' | head -1)
    [ -z "$line" ] && return 1
    ssid=$(echo "$line" | cut -d: -f2)
    signal=$(echo "$line" | cut -d: -f3)
    [ -z "$ssid" ] && return 1

    if   [ "$signal" -ge 80 ]; then icon="󰤨"
    elif [ "$signal" -ge 60 ]; then icon="󰤥"
    elif [ "$signal" -ge 40 ]; then icon="󰤢"
    else                             icon="󰤟"
    fi

    printf '{"text":"%s  %s%%","tooltip":"WiFi: %s (%s%%)","class":"wifi"}\n' "$icon" "$signal" "$ssid" "$signal"
}

get_ethernet() {
    local dev
    dev=$(nmcli -t -f DEVICE,TYPE,STATE dev status 2>/dev/null | awk -F: '$2=="ethernet" && $3=="connected"{print $1; exit}')
    [ -z "$dev" ] && return 1

    printf '{"text":"󰗹  %s","tooltip":"Ethernet: %s","class":"ethernet"}\n' "$dev" "$dev"
}

# priority: wifi > ethernet > disconnected
if get_wifi; then
    exit 0
elif get_ethernet; then
    exit 0
else
    printf '{"text":"󰤭  disconnected","tooltip":"No network — click to connect","class":"disconnected"}\n'
fi
