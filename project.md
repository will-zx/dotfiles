# Proyek Dotfiles

Konfigurasi dotfiles untuk **SwayWM (Wayland)** di Arch Linux, dikelola dengan symlink.

## Ringkasan

Proyek ini berisi semua file konfigurasi desktop pengguna, dibuat agar tersinkron dengan sistem melalui symlink (bukan copy). Dipasang/dilepas lewat `install.sh` / `uninstall.sh`.

**Stack desktop:**

| Komponen | Aplikasi |
|---|---|
| WM | sway (tiling, Wayland) |
| Bar | waybar |
| Launcher | rofi |
| Notifikasi | mako |
| Terminal | kitty |
| Wallpaper | sway (native `output * bg`) |
| Display manager | lightdm + lightdm-gtk-greeter |
| Theme GTK | Arc-Dark (dark) |
| Icon theme | Papirus-Dark |
| Cursor | macOS-White |
| QT style | qt5ct / qt6ct |

> Auto-lock & idle timeout **dimatikan** (swayidle/swaylock tidak dipakai).

## Struktur

```
dotfiles/
├── install.sh          # pasang (symlink) semua konfigurasi
├── uninstall.sh        # hapus symlink + restore *.bak
├── .gitignore
├── environment.d/
│   └── desktop.conf    # env var systemd-user (XDG_CURRENT_DESKTOP, dll)
├── gtk-3.0/
│   ├── settings.ini    # tema GTK3 Arc-Dark, font Ubuntu, cursor macOS-White
│   └── bookmarks       # bookmark file manager
├── gtk-4.0/
│   └── settings.ini    # tema GTK4
├── gtkrc-2.0           # tema GTK2
├── kitty/
│   └── kitty.conf      # terminal kitty
├── lightdm/
│   ├── lightdm-gtk-greeter.conf   # greeter (tema, font SF Pro, clock)
│   └── lightdm-gtk-greeter.css    # styling Arc-Dark untuk greeter
├── macOS-White/        # tema cursor (kursor putih ala macOS)
│   ├── index.theme
│   ├── cursor.theme
│   └── cursors/        # banyak file cursor (X11 + Wayland)
├── mako/
│   └── config          # notifikasi daemon
├── qt5ct/
│   └── qt5ct.conf      # styling QT5
├── qt6ct/
│   └── qt6ct.conf      # styling QT6
├── rofi/
│   ├── config.rasi     # launcher config
│   └── themes/
│       └── polybar-arc.rasi
├── sway/
│   ├── config          # konfigurasi utama sway (keybind, workspace, display)
│   └── scripts/        # helper scripts
│       ├── blueman-applet-headless.sh   # applet bluetooth
│       ├── display-mode.sh              # mode layar: mirror / extend / laptop
│       ├── display-toggle.sh            # toggle laptop <-> mirror
│       ├── power-menu.sh                # shutdown/restart/logout (rofi)
│       ├── restart-desktop.sh           # restart helper services + reload
│       └── test-display-mode.sh         # unit test display-mode.sh
├── swaylock/
│   └── config          # screenlock
├── waybar/
│   ├── config.jsonc    # modul waybar (clock, audio, baterai, network)
│   ├── style.css       # styling waybar (Arc-Dark)
│   └── scripts/        # helper scripts
│       ├── bluetooth.sh
│       ├── bluetooth-toggle.sh
│       ├── network.sh
│       ├── network-menu.sh
│       └── network-speed.py            # kecepatan jaringan (butuh python3)
└── README.md
```

## Pemetaan Symlink

`install.sh` membuat symlink dari file di repo ke lokasi sistem:

| File di repo | Lokasi sistem |
|---|---|
| `sway/config`, `sway/scripts` | `~/.config/sway/{config,scripts}` |
| `waybar/config.jsonc`, `style.css`, `scripts` | `~/.config/waybar/…` |
| `swaylock/config` | `~/.config/swaylock/config` |
| `mako/config` | `~/.config/mako/config` |
| `rofi/config.rasi`, `rofi/themes` | `~/.config/rofi/…` |
| `kitty/kitty.conf` | `~/.config/kitty/kitty.conf` |
| `gtkrc-2.0` | `~/.gtkrc-2.0` |
| `gtk-3.0/settings.ini`, `bookmarks` | `~/.config/gtk-3.0/…` |
| `gtk-4.0/settings.ini` | `~/.config/gtk-4.0/settings.ini` |
| `qt5ct/qt5ct.conf` | `~/.config/qt5ct/qt5ct.conf` |
| `qt6ct/qt6ct.conf` | `~/.config/qt6ct/qt6ct.conf` |
| `environment.d/desktop.conf` | `~/.config/environment.d/desktop.conf` |
| `macOS-White` | `~/.local/share/icons/macOS-White` |

> **lightdm** tidak dipasang via symlink (butuh root). `install.sh`
> otomatis memasang `lightdm-gtk-greeter.conf` + `lightdm-gtk-greeter.css`
> ke `/etc/lightdm/` bila dijalankan sebagai root; kalau tidak, skrip
> menampilkan perintahnya untuk dijalankan manual dengan `sudo`.
> Ubah path `background=` sesuai wallpaper user.

Untuk file yang sudah ada di sistem saat install, `install.sh` otomatis
membackup-nya menjadi `*.bak` (misal `settings.ini.bak`), dan `uninstall.sh`
me-restore-nya.

## Install

```bash
git clone https://github.com/will-zx/dotfiles.git ~/dotfiles
cd ~/dotfiles
chmod +x install.sh
./install.sh
```

Dependensi lengkap (paket pacman) ada di `README.md`, termasuk Arc-Dark yang
harus dibuild dari source (fork `jnsh/arc-theme`) karena mendukung GTK4.

## Uninstall

```bash
cd ~/dotfiles
./uninstall.sh
```

## Catatan Teknis

- **Display multi-monitor** di-handle dengan `swaymsg` + `python3` (parsing
  `get_outputs`), bukan xrandr, karena ini murni Wayland. Internal display
  diasumsikan bernama `eDP-1`; external terdeteksi otomatis.
  Tiga mode (lihat `sway/scripts/display-mode.sh`):
  - `mirror` (`$mod+F4`) — semua workspace tampil identik di kedua layar.
    sway 1.12 **tidak** punya perintah `output ... mirror`; mirror
    dicapai dengan menaruh kedua output pada posisi `(0,0)` dan resolusi
    yang sama. Diverifikasi: hasil tangkapan layar kedua output identik
    100% (0% piksel beda).
  - `extend` (`$mod+F5`) — workspace 1-5 di panel internal, 6-10 di
    layar eksternal. Pemetaan dipakai lewat perintah sway
    `workspace <n> output <output>` (sway(5)), lalu workspace yang sudah
    ada dipindah dengan `move workspace to output`.
  - `laptop` (`$mod+F6`) — batalkan mirror & extend; layar eksternal
    dimatikan dan semua workspace kembali ke panel internal.
  - `workspace-toggle` (`$mod+Shift+F4`) — pindahkan workspace aktif saja.
- **Jangan pakai `workspace "<n>" output <output>` di `sway/config`.**
  Perintah itu bukan sekadar "pin", tapi juga memberi NAMA workspace
  pertama yang dibuat sway di output tersebut. Akibatnya sway boot
  langsung ke workspace "6" (bukan "1"). Karena itu pemetaan
  workspace→output dilakukan saat runtime lewat skrip, bukan di config.
- **sway menghapus workspace kosong** di sebuah output saat workspace
  terakhir dipindah dari sana (sway otomatis membuat workspace
  pengganti). Karena itu `extend` memindahkan workspace ke output
  eksternal lebih dulu, baru ke internal.
- **Lock screen & idle** sengaja dimatikan di `sway/config` (laptop
  tidak pernah ditinggal menyala). `swaylock/config` tetap ada di repo
  untuk dipakai nanti.
- **Screenshot** menggunakan `grim` + `slurp` → clipboard (`wl-copy`),
  riwayat clipboard via `cliphist` → rofi.
- **Power menu** (`$mod+Shift+x`) → rofi + swaymsg untuk shutdown/restart/logout.
- **environment.d** diproses saat login (systemd user), perubahan env baru
  efektif setelah re-login atau `systemctl --user import-environment`.
- **Font** greeter menggunakan `SF Pro Display`, sedangkan GTK menggunakan
  font `Ubuntu`; keduanya harus ter-install agar tidak jatuh ke fallback.