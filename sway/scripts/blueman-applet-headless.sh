#!/bin/bash
# Jalankan blueman-applet (dibutuhkan blueman-manager) TANPA ikon tray.
# blueman-tray (ikon tray) di-spawn ulang oleh applet pada event tertentu,
# jadi kita kill terus menerus selama applet masih hidup.

blueman-applet &
sleep 1
pkill -x blueman-tray 2>/dev/null

while pgrep -x blueman-applet >/dev/null 2>&1; do
    pkill -x blueman-tray 2>/dev/null
    sleep 5
done
