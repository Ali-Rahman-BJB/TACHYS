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
    echo -e "${C_SUB}Repository  ${C_RST}: https://github.com/Ali-Rahman-BJB/TACHYS"
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

run_wifi_check() {
    echo "[INFO] Memeriksa status WiFi Card ..."
    echo

    local wifi_iface=""

    if command -v iw >/dev/null 2>&1; then
        wifi_iface="$(iw dev 2>/dev/null | awk '$1=="Interface"{print $2; exit}')"
    fi

    if [ -z "$wifi_iface" ] && command -v nmcli >/dev/null 2>&1; then
        wifi_iface="$(nmcli -t -f DEVICE,TYPE device 2>/dev/null | awk -F: '$2=="wifi"{print $1; exit}')"
    fi

    if [ -z "$wifi_iface" ]; then
        echo "[WARN] Tidak ditemukan interface WiFi pada sistem ini."
        echo "       (Wajar jika laptop/PC ini tidak memiliki WiFi card atau modul WiFi mati.)"
        return 1
    fi

    echo "Interface WiFi : $wifi_iface"

    if [ -f "/sys/class/net/$wifi_iface/operstate" ]; then
        echo "Status Link    : $(cat "/sys/class/net/$wifi_iface/operstate")"
    fi

    if command -v rfkill >/dev/null 2>&1; then
        local blocked
        blocked="$(rfkill list wifi 2>/dev/null | grep -i "Soft blocked: yes\|Hard blocked: yes")"
        if [ -n "$blocked" ]; then
            echo "[WARN] WiFi dalam keadaan diblokir (rfkill):"
            echo "$blocked"
        fi
    fi

    if command -v nmcli >/dev/null 2>&1; then
        local ssid signal
        ssid="$(nmcli -t -f active,ssid dev wifi 2>/dev/null | awk -F: '$1=="yes"{print $2; exit}')"
        signal="$(nmcli -t -f active,signal dev wifi 2>/dev/null | awk -F: '$1=="yes"{print $2; exit}')"

        if [ -n "$ssid" ]; then
            echo "SSID           : $ssid"
        fi

        if [ -n "$signal" ]; then
            echo "Kekuatan Sinyal: ${signal}%"
            if [ "$signal" -ge 70 ]; then
                echo "Kualitas       : Kuat"
            elif [ "$signal" -ge 40 ]; then
                echo "Kualitas       : Sedang"
            else
                echo "Kualitas       : Lemah"
            fi
        else
            echo "[WARN] Tidak sedang terhubung ke jaringan WiFi manapun."
        fi
    elif [ -f /proc/net/wireless ]; then
        local line quality
        line="$(grep "$wifi_iface" /proc/net/wireless)"
        if [ -n "$line" ]; then
            quality="$(echo "$line" | awk '{print $3}' | tr -d '.')"
            echo "Link Quality   : ${quality} (skala /proc/net/wireless, umumnya maks ~70)"
        else
            echo "[WARN] Tidak ada data sinyal untuk $wifi_iface pada saat ini."
        fi
    else
        echo "[WARN] Tidak dapat membaca kekuatan sinyal (nmcli/iw tidak tersedia)."
        echo "       Coba install: sudo apt install network-manager"
    fi

    echo
    echo "--- Uji konektivitas: Google.com ---"
    if command -v ping >/dev/null 2>&1; then
        if ! mkdir -p "$TMP_DIR"; then
            echo "[WARN] Gagal membuat direktori sementara untuk log ping. Melanjutkan tanpa file log..."
            ping -c 3 -W 2 google.com
        else
            local ping_log="$TMP_DIR/google_ping.txt"
            if ping -c 3 -W 2 google.com >"$ping_log" 2>&1; then
                echo "[INFO] Koneksi internet ke Google berhasil terdeteksi."
                cat "$ping_log"
            else
                echo "[WARN] Ping ke Google gagal atau koneksi internet tidak tersedia."
                cat "$ping_log"
            fi
        fi
    else
        echo "[WARN] Tidak dapat melakukan ping karena utilitas 'ping' tidak tersedia."
    fi

    echo
    return 0
}

run_process_monitor() {
    echo "[INFO] Memeriksa program berat yang berjalan ..."
    echo

    echo "--- 10 proses dengan penggunaan CPU tertinggi ---"
    ps -eo pid,ppid,%cpu,%mem,comm --sort=-%cpu | head -n 11
    echo

    echo "--- Kemungkinan proses antivirus / security ---"
    local av_patterns="clamd|clamav|freshclam|avast|avgd|avguard|kaspersky|kav|bitdefender|bdlogin|mcafee|sophos|comodo|eset|nod32|f-secure|rkhunter|chkrootkit|fail2ban"
    local av_list
    av_list="$(ps -eo pid,comm | grep -Ei "$av_patterns" | grep -v grep)"

    if [ -n "$av_list" ]; then
        echo "$av_list"
    else
        echo "Tidak ditemukan proses antivirus/security yang umum dikenali."
    fi
    echo

    echo "--- Proses dengan pemakaian resource sangat berat (CPU > 20% atau MEM > 20%) ---"
    local heavy_list
    heavy_list="$(ps -eo pid,comm,%cpu,%mem --no-headers | awk '$3+0>20 || $4+0>20')"

    if [ -z "$heavy_list" ]; then
        echo "Tidak ada proses yang terdeteksi memakai resource sangat berat saat ini."
        echo
        return 0
    fi

    echo "PID     NAMA            %CPU   %MEM"
    echo "$heavy_list"
    echo

    while true; do
        read -r -p "Masukkan PID yang ingin dimatikan (kosongkan untuk selesai): " target_pid
        if [ -z "$target_pid" ]; then
            break
        fi

        if ! echo "$target_pid" | grep -Eq '^[0-9]+$'; then
            echo "[ERROR] PID tidak valid, harus berupa angka."
            echo
            continue
        fi

        local pname
        pname="$(ps -p "$target_pid" -o comm= 2>/dev/null)"

        if [ -z "$pname" ]; then
            echo "[ERROR] PID $target_pid tidak ditemukan (mungkin sudah berhenti)."
            echo
            continue
        fi

        read -r -p "Yakin ingin mematikan proses '$pname' (PID $target_pid)? [Y/N]: " confirm
        case "$confirm" in
            [Yy]|[Yy][Ee][Ss])
                if kill "$target_pid" 2>/dev/null; then
                    echo "[INFO] Proses '$pname' (PID $target_pid) berhasil dihentikan."
                else
                    echo "[ERROR] Gagal menghentikan proses. Mungkin perlu izin root (coba jalankan dengan sudo)."
                fi
                ;;
            *)
                echo "[INFO] Dilewati, proses tidak dimatikan."
                ;;
        esac
        echo
    done

    return 0
}

run_disk_health() {
    echo "[INFO] Memeriksa kesehatan HDD/SSD (SMART) ..."
    echo

    if ! command -v smartctl >/dev/null 2>&1; then
        echo "[ERROR] Tool 'smartctl' tidak ditemukan di sistem ini."
        echo "        Ini setara dengan HDD Sentinel di Windows, bagian dari paket 'smartmontools'."
        echo
        echo "Silakan install terlebih dahulu:"
        echo "  Ubuntu/Debian : sudo apt install smartmontools"
        echo "  Fedora        : sudo dnf install smartmontools"
        echo "  Arch          : sudo pacman -S smartmontools"
        echo
        echo "Setelah terinstall, jalankan kembali menu ini."
        return 1
    fi

    if [ "$(id -u)" -ne 0 ]; then
        echo "[WARN] Tidak dijalankan sebagai root. Sebagian data SMART mungkin tidak lengkap"
        echo "       atau device tidak terdeteksi sama sekali. Disarankan jalankan Tachys dengan sudo."
        echo
    fi

    local scan_result
    scan_result="$(smartctl --scan 2>/dev/null | awk '{print $1}')"

    if [ -z "$scan_result" ]; then
        echo "[WARN] Tidak ditemukan device disk yang bisa diperiksa smartctl."
        echo "       Mencoba fallback ke daftar block device via lsblk ..."
        if command -v lsblk >/dev/null 2>&1; then
            scan_result="$(lsblk -dno NAME | awk '{print "/dev/"$1}')"
        fi
    fi

    if [ -z "$scan_result" ]; then
        echo "[ERROR] Tidak ada device disk yang terdeteksi sama sekali."
        return 1
    fi

    local dev
    for dev in $scan_result; do
        echo "════════════════════════════════════════════════════════════"
        echo "Device: $dev"
        echo "════════════════════════════════════════════════════════════"

        local info
        info="$(smartctl -a "$dev" 2>/dev/null)"

        if [ -z "$info" ]; then
            echo "[WARN] Tidak bisa membaca data SMART dari $dev."
            echo "       Kemungkinan butuh akses root (jalankan dengan sudo) atau"
            echo "       device tidak mendukung SMART (mis. USB flashdisk / SD card)."
            echo
            continue
        fi

        local model
        model="$(echo "$info" | grep -iE "Device Model|Model Number" | head -n 1 | sed 's/.*:\s*//')"
        [ -n "$model" ] && echo "Model         : $model"

        local health
        health="$(echo "$info" | grep -i "overall-health self-assessment" | sed 's/.*:\s*//')"
        if [ -n "$health" ]; then
            echo "Status SMART  : $health"
        else
            echo "Status SMART  : tidak tersedia dari device ini"
        fi

        local temp
        temp="$(echo "$info" | grep -iE "Temperature_Celsius|^Temperature:" | head -n 1 | awk '{print $NF, "C"}')"
        [ -n "$temp" ] && echo "Suhu          : $temp"

        local poweron
        poweron="$(echo "$info" | grep -i "Power_On_Hours" | awk '{print $NF}')"
        [ -n "$poweron" ] && echo "Power-On Hours: $poweron jam"

        # SATA/HDD-specific: reallocated & pending sectors
        local realloc pending
        realloc="$(echo "$info" | grep -i "Reallocated_Sector_Ct" | awk '{print $NF}')"
        pending="$(echo "$info" | grep -i "Current_Pending_Sector" | awk '{print $NF}')"
        if [ -n "$realloc" ]; then
            echo "Bad Sectors   : $realloc (realokasi), pending: ${pending:-0}"
            if [ "$realloc" != "0" ] || { [ -n "$pending" ] && [ "$pending" != "0" ]; }; then
                echo "[WARN] Terdeteksi bad sector! Pertimbangkan backup data segera."
            fi
        fi

        # NVMe-specific: percentage used & available spare
        local pct_used spare
        pct_used="$(echo "$info" | grep -i "Percentage Used" | sed 's/.*:\s*//')"
        spare="$(echo "$info" | grep -i "Available Spare:" | grep -v Threshold | sed 's/.*:\s*//')"
        [ -n "$pct_used" ] && echo "Wear Level    : $pct_used terpakai dari usia pakai (NVMe)"
        [ -n "$spare" ] && echo "Spare Blocks  : $spare tersisa (NVMe)"

        echo
    done

    echo "[INFO] Pemeriksaan SMART selesai."
    echo "       Status 'PASSED'/'OK' = sehat. Jika 'FAILED' atau ada banyak bad sector,"
    echo "       segera backup data dan pertimbangkan penggantian disk."
    return 0
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
    echo -e "${C_TEAL}  1. Cek Kesehatan HDD/SSD${C_RST}"
    echo -e "${C_TEAL}  2. Cek Status WiFi Card${C_RST}"
    echo -e "${C_TEAL}  3. Tes Keyboard${C_RST}"
    echo -e "${C_TEAL}  4. Tes Audio${C_RST}"
    echo -e "${C_TEAL}  5. Cek Kesehatan Baterai${C_RST}"
    echo -e "${C_TEAL}  6. Cek Program Berat${C_RST}"
    echo -e "${C_TEAL}  0. Keluar${C_RST}"
    echo
    echo -e "${C_LINE}${LINE}${C_RST}"
    echo
}

while true; do
    show_banner
    show_menu

    read -r -p "Masukkan pilihan [0-6]: " pilihan
    echo

    case "$pilihan" in
        1)
            run_disk_health
            ;;
        2)
            run_wifi_check
            ;;
        3)
            run_keyboard_tester
            ;;
        4)
            run_audio_output_test
            ;;
        5)
            run_battery_health
            ;;
        6)
            run_process_monitor
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