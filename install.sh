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

# Kitty
link "$DOTFILES/kitty/kitty.conf"  "$XDG_CONFIG_HOME/kitty/kitty.conf"

# GTK
link "$DOTFILES/gtkrc-2.0"         "$HOME/.gtkrc-2.0"
link "$DOTFILES/gtk-3.0/settings.ini" "$XDG_CONFIG_HOME/gtk-3.0/settings.ini"
link "$DOTFILES/gtk-3.0/bookmarks"    "$XDG_CONFIG_HOME/gtk-3.0/bookmarks"
link "$DOTFILES/gtk-4.0/settings.ini" "$XDG_CONFIG_HOME/gtk-4.0/settings.ini"

# Qt (qt5ct / qt6ct)
link "$DOTFILES/qt5ct/qt5ct.conf"  "$XDG_CONFIG_HOME/qt5ct/qt5ct.conf"
link "$DOTFILES/qt6ct/qt6ct.conf"  "$XDG_CONFIG_HOME/qt6ct/qt6ct.conf"

# Environment (systemd-user)
link "$DOTFILES/environment.d/desktop.conf" "$XDG_CONFIG_HOME/environment.d/desktop.conf"

# macOS-White cursor theme → shared icons
mkdir -p "$HOME/.local/share/icons"
if [ -e "$HOME/.local/share/icons/macOS-White" ] && [ ! -L "$HOME/.local/share/icons/macOS-White" ]; then
    echo "  backing up cursor theme → macOS-White.bak"
    mv "$HOME/.local/share/icons/macOS-White" "$HOME/.local/share/icons/macOS-White.bak"
fi
rm -f "$HOME/.local/share/icons/macOS-White"
ln -sf "$DOTFILES/macOS-White" "$HOME/.local/share/icons/macOS-White"
echo "  linked cursor theme → $HOME/.local/share/icons/macOS-White"

# LightDM greeter — butuh root, jadi pakai sudo (password diminta di titik ini).
#
# CATATAN: lightdm-gtk-greeter 2.0.9 memuat CSS dari dalam binary, bukan dari
# file .css terpisah. Styling greeter harus lewat GTK theme, jadi install.sh
# membangun theme turunan "Arc-Dark-Greeter" di /usr/share/themes/.
#
# sudo -v dipakai sekali: memvalidasi kredensial & meng-cache-nya, sehingga
# perintah sudo berikutnya tidak meminta password lagi. Kalau sudo gagal atau
# dibatalkan, install tetap lanjut (tidak abort).
GREETER_THEME="Arc-Dark-Greeter"
ARC_DARK_THEME_DIR="/usr/share/themes/Arc-Dark/gtk-3.0"
GREETER_THEME_DIR="/usr/share/themes/$GREETER_THEME"

install_greeter_theme() {
    local dst="$1"

    # Theme turunan wajib menyalin gtk.gresource Arc-Dark; tanpa itu resource
    # /org/gnome/arc-theme/... tidak resolve dan @import di gtk.css gagal.
    if [ ! -f "$ARC_DARK_THEME_DIR/gtk.gresource" ]; then
        echo "  [skip] theme greeter: theme Arc-Dark tidak ditemukan"
        echo "         (pasang Arc-Dark dulu: https://github.com/jnsh/arc-theme)"
        return 1
    fi

    sudo install -d -m755 "$dst/gtk-3.0"
    sudo install -m644 "$ARC_DARK_THEME_DIR/gtk.gresource" "$dst/gtk-3.0/gtk.gresource"
    sudo install -m644 "$DOTFILES/lightdm/gtk.css" "$dst/gtk-3.0/gtk.css"
    sudo install -m644 "$DOTFILES/lightdm/gtk.css" "$dst/gtk-3.0/gtk-dark.css"
    sudo install -m644 "$DOTFILES/lightdm/index.theme" "$dst/index.theme"
    return 0
}

if [ "$(id -u)" -eq 0 ]; then
    # Sudah root: tidak perlu sudo.
    if install_greeter_theme "$GREETER_THEME_DIR"; then
        install -Dm644 "$DOTFILES/lightdm/lightdm-gtk-greeter.conf" \
            /etc/lightdm/lightdm-gtk-greeter.conf
        echo "  installed lightdm greeter theme + config"
    fi
elif command -v sudo >/dev/null 2>&1; then
    echo "  lightdm greeter butuh root — diminta password sekarang:"
    if sudo -v; then
        if install_greeter_theme "$GREETER_THEME_DIR"; then
            sudo install -Dm644 "$DOTFILES/lightdm/lightdm-gtk-greeter.conf" \
                /etc/lightdm/lightdm-gtk-greeter.conf
            echo "  installed lightdm greeter theme + config"
        fi
    else
        echo "  [skip] lightdm greeter (sudo gagal / dibatalkan)"
    fi
else
    echo "  [skip] lightdm greeter (sudo tidak tersedia)"
    echo "         jalankan manual: sudo ./install.sh"
fi

echo ""
echo "Done. Reload sway: \$mod+Shift+c"
echo "Reload env: systemctl --user import-environment; " \
     "logind configure-editor or re-login needed for environment.d"
