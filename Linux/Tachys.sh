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

read_sys() {
    [ -r "$1" ] || return 1
    local _v=""
    IFS= read -r _v < "$1" 2>/dev/null
    printf -v "$2" '%s' "$_v"
}

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

    if [ ! -x "$dst_app" ] || [ "$src_app" -nt "$dst_app" ]; then
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

    local bat name status capacity full design cycles health

    for bat in "${bat_dirs[@]}"; do
        name="${bat##*/}"
        echo "--- Baterai: $name ---"

        status="" capacity="" full="" design="" cycles=""

        read_sys "$bat/status"   status   && echo "Status        : $status"
        read_sys "$bat/capacity" capacity && echo "Kapasitas kini: ${capacity}%"

        if [ -r "$bat/energy_full" ] && [ -r "$bat/energy_full_design" ]; then
            read_sys "$bat/energy_full" full
            read_sys "$bat/energy_full_design" design
        elif [ -r "$bat/charge_full" ] && [ -r "$bat/charge_full_design" ]; then
            read_sys "$bat/charge_full" full
            read_sys "$bat/charge_full_design" design
        fi

        if [[ $full =~ ^[0-9]+$ && $design =~ ^[0-9]+$ ]] && [ "$((10#$design))" -gt 0 ]; then
            health=$(( (10#$full * 1000) / (10#$design) ))
            printf 'Kesehatan     : %d.%d%% (dibanding kapasitas pabrik)\n' \
                "$((health / 10))" "$((health % 10))"
        else
            echo "Kesehatan     : tidak tersedia dari sistem ini"
        fi

        if read_sys "$bat/cycle_count" cycles && [ "$cycles" != "0" ]; then
            echo "Cycle count   : $cycles"
        fi

        echo
    done

    if command -v upower >/dev/null 2>&1; then
        echo "--- Info tambahan (upower) ---"
        upower -i "/org/freedesktop/UPower/devices/battery_${bat_dirs[0]##*/}" 2>/dev/null
    fi

    return 0
}

run_audio_output_test() {
    echo "[INFO] Menjalankan tes output audio ..."
    echo

    if command -v speaker-test >/dev/null 2>&1; then
        echo "[INFO] Memutar test tone per channel (Kiri/Kanan) selama beberapa detik ..."
        echo "[INFO] Tekan Ctrl+C jika ingin berhenti lebih awal."
        speaker-test -c 2 -t wav -l 1
        return 0
    fi

    if command -v aplay >/dev/null 2>&1 && command -v speaker-test >/dev/null 2>&1; then
        : # sudah tercover di atas
    fi

    echo "[ERROR] Tool 'speaker-test' (paket alsa-utils) tidak ditemukan."
    echo
    echo "Silakan install terlebih dahulu:"
    echo "  Ubuntu/Debian : sudo apt install alsa-utils"
    echo "  Fedora        : sudo dnf install alsa-utils"
    echo "  Arch          : sudo pacman -S alsa-utils"

    return 1
}

run_wifi_check() {
    echo "[INFO] Memeriksa status WiFi Card ..."
    echo

    local wifi_iface="" p

    for p in /sys/class/net/*/phy80211; do
        if [ -e "$p" ]; then
            wifi_iface="${p#/sys/class/net/}"
            wifi_iface="${wifi_iface%%/*}"
            break
        fi
    done

    if [ -z "$wifi_iface" ] && command -v iw >/dev/null 2>&1; then
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

    local state=""
    if read_sys "/sys/class/net/$wifi_iface/operstate" state; then
        echo "Status Link    : $state"
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
        local ssid="" signal="" nm_line rest

        nm_line="$(nmcli -t -f active,signal,ssid dev wifi list ifname "$wifi_iface" --rescan no 2>/dev/null \
                    | grep -m1 '^yes:')"

        if [ -n "$nm_line" ]; then
            rest="${nm_line#yes:}"
            signal="${rest%%:*}"
            ssid="${rest#*:}"
            ssid="${ssid//\\:/:}"
        fi

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
    elif [ -r /proc/net/wireless ]; then
        local quality
        quality="$(awk -v i="$wifi_iface:" '$1==i { gsub(/\./, "", $3); print $3; exit }' /proc/net/wireless)"
        if [ -n "$quality" ]; then
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
        local ping_out
        if ping_out="$(ping -c 3 -W 2 google.com 2>&1)"; then
            echo "[INFO] Koneksi internet ke Google berhasil terdeteksi."
        else
            echo "[WARN] Ping ke Google gagal atau koneksi internet tidak tersedia."
        fi
        echo "$ping_out"
    else
        echo "[WARN] Tidak dapat melakukan ping karena utilitas 'ping' tidak tersedia."
    fi

    echo
    return 0
}

run_process_monitor() {
    echo "[INFO] Memeriksa program berat yang berjalan ..."
    echo

    local av_patterns="clamd|clamav|freshclam|avast|avgd|avguard|kaspersky|kav|bitdefender|bdlogin|mcafee|sophos|comodo|eset|nod32|f-secure|rkhunter|chkrootkit|fail2ban"

    local -a rc
    ps -eo pid=,ppid=,pcpu=,pmem=,comm= --sort=-pcpu | awk -v me="$$" -v av="$av_patterns" '
        $1 == me || $2 == me { next }

        {
            name = $5
            for (i = 6; i <= NF; i++) name = name " " $i

            if (n_top < 10) {
                n_top++
                top[n_top] = sprintf("%-8s %-8s %6s %6s  %s", $1, $2, $3, $4, name)
            }
            if (tolower(name) ~ av) {
                n_av++
                avl[n_av] = sprintf("%-8s %s", $1, name)
            }
            if ($3 + 0 > 20 || $4 + 0 > 20) {
                n_hv++
                hv[n_hv] = sprintf("%-8s %-15s %6s %6s", $1, name, $3, $4)
            }
        }

        END {
            print "--- 10 proses dengan penggunaan CPU tertinggi ---"
            printf "%-8s %-8s %6s %6s  %s\n", "PID", "PPID", "%CPU", "%MEM", "COMMAND"
            for (i = 1; i <= n_top; i++) print top[i]
            print ""

            print "--- Kemungkinan proses antivirus / security ---"
            if (n_av > 0) {
                for (i = 1; i <= n_av; i++) print avl[i]
            } else {
                print "Tidak ditemukan proses antivirus/security yang umum dikenali."
            }
            print ""

            print "--- Proses dengan pemakaian resource sangat berat (CPU > 20% atau MEM > 20%) ---"
            if (n_hv == 0) {
                print "Tidak ada proses yang terdeteksi memakai resource sangat berat saat ini."
                print ""
                exit 0
            }
            printf "%-8s %-15s %6s %6s\n", "PID", "NAMA", "%CPU", "%MEM"
            for (i = 1; i <= n_hv; i++) print hv[i]
            print ""
            exit 10
        }
    '
    rc=("${PIPESTATUS[@]}")

    if [ "${rc[0]}" -ne 0 ]; then
        echo "[ERROR] Perintah 'ps' gagal dijalankan (kode ${rc[0]})."
        return 1
    fi

    if [ "${rc[1]}" -ne 10 ]; then
        return 0
    fi

    local target_pid pname confirm

    while true; do
        read -r -p "Masukkan PID yang ingin dimatikan (kosongkan untuk selesai): " target_pid
        if [ -z "$target_pid" ]; then
            break
        fi

        if [[ ! $target_pid =~ ^[0-9]{1,7}$ ]]; then
            echo "[ERROR] PID tidak valid, harus berupa angka."
            echo
            continue
        fi
        target_pid=$((10#$target_pid))

        pname=""
        { read -r pname < "/proc/$target_pid/comm"; } 2>/dev/null

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

    if [ "$EUID" -ne 0 ]; then
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
            scan_result="$(lsblk -dno NAME,TYPE 2>/dev/null \
                | awk '$2=="disk" && $1 !~ /^(loop|ram|zram)/ {print "/dev/"$1}')"
        fi
    fi

    if [ -z "$scan_result" ]; then
        echo "[ERROR] Tidak ada device disk yang terdeteksi sama sekali."
        return 1
    fi

    local dev info
    for dev in $scan_result; do
        echo "════════════════════════════════════════════════════════════"
        echo "Device: $dev"
        echo "════════════════════════════════════════════════════════════"

        info="$(smartctl -i -H -A "$dev" 2>/dev/null)"

        if [ -z "$info" ]; then
            echo "[WARN] Tidak bisa membaca data SMART dari $dev."
            echo "       Kemungkinan butuh akses root (jalankan dengan sudo) atau"
            echo "       device tidak mendukung SMART (mis. USB flashdisk / SD card)."
            echo
            continue
        fi

        awk '
            function after_colon(s) { sub(/^[^:]*:[ \t]*/, "", s); return s }

            {
                l = tolower($0)

                if (model == "" && (l ~ /device model/ || l ~ /model number/))  model = after_colon($0)
                else if (l ~ /overall-health self-assessment/)                  health = after_colon($0)
                else if (temp == "" && l ~ /temperature_celsius/)               temp = $10        # SATA
                else if (temp == "" && l ~ /^temperature:/)                     temp = $2         # NVMe
                else if (l ~ /power_on_hours/)                                  poweron = $10     # SATA
                else if (l ~ /^power on hours:/)                                poweron = $4      # NVMe
                else if (l ~ /reallocated_sector_ct/)                           realloc = $10
                else if (l ~ /current_pending_sector/)                          pending = $10
                else if (l ~ /percentage used/)                                 pct_used = after_colon($0)
                else if (l ~ /available spare:/)                                spare = after_colon($0)
            }

            END {
                if (model != "")   printf "Model         : %s\n", model
                printf "Status SMART  : %s\n", (health != "" ? health : "tidak tersedia dari device ini")
                if (temp != "")    printf "Suhu          : %s C\n", temp
                if (poweron != "") printf "Power-On Hours: %s jam\n", poweron

                # SATA/HDD: reallocated & pending sectors
                if (realloc != "") {
                    printf "Bad Sectors   : %s (realokasi), pending: %s\n", realloc, (pending != "" ? pending : "0")
                    if (realloc != "0" || (pending != "" && pending != "0"))
                        print "[WARN] Terdeteksi bad sector! Pertimbangkan backup data segera."
                }

                # NVMe: percentage used & available spare
                if (pct_used != "") printf "Wear Level    : %s terpakai dari usia pakai (NVMe)\n", pct_used
                if (spare != "")    printf "Spare Blocks  : %s tersisa (NVMe)\n", spare
            }
        ' <<< "$info"

        echo
    done

    echo "[INFO] Pemeriksaan SMART selesai."
    echo "       Status 'PASSED'/'OK' = sehat. Jika 'FAILED' atau ada banyak bad sector,"
    echo "       segera backup data dan pertimbangkan penggantian disk."
    return 0
}

show_menu() {
    local C_SUB="\033[0;36m"
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

    read -r -p "Masukkan pilihan [0-6]: " pilihan || { echo; exit 0; }
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