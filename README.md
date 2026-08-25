# Dotfiles

Swaywm dotfiles.

## Dependencies

### Core

| Package | Description |
|---|---|
| `sway` | Wayland tiling window manager |
| `swayidle` | Idle management (auto-lock, DPMS) |
| `swaylock` | Screen locker |
| `swaybg` | Wallpaper setter |

### Bar & UI

| Package | Description |
|---|---|
| `waybar` | Status bar (clock, audio, battery, network, etc.) |
| `rofi` | Application launcher and menu |
| `mako` | Notification daemon |
| `kitty` | Terminal emulator |

### Screenshot & Clipboard

| Package | Description |
|---|---|
| `grim` | Screenshot tool for Wayland |
| `slurp` | Region selection for screenshots |
| `wl-clipboard` | Wayland clipboard utilities (`wl-copy`, `wl-paste`) |
| `cliphist` | Clipboard history manager |

### Audio

| Package | Description |
|---|---|
| `pavucontrol` | PulseAudio volume control GUI |

### Hardware & System

| Package | Description |
|---|---|
| `brightnessctl` | Backlight brightness control |
| `polkit-gnome` | Authentication dialog for privilege escalation |
| `blueman` | Bluetooth manager |
| `network-manager-applet` | NetworkManager tray applet |
| `arandr` | GUI display configuration (mirror/extend) |
| `gnome-calculator` | Calculator |

### Desktop Integration

| Package | Description |
|---|---|
| `xdg-desktop-portal` | Desktop portal backend |
| `xdg-desktop-portal-gtk` | GTK desktop portal frontend |
| `python3` | Required by waybar network-speed script |

### Theme & Fonts

| Package | Description |
|---|---|
| `arc-gtk-theme` | GTK theme (Arc-Dark) |
| `papirus-icon-theme` | Icon theme (Papirus-Dark) |
| `ttf-nerd-fonts-symbols` | Icons for waybar and rofi |
| `noto-fonts` | Base font family |

```bash
sudo pacman -S sway swayidle swaylock swaybg waybar mako rofi kitty \
  grim slurp wl-clipboard cliphist pavucontrol brightnessctl \
  polkit-gnome blueman network-manager-applet arandr gnome-calculator \
  xdg-desktop-portal xdg-desktop-portal-gtk python3 \
  arc-gtk-theme papirus-icon-theme ttf-nerd-fonts-symbols noto-fonts
```

## Install

```bash
git clone https://github.com/will-zx/dotfiles.git ~/dotfiles
cd ~/dotfiles
chmod +x install.sh
./install.sh
```

## Uninstall

```bash
cd ~/dotfiles
./uninstall.sh
```

## Keybindings

`$mod` = `Super` (Windows key)

### General

| Key | Action |
|---|---|
| `$mod+Return` | Open terminal (kitty) |
| `$mod+d` | App launcher (rofi) |
| `$mod+Escape` | Lock screen |
| `$mod+Shift+x` | Power menu (shutdown/restart/logout) |
| `$mod+Shift+q` | Close window |
| `$mod+Shift+e` | Exit sway |
| `$mod+Shift+c` | Reload config |
| `$mod+Shift+r` | Restart sway |

### Audio & Brightness

| Key | Action |
|---|---|
| `XF86AudioRaiseVolume` | Volume up |
| `XF86AudioLowerVolume` | Volume down |
| `XF86AudioMute` | Mute/unmute |
| `XF86AudioMicMute` | Mute/unmute microphone |
| `$mod+Shift+v` | Open audio mixer (pavucontrol) |
| `XF86MonBrightnessUp` | Brightness up |
| `XF86MonBrightnessDown` | Brightness down |

### Screenshot

| Key | Action |
|---|---|
| `Print` | Screenshot entire screen → clipboard |
| `$mod+Shift+Print` | Screenshot selection (slurp) → clipboard |

### Clipboard

| Key | Action |
|---|---|
| `$mod+Ctrl+v` | Clipboard history (cliphist → rofi) |

### Display Management

| Key | Action |
|---|---|
| `$mod+Shift+d` | Open display config GUI (arandr) |
| `$mod+Alt+d` | Toggle laptop ↔ mirror external |
| `$mod+F1` | Mirror to projector |
| `$mod+F2` | Extend right |
| `$mod+F3` | Extend left |
| `$mod+F4` | External display only |
| `$mod+F5` | Internal display only |
| `XF86Display` | Toggle laptop ↔ mirror (Fn key) |

### Window Focus

| Key | Action |
|---|---|
| `$mod+j/k/l/;` | Focus left/down/up/right |
| `$mod+arrows` | Focus left/down/up/right |
| `$mod+space` | Toggle focus (tiling ↔ floating) |
| `$mod+a` | Focus parent |

### Window Move

| Key | Action |
|---|---|
| `$mod+Shift+j/k/l/;` | Move window left/down/up/right |
| `$mod+Shift+arrows` | Move window left/down/up/right |

### Window Layout

| Key | Action |
|---|---|
| `$mod+h` | Split horizontal |
| `$mod+v` | Split vertical |
| `$mod+f` | Fullscreen toggle |
| `$mod+Shift+space` | Toggle tiling/floating |
| `$mod+s` | Stacked layout |
| `$mod+w` | Tabbed layout |
| `$mod+e` | Toggle split layout |

### Resize Mode

Press `$mod+r` to enter resize mode, then:

| Key | Action |
|---|---|
| `j/Left` | Shrink width |
| `l/Up` | Shrink height |
| `k/Down` | Grow height |
| `;/Right` | Grow width |
| `Return/Escape/$mod+r` | Exit resize mode |

### Workspaces

| Key | Action |
|---|---|
| `$mod+1-0` | Switch to workspace 1-10 |
| `$mod+Shift+1-0` | Move window to workspace 1-10 |

## Structure

```
dotfiles/
├── install.sh
├── uninstall.sh
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
