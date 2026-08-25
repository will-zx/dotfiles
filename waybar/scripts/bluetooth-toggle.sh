#!/bin/bash
# Waybar bluetooth: toggle adapter power

if bluetoothctl show | grep -q "Powered: yes"; then
    bluetoothctl power off
else
    bluetoothctl power on
fi
