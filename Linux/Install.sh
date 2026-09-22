#!/bin/bash
#
# install.sh
#
# JALANKAN INI SEKALI SAJA per komputer baru (lewat terminal):
#   bash install.sh
#
# Fungsinya: mendaftarkan sebuah "aplikasi pembuka" bernama
# "Tachys (Jalankan di Terminal)" ke komputer ini (bukan ke flashdisk).
# Aplikasi ini disimpan di ~/.local/share/applications/, yaitu folder
# lokal milik user di filesystem komputer (ext4/dll), BUKAN di flashdisk.
# Karena itu ia tidak terpengaruh oleh keterbatasan vfat/FAT32 yang
# tidak bisa menyimpan izin "execute".
#
# Setelah script ini dijalankan sekali, kamu bisa:
#   klik kanan Tachys.sh -> Open With -> Other Application
#   -> pilih "Tachys (Jalankan di Terminal)"
#   -> centang "Always use for this file type" (opsional, supaya
#      double-click langsung pakai ini seterusnya di komputer ini)
#
# Script ini TIDAK mengubah apa pun di flashdisk, dan TIDAK perlu sudo.

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
Name=Tachys (Jalankan di Terminal)
Comment=Menjalankan script .sh (mis. dari flashdisk Tachys) di dalam terminal
# %f diisi otomatis oleh file manager dengan path file .sh yang di-klik.
# "bash %f" tidak butuh file itu sendiri executable, cukup bisa dibaca.
Exec=bash %f
Terminal=true
Icon=utilities-terminal
MimeType=text/x-shellscript;application/x-shellscript;
NoDisplay=false
EOF

# File ini milik komputer (filesystem lokal), jadi chmod +x di sini AMAN
# dan akan selalu berhasil (berbeda dengan file di flashdisk vfat).
chmod +x "$DESKTOP_FILE"

# Perbarui database aplikasi supaya file manager langsung mengenali
# launcher baru ini tanpa perlu logout/restart.
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