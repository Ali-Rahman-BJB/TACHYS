#!/usr/bin/env bash
# --- Auto-perbaiki line ending CRLF (file yang disalin lewat Windows) ---
if [ -z "${TACHYS_FIXED:-}" ] && grep -q $'\r' "$0" 2>/dev/null; then export TACHYS_FIXED=1; if sed -i 's/\r$//' "$0" 2>/dev/null; then exec bash "$0" "$@"; else _t="$(mktemp)"; tr -d '\r' < "$0" > "$_t"; exec bash "$_t" "$@"; fi; fi # fix-crlf
set -u
set -o pipefail

APPS_DIR="$HOME/.local/share/applications"
DESKTOP_FILE="$APPS_DIR/tachys-run-in-terminal.desktop"

# Shortcut TIDAK dibuat otomatis.
# Hanya dibuat jika pengguna menjawab "y" atau menjalankan: bash Install.sh --yes
AUTO_YES=0
if [ "${1:-}" = "--yes" ] || [ "${1:-}" = "-y" ]; then
    AUTO_YES=1
fi

if [ "$AUTO_YES" -ne 1 ]; then
    echo "Skrip ini akan memasang launcher Tachys (shortcut) di:"
    echo "  $DESKTOP_FILE"
    echo
    printf "Pasang launcher sekarang? [y/N]: "
    answer=""
    read -r answer || answer=""
    case "$answer" in
        y|Y|yes|YES) ;;
        *)
            echo
            echo "[DIBATALKAN] Tidak ada shortcut yang dibuat."
            echo "Tachys tetap bisa dijalankan manual: bash /path/ke/Tachys.sh"
            exit 0
            ;;
    esac
fi

echo "[INFO] Menyiapkan folder aplikasi lokal: $APPS_DIR"
mkdir -p "$APPS_DIR"

echo "[INFO] Menulis file launcher: $DESKTOP_FILE"
cat > "$DESKTOP_FILE" << 'EOF'
[Desktop Entry]
Type=Application
Name=Tachys | SMK PGRI 1 Martapura
Comment=Menjalankan script .sh dari program Tachys
Exec=bash %f
Terminal=true
Icon=utilities-terminal
MimeType=text/x-shellscript;application/x-shellscript;
NoDisplay=false
EOF

chmod +x "$DESKTOP_FILE"

if command -v update-desktop-database >/dev/null 2>&1; then
    update-desktop-database "$APPS_DIR" >/dev/null 2>&1 || true
fi

echo
echo "[SELESAI] Launcher berhasil dipasang di komputer ini."
echo
echo "Langkah berikutnya:"
echo "  1. Buka Files (Nautilus), cari file Tachys.sh di flashdisk."
echo "  2. Klik kanan -> Open With -> Other Application."
echo "  3. Pilih \"Tachys | SMK PGRI 1 Martapura\"."
echo "  4. (Opsional) Centang \"Always use for this file type\" agar"
echo "     double-click langsung pakai launcher ini seterusnya."
echo
echo "Untuk menghapus launcher: bash Uninstall.sh"