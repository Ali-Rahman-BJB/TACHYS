if [ -z "${TACHYS_FIXED:-}" ] && grep -q $'\r' "$0" 2>/dev/null; then export TACHYS_FIXED=1; if sed -i 's/\r$//' "$0" 2>/dev/null; then exec bash "$0" "$@"; else _t="$(mktemp)"; tr -d '\r' < "$0" > "$_t"; exec bash "$_t" "$@"; fi; fi # fix-crlf
set -u

APPS_DIR="$HOME/.local/share/applications"
DESKTOP_FILE="$APPS_DIR/tachys-run-in-terminal.desktop"
WRAPPER_DIR="$HOME/.local/share/tachys"
WRAPPER="$WRAPPER_DIR/run-in-terminal.sh"

removed=0

if [ -f "$DESKTOP_FILE" ]; then
    rm -f "$DESKTOP_FILE" && removed=1
fi

if [ -f "$WRAPPER" ]; then
    rm -f "$WRAPPER" && removed=1
fi

rmdir "$WRAPPER_DIR" 2>/dev/null || true

if command -v update-desktop-database >/dev/null 2>&1; then
    update-desktop-database "$APPS_DIR" >/dev/null 2>&1 || true
fi

if [ "$removed" -eq 1 ]; then
    echo "[INFO] Launcher Tachys berhasil dihapus."
else
    echo "[INFO] Launcher Tachys tidak ditemukan (mungkin sudah dihapus)."
fi

echo "[SELESAI] Uninstall selesai."