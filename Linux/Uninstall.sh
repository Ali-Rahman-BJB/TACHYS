#!/usr/bin/env bash
# --- Auto-perbaiki line ending CRLF (file yang disalin lewat Windows) ---
if [ -z "${TACHYS_FIXED:-}" ] && grep -q $'\r' "$0" 2>/dev/null; then export TACHYS_FIXED=1; if sed -i 's/\r$//' "$0" 2>/dev/null; then exec bash "$0" "$@"; else _t="$(mktemp)"; tr -d '\r' < "$0" > "$_t"; exec bash "$_t" "$@"; fi; fi # fix-crlf
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