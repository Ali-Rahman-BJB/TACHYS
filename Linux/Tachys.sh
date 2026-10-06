#!/usr/bin/env bash
if [ -z "${TACHYS_FIXED:-}" ] && grep -q $'\r' "$0" 2>/dev/null; then export TACHYS_FIXED=1; if sed -i 's/\r$//' "$0" 2>/dev/null; then exec bash "$0" "$@"; else export TACHYS_SELF="$0"; _t="$(mktemp)"; export TACHYS_TMPSELF="$_t"; tr -d '\r' < "$0" > "$_t"; exec bash "$_t" "$@"; fi; fi;
set -u
set -o pipefail

SCRIPT_DIR="$(cd "$(dirname "${TACHYS_SELF:-$0}")" && pwd)"
# Folder aplikasi Linux (TACHYS/Application/LINUX), sejajar dengan folder skrip (TACHYS/Linux)
APP_DIR="$(dirname "$SCRIPT_DIR")/Application/LINUX"
TMP_DIR=""

cleanup() {
    if [ -n "$TMP_DIR" ] && [ -d "$TMP_DIR" ]; then
        rm -rf "$TMP_DIR"
    fi
    if [ -n "${TACHYS_TMPSELF:-}" ]; then
        rm -f "$TACHYS_TMPSELF"
    fi
    return 0
}
trap cleanup EXIT

read_sys() {
    [ -r "$1" ] || return 1
    local _v=""
    IFS= read -r _v < "$1" 2>/dev/null
    printf -v "$2" '%s' "$_v"
}

BLANKS=1
ART=1
MENU2=0
MINI=0
TERM_ROWS=24
TERM_COLS=80

blank() { [ "$BLANKS" = 1 ] && echo; return 0; }

# ============================================================
# TAMPILAN: BANNER, MENU, UKURAN TERMINAL
# ============================================================
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
░██████╗███╗░░░███╗██╗░░██╗  ██████╗░░██████╗░██████╗░██╗  ░░███╗░░
██╔════╝████╗░████║██║░██╔╝  ██╔══██╗██╔════╝░██╔══██╗██║  ░████║░░
╚█████╗░██╔████╔██║█████═╝░  ██████╔╝██║░░██╗░██████╔╝██║  ██╔██║░░
░╚═══██╗██║╚██╔╝██║██╔═██╗░  ██╔═══╝░██║░░╚██╗██╔══██╗██║  ╚═╝██║░░
██████╔╝██║░╚═╝░██║██║░╚██╗  ██║░░░░░╚██████╔╝██║░░██║██║  ███████╗
╚═════╝░╚═╝░░░░░╚═╝╚═╝░░╚═╝  ╚═╝░░░░░░╚═════╝░╚═╝░░╚═╝╚═╝  ╚══════╝
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
        if [ "$ART" = 1 ] && [ "$TERM_COLS" -lt 78 ]; then continue; fi
        out="$(show_banner; show_menu; echo x)"
        n="$(printf '%s\n' "$out" | wc -l)"
        if [ "$(( n + 1 ))" -le "$TERM_ROWS" ]; then break; fi
    done
    show_banner
    show_menu
}

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

# ============================================================
# 1. DISK HEALTH (SMART)
# ============================================================
SMARTCTL_BIN=""
SMART_SUDO=0
SMART_ASKED=0

smart() {
    if [ "$SMART_SUDO" = 1 ]; then
        sudo "$SMARTCTL_BIN" "$@"
    else
        "$SMARTCTL_BIN" "$@"
    fi
}

ask_root_for_smart() {
    [ "$EUID" -eq 0 ] && return 0

    if [ "$SMART_SUDO" = 1 ]; then
        if ! sudo -v 2>/dev/null; then
            SMART_SUDO=0
            echo "[WARN] Akses sudo habis, melanjutkan tanpa root (data mungkin tidak lengkap)."
            echo
        fi
        return 0
    fi

    [ "$SMART_ASKED" = 1 ] && return 0
    SMART_ASKED=1

    if ! command -v sudo >/dev/null 2>&1; then
        echo "[WARN] 'sudo' tidak ditemukan, data SMART mungkin tidak lengkap."
        echo
        return 0
    fi

    echo "[INFO] smartctl butuh akses root untuk membaca data SMART."
    if sudo -v; then
        SMART_SUDO=1
    else
        echo "[WARN] Gagal mendapat akses sudo, melanjutkan tanpa root (data mungkin tidak lengkap)."
    fi
    echo
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
                else if (temp == "" && l ~ /temperature_celsius/)               temp = $10
                else if (temp == "" && l ~ /^temperature:/)                     temp = $2
                else if (l ~ /power_on_hours/)                                  poweron = $10
                else if (l ~ /^power on hours:/)                                poweron = $4
                else if (l ~ /reallocated_sector_ct/)                           realloc = $10
                else if (l ~ /current_pending_sector/)                          pending = $10
                else if (l ~ /percentage used/)                                 pct_used = after_colon($0)
                else if (l ~ /available spare:/)                                spare = after_colon($0)
                else if (l ~ /^critical warning:/)                              crit = $3
                else if (l ~ /media and data integrity errors:/)                integ = $NF
                else if (l ~ /wear_leveling_count|media_wearout_indicator|percent_lifetime_remain|ssd_life_left/) {
                    life_name = $2; life = $4
                }
            }

            END {
                if (model != "")   printf "Model         : %s\n", model
                printf "Status SMART  : %s\n", (health != "" ? health : "tidak tersedia dari device ini")
                if (health != "" && toupper(health) !~ /PASSED|OK/)
                    print "[WARN] Status SMART bukan PASSED! Segera backup data."
                if (temp != "")    printf "Suhu          : %s C\n", temp
                if (poweron != "") printf "Power-On Hours: %s jam\n", poweron

                if (realloc != "") {
                    printf "Bad Sectors   : %s (realokasi), pending: %s\n", realloc, (pending != "" ? pending : "0")
                    if (realloc != "0" || (pending != "" && pending != "0"))
                        print "[WARN] Terdeteksi bad sector! Pertimbangkan backup data segera."
                }

                if (life != "")     printf "Sisa Umur SSD : %s%% (atribut %s)\n", life, life_name

                if (pct_used != "") {
                    printf "Wear Level    : %s terpakai dari usia pakai (NVMe)\n", pct_used
                    pu = pct_used; gsub(/[^0-9]/, "", pu)
                    if (pu + 0 >= 80) print "[WARN] Wear level NVMe sudah tinggi, pertimbangkan backup/penggantian."
                }
                if (spare != "")    printf "Spare Blocks  : %s tersisa (NVMe)\n", spare
                if (integ != "")    printf "Integrity Err : %s (NVMe)\n", integ
                if (crit != "" && crit != "0x00")
                    printf "[WARN] Critical Warning NVMe aktif (%s), segera backup data.\n", crit
            }
        ' <<< "$info"

        echo
    done

    echo "[INFO] Pemeriksaan SMART selesai."
    echo "       Status 'PASSED'/'OK' = sehat. Jika 'FAILED' atau ada banyak bad sector,"
    echo "       segera backup data dan pertimbangkan penggantian disk."
    return 0
}

# ============================================================
# 2. WIFI CHECK
# ============================================================
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
    echo "--- Uji gateway lokal (ping + packet loss) ---"
    if ! command -v ping >/dev/null 2>&1; then
        echo "[WARN] Tidak dapat melakukan ping karena utilitas 'ping' tidak tersedia."
    elif ! command -v ip >/dev/null 2>&1; then
        echo "[WARN] Utilitas 'ip' tidak tersedia, uji gateway dilewati."
    else
        local gw gw_out loss avg q
        gw="$(ip route show default dev "$wifi_iface" 2>/dev/null \
                | awk '{for (i = 1; i < NF; i++) if ($i == "via") { print $(i + 1); exit }}')"
        if [ -z "$gw" ]; then
            echo "[WARN] Tidak ada default gateway pada $wifi_iface (belum dapat IP / DHCP bermasalah)."
        else
            gw_out="$(ping -c 10 -i 0.2 -W 1 "$gw" 2>&1)"
            loss="$(grep -oE '[0-9]+(\.[0-9]+)?% packet loss' <<< "$gw_out" | grep -oE '^[0-9.]+')"
            avg="$(awk -F'/' '/^rtt|^round-trip/ {print $5; exit}' <<< "$gw_out")"
            if [ -z "$loss" ]; then
                echo "[WARN] Gagal membaca hasil ping ke gateway $gw."
            else
                q="$(awk -v l="$loss" 'BEGIN { if (l + 0 == 0) print "Baik"; else if (l + 0 <= 5) print "Ringan"; else print "Buruk" }')"
                echo "Gateway        : $gw${avg:+ (rata-rata ${avg} ms)}"
                echo "Packet Loss    : ${loss}% ($q)"
                echo "[INFO] Sebagian router memblokir ICMP, sehingga ping gateway bisa gagal padahal koneksi normal."
            fi
        fi
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

# ============================================================
# 3. KEYBOARD TESTER
# ============================================================
search_roots() {
    [ -d "$APP_DIR" ] && printf '%s\n' "$APP_DIR"
    local d="$SCRIPT_DIR" i
    for i in 1 2 3; do
        [ "$d" = "/" ] && break
        printf '%s\n' "$d"
        d="$(dirname "$d")"
    done
}

is_elf_binary() {
    [ -f "$1" ] || return 1
    [ "$(head -c 4 "$1" 2>/dev/null | od -An -tx1 | tr -d ' \n')" = "7f454c46" ]
}

find_keyboard_binary() {
    local r c
    while IFS= read -r r; do
        while IFS= read -r c; do
            [ -n "$c" ] || continue
            # Lewati binary non-Linux (mis. binary macOS di folder bin/ repo upstream)
            if is_elf_binary "$c"; then
                printf '%s' "$c"
                return 0
            fi
        done < <(find "$r" -maxdepth 4 -type f -name 'keyboard-tester' \
                     -not -path '*/.git/*' 2>/dev/null)
    done < <(search_roots)
    return 1
}

find_keyboard_source() {
    local r c
    while IFS= read -r r; do
        c="$(find "$r" -maxdepth 4 -type f -name 'keyboard-tester.c' \
                 -not -path '*/.git/*' 2>/dev/null | head -n 1)"
        if [ -n "$c" ]; then
            printf '%s' "$c"
            return 0
        fi
    done < <(search_roots)
    return 1
}

KT_TARBALL_URL="https://github.com/inflex/keyboard-tester/archive/refs/heads/master.tar.gz"
KT_GIT_URL="https://github.com/inflex/keyboard-tester.git"

keyboard_deps_ok() {
    command -v gcc >/dev/null 2>&1 || return 1
    command -v sdl2-config >/dev/null 2>&1 || return 1
    # Pastikan header SDL2_ttf juga ada
    # shellcheck disable=SC2046
    echo '#include <SDL_ttf.h>' | gcc $(sdl2-config --cflags) -E -x c - >/dev/null 2>&1 || return 1
    return 0
}

install_keyboard_deps() {
    keyboard_deps_ok && return 0

    local SUDO=""
    if [ "$EUID" -ne 0 ]; then
        if command -v sudo >/dev/null 2>&1; then
            SUDO="sudo"
        else
            echo "[ERROR] Dependensi belum lengkap dan 'sudo' tidak tersedia."
            echo "        Install manual: build-essential libsdl2-dev libsdl2-ttf-dev"
            return 1
        fi
    fi

    echo "[INFO] Dependensi build (gcc, SDL2, SDL2_ttf) belum lengkap, mencoba install otomatis ..."
    if command -v apt-get >/dev/null 2>&1; then
        $SUDO apt-get update && $SUDO apt-get install -y build-essential libsdl2-dev libsdl2-ttf-dev
    elif command -v dnf >/dev/null 2>&1; then
        $SUDO dnf install -y gcc make SDL2-devel SDL2_ttf-devel
    elif command -v pacman >/dev/null 2>&1; then
        $SUDO pacman -S --needed --noconfirm base-devel sdl2 sdl2_ttf
    elif command -v zypper >/dev/null 2>&1; then
        $SUDO zypper install -y gcc make libSDL2-devel libSDL2_ttf-devel
    else
        echo "[ERROR] Package manager tidak dikenali. Install manual: gcc, make, SDL2 dev, SDL2_ttf dev."
        return 1
    fi

    if ! keyboard_deps_ok; then
        echo "[ERROR] Dependensi masih belum lengkap setelah install."
        return 1
    fi
    return 0
}

# Mengunduh source keyboard-tester dari GitHub (inflex/keyboard-tester).
# Hanya path source (keyboard-tester.c) yang dicetak ke stdout; pesan ke stderr.
download_keyboard_source() {
    local base dest
    for base in "$APP_DIR" "${XDG_CACHE_HOME:-$HOME/.cache}/tachys"; do
        mkdir -p "$base" 2>/dev/null || continue
        [ -w "$base" ] || continue
        dest="$base/keyboard-tester"

        if [ -f "$dest/keyboard-tester.c" ]; then
            printf '%s' "$dest/keyboard-tester.c"
            return 0
        fi

        rm -rf "$dest" 2>/dev/null
        echo "[INFO] Mengunduh source keyboard-tester ke: $dest" >&2

        if command -v git >/dev/null 2>&1 \
            && git clone --depth 1 "$KT_GIT_URL" "$dest" >&2 2>&1; then
            :
        elif command -v curl >/dev/null 2>&1 \
            && mkdir -p "$dest" \
            && curl -fsSL "$KT_TARBALL_URL" | tar -xz --strip-components=1 -C "$dest" 2>/dev/null; then
            :
        elif command -v wget >/dev/null 2>&1 \
            && mkdir -p "$dest" \
            && wget -qO- "$KT_TARBALL_URL" | tar -xz --strip-components=1 -C "$dest" 2>/dev/null; then
            :
        else
            rm -rf "$dest" 2>/dev/null
            continue
        fi

        if [ -f "$dest/keyboard-tester.c" ]; then
            printf '%s' "$dest/keyboard-tester.c"
            return 0
        fi
        rm -rf "$dest" 2>/dev/null
    done

    echo "[ERROR] Gagal mengunduh keyboard-tester dari GitHub." >&2
    echo "        Pastikan internet aktif dan 'git' atau 'curl' atau 'wget' terpasang," >&2
    echo "        atau unduh manual: https://github.com/inflex/keyboard-tester" >&2
    return 1
}

build_keyboard_tester() {
    local src="$1" out="$2"

    install_keyboard_deps || return 1

    echo "[INFO] Binary belum ada, membangun dari source: $src"
    if ! gcc -Wall -O2 $(sdl2-config --cflags) "$src" -o "$out" \
            -lm $(sdl2-config --libs) -lSDL2_ttf; then
        echo "[ERROR] Build gagal. Pastikan: sudo apt install build-essential libsdl2-dev libsdl2-ttf-dev"
        return 1
    fi
    return 0
}

run_keyboard_tester() {
    local src_app dst_app src_c

    echo "[INFO] Menyiapkan Keyboard Tester ..."

    if [ -z "$TMP_DIR" ] || [ ! -d "$TMP_DIR" ]; then
        if ! TMP_DIR="$(mktemp -d /tmp/Tachys.XXXXXX 2>/dev/null)"; then
            TMP_DIR=""
            echo "[ERROR] Gagal membuat direktori sementara di /tmp"
            return 1
        fi
    fi
    dst_app="$TMP_DIR/keyboard-tester"

    if src_app="$(find_keyboard_binary)"; then
        echo "[INFO] Ditemukan: $src_app"
        if [ ! -x "$dst_app" ] || [ "$src_app" -nt "$dst_app" ]; then
            if ! cp "$src_app" "$dst_app" || ! chmod +x "$dst_app"; then
                echo "[ERROR] Gagal menyalin/mengatur permission ke $TMP_DIR"
                return 1
            fi
        fi
    else
        if ! src_c="$(find_keyboard_source)"; then
            echo "[INFO] keyboard-tester (binary/source) tidak ditemukan di folder aplikasi."
            echo "[INFO] Mengunduh dan membangun otomatis dari GitHub ..."
            if ! src_c="$(download_keyboard_source)"; then
                echo "        Lokasi skrip   : $SCRIPT_DIR"
                echo "        Folder dicari  :"
                search_roots | sed 's/^/          /'
                return 1
            fi
        fi
        build_keyboard_tester "$src_c" "$dst_app" || return 1

        # Simpan binary hasil build di samping source agar run berikutnya tidak build ulang
        cp "$dst_app" "$(dirname "$src_c")/keyboard-tester" 2>/dev/null \
            && echo "[INFO] Binary disimpan: $(dirname "$src_c")/keyboard-tester"
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

# ============================================================
# 4. AUDIO OUTPUT
# ============================================================
run_audio_output_test() {
    echo "[INFO] Menjalankan tes output audio ..."
    echo

    if ! command -v speaker-test >/dev/null 2>&1; then
        echo "[ERROR] Tool 'speaker-test' (paket alsa-utils) tidak ditemukan."
        echo
        echo "Silakan install terlebih dahulu:"
        echo "  Ubuntu/Debian : sudo apt install alsa-utils"
        echo "  Fedora        : sudo dnf install alsa-utils"
        echo "  Arch          : sudo pacman -S alsa-utils"
        return 1
    fi

    echo "[INFO] Memutar test tone per channel (Kiri/Kanan) selama beberapa detik ..."
    echo "[INFO] Tekan Ctrl+C jika ingin berhenti lebih awal."

    local rc
    trap ':' INT
    speaker-test -c 2 -t wav -l 1
    rc=$?
    trap - INT

    if [ "$rc" -ne 0 ] && [ "$rc" -ne 130 ]; then
        echo
        echo "[ERROR] speaker-test gagal (kode $rc)."
        echo "        Kemungkinan tidak ada output audio aktif atau driver/sound server bermasalah."
        return 1
    fi

    echo
    echo "[INFO] Jika Anda mendengar suara di kiri lalu kanan, output audio berfungsi normal."
    echo "       Tidak dengar suara? Cek volume/mute, headphone, dan default output device."
    return 0
}

# ============================================================
# 5. BATTERY HEALTH
# ============================================================
run_battery_health() {
    echo "[INFO] Memeriksa kesehatan baterai ..."
    echo

    local bat_dirs=(/sys/class/power_supply/BAT*)

    if [ ! -d "${bat_dirs[0]}" ]; then
        echo "[WARN] Tidak ditemukan baterai di sistem ini."
        echo "       (Wajar jika ini adalah PC desktop tanpa baterai.)"
        return 1
    fi

    local bat name status capacity full design cycles health rate

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
            if   [ "$health" -ge 800 ]; then rate="Baik"
            elif [ "$health" -ge 600 ]; then rate="Cukup, mulai menurun"
            else                             rate="Buruk, pertimbangkan ganti baterai"
            fi
            printf 'Kesehatan     : %d.%d%% (%s)\n' "$((health / 10))" "$((health % 10))" "$rate"
            printf 'Tingkat keausan: %d.%d%%\n' "$(( (1000 - health) / 10 ))" "$(( (1000 - health) % 10 ))"
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

# ============================================================
# 6. PROSES BERAT / ANTIVIRUS
# ============================================================
run_process_monitor() {
    echo "[INFO] Memeriksa program berat yang berjalan ..."
    echo

    local av_patterns="clamd|clamav|freshclam|avast|avgd|avguard|kaspersky|bitdefender|bdlogin|mcafee|sophos|comodo|eset|nod32|f-secure|rkhunter|chkrootkit|fail2ban"

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
            if (tolower(name) ~ ("^(" av ")")) {
                n_av++
                avl[n_av] = sprintf("%-8s %s", $1, name)
            }
            if ($3 + 0 > 20 || $4 + 0 > 20) {
                n_hv++
                hv[n_hv] = sprintf("%-8s %-15s %6s %6s", $1, name, $3, $4)
            }
        }

        END {
            print "--- 10 proses dengan penggunaan CPU tertinggi (rata-rata sejak proses dimulai) ---"
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

        if [ "$target_pid" -le 2 ] || [ "$target_pid" -eq "$$" ] || [ "$target_pid" -eq "$PPID" ]; then
            echo "[ERROR] PID $target_pid adalah proses sistem/Tachys sendiri, tidak boleh dimatikan."
            echo
            continue
        fi

        pname=""
        { read -r pname < "/proc/$target_pid/comm"; } 2>/dev/null

        if [ -z "$pname" ]; then
            echo "[ERROR] PID $target_pid tidak ditemukan (mungkin sudah berhenti)."
            echo
            continue
        fi

        if [ ! -s "/proc/$target_pid/cmdline" ]; then
            echo "[ERROR] PID $target_pid adalah kernel thread atau proses zombie, tidak bisa dimatikan."
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

# ============================================================
# MAIN LOOP
# ============================================================
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