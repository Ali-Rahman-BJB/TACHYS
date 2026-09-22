#!/bin/bash
#
# Tachys.sh
# Menu utama Tachys - Portable Diagnostic Toolkit (Linux)
#
# Struktur flashdisk yang diasumsikan:
#   TACHYS/
#   ├── Linux/
#   │   └── Tachys.sh              <- script ini
#   └── Application/
#       └── LINUX/
#           └── keyboard-tester/
#               └── keyboard-tester
#
# Catatan penting soal flashdisk vfat/FAT32:
#   Permission "execute" tidak tersimpan di flashdisk vfat, jadi
#   setiap binary yang mau dijalankan harus DI-COPY dulu ke /tmp,
#   baru diberi izin execute (chmod +x), baru dijalankan dari /tmp.
#
# set -u          : error jika memakai variabel yang belum didefinisikan
# set -o pipefail : tangkap error di dalam pipe (perintah | perintah)
#
# CATATAN: "set -e" sengaja TIDAK dipakai di sini, karena ini adalah
# menu yang harus tetap hidup (loop) walau salah satu pilihan gagal.
# Setiap error ditangani manual dengan pengecekan if/return.
set -u
set -o pipefail

# ------------------------------------------------------------------
# Lokasi script & lokasi root flashdisk
# ------------------------------------------------------------------
# Tidak hardcode path, karena mount point flashdisk bisa berbeda-beda
# di tiap komputer (mis. /run/media/USER/TACHYS, /media/USER/TACHYS, dll).
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# Tachys.sh ada di dalam folder "Linux/", sedangkan "Application/"
# ada satu level di atasnya (root flashdisk) -> naik satu folder ("..").
FLASHDISK_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# ------------------------------------------------------------------
# Lokasi file sementara di /tmp (tempat "kerja" tool-tool Tachys)
# ------------------------------------------------------------------
TMP_DIR="/tmp/Tachys"

# ------------------------------------------------------------------
# Bersihkan folder sementara setiap kali script ditutup,
# baik ditutup normal (pilih Keluar) maupun ditutup paksa (Ctrl+C).
# ------------------------------------------------------------------
cleanup() {
    if [ -d "$TMP_DIR" ]; then
        rm -rf "$TMP_DIR"
    fi
}
trap cleanup EXIT

# ------------------------------------------------------------------
# Tampilan judul/banner Tachys (ASCII art "SMK PGRI 1 MARTAPURA")
# ------------------------------------------------------------------
# Catatan: karakter blok (█) adalah karakter UTF-8 biasa, aman
# ditampilkan di hampir semua terminal Linux modern. Kalau di
# suatu komputer tampilannya jadi kotak-kotak aneh, itu tandanya
# terminal tersebut tidak diset locale UTF-8 (jarang terjadi).
show_banner() {
    clear

    # Warna ala terminal "hacker" (hijau khas), plus reset di akhir.
    # \033[1;32m -> hijau terang bold, \033[0;36m -> cyan, \033[0m -> reset
    local C_LINE="\033[1;32m"
    local C_ART="\033[1;32m"
    local C_SUB="\033[0;36m"
    local C_RST="\033[0m"

    local LINE="════════════════════════════════════════════════════════════════════════════"

    echo -e "${C_LINE}${LINE}${C_RST}"
    echo -e "${C_ART}"
    cat << 'BANNER'
███████╗███╗   ███╗██╗  ██╗    ██████╗  ██████╗ ██████╗ ██╗     ██╗    ███╗   ███╗ █████╗ ██████╗ ████████╗ █████╗ ██████╗ ██╗   ██╗██████╗  █████╗
██╔════╝████╗ ████║██║ ██╔╝    ██╔══██╗██╔════╝ ██╔══██╗██║    ███║    ████╗ ████║██╔══██╗██╔══██╗╚══██╔══╝██╔══██╗██╔══██╗██║   ██║██╔══██╗██╔══██╗
███████╗██╔████╔██║█████╔╝     ██████╔╝██║  ███╗██████╔╝██║    ╚██║    ██╔████╔██║███████║██████╔╝   ██║   ███████║██████╔╝██║   ██║██████╔╝███████║
╚════██║██║╚██╔╝██║██╔═██╗     ██╔═══╝ ██║   ██║██╔══██╗██║     ██║    ██║╚██╔╝██║██╔══██║██╔══██╗   ██║   ██╔══██║██╔═══╝ ██║   ██║██╔══██╗██╔══██║
███████║██║ ╚═╝ ██║██║  ██╗    ██║     ╚██████╔╝██║  ██║██║     ██║    ██║ ╚═╝ ██║██║  ██║██║  ██║   ██║   ██║  ██║██║     ╚██████╔╝██║  ██║██║  ██║
╚══════╝╚═╝     ╚═╝╚═╝  ╚═╝    ╚═╝      ╚═════╝ ╚═╝  ╚═╝╚═╝     ╚═╝    ╚═╝     ╚═╝╚═╝  ╚═╝╚═╝  ╚═╝   ╚═╝   ╚═╝  ╚═╝╚═╝      ╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═╝
BANNER
    echo -e "${C_RST}"
    echo -e "${C_LINE}${LINE}${C_RST}"
    echo -e "${C_SUB}        TACHYS - Portable Diagnostic Toolkit (Linux)${C_RST}"
    echo -e "${C_LINE}${LINE}${C_RST}"
    echo
}

# ------------------------------------------------------------------
# MENU 1: Keyboard Tester
# Alur: cari executable -> copy ke /tmp -> chmod +x -> jalankan
# ------------------------------------------------------------------
run_keyboard_tester() {
    local src_app="$FLASHDISK_ROOT/Application/LINUX/keyboard-tester/keyboard-tester"
    local dst_app="$TMP_DIR/keyboard-tester"

    echo "[INFO] Menyiapkan Keyboard Tester ..."

    # 1. Pastikan file ada di flashdisk
    if [ ! -f "$src_app" ]; then
        echo "[ERROR] File keyboard-tester tidak ditemukan di:"
        echo "        $src_app"
        echo "        Pastikan struktur folder flashdisk masih sesuai:"
        echo "        TACHYS/Application/LINUX/keyboard-tester/keyboard-tester"
        return 1
    fi

    # 2. Siapkan folder sementara
    if ! mkdir -p "$TMP_DIR"; then
        echo "[ERROR] Gagal membuat direktori sementara: $TMP_DIR"
        return 1
    fi

    # 3. Copy executable ke /tmp
    if ! cp "$src_app" "$dst_app"; then
        echo "[ERROR] Gagal menyalin file dari flashdisk ke $TMP_DIR"
        echo "        Kemungkinan penyebab: flashdisk terlepas, ruang /tmp penuh,"
        echo "        atau tidak ada izin tulis ke /tmp."
        return 1
    fi

    # 4. Beri izin execute
    if ! chmod +x "$dst_app"; then
        echo "[ERROR] Gagal memberikan permission execute pada $dst_app"
        return 1
    fi

    # 5. Jalankan dari /tmp (bukan dari flashdisk)
    echo "[INFO] Menjalankan Keyboard Tester ..."
    if ! "$dst_app"; then
        echo "[ERROR] Keyboard Tester gagal dijalankan atau keluar dengan error."
        return 1
    fi

    echo "[INFO] Keyboard Tester selesai."
    return 0
}

# ------------------------------------------------------------------
# MENU 2: Cek Kesehatan Baterai
# Membaca langsung dari /sys/class/power_supply/ (bawaan kernel Linux,
# tidak perlu install apa pun). Sebagai tambahan, jika tool "upower"
# tersedia di sistem, dipakai untuk info yang lebih lengkap.
# ------------------------------------------------------------------
run_battery_health() {
    echo "[INFO] Memeriksa kesehatan baterai ..."
    echo

    # Cari folder baterai, misal BAT0, BAT1, dst.
    local bat_dirs=(/sys/class/power_supply/BAT*)

    # Jika pola di atas tidak match apa pun, bash akan mengembalikan
    # string literalnya sendiri -> kita cek keberadaan foldernya.
    if [ ! -d "${bat_dirs[0]}" ]; then
        echo "[WARN] Tidak ditemukan baterai di sistem ini."
        echo "       (Wajar jika ini adalah PC desktop tanpa baterai.)"
        return 1
    fi

    # Bisa saja ada lebih dari satu baterai (laptop tertentu)
    for bat in "${bat_dirs[@]}"; do
        local name
        name="$(basename "$bat")"
        echo "--- Baterai: $name ---"

        # Status pengisian (Charging/Discharging/Full/dll)
        if [ -f "$bat/status" ]; then
            echo "Status        : $(cat "$bat/status")"
        fi

        # Kapasitas saat ini (dalam persen)
        if [ -f "$bat/capacity" ]; then
            echo "Kapasitas kini: $(cat "$bat/capacity")%"
        fi

        # Kesehatan baterai dihitung dari kapasitas penuh saat ini
        # dibanding kapasitas penuh rancangan pabrik (design capacity).
        # Beberapa sistem pakai satuan energy_*, sebagian pakai charge_*.
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
            # Hitung persentase kesehatan pakai awk (aman untuk desimal)
            local health
            health="$(awk -v f="$full" -v d="$design" 'BEGIN { printf "%.1f", (f/d)*100 }')"
            echo "Kesehatan     : ${health}% (dibanding kapasitas pabrik)"
        else
            echo "Kesehatan     : tidak tersedia dari sistem ini"
        fi

        # Jumlah siklus charge, jika tersedia
        if [ -f "$bat/cycle_count" ]; then
            local cycles
            cycles="$(cat "$bat/cycle_count")"
            if [ "$cycles" != "0" ]; then
                echo "Cycle count   : $cycles"
            fi
        fi

        echo
    done

    # Info tambahan dari "upower" HANYA jika sudah terpasang di sistem.
    # Tidak menginstall apa pun secara otomatis (sesuai aturan Tachys).
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

# ------------------------------------------------------------------
# Tampilkan daftar pilihan menu
# ------------------------------------------------------------------
show_menu() {
    echo "Pilih tool yang ingin dijalankan:"
    echo
    echo "  1) Keyboard Tester"
    echo "  2) Cek Kesehatan Baterai"
    echo "  0) Keluar"
    echo
}

# ------------------------------------------------------------------
# LOOP UTAMA: tampilkan menu terus-menerus sampai user memilih Keluar
# ------------------------------------------------------------------
while true; do
    show_banner
    show_menu

    read -r -p "Masukkan pilihan [0-2]: " pilihan
    echo

    case "$pilihan" in
        1)
            run_keyboard_tester
            ;;
        2)
            run_battery_health
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