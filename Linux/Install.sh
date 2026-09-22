set -u
set -o pipefail

APPS_DIR="$HOME/.local/share/applications"
DESKTOP_FILE="$APPS_DIR/tachys-run-in-terminal.desktop"

echo "[INFO] Menyiapkan folder aplikasi lokal: $APPS_DIR"
mkdir -p "$APPS_DIR"

echo "[INFO] Menulis file launcher: $DESKTOP_FILE"
cat > "$DESKTOP_FILE" << 'EOF'
[Desktop Entry]
Type=Application
Name=Tachys | SMK PGRI 1 Martapura
Comment=Menjalankan script .sh (mis. dari flashdisk Tachys) di dalam terminal
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
echo "  3. Pilih \"Tachys (Jalankan di Terminal)\"."
echo "  4. (Opsional) Centang \"Always use for this file type\" agar"
echo "     double-click langsung pakai launcher ini seterusnya."
