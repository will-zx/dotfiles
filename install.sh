#!/bin/bash
set -euo pipefail

DOTFILES="$(cd "$(dirname "$0")" && pwd)"
XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"

link() {
    local src="$1" dst="$2"
    if [ -L "$dst" ]; then
        rm "$dst"
    elif [ -e "$dst" ]; then
        echo "  backing up $dst → ${dst}.bak"
        mv "$dst" "${dst}.bak"
    fi
    mkdir -p "$(dirname "$dst")"
    ln -sf "$src" "$dst"
    echo "  linked $dst → $src"
}

echo "=== Installing dotfiles ==="

# Sway
link "$DOTFILES/sway/config"       "$XDG_CONFIG_HOME/sway/config"
link "$DOTFILES/sway/scripts"      "$XDG_CONFIG_HOME/sway/scripts"

# Waybar
link "$DOTFILES/waybar/config.jsonc" "$XDG_CONFIG_HOME/waybar/config.jsonc"
link "$DOTFILES/waybar/style.css"    "$XDG_CONFIG_HOME/waybar/style.css"
link "$DOTFILES/waybar/scripts"      "$XDG_CONFIG_HOME/waybar/scripts"

# Swaylock
link "$DOTFILES/swaylock/config"   "$XDG_CONFIG_HOME/swaylock/config"

# Mako
link "$DOTFILES/mako/config"       "$XDG_CONFIG_HOME/mako/config"

# Rofi
link "$DOTFILES/rofi/config.rasi"  "$XDG_CONFIG_HOME/rofi/config.rasi"
link "$DOTFILES/rofi/themes"       "$XDG_CONFIG_HOME/rofi/themes"

# GTK
link "$DOTFILES/gtkrc-2.0"         "$HOME/.gtkrc-2.0"
link "$DOTFILES/gtk-3.0/settings.ini" "$XDG_CONFIG_HOME/gtk-3.0/settings.ini"

echo ""
echo "Done. Reload sway: \$mod+Shift+c"
