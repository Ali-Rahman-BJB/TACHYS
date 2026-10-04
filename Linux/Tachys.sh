#!/usr/bin/env bash
# --- Auto-perbaiki line ending CRLF (file yang disalin lewat Windows) ---
if [ -z "${TACHYS_FIXED:-}" ] && grep -q $'\r' "$0" 2>/dev/null; then export TACHYS_FIXED=1; if sed -i 's/\r$//' "$0" 2>/dev/null; then exec bash "$0" "$@"; else TACHYS_SELF="$0"; export TACHYS_SELF; _t="$(mktemp)"; tr -d '\r' < "$0" > "$_t"; exec bash "$_t" "$@"; fi; fi # fix-crlf
set -u
set -o pipefail

SCRIPT_DIR="$(cd "$(dirname "${TACHYS_SELF:-$0}")" && pwd)"

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

# Mode tampilan (diatur oleh show_screen). Nilai bawaan = tampilan asli.
BLANKS=1     # 1 = pakai baris kosong antar bagian (asli), 0 = rapatkan
ART=1        # 1 = tampilkan banner ASCII
MENU2=0      # 1 = menu 2 kolom
MINI=0       # 1 = tampilan paling ringkas
TERM_ROWS=24
TERM_COLS=80

blank() { [ "$BLANKS" = 1 ] && echo; return 0; }

show_banner() {
    clear

    local C_LINE="\033[1;32m"
    local C_ART="\033[1;32m"
    local C_SUB="\033[0;36m"
    local C_RST="\033[0m"

    local LINE="════════════════════════════════════════════════════════════════════════════"

    [ "$TERM_COLS" -lt 77 ] && LINE="${LINE:0:$(( TERM_COLS - 1 ))}"

    [ "$MINI" = 1 ] || echo -e "${C_LINE}${LINE}${C_RST}"
    if [ "$ART" = 1 ]; then
    printf '%b' "${C_ART}"; blank
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
    printf '%b' "${C_RST}"; blank
    echo -e "${C_LINE}${LINE}${C_RST}"
    fi
    echo -e "${C_SUB}        TACHYS - Portable Diagnostic Toolkit (Linux)${C_RST}"
    if [ "$MINI" != 1 ]; then
    echo -e "${C_LINE}${LINE}${C_RST}"
    blank
    echo -e "${C_SUB}Author      ${C_RST}: Ali Rahman"
    echo -e "${C_SUB}Student ID  ${C_RST}: 24020115 / 3085417291"
    echo -e "${C_SUB}Grade       ${C_RST}: Grade 12 - Computer and Network Engineering"
    echo -e "${C_SUB}Repository  ${C_RST}: https://github.com/Ali-Rahman-BJB/TACHYS"
    [ "$ART" = 1 ] || echo -e "${C_SUB}(Perbesar jendela terminal agar banner ASCII tampil)${C_RST}"
    blank
    fi
}

# Maksimalkan jendela terminal (best effort, aman kalau tidak didukung).
maximize_window() {
    [ -t 1 ] || return 0
    printf '\033[9;1t'
    if [ -n "${DISPLAY:-}" ]; then
        if command -v wmctrl >/dev/null 2>&1; then
            wmctrl -r :ACTIVE: -b add,maximized_vert,maximized_horz >/dev/null 2>&1
        elif command -v xdotool >/dev/null 2>&1; then
            xdotool getactivewindow windowstate --add MAXIMIZED_VERT --add MAXIMIZED_HORZ >/dev/null 2>&1
        fi
    fi
    sleep 0.3
}

get_term_size() {
    local sz
    sz="$(stty size 2>/dev/null)" || sz=""
    if [ -n "$sz" ]; then
        TERM_ROWS="${sz% *}"; TERM_COLS="${sz#* }"
    elif command -v tput >/dev/null 2>&1; then
        TERM_ROWS="$(tput lines 2>/dev/null)"; TERM_COLS="$(tput cols 2>/dev/null)"
    fi
    case "$TERM_ROWS" in ''|*[!0-9]*|0) TERM_ROWS=24 ;; esac
    case "$TERM_COLS" in ''|*[!0-9]*|0) TERM_COLS=80 ;; esac
}

# Cari tool yang bisa saja ada di /usr/sbin (tidak masuk PATH user biasa di Debian)
find_tool() {
    local t="$1" p
    if p="$(command -v "$t" 2>/dev/null)" && [ -n "$p" ]; then
        printf '%s' "$p"; return 0
    fi
    for p in /usr/sbin /sbin /usr/local/sbin; do
        if [ -x "$p/$t" ]; then printf '%s' "$p/$t"; return 0; fi
    done
    return 1
}

# ---------- Akses root untuk smartctl ----------
SMARTCTL_BIN=""
SMART_SUDO=0     # 1 = smartctl dipanggil lewat sudo (Tachys tidak perlu di-restart)
SMART_ASKED=0    # pertanyaan hanya diajukan sekali per sesi

# Panggil smartctl, otomatis lewat sudo jika pengguna memilih opsi itu
smart() {
    if [ "$SMART_SUDO" = 1 ]; then
        sudo "$SMARTCTL_BIN" "$@"
    else
        "$SMARTCTL_BIN" "$@"
    fi
}

# Jalankan ulang seluruh Tachys sebagai root
restart_as_root() {
    local self v
    local -a env_args=()
    self="$SCRIPT_DIR/$(basename "${TACHYS_SELF:-$0}")"

    # teruskan variabel sesi supaya tes keyboard (SDL) dan audio tetap jalan sebagai root
    for v in DISPLAY XAUTHORITY WAYLAND_DISPLAY XDG_RUNTIME_DIR DBUS_SESSION_BUS_ADDRESS TERM; do
        if [ -n "${!v:-}" ]; then env_args+=("$v=${!v}"); fi
    done

    echo "[INFO] Menjalankan ulang Tachys sebagai root ..."
    cleanup
    exec sudo env -u TACHYS_FIXED -u TACHYS_SELF "${env_args[@]}" bash "$self"
}

# Tanyakan cara mendapatkan akses root untuk smartctl (sekali per sesi)
ask_root_for_smart() {
    [ "$EUID" -eq 0 ] && return 0

    if [ "$SMART_SUDO" = 1 ]; then
        # sesi sudo bisa kedaluwarsa; segarkan agar tidak minta password di tengah scan
        sudo -v 2>/dev/null || SMART_SUDO=0
        [ "$SMART_SUDO" = 1 ] && return 0
    fi

    if [ "$SMART_ASKED" = 1 ]; then
        echo "[WARN] Berjalan tanpa root, data SMART mungkin tidak lengkap."
        echo
        return 0
    fi
    SMART_ASKED=1

    echo "[WARN] smartctl butuh akses root untuk membaca data SMART."
    echo "       Tanpa root, data bisa tidak lengkap atau disk tidak terdeteksi."
    echo
    echo "Pilih cara melanjutkan:"
    echo "  1. Jalankan ulang seluruh Tachys dengan sudo"
    echo "  2. Tidak usah ulang Tachys, pakai sudo hanya untuk cek disk ini"
    echo "  3. Lanjut tanpa root"
    echo

    if ! command -v sudo >/dev/null 2>&1; then
        echo "[ERROR] 'sudo' tidak ditemukan. Melanjutkan tanpa root."
        echo "        (Alternatif: jalankan 'su -c \"bash Tachys.sh\"' lalu buka menu ini lagi.)"
        echo
        return 0
    fi

    local choice
    read -r -p "Pilihan [1-3, Enter = 2]: " choice
    echo

    case "${choice:-2}" in
        1)
            if sudo -v; then
                restart_as_root   # tidak kembali jika berhasil
            fi
            echo "[ERROR] Gagal mendapatkan akses sudo. Melanjutkan tanpa root."
            ;;
        2)
            if sudo -v; then
                SMART_SUDO=1
                echo "[INFO] OK, sudo dipakai hanya untuk smartctl."
            else
                echo "[ERROR] Gagal mendapatkan akses sudo. Melanjutkan tanpa root."
            fi
            ;;
        3)
            echo "[INFO] Melanjutkan tanpa root."
            ;;
        *)
            echo "[WARN] Pilihan tidak dikenali, melanjutkan tanpa root."
            ;;
    esac
    echo
    return 0
}

run_disk_health() {
    echo "[INFO] Memeriksa kesehatan HDD/SSD (SMART) ..."
    echo

    if ! SMARTCTL_BIN="$(find_tool smartctl)"; then
        echo "[ERROR] Tool 'smartctl' tidak ditemukan di sistem ini."
        echo
        echo "Silakan install terlebih dahulu:"
        echo "  Ubuntu/Debian : sudo apt install smartmontools"
        echo "  Fedora        : sudo dnf install smartmontools"
        echo "  Arch          : sudo pacman -S smartmontools"
        echo
        echo "Setelah terinstall, jalankan kembali menu ini."
        return 1
    fi

    ask_root_for_smart

    local scan_result
    scan_result="$(smart --scan 2>/dev/null | awk '{print $1}')"

    if [ -z "$scan_result" ]; then
        echo "[INFO] smartctl --scan tidak menemukan device (normal untuk eMMC / USB)."
        echo "       Memakai daftar disk dari lsblk ..."
        echo
        if command -v lsblk >/dev/null 2>&1; then
            scan_result="$(lsblk -dno NAME,TYPE 2>/dev/null \
                | awk '$2=="disk" {print "/dev/"$1}')"
        fi
    fi

    # buang device virtual dan partisi khusus eMMC (boot0/boot1/rpmb)
    scan_result="$(printf '%s\n' "$scan_result" \
        | grep -Ev '/(loop|ram|zram|sr)[0-9]*$|/mmcblk[0-9]+(boot[0-9]+|rpmb)$')"

    if [ -z "$scan_result" ]; then
        echo "[ERROR] Tidak ada device disk yang terdeteksi sama sekali."
        return 1
    fi

    local dev name info alt model size tran rota kind
    local pat='overall-health|SMART/Health Information|Percentage Used|Reallocated_Sector'

    for dev in $scan_result; do
        name="${dev##*/}"
        model=""; size=""; tran=""; rota=""
        if command -v lsblk >/dev/null 2>&1; then
            model="$(lsblk -dno MODEL "$dev" 2>/dev/null | sed 's/[[:space:]]*$//')"
            size="$(lsblk -dno SIZE "$dev" 2>/dev/null | tr -d ' ')"
            tran="$(lsblk -dno TRAN "$dev" 2>/dev/null | tr -d ' ')"
            rota="$(lsblk -dno ROTA "$dev" 2>/dev/null | tr -d ' ')"
        fi
        case "$name" in
            mmcblk*) kind="eMMC / SD card" ;;
            nvme*)   kind="NVMe SSD" ;;
            *)
                if [ "$tran" = "usb" ]; then kind="USB (flashdisk / disk eksternal)"
                elif [ "$rota" = "1" ]; then kind="HDD"
                else kind="SSD"
                fi
                ;;
        esac

        echo "════════════════════════════════════════════════════════════"
        echo "Device: $dev"
        echo "════════════════════════════════════════════════════════════"

        info="$(smart -i -H -A "$dev" 2>/dev/null)"
        if ! grep -qiE "$pat" <<< "$info"; then
            # bridge USB-SATA sering butuh mode -d sat
            alt="$(smart -d sat -i -H -A "$dev" 2>/dev/null)"
            if grep -qiE "$pat" <<< "$alt"; then
                info="$alt"
            fi
        fi

        if ! grep -qiE "$pat" <<< "$info"; then
            [ -n "$model" ] && echo "Model         : $model"
            [ -n "$size" ]  && echo "Ukuran        : $size"
            echo "Tipe          : $kind"
            echo "Status SMART  : tidak didukung oleh device ini"

            # eMMC punya indikator usia pakai sendiri lewat sysfs
            local lt="/sys/block/$name/device/life_time" eol="/sys/block/$name/device/pre_eol_info"
            if [ -r "$lt" ] || [ -r "$eol" ]; then
                local a b v e
                if read -r a b < "$lt" 2>/dev/null && [ -n "${a:-}" ]; then
                    v=$(( 16#${a#0x} ))
                    if   [ "$v" -eq 0 ];  then echo "Usia Pakai    : tidak dilaporkan oleh eMMC"
                    elif [ "$v" -le 10 ]; then echo "Usia Pakai    : sekitar $(( (v-1)*10 ))-$(( v*10 ))% terpakai (eMMC)"
                    else                       echo "Usia Pakai    : melebihi estimasi usia pakai! (eMMC)"
                    fi
                fi
                if read -r e < "$eol" 2>/dev/null && [ -n "${e:-}" ]; then
                    case "$e" in
                        0x01) echo "Cadangan Blok : normal (eMMC)" ;;
                        0x02) echo "Cadangan Blok : [WARN] 80% cadangan blok sudah terpakai (eMMC)" ;;
                        0x03) echo "Cadangan Blok : [WARN] cadangan blok hampir habis, segera backup (eMMC)" ;;
                        *)    echo "Cadangan Blok : tidak dilaporkan ($e)" ;;
                    esac
                fi
            else
                echo "              (Wajar untuk flashdisk USB, SD card, dan eMMC: tidak punya fitur SMART.)"
            fi
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


# Tampilkan driver, modul, bus, dan nama perangkat WiFi card
show_wifi_driver() {
    local iface="$1"
    local devdir="/sys/class/net/$iface/device"
    local driver="" module="" bus="" hw="" ver="" fw="" slot="" vid="" pid="" bin

    if [ -L "$devdir/driver" ]; then
        driver="$(basename "$(readlink -f "$devdir/driver")")"
    elif [ -r "$devdir/uevent" ]; then
        driver="$(sed -n 's/^DRIVER=//p' "$devdir/uevent" 2>/dev/null | head -n 1)"
    fi

    if [ -L "$devdir/driver/module" ]; then
        module="$(basename "$(readlink -f "$devdir/driver/module")")"
    fi

    if [ -L "$devdir/subsystem" ]; then
        bus="$(basename "$(readlink -f "$devdir/subsystem")")"
    fi

    # Nama chipset / perangkat
    case "$bus" in
        pci)
            slot="$(basename "$(readlink -f "$devdir")")"
            if bin="$(find_tool lspci)"; then
                hw="$("$bin" -s "$slot" 2>/dev/null | sed 's/^[^ ]* [^:]*: //')"
            fi
            if [ -z "$hw" ]; then
                read_sys "$devdir/vendor" vid; read_sys "$devdir/device" pid
                [ -n "$vid" ] && hw="ID ${vid#0x}:${pid#0x} (install 'pciutils' untuk nama lengkap)"
            fi
            ;;
        usb)
            read_sys "$devdir/../idVendor" vid; read_sys "$devdir/../idProduct" pid
            if [ -n "$vid" ] && bin="$(find_tool lsusb)"; then
                hw="$("$bin" -d "$vid:$pid" 2>/dev/null | sed 's/^Bus .* ID [0-9a-fA-F:]* //')"
            fi
            [ -z "$hw" ] && [ -n "$vid" ] && hw="ID $vid:$pid"
            ;;
        *)
            read_sys "$devdir/vendor" vid; read_sys "$devdir/device" pid
            [ -n "$vid" ] && hw="ID ${vid#0x}:${pid#0x}"
            ;;
    esac

    # Versi driver & firmware (tidak butuh root)
    if bin="$(find_tool ethtool)"; then
        local et
        et="$("$bin" -i "$iface" 2>/dev/null)"
        if [ -n "$et" ]; then
            [ -z "$driver" ] && driver="$(awk -F': ' '$1=="driver"{print $2; exit}' <<< "$et")"
            ver="$(awk -F': ' '$1=="version"{print $2; exit}' <<< "$et")"
            fw="$(awk -F': ' '$1=="firmware-version"{print $2; exit}' <<< "$et")"
            [ "$fw" = "N/A" ] && fw=""
        fi
    fi

    if [ -n "$driver" ]; then
        printf '%-15s: %s\n' "Driver" "$driver"
        if [ -n "$module" ] && [ "$module" != "$driver" ]; then
            printf '%-15s: %s\n' "Modul Kernel" "$module"
        fi
    else
        printf '%-15s: %s\n' "Driver" "tidak terdeteksi"
        echo "[WARN] Tidak ada driver yang terikat ke WiFi card ini (belum terpasang / gagal dimuat)."
    fi
    [ -n "$bus" ] && printf '%-15s: %s\n' "Bus" "${bus^^}"
    [ -n "$hw" ]  && printf '%-15s: %s\n' "Perangkat" "$hw"
    [ -n "$ver" ] && printf '%-15s: %s\n' "Versi Driver" "$ver"
    [ -n "$fw" ]  && printf '%-15s: %s\n' "Firmware" "$fw"
    return 0
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

        # Hardware mungkin ada tapi driver belum terpasang -> tampilkan dari lspci
        local lspci_bin hw_found
        if lspci_bin="$(find_tool lspci)"; then
            hw_found="$("$lspci_bin" -k 2>/dev/null | awk '
                /^[0-9a-fA-F]/ { show = ($0 ~ /Network controller|Wireless|802\.11/) }
                show { print }')"
            if [ -n "$hw_found" ]; then
                echo
                echo "[INFO] Perangkat jaringan nirkabel terdeteksi di hardware (PCI):"
                echo "$hw_found" | sed 's/^/       /'
                echo "       Jika tidak ada baris 'Kernel driver in use', driver belum terpasang."
            fi
        fi
        return 1
    fi

    echo "Interface WiFi : $wifi_iface"
    show_wifi_driver "$wifi_iface"

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


# Kumpulkan folder dasar untuk pencarian: lokasi skrip + 3 tingkat folder induknya
search_roots() {
    local d="$SCRIPT_DIR" i
    for i in 1 2 3 4; do
        printf '%s\n' "$d"
        [ "$d" = "/" ] && break
        d="$(dirname "$d")"
    done
}

# Cari binary keyboard-tester yang sudah jadi (file biasa, bukan .c)
find_keyboard_binary() {
    local r c
    while IFS= read -r r; do
        c="$(find "$r" -maxdepth 5 -type f -name 'keyboard-tester' \
                 -not -path '*/.git/*' 2>/dev/null | head -n 1)"
        if [ -n "$c" ]; then
            printf '%s' "$c"
            return 0
        fi
    done < <(search_roots)
    return 1
}

# Cari source keyboard-tester.c untuk dibuild jika binary tidak ada
find_keyboard_source() {
    local r c
    while IFS= read -r r; do
        c="$(find "$r" -maxdepth 5 -type f -name 'keyboard-tester.c' \
                 -not -path '*/.git/*' 2>/dev/null | head -n 1)"
        if [ -n "$c" ]; then
            printf '%s' "$c"
            return 0
        fi
    done < <(search_roots)
    return 1
}

build_keyboard_tester() {
    local src="$1" out="$2"

    command -v gcc >/dev/null 2>&1 || { echo "[ERROR] gcc tidak ditemukan. sudo apt install build-essential"; return 1; }
    command -v sdl2-config >/dev/null 2>&1 || { echo "[ERROR] SDL2 dev tidak ditemukan. sudo apt install libsdl2-dev libsdl2-ttf-dev"; return 1; }

    echo "[INFO] Binary belum ada, membangun dari source: $src"
    # shellcheck disable=SC2046
    if ! gcc -Wall -O2 $(sdl2-config --cflags) "$src" -o "$out" \
            -lm $(sdl2-config --libs) -lSDL2_ttf; then
        echo "[ERROR] Build gagal. Pastikan: sudo apt install build-essential libsdl2-dev libsdl2-ttf-dev"
        return 1
    fi
    return 0
}

run_keyboard_tester() {
    local src_app dst_app="$TMP_DIR/keyboard-tester" src_c

    echo "[INFO] Menyiapkan Keyboard Tester ..."

    if ! mkdir -p "$TMP_DIR"; then
        echo "[ERROR] Gagal membuat direktori sementara: $TMP_DIR"
        return 1
    fi

    if src_app="$(find_keyboard_binary)"; then
        echo "[INFO] Ditemukan: $src_app"
        if [ ! -x "$dst_app" ] || [ "$src_app" -nt "$dst_app" ]; then
            if ! cp "$src_app" "$dst_app" || ! chmod +x "$dst_app"; then
                echo "[ERROR] Gagal menyalin/mengatur permission ke $TMP_DIR"
                return 1
            fi
        fi
    elif src_c="$(find_keyboard_source)"; then
        build_keyboard_tester "$src_c" "$dst_app" || return 1
    else
        echo "[ERROR] keyboard-tester (binary maupun keyboard-tester.c) tidak ditemukan."
        echo "        Lokasi skrip   : $SCRIPT_DIR"
        echo "        Folder dicari  :"
        search_roots | sed 's/^/          /'
        echo "        Isi folder skrip:"
        ls -la "$SCRIPT_DIR" 2>&1 | sed 's/^/          /'
        return 1
    fi

    if command -v ldd >/dev/null 2>&1; then
        local missing
        missing="$(ldd "$dst_app" 2>/dev/null | awk '/not found/ {print $1}')"
        if [ -n "$missing" ]; then
            echo "[ERROR] Library berikut belum terpasang:"
            echo "$missing" | sed 's/^/        /'
            echo "        Install: sudo apt install libsdl2-2.0-0 libsdl2-ttf-2.0-0"
            return 1
        fi
    fi

    echo "[INFO] Menjalankan Keyboard Tester ..."
    if ! "$dst_app"; then
        echo "[ERROR] Keyboard Tester gagal dijalankan atau keluar dengan error."
        echo "        Jika 'Exec format error', build ulang di mesin ini dengan 'make'."
        return 1
    fi

    echo "[INFO] Keyboard Tester selesai."
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

show_menu() {
    local C_SUB="\033[0;36m"
    local C_TEAL="\033[0;36m"
    local C_LINE="\033[1;32m"
    local C_RST="\033[0m"
    local LINE="════════════════════════════════════════════════════════════════════════════"

    [ "$TERM_COLS" -lt 77 ] && LINE="${LINE:0:$(( TERM_COLS - 1 ))}"

    [ "$MINI" = 1 ] || echo -e "${C_LINE}${LINE}${C_RST}"
    echo -e "${C_SUB}        Pilih tool yang ingin dijalankan:${C_RST}"
    blank
    if [ "$MENU2" = 1 ]; then
        printf "${C_TEAL}  %-30s%s${C_RST}\n" "1. Cek Kesehatan HDD/SSD" "5. Cek Kesehatan Baterai"
        printf "${C_TEAL}  %-30s%s${C_RST}\n" "2. Cek Status WiFi Card"  "6. Cek Program Berat"
        printf "${C_TEAL}  %-30s%s${C_RST}\n" "3. Tes Keyboard"          "0. Keluar"
        printf "${C_TEAL}  %-30s%s${C_RST}\n" "4. Tes Audio"             ""
    else
        echo -e "${C_TEAL}  1. Cek Kesehatan HDD/SSD${C_RST}"
        echo -e "${C_TEAL}  2. Cek Status WiFi Card${C_RST}"
        echo -e "${C_TEAL}  3. Tes Keyboard${C_RST}"
        echo -e "${C_TEAL}  4. Tes Audio${C_RST}"
        echo -e "${C_TEAL}  5. Cek Kesehatan Baterai${C_RST}"
        echo -e "${C_TEAL}  6. Cek Program Berat${C_RST}"
        echo -e "${C_TEAL}  0. Keluar${C_RST}"
    fi
    blank
    [ "$MINI" = 1 ] || echo -e "${C_LINE}${LINE}${C_RST}"
    blank
}

# Pilih tampilan terbesar yang muat penuh di jendela (tanpa scroll / terpotong).
# Urutan: asli -> rapat -> menu 2 kolom -> tanpa ASCII -> ringkas.
show_screen() {
    get_term_size
    local mode out n
    for mode in roomy tight twocol noart mini; do
        BLANKS=1; ART=1; MENU2=0; MINI=0
        case "$mode" in
            tight)  BLANKS=0 ;;
            twocol) BLANKS=0; MENU2=1 ;;
            noart)  BLANKS=0; ART=0 ;;
            mini)   BLANKS=0; ART=0; MINI=1 ;;
        esac
        [ "$mode" = mini ] && break
        # banner ASCII lebar 77 kolom, jadi butuh minimal 78 kolom
        if [ "$ART" = 1 ] && [ "$TERM_COLS" -lt 78 ]; then continue; fi
        out="$(show_banner; show_menu; echo x)"
        n="$(printf '%s\n' "$out" | wc -l)"
        # n = baris terpakai termasuk baris prompt; sisakan 1 baris cadangan
        if [ "$(( n + 1 ))" -le "$TERM_ROWS" ]; then break; fi
    done
    show_banner
    show_menu
}

maximize_window

while true; do
    show_screen

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
            echo "[INFO] Menutup Tachys. Sampai jumpa!"
            exit 0
            ;;
        *)
            echo "[ERROR] Pilihan tidak dikenali: $pilihan"
            ;;
    esac

    echo
    read -r -p "Tekan Enter untuk kembali ke menu ..." _
done