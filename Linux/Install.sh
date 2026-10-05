#!/usr/bin/env bash
if [ -z "${TACHYS_FIXED:-}" ] && grep -q $'\r' "$0" 2>/dev/null; then export TACHYS_FIXED=1; if sed -i 's/\r$//' "$0" 2>/dev/null; then exec bash "$0" "$@"; else _t="$(mktemp)"; tr -d '\r' < "$0" > "$_t"; exec bash "$_t" "$@"; fi; fi # fix-crlf
set -u
set -o pipefail

APPS_DIR="$HOME/.local/share/applications"
DESKTOP_FILE="$APPS_DIR/tachys-run-in-terminal.desktop"
WRAPPER_DIR="$HOME/.local/share/tachys"
WRAPPER="$WRAPPER_DIR/run-in-terminal.sh"

AUTO_YES=0
case "${1:-}" in
    --yes|-y) AUTO_YES=1 ;;
esac

if [ "$AUTO_YES" -ne 1 ]; then
    echo "Skrip ini akan memasang launcher Tachys (shortcut) di:"
    echo "  $DESKTOP_FILE"
    echo
    printf "Pasang launcher sekarang? [Y/N]: "
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

if [ -f "$DESKTOP_FILE" ]; then
    echo "[INFO] Launcher lama ditemukan, akan diperbarui."
fi

echo "[INFO] Menyiapkan folder..."
if ! mkdir -p "$APPS_DIR" "$WRAPPER_DIR"; then
    echo "[ERROR] Gagal membuat folder di $HOME/.local/share"
    exit 1
fi

echo "[INFO] Menulis pembungkus: $WRAPPER"
cat > "$WRAPPER" << 'EOF'
#!/usr/bin/env bash
file="${1:-}"
if [ -n "$file" ] && [ -f "$file" ]; then
    bash "$file"
else
    echo "[ERROR] File tidak ditemukan: ${file:-<kosong>}"
fi
echo
read -rp "Tekan Enter untuk menutup..." _
EOF
chmod +x "$WRAPPER"

echo "[INFO] Menulis launcher: $DESKTOP_FILE"
if ! cat > "$DESKTOP_FILE" << EOF
[Desktop Entry]
Type=Application
Name=Tachys | SMK PGRI 1 Martapura
Comment=Menjalankan script .sh dari program Tachys
Exec=bash "$WRAPPER" %f
Terminal=true
Icon=utilities-terminal
MimeType=text/x-shellscript;application/x-shellscript;
NoDisplay=false
EOF
then
    echo "[ERROR] Gagal menulis file launcher."
    exit 1
fi
chmod +x "$DESKTOP_FILE"

if command -v update-desktop-database >/dev/null 2>&1; then
    update-desktop-database "$APPS_DIR" >/dev/null 2>&1 || true
fi

echo
echo "[SELESAI] Launcher berhasil dipasang di komputer ini."
echo
echo "Untuk menghapus launcher: bash Uninstall.sh"