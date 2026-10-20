#!/bin/bash
# Waybar network menu: rofi + nmcli

pick_wifi() {
    local raw choice ssid sec wpa rsn pass out conn rc
    raw=$(nmcli -t -f IN-USE,SSID,SECURITY,WPA-FLAGS,RSN-FLAGS,SIGNAL dev wifi list --rescan yes 2>/dev/null)
    [ -z "$raw" ] && return
    # Catatan: nmcli -t meng-escape ':' sebagai '\:'. Field harus di-split
    # pada ':' yang TIDAK ter-escape, lalu di-unescape saat dipakai.
    choice=$(printf '%s\n' "$raw" | awk '
        function split_escaped(str, out,   i, c, cur, n) {
            n = 0; cur = ""
            for (i = 1; i <= length(str); i++) {
                c = substr(str, i, 1)
                if (c == "\\" && i < length(str)) {
                    cur = cur c substr(str, i + 1, 1)
                    i++
                    continue
                }
                if (c == ":") { out[++n] = cur; cur = ""; continue }
                cur = cur c
            }
            out[++n] = cur
            return n
        }
        function unescape(s) {
            gsub(/\\:/, ":", s)
            gsub(/\\\\/, "\\", s)
            return s
        }
        function label(s, w, r) {
            if (s == "--") return "open"
            if (tolower(w) ~ /802.1x/ || tolower(r) ~ /802.1x/) return s " ent"
            return s
        }
        {
            n = split_escaped($0, f)
            if (n < 6 || f[2] == "") next
            if (seen[f[2]]++) next
            ssid = unescape(f[2])
            printf "%s    [%s | %s%%]\n", ssid, label(f[3], f[4], f[5]), f[6]
        }' | rofi -dmenu -p "WiFi: ")
    [ -z "$choice" ] && return
    ssid=$(printf '%s\n' "$choice" | sed 's/    \[.*//')

    if nmcli -t -f NAME connection show | grep -qx "$ssid"; then
        out=$(nmcli dev wifi connect "$ssid" 2>&1); rc=$?
    else
        info=$(printf '%s\n' "$raw" | awk '
            function split_escaped(str, out,   i, c, cur, n) {
                n = 0; cur = ""
                for (i = 1; i <= length(str); i++) {
                    c = substr(str, i, 1)
                    if (c == "\\" && i < length(str)) {
                        cur = cur c substr(str, i + 1, 1)
                        i++
                        continue
                    }
                    if (c == ":") { out[++n] = cur; cur = ""; continue }
                    cur = cur c
                }
                out[++n] = cur
                return n
            }
            function unescape(s) {
                gsub(/\\:/, ":", s)
                gsub(/\\\\/, "\\", s)
                return s
            }
            {
                n = split_escaped($0, f)
                if (n < 6) next
                if (unescape(f[2]) == s) { print f[3] "|" f[4] "|" f[5]; exit }
            }' -v s="$ssid")
        sec=${info%%|*}
        wpa=${info#*|}; wpa=${wpa%%|*}
        rsn=${info##*|}
        if [ -n "$sec" ] && [ "$sec" != "--" ]; then
            if printf '%s' "$wpa$rsn" | grep -qi '802.1x'; then
                notify-send "Network" "Jaringan enterprise ($ssid) butuh konfigurasi manual.\nKlik kanan ikon jaringan > Edit Connections."
                return
            fi
            pass=$(rofi -dmenu -p "Password $ssid: " -password)
            [ -z "$pass" ] && return
            out=$(nmcli dev wifi connect "$ssid" password "$pass" 2>&1); rc=$?
        else
            out=$(nmcli dev wifi connect "$ssid" 2>&1); rc=$?
        fi
    fi

    if [ "$rc" -ne 0 ]; then
        notify-send -u critical "Network" "$out"
        return
    fi

    sleep 3
    conn=$(nmcli -t -f CONNECTIVITY general 2>/dev/null)
    case "$conn" in
        portal) notify-send "Network" "Terhubung ke $ssid, tapi butuh login di halaman web (captive portal)." ;;
        full)   notify-send "Network" "Terhubung ke $ssid." ;;
        *)      notify-send "Network" "$out" ;;
    esac
}

toggle_wifi() {
    if nmcli radio wifi | grep -q enabled; then
        nmcli radio wifi off
        notify-send "Network" "WiFi dimatikan"
    else
        nmcli radio wifi on
        notify-send "Network" "WiFi dinyalakan"
    fi
}

disconnect_wifi() {
    local dev
    dev=$(nmcli -t -f DEVICE,TYPE dev status | awk -F: '$2=="wifi"{print $1; exit}')
    [ -z "$dev" ] && { notify-send "Network" "Tidak ada interface WiFi"; return; }
    nmcli dev disconnect "$dev" 2>/dev/null
    notify-send "Network" "WiFi disconnected"
}

connected=$(nmcli -t -f NAME,TYPE con show --active | awk -F: '$2=="802-11-wireless"{print $1; exit}')
if [ -n "$connected" ]; then
    action=$(printf '%s\n' \
        "WiFi: $connected" \
        "Connect WiFi..." \
        "Disconnect WiFi" \
        "Toggle WiFi" \
        "Edit Connections..." | rofi -dmenu -p "Network: ")
else
    action=$(printf '%s\n' \
        "Connect WiFi..." \
        "Toggle WiFi" \
        "Edit Connections..." | rofi -dmenu -p "Network: ")
fi

case "$action" in
    "WiFi: "*) pick_wifi ;;
    "Connect WiFi...") pick_wifi ;;
    "Disconnect WiFi") disconnect_wifi ;;
    "Toggle WiFi") toggle_wifi ;;
    "Edit Connections...") nm-connection-editor ;;
esac
