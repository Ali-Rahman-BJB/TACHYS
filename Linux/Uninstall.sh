#!/usr/bin/env bash
set -u

DESKTOP_FILE="$HOME/.local/share/applications/tachys-run-in-terminal.desktop"

if [ -f "$DESKTOP_FILE" ]; then
    rm -f "$DESKTOP_FILE"
    echo "[INFO] Launcher Tachys berhasil dihapus."
else
    echo "[INFO] Launcher Tachys tidak ditemukan (mungkin sudah dihapus)."
fi

if command -v update-desktop-database >/dev/null 2>&1; then
    update-desktop-database "$HOME/.local/share/applications" >/dev/null 2>&1 || true
fi

echo "[SELESAI] Uninstall selesai."