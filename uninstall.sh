#!/bin/bash
set -euo pipefail

XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"

echo "=== Uninstall dotfiles ==="
echo ""
echo "This will remove all symlinks created by install.sh"
echo "and restore .bak backups if they exist."
echo ""

read -rp "Continue? [y/N] " confirm
[[ "$confirm" =~ ^[yY]$ ]] || { echo "Aborted."; exit 0; }

echo ""

unlink_or_restore() {
    local dst="$1"
    if [ -L "$dst" ]; then
        rm "$dst"
        echo "  removed symlink $dst"
        if [ -e "${dst}.bak" ]; then
            mv "${dst}.bak" "$dst"
            echo "  restored ${dst}.bak → $dst"
        fi
    elif [ -e "$dst" ] && [ -e "${dst}.bak" ]; then
        rm "$dst"
        mv "${dst}.bak" "$dst"
        echo "  restored ${dst}.bak → $dst"
    else
        echo "  skipped $dst (not a symlink)"
    fi
}

# Sway
unlink_or_restore "$XDG_CONFIG_HOME/sway/config"
unlink_or_restore "$XDG_CONFIG_HOME/sway/scripts"

# Waybar
unlink_or_restore "$XDG_CONFIG_HOME/waybar/config.jsonc"
unlink_or_restore "$XDG_CONFIG_HOME/waybar/style.css"
unlink_or_restore "$XDG_CONFIG_HOME/waybar/scripts"

# Swaylock
unlink_or_restore "$XDG_CONFIG_HOME/swaylock/config"

# Mako
unlink_or_restore "$XDG_CONFIG_HOME/mako/config"

# Rofi
unlink_or_restore "$XDG_CONFIG_HOME/rofi/config.rasi"
unlink_or_restore "$XDG_CONFIG_HOME/rofi/themes"

# GTK
unlink_or_restore "$HOME/.gtkrc-2.0"
unlink_or_restore "$XDG_CONFIG_HOME/gtk-3.0/settings.ini"

echo ""
echo "Done. Reload sway or log out to apply."
