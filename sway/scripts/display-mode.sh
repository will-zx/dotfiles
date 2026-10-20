#!/usr/bin/env bash
# Manajemen tampilan layar untuk sway.
#
# Tiga mode:
#   mirror  — semua workspace tampil identik di kedua layar.
#   extend  — mode multi layar: workspace 1-5 di panel internal,
#             workspace 6-10 di layar eksternal.
#   laptop  — batalkan mirror & extend; layar eksternal dimatikan,
#             semua workspace kembali ke panel internal.
#
# CATATAN sway:
#  - sway 1.12 tidak punya perintah 'output ... mirror'. 'Mirror' di
#    sini dicapai dengan menaruh kedua output pada posisi & resolusi
#    yang sama persis, sehingga sway me-render konten yang sama di
#    keduanya (terbukti: pixel identik 100%).
#  - Perintah 'workspace N output X' di config TIDAK dipakai di sini.
#    perintah itu membuat sway memakai nama workspace tersebut sebagai
#    workspace PERTAMA saat boot (terbukti: boot menghasilkan
#    workspace "6", bukan "1"), dan swayed bind 'workspace number N'
#    ke nama yang sama. Karena itu kita pakai 'move workspace to
#    output' saat runtime, yang tidak punya efek samping itu.

set -u

INTERNAL="${INTERNAL:-eDP-1}"

# Workspace 1..EXTEND_SPLIT di panel internal, sisanya di eksternal.
EXTEND_SPLIT=5
# Berapa banyak workspace yang dipakai di mode extend.
EXTEND_COUNT=10

STATE_FILE="${XDG_STATE_HOME:-$HOME/.local/state}/sway-display-mode"

notify() {
    notify-send "Display" "$1" 2>/dev/null || true
}

# Output eksternal = output aktif selain panel internal.
get_external() {
    swaymsg -t get_outputs 2>/dev/null | python3 -c "
import sys, json
for o in json.load(sys.stdin):
    if o.get('active') and o['name'] != '$INTERNAL':
        print(o['name'])
        break
"
}

# Resolusi panel internal (dipakai agar mirror benar-benar identik).
internal_mode() {
    swaymsg -t get_outputs 2>/dev/null | python3 -c "
import sys, json
for o in json.load(sys.stdin):
    if o['name'] == '$INTERNAL' and o.get('active'):
        m = o.get('current_mode') or {}
        if m.get('width'):
            print('%dx%d' % (m['width'], m['height']))
        break
"
}

# Lebar panel internal dalam px.
internal_width() {
    swaymsg -t get_outputs 2>/dev/null | python3 -c "
import sys, json
for o in json.load(sys.stdin):
    if o['name'] == '$INTERNAL' and o.get('active'):
        m = o.get('current_mode') or {}
        if m.get('width'):
            print(m['width'])
        break
"
}

# Workspace yang sedang difokus (dipulihkan setelah mode diganti).
focused_workspace() {
    swaymsg -t get_workspaces 2>/dev/null | python3 -c "
import sys, json
for w in json.load(sys.stdin):
    if w.get('focused'):
        print(w['name'])
        break
"
}

# Daftar nama workspace yang ada di output tertentu.
workspaces_of() {
    swaymsg -t get_workspaces 2>/dev/null | python3 -c "
import sys, json
for w in json.load(sys.stdin):
    if w['output'] == '$1':
        print(w['name'])
"
}

save_state() {
    mkdir -p "$(dirname "$STATE_FILE")"
    echo "$1" > "$STATE_FILE"
}

load_state() {
    [ -f "$STATE_FILE" ] && cat "$STATE_FILE" || echo ""
}

# --- MODE: mirror -------------------------------------------------------
# Kedua output aktif, posisi (0 0) & resolusi identik → sway merender
# konten yang sama di kedua layar.
mode_mirror() {
    local external mode name prev
    external=$(get_external)
    if [ -z "$external" ]; then
        notify "Tidak ada layar eksternal aktif"
        return 1
    fi

    mode=$(internal_mode)
    prev=$(focused_workspace)

    swaymsg output "$external" enable >/dev/null 2>&1
    # Resolusi identik → ukuran & rasio sama, tidak ada distorsi.
    [ -n "$mode" ] && swaymsg output "$external" mode "$mode" >/dev/null 2>&1
    # Skala identik supaya rendering tidak berbeda.
    swaymsg output "$external" scale 1 >/dev/null 2>&1

    # Semua workspace dikembalikan ke panel internal, sehingga layar
    # eksternal menampilkan workspace yang sama dengan panel internal.
    while IFS= read -r name; do
        [ -z "$name" ] && continue
        swaymsg "workspace $name" >/dev/null 2>&1
        swaymsg "move workspace to output $INTERNAL" >/dev/null 2>&1
        [ -n "$prev" ] && swaymsg "workspace $prev" >/dev/null 2>&1
    done < <(workspaces_of "$external")

    # Posisi identik → sway menumpuk keduanya, konten sama di dua layar.
    swaymsg output "$INTERNAL" position 0 0 >/dev/null 2>&1
    swaymsg output "$external" position 0 0 >/dev/null 2>&1

    [ -n "$prev" ] && swaymsg "workspace $prev" >/dev/null 2>&1

    save_state mirror
    notify "Mirror: semua workspace di kedua layar"
    echo "  mode: mirror (internal=$INTERNAL external=$external ${mode:-?})"
}

# --- MODE: extend -------------------------------------------------------
# Workspace 1-5 di panel internal, 6-10 di layar eksternal.
# 'move workspace to output' bekerja pada workspace yang sedang fokus,
# jadi kita pindah workspace satu per satu lalu pulihkan fokus.
mode_extend() {
    local external mode width i prev
    external=$(get_external)
    if [ -z "$external" ]; then
        notify "Tidak ada layar eksternal aktif"
        return 1
    fi

    mode=$(internal_mode)
    width=$(internal_width)
    prev=$(focused_workspace)

    swaymsg output "$external" enable >/dev/null 2>&1
    [ -n "$mode" ] && swaymsg output "$external" mode "$mode" >/dev/null 2>&1
    # Bersihkan sisa mirror: layar eksternal digeser ke kanan internal.
    swaymsg output "$INTERNAL" position 0 0 >/dev/null 2>&1
    swaymsg output "$external" position "$width" 0 >/dev/null 2>&1

    # Tentukan penempatan tiap workspace lewat 'workspace N output X'.
    #
    # sway(5): "workspace <name> output <outputs...> Specifies that workspace
    # name should be shown on the specified outputs." Inilah mekanisme resmi
    # sway untuk memetakan workspace ke output tertentu.
    #
    # CATATAN sway: perintah ini MENUMPIKAN output (append), jadi assignment
    # lama tidak hilang. Karena output_by_name_or_id() hanya mencari output
    # yang AKTIF, assignment ke output yang sudah dimatikan otomatis
    # diabaikan. Urutan: set assignment dulu, baru pindahkan workspace.
    for i in $(seq 1 "$EXTEND_SPLIT"); do
        swaymsg "workspace $i output $INTERNAL" >/dev/null 2>&1
    done
    for i in $(seq $((EXTEND_SPLIT + 1)) "$EXTEND_COUNT"); do
        swaymsg "workspace $i output $external" >/dev/null 2>&1
    done

    # Workspace yang ada dipindah ke output yang sesuai.
    # 'move workspace to output' hanya berlaku untuk workspace yang sedang
    # difokus, jadi kita fokuskan dulu, pindahkan, lalu kembalikan fokus.
    #
    # CATATAN sway: saat workspace TERAKHIR dipindah dari sebuah output,
    # sway otomatis membuat workspace pengganti di output itu
    # (sway/tree/workspace.c:1148). Karena itu kita memindahkan dalam
    # urutan: ke eksternal dulu (1-5 masih menyisso di internal), baru
    # ke internal — supaya workspace pengganti tidak menggeser nomor.
    for i in $(seq $((EXTEND_SPLIT + 1)) "$EXTEND_COUNT"); do
        swaymsg "workspace $i" >/dev/null 2>&1
        swaymsg "move workspace to output $external" >/dev/null 2>&1
        [ -n "$prev" ] && swaymsg "workspace $prev" >/dev/null 2>&1
    done
    for i in $(seq 1 "$EXTEND_SPLIT"); do
        swaymsg "workspace $i" >/dev/null 2>&1
        swaymsg "move workspace to output $INTERNAL" >/dev/null 2>&1
        [ -n "$prev" ] && swaymsg "workspace $prev" >/dev/null 2>&1
    done

    # Kembalikan fokus ke workspace yang aktif sebelum mode diganti.
    [ -n "$prev" ] && swaymsg "workspace $prev" >/dev/null 2>&1

    save_state extend
    notify "Extend: workspace 1-$EXTEND_SPLIT di laptop, sisanya di layar luar"
    echo "  mode: extend (internal=$INTERNAL external=$external split=$EXTEND_SPLIT)"
}

# --- MODE: laptop -------------------------------------------------------
# Batalkan mirror & extend: layar eksternal dimatikan, semua workspace
# dikembalikan ke panel internal.
mode_laptop() {
    local external i name prev
    external=$(get_external)
    prev=$(focused_workspace)

    if [ -n "$external" ]; then
        swaymsg output "$external" disable >/dev/null 2>&1
    fi
    swaymsg output "$INTERNAL" enable position 0 0 >/dev/null 2>&1

    # Kembalikan semua workspace ke panel internal.
    while IFS= read -r name; do
        [ -z "$name" ] && continue
        swaymsg "workspace $name" >/dev/null 2>&1
        swaymsg "move workspace to output $INTERNAL" >/dev/null 2>&1
        [ -n "$prev" ] && swaymsg "workspace $prev" >/dev/null 2>&1
    done < <(workspaces_of "$INTERNAL"; workspaces_of "$external")

    # Workspace yang belum pernah ada ikut dibuat di panel internal.
    for i in $(seq 1 "$EXTEND_COUNT"); do
        if [ -z "$(workspaces_of "$INTERNAL" | grep -x "$i")" ]; then
            swaymsg "workspace $i" >/dev/null 2>&1
            swaymsg "move workspace to output $INTERNAL" >/dev/null 2>&1
            [ -n "$prev" ] && swaymsg "workspace $prev" >/dev/null 2>&1
        fi
    done

    [ -n "$prev" ] && swaymsg "workspace $prev" >/dev/null 2>&1

    save_state laptop
    notify "Laptop saja: layar luar dimatikan"
    echo "  mode: laptop (internal=$INTERNAL)"
}
# --- MODE: workspace-toggle ----------------------------------------------
# Pindahkan workspace yang sedang fokus ke output lain (bolak-balik).
# Dipakai untuk memindahkan satu workspace secara manual, bukan
# memetakan seluruh range seperti mode extend.
mode_workspace_toggle() {
    local external current
    external=$(get_external)
    if [ -z "$external" ]; then
        # Tidak ada layar eksternal: pastikan panel internal aktif, lalu selesai.
        swaymsg output "$INTERNAL" enable >/dev/null 2>&1
        notify "Tidak ada display eksternal, hanya laptop"
        return 0
    fi

    current=$(swaymsg -t get_workspaces 2>/dev/null | python3 -c "
import sys, json
for w in json.load(sys.stdin):
    if w.get('focused'):
        print(w['output'])
        break
")
    if [ -z "$current" ]; then
        notify "Tidak bisa menentukan output workspace aktif"
        return 1
    fi

    if [ "$current" = "$external" ]; then
        swaymsg "move workspace to output $INTERNAL" >/dev/null 2>&1
    else
        swaymsg "move workspace to output $external" >/dev/null 2>&1
    fi
    echo "  mode: workspace-toggle (dari $current)"
}

usage() {
    cat <<EOF
Penggunaan: $(basename "$0") <mode>

Mode:
  mirror   Semua workspace tampil identik di kedua layar.
  extend   Workspace 1-$EXTEND_SPLIT di panel internal, sisanya di layar eksternal.
  laptop   Matikan layar eksternal (batalkan mirror & extend).
  workspace-toggle
           Pindahkan workspace aktif ke output lain.
  toggle   Ganti antara mode aktif dan mode sebelumnya.
  status   Tampilkan mode yang sedang aktif.

Shortcut sway:
  \$mod+F4  mirror
  \$mod+F5  extend
  \$mod+F6  laptop
EOF
}

case "${1:-}" in
    mirror) mode_mirror ;;
    extend) mode_extend ;;
    laptop) mode_laptop ;;
    workspace-toggle) mode_workspace_toggle ;;
    toggle)
        case "$(load_state)" in
            mirror)  mode_extend ;;
            extend)  mode_laptop ;;
            laptop)  mode_mirror ;;
            *)       mode_mirror ;;
        esac
        ;;
    status)
        echo "mode: $(load_state)"
        ;;
    *)
        usage
        exit 1
        ;;
esac
