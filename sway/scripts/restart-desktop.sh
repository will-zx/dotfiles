#!/usr/bin/env bash
# Restart komponen desktop (helper services) + reload config sway.
#
# CATATAN: sway TIDAK mendukung restart compositor in-place seperti i3
# (perintah 'restart' tidak ada di sway 1.12, dan wlroots tidak
# menyediakan re-exec compositor). Jadi yang di-restart di sini adalah
# service helper: waybar, mako, blueman-applet, dan wl-paste/cliphist.
#
# Untuk restart sway penuh: $mod+Shift+e (exit) lalu login lagi.

set -u

# Helper yang mungkin sedang jalan, restart satu per satu.
restart_helper() {
    local name="$1" pattern="$2"
    shift 2

    pkill -f "$pattern" 2>/dev/null && sleep 0.3
    "$@" >/dev/null 2>&1 &
    disown 2>/dev/null || true
    echo "  restarted: $name"
}

echo "Restarting desktop helpers..."

# waybar — pakai LC_TIME id_ID supaya format tanggal Bahasa Indonesia.
restart_helper "waybar" "waybar" env LC_TIME=id_ID.UTF-8 waybar

# mako — notification daemon.
restart_helper "mako" "^mako$" mako

# blueman-applet —Bluetooth tray (headless, tanpa ikon tray).
restart_helper "blueman-applet" "blueman-applet" \
    "$HOME/.config/sway/scripts/blueman-applet-headless.sh"

# cliphist — wl-paste --watch menyimpan clipboard ke riwayat.
restart_helper "cliphist" "wl-paste --watch cliphist" \
    wl-paste --watch cliphist store

# Muat ulang config sway (termasuk perubahan keybinding).
if swaymsg reload >/dev/null 2>&1; then
    echo "  reloaded: sway config"
else
    echo "  GAGAL reload config sway" >&2
fi

echo "Selesai."
