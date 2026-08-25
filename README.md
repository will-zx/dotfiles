# Dotfiles

Swaywm dotfiles

## Packages needed

```bash
sudo pacman -S sway swayidle swaylock swaybg waybar mako rofi grim slurp \
  wl-clipboard cliphist brightnessctl pavucontrol blueman polkit-gnome \
  network-manager-applet arandr gnome-calculator kitty \
  xdg-desktop-portal xdg-desktop-portal-gtk python3 \
  arc-gtk-theme papirus-icon-theme ttf-nerd-fonts-symbols noto-fonts
```

## Install

```bash
git clone https://github.com/<username>/dotfiles.git ~/dotfiles
cd ~/dotfiles
chmod +x install.sh
./install.sh
```

## Structure

```
dotfiles/
├── install.sh            # Symlink installer
├── sway/
│   ├── config
│   └── scripts/
│       ├── blueman-applet-headless.sh
│       ├── display-switcher.sh
│       ├── display-toggle.sh
│       └── power-menu.sh
├── waybar/
│   ├── config.jsonc
│   ├── style.css
│   └── scripts/
│       ├── bluetooth.sh
│       ├── bluetooth-toggle.sh
│       ├── network.sh
│       ├── network-menu.sh
│       └── network-speed.py
├── swaylock/config
├── mako/config
├── rofi/
│   ├── config.rasi
│   └── themes/polybar-arc.rasi
└── gtk-3.0/settings.ini
```
