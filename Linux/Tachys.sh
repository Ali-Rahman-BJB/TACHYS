set -u
set -o pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

FLASHDISK_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

TMP_DIR="/tmp/Tachys"

cleanup() {
    if [ -d "$TMP_DIR" ]; then
        rm -rf "$TMP_DIR"
    fi
}
trap cleanup EXIT

show_banner() {
    clear

    local C_LINE="\033[1;32m"
    local C_ART="\033[1;32m"
    local C_SUB="\033[0;36m"
    local C_RST="\033[0m"

    local LINE="════════════════════════════════════════════════════════════════════════════"

    echo -e "${C_LINE}${LINE}${C_RST}"
    echo -e "${C_ART}"
    cat << 'BANNER'
░██████╗███╗░░░███╗██╗░░██╗  ██████╗░░██████╗░██████╗░██╗  ░░███╗░░
██╔════╝████╗░████║██║░██╔╝  ██╔══██╗██╔════╝░██╔══██╗██║  ░████║░░
╚█████╗░██╔████╔██║█████═╝░  ██████╔╝██║░░██╗░██████╔╝██║  ██╔██║░░
░╚═══██╗██║╚██╔╝██║██╔═██╗░  ██╔═══╝░██║░░╚██╗██╔══██╗██║  ╚═╝██║░░
██████╔╝██║░╚═╝░██║██║░╚██╗  ██║░░░░░╚██████╔╝██║░░██║██║  ███████╗
╚═════╝░╚═╝░░░░░╚═╝╚═╝░░╚═╝  ╚═╝░░░░░░╚═════╝░╚═╝░░╚═╝╚═╝  ╚══════╝
███╗░░░███╗░█████╗░██████╗░████████╗░█████╗░██████╗░██╗░░░██╗██████╗░░█████╗░
████╗░████║██╔══██╗██╔══██╗╚══██╔══╝██╔══██╗██╔══██╗██║░░░██║██╔══██╗██╔══██╗
██╔████╔██║███████║██████╔╝░░░██║░░░███████║██████╔╝██║░░░██║██████╔╝███████║
██║╚██╔╝██║██╔══██║██╔══██╗░░░██║░░░██╔══██║██╔═══╝░██║░░░██║██╔══██╗██╔══██║
██║░╚═╝░██║██║░░██║██║░░██║░░░██║░░░██║░░██║██║░░░░░╚██████╔╝██║░░██║██║░░██║
╚═╝░░░░░╚═╝╚═╝░░╚═╝╚═╝░░╚═╝░░░╚═╝░░░╚═╝░░╚═╝╚═╝░░░░░░╚═════╝░╚═╝░░╚═╝╚═╝░░╚═╝
BANNER
    echo -e "${C_RST}"
    echo -e "${C_LINE}${LINE}${C_RST}"
    echo -e "${C_SUB}        TACHYS - Portable Diagnostic Toolkit (Linux)${C_RST}"
    echo -e "${C_LINE}${LINE}${C_RST}"
    echo
    echo -e "${C_SUB}Author      ${C_RST}: Ali Rahman"
    echo -e "${C_SUB}Student ID  ${C_RST}: 24020115 / 3085417291"
    echo -e "${C_SUB}Grade       ${C_RST}: Grade 12 - Computer and Network Engineering"
    echo -e "${C_SUB}GitHub      ${C_RST}: https://github.com/Ali-Rahman-BJB"
    echo
}
run_keyboard_tester() {
    local src_app="$FLASHDISK_ROOT/Application/LINUX/keyboard-tester/keyboard-tester"
    local dst_app="$TMP_DIR/keyboard-tester"

    echo "[INFO] Menyiapkan Keyboard Tester ..."

    if [ ! -f "$src_app" ]; then
        echo "[ERROR] File keyboard-tester tidak ditemukan di:"
        echo "        $src_app"
        echo "        Pastikan struktur folder flashdisk masih sesuai:"
        echo "        TACHYS/Application/LINUX/keyboard-tester/keyboard-tester"
        return 1
    fi

    if ! mkdir -p "$TMP_DIR"; then
        echo "[ERROR] Gagal membuat direktori sementara: $TMP_DIR"
        return 1
    fi

    if ! cp "$src_app" "$dst_app"; then
        echo "[ERROR] Gagal menyalin file dari flashdisk ke $TMP_DIR"
        echo "        Kemungkinan penyebab: flashdisk terlepas, ruang /tmp penuh,"
        echo "        atau tidak ada izin tulis ke /tmp."
        return 1
    fi

    if ! chmod +x "$dst_app"; then
        echo "[ERROR] Gagal memberikan permission execute pada $dst_app"
        return 1
    fi

    echo "[INFO] Menjalankan Keyboard Tester ..."
    if ! "$dst_app"; then
        echo "[ERROR] Keyboard Tester gagal dijalankan atau keluar dengan error."
        return 1
    fi

    echo "[INFO] Keyboard Tester selesai."
    return 0
}

run_battery_health() {
    echo "[INFO] Memeriksa kesehatan baterai ..."
    echo

    local bat_dirs=(/sys/class/power_supply/BAT*)

    if [ ! -d "${bat_dirs[0]}" ]; then
        echo "[WARN] Tidak ditemukan baterai di sistem ini."
        echo "       (Wajar jika ini adalah PC desktop tanpa baterai.)"
        return 1
    fi

    for bat in "${bat_dirs[@]}"; do
        local name
        name="$(basename "$bat")"
        echo "--- Baterai: $name ---"

        if [ -f "$bat/status" ]; then
            echo "Status        : $(cat "$bat/status")"
        fi

        if [ -f "$bat/capacity" ]; then
            echo "Kapasitas kini: $(cat "$bat/capacity")%"
        fi

        local full=""
        local design=""

        if [ -f "$bat/energy_full" ] && [ -f "$bat/energy_full_design" ]; then
            full="$(cat "$bat/energy_full")"
            design="$(cat "$bat/energy_full_design")"
        elif [ -f "$bat/charge_full" ] && [ -f "$bat/charge_full_design" ]; then
            full="$(cat "$bat/charge_full")"
            design="$(cat "$bat/charge_full_design")"
        fi

        if [ -n "$full" ] && [ -n "$design" ] && [ "$design" -gt 0 ]; then
            local health
            health="$(awk -v f="$full" -v d="$design" 'BEGIN { printf "%.1f", (f/d)*100 }')"
            echo "Kesehatan     : ${health}% (dibanding kapasitas pabrik)"
        else
            echo "Kesehatan     : tidak tersedia dari sistem ini"
        fi

        if [ -f "$bat/cycle_count" ]; then
            local cycles
            cycles="$(cat "$bat/cycle_count")"
            if [ "$cycles" != "0" ]; then
                echo "Cycle count   : $cycles"
            fi
        fi

        echo
    done

    if command -v upower >/dev/null 2>&1; then
        echo "--- Info tambahan (upower) ---"
        local upower_dev
        upower_dev="$(upower -e 2>/dev/null | grep -i battery | head -n 1)"
        if [ -n "$upower_dev" ]; then
            upower -i "$upower_dev" 2>/dev/null
        fi
    fi

    return 0
}

run_audio_output_test() {
    echo "[INFO] Membuka pengaturan Audio Output ..."
    echo

    # GNOME
    if command -v gnome-control-center >/dev/null 2>&1; then
        echo "[INFO] Menggunakan GNOME Settings."
        gnome-control-center sound >/dev/null 2>&1 &
        return 0
    fi

    # KDE Plasma
    if command -v systemsettings >/dev/null 2>&1; then
        echo "[INFO] Menggunakan KDE System Settings."
        systemsettings kcm_pulseaudio >/dev/null 2>&1 &
        return 0
    fi

    # XFCE
    if command -v pavucontrol >/dev/null 2>&1; then
        echo "[INFO] Menggunakan PulseAudio Volume Control."
        pavucontrol >/dev/null 2>&1 &
        return 0
    fi

    # PipeWire / PulseAudio melalui pavucontrol
    if command -v pavucontrol >/dev/null 2>&1; then
        echo "[INFO] Membuka pengaturan audio."
        pavucontrol >/dev/null 2>&1 &
        return 0
    fi
    echo "[ERROR] Tidak ditemukan aplikasi pengaturan audio."
    echo
    echo "Coba install salah satu:"
    echo "  Ubuntu/Debian : sudo apt install pavucontrol"
    echo "  Fedora        : sudo dnf install pavucontrol"
    echo "  Arch          : sudo pacman -S pavucontrol"

    return 1
}

show_menu() {
    local local C_SUB="\033[0;36m"
    local C_TEAL="\033[0;36m"
    local C_LINE="\033[1;32m"
    local C_RST="\033[0m"
    local LINE="════════════════════════════════════════════════════════════════════════════"

    echo -e "${C_LINE}${LINE}${C_RST}"
    echo -e "${C_SUB}        Pilih tool yang ingin dijalankan:${C_RST}"
    echo
    echo -e "${C_TEAL}  1. Keyboard Tester${C_RST}"
    echo -e "${C_TEAL}  2. Cek Kesehatan Baterai${C_RST}"
    echo -e "${C_TEAL}  3. Audio Output Test${C_RST}"
    echo -e "${C_TEAL}  0. Keluar${C_RST}"
    echo
    echo -e "${C_LINE}${LINE}${C_RST}"
    echo
}

while true; do
    show_banner
    show_menu

    read -r -p "Masukkan pilihan [0-3]: " pilihan
    echo

    case "$pilihan" in
        1)
            run_keyboard_tester
            ;;
        2)
            run_battery_health
            ;;
        3)
            run_audio_output_test
            ;;
        0)
            echo "[INFO] Keluar dari Tachys. Sampai jumpa!"
            exit 0
            ;;
        *)
            echo "[ERROR] Pilihan tidak dikenali: $pilihan"
            ;;
    esac

    echo
    read -r -p "Tekan Enter untuk kembali ke menu ..." _
done
