# Dotfiles

Swaywm dotfiles.

## Dependencies

### Core

| Package | Description |
|---|---|
| `sway` | Wayland tiling window manager |
| `swaybg` | Wallpaper setter |

> `swayidle` & `swaylock` **tidak** dipakai: auto-lock & idle timeout sengaja
> dimatikan di `sway/config`. `swaylock/config` tetap ada di repo bila
> ingin diaktifkan nanti.

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
| `gnome-calculator` | Calculator |

### Desktop Integration

| Package | Description |
|---|---|
| `xdg-desktop-portal` | Desktop portal backend |
| `xdg-desktop-portal-gtk` | GTK desktop portal frontend |
| `python3` | Required by waybar network-speed script |

### Theme & Fonts

| Package/Repo | Description |
|---|---|
| [jnsh/arc-theme](https://github.com/jnsh/arc-theme) | GTK 2/3/4 theme (Arc-Dark) — build from source, **not** in official repos |
| `papirus-icon-theme` | Icon theme (Papirus-Dark) |
| `ttf-nerd-fonts-symbols` | Icons for waybar and rofi |
| `ttf-ubuntu-font-family` | UI font (Ubuntu) |
| `ttf-jetbrains-mono` | Terminal font (kitty) |
| `noto-fonts` | Base font family |

```bash
sudo pacman -S sway waybar mako rofi kitty \
  grim slurp wl-clipboard cliphist pavucontrol brightnessctl \
  polkit-gnome blueman networkmanager network-manager-applet \
  gnome-calculator playerctl \
  xdg-desktop-portal xdg-desktop-portal-gtk python3 \
  papirus-icon-theme ttf-nerd-fonts-symbols noto-fonts \
  ttf-ubuntu-font-family ttf-jetbrains-mono \
  qt5ct qt6ct lightdm-gtk-greeter

# Arc-Dark build from source (jnsh fork, supports GTK4):
#   git clone --depth 1 https://github.com/jnsh/arc-theme /tmp/arc-theme
#   cd /tmp/arc-theme
#   meson setup --prefix=/usr -Dvariants=dark -Dthemes=gtk2,gtk3,gtk4 build/
#   ninja -C build/ && sudo meson install -C build/
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
| `$mod+Shift+x` | Power menu (shutdown/restart/logout) |
| `$mod+Shift+q` | Close window |
| `$mod+Shift+e` | Exit sway |
| `$mod+Shift+c` | Reload config |
| `$mod+Shift+r` | Restart komponen desktop (reload config + restart waybar/mako/cliphist) |

> **Catatan lock screen:** `$mod+Escape` (swaylock) dan idle timeout **tidak**
> diaktifkan di `sway/config` — sengaja, laptop tidak pernah ditinggal menyala.
> File `swaylock/config` tetap ada di repo untuk dipakai nanti, tapi paket
> `swaylock` tidak perlu terinstal.

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

Tiga mode tampilan layar, dipilih lewat `sway/scripts/display-mode.sh`:

| Key | Mode | Arti |
|---|---|---|
| `$mod+F4` | **mirror** | Semua workspace tampil identik di kedua layar (kedua output di posisi & resolusi yang sama) |
| `$mod+F5` | **extend** | Workspace 1-5 di panel laptop, workspace 6-10 di layar eksternal |
| `$mod+F6` | **laptop** | Batalkan mirror & extend — layar eksternal dimatikan, semua workspace kembali ke laptop |

| Key | Action |
|---|---|
| `$mod+Shift+F4` | Workspace aktif pindah ke layar lain (tekan 2x = balik) |
| `$mod+Shift+d` | Toggle laptop ↔ mirror external |
| `$mod+Alt+d` | Toggle laptop ↔ mirror external |
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
│       ├── display-mode.sh
│       ├── display-toggle.sh
│       ├── power-menu.sh
│       ├── restart-desktop.sh
│       └── test-display-mode.sh
├── waybar/
│   ├── config.jsonc
│   ├── style.css
│   └── scripts/
│       ├── bluetooth.sh
│       ├── bluetooth-toggle.sh
│       ├── network.sh
│       ├── network-menu.sh
│       └── network-speed.py
├── kitty/kitty.conf
├── swaylock/config
├── mako/config
├── rofi/
│   ├── config.rasi
│   └── themes/polybar-arc.rasi
├── lightdm/
│   ├── lightdm-gtk-greeter.conf
│   └── lightdm-gtk-greeter.css
├── macOS-White/          # cursor theme (symlink ke ~/.local/share/icons)
├── gtk-3.0/
│   ├── settings.ini
│   └── bookmarks
├── gtk-4.0/settings.ini
├── qt5ct/qt5ct.conf
├── qt6ct/qt6ct.conf
├── environment.d/desktop.conf
├── project.md
└── gtkrc-2.0
```
