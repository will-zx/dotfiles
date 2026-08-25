#!/usr/bin/env bash
set -euo pipefail

choice=$(printf "Matikan (Shutdown)\nRestart\nLogout\nBatal" | rofi -dmenu -p "Power Menu" -i -lines 4 -no-custom)

case "$choice" in
  "Matikan (Shutdown)")
    notify-send -t 2000 "Power" "Shutdown... babay 👋"
    loginctl poweroff 2>/dev/null || openrc-shutdown --poweroff 2>/dev/null || poweroff
    ;;
  "Restart")
    notify-send -t 2000 "Power" "Restart..."
    loginctl reboot 2>/dev/null || openrc-shutdown --reboot 2>/dev/null || reboot
    ;;
  "Logout")
    swaymsg exit
    ;;
  *)
    exit 0
    ;;
esac
