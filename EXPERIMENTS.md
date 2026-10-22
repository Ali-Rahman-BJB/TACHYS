# Eksperimen & Hasil

Dokumen ini berisi data, hasil pengujian, tabel, dan diagram dari proses development dan testing **Tachys** (ταχύς, bahasa Yunani: "cepat"), toolkit diagnostik portabel berbasis script untuk pemeriksaan awal laptop. Tachys dikembangkan selama Praktik Kerja Lapangan (PKL) di Bandung Computer Banjarbaru, Indonesia, dan diuji pada **8–21 Oktober 2026**.

> **Catatan:** Flowchart dan screenshot dari laporan PKL tidak ditampilkan di sini. Alur program dijelaskan lewat teks dan tabel. Untuk flowchart lengkapnya, lihat laporan PKL.

## Daftar Isi

1. [Latar Belakang](#1-latar-belakang)
2. [Metodologi](#2-metodologi)
3. [Perangkat Uji](#3-perangkat-uji)
4. [Dukungan Fitur per Sistem Operasi](#4-dukungan-fitur-per-sistem-operasi)
5. [Hasil Uji Fungsional](#5-hasil-uji-fungsional)
6. [Efisiensi Waktu: Manual vs Tachys](#6-efisiensi-waktu-manual-vs-tachys)
7. [Kendala di Lapangan](#7-kendala-di-lapangan)
8. [Desain: Computational Thinking](#8-desain-computational-thinking)
9. [Desain: Alur Program](#9-desain-alur-program)
10. [Lingkungan Pengembangan & Dependensi](#10-lingkungan-pengembangan--dependensi)
11. [Keterbatasan](#11-keterbatasan)
12. [Kesimpulan & Pengembangan Lanjutan](#12-kesimpulan--pengembangan-lanjutan)

---

## 1. Latar Belakang

Sebelum ada Tachys, pemeriksaan awal laptop pelanggan dilakukan secara manual, satu langkah demi satu langkah. Setiap perangkat melewati rangkaian langkah yang sama:

| # | Langkah pemeriksaan manual | Cara pelaksanaan |
|---|----------------------------|------------------|
| 1 | Kesehatan storage (SSD/HDD) | Menjalankan Hard Disk Sentinel portable dari flash drive USB; lambat karena harus scan semua drive dulu |
| 2 | Wi-Fi adapter | Cek apakah driver sudah terpasang, lalu buka internet / YouTube untuk menguji koneksi |
| 3 | Keyboard | Membuka website keyboard tester di browser |
| 4 | Audio output | Memakai tab *Sounds* di Audio Settings, atau memutar video |
| 5 | Kesehatan baterai | Menjalankan laptop dengan baterai minimal 10 menit sambil memantau penurunan yang tidak wajar |
| 6 | Program berat (resource-intensive) | Memeriksa Task Manager dan menghentikan proses berat secara manual |
| 7 | Windows Security / Fast Startup | Menonaktifkan sementara Virus & Threat Protection dan Fast Startup lewat Settings / Control Panel |

**Masalah pada proses manual:**

- Langkah-langkahnya terpisah dan berulang, sehingga total waktu bertambah seiring jumlah perangkat.
- Hasil bergantung pada ketelitian teknisi, sehingga bisa tidak konsisten.
- Tidak ada logging, sehingga sulit melacak apa saja yang sudah dilakukan pada laptop pelanggan.
- Memakai flash drive USB dan tool eksternal di banyak laptop berisiko menyebarkan malware.
- Pemeriksaan dilakukan di perangkat pelanggan, sehingga privasi data harus dihormati.

**Tujuan:** toolkit yang ringan, portabel, dan non-destruktif, yang menjalankan semua pemeriksaan dari satu menu dan menampilkan hasil yang singkat dan mudah dibaca.

---

## 2. Metodologi

### 2.1 Tujuan pengujian

1. Memastikan setiap opsi menu berjalan sesuai desain di Windows dan Linux Ubuntu.
2. Memeriksa akurasi hasil pada laptop dengan kondisi dan keluhan yang berbeda-beda.
3. Membandingkan waktu pemeriksaan: manual vs Tachys.
4. Mengidentifikasi kendala di lapangan (security software, versi OS lama) beserta solusinya.

### 2.2 Setup pengujian

| Item | Detail |
|------|--------|
| Lokasi | Bandung Computer Banjarbaru |
| Periode | 8–21 Oktober 2026 |
| Perangkat | 18 laptop (17 Windows, 1 Linux Ubuntu), dari pelanggan, toko, dan penulis |
| Kondisi | Laptop sehat, laptop dengan masalah sistem, laptop dengan kerusakan hardware |
| Keluhan | Wi-Fi adapter lemah, performa lambat, masalah HDD/SSD |
| Persiapan | *Virus & Threat Protection* dinonaktifkan lebih dulu di setiap laptop, kecuali laptop dengan antivirus pihak ketiga yang sengaja dibiarkan aktif untuk melihat pengaruhnya |

### 2.3 Pengukuran waktu

- **Alat:** stopwatch di aplikasi Clock pada HP OPPO A5.
- **Sampel:** 5 laptop (ID01–ID05) dengan kondisi berbeda, masing-masing diukur **satu kali per metode** (manual dan Tachys), selalu oleh orang yang sama.
- **Langkah yang diukur (6):**
  1. Menjalankan HDD Sentinel dari flash drive USB milik toko
  2. Menghubungkan laptop ke Wi-Fi
  3. Menguji keyboard lewat website keyboard tester
  4. Menguji audio output lewat Sound Settings
  5. Membuka Task Manager untuk mencari antivirus / program berat
  6. Menonaktifkan Fast Startup lewat Control Panel
- **Tidak diukur:** pengecekan baterai 10 menit, karena durasinya tetap dan tidak bergantung pada metode.
- **Aturan start / stop:** stopwatch dimulai di desktop Windows tanpa aplikasi terbuka, bersamaan dengan aksi pertama tiap langkah. Stopwatch dihentikan saat langkah manual selesai, atau saat Tachys menampilkan hasilnya.
- **Reset:** laptop dikembalikan ke kondisi awal yang sama sebelum setiap pengukuran.
- **Pencatatan:** durasi tiap langkah dicatat di Microsoft Excel dan dijumlahkan per laptop.

### 2.4 Rumus efisiensi

Efisiensi waktu dihitung per laptop, lalu dirata-rata:

```
E = (Tm − Ta) / Tm × 100%
```

| Simbol | Arti |
|--------|------|
| `E` | Efisiensi waktu (%) |
| `Tm` | Waktu pemeriksaan manual (detik) |
| `Ta` | Waktu pemeriksaan otomatis dengan Tachys (detik) |

---

## 3. Perangkat Uji

### 3.1 Merek laptop (n = 18)

| Merek | Frekuensi | Persentase |
|-------|----------:|-----------:|
| Acer | 6 | 33,3% |
| Lenovo | 5 | 27,8% |
| ASUS | 4 | 22,2% |
| Advan | 1 | 5,6% |
| HP | 1 | 5,6% |
| Axioo | 1 | 5,6% |
| **Total** | **18** | **100,0%** |

Acer, Lenovo, dan ASUS bersama-sama mencakup 15 dari 18 laptop (83,3%), sesuai dengan merek yang umum masuk ke toko servis.

![Proporsi merek laptop yang diuji](docs/images/chart-laptop-brands.png)

### 3.2 Sistem operasi (n = 18)

| Sistem operasi | Frekuensi | Persentase |
|----------------|----------:|-----------:|
| Windows 11 Home | 6 | 33,3% |
| Windows 10 Pro | 4 | 22,2% |
| Windows 7 Ultimate | 3 | 16,7% |
| Windows 10 Home | 2 | 11,1% |
| Windows 11 Pro | 2 | 11,1% |
| Linux Ubuntu | 1 | 5,6% |
| **Total** | **18** | **100,0%** |

- Windows 10 dan 11 (didukung): **14 laptop (77,8%)**
- Windows 7 (tambahan, tidak didukung): **3 laptop (16,7%)**
- Linux Ubuntu: **1 laptop (5,6%)**, karena laptop Linux jarang ada di toko servis

![Jumlah laptop yang diuji berdasarkan sistem operasi](docs/images/chart-operating-systems.png)

---

## 4. Dukungan Fitur per Sistem Operasi

Tachys ditulis dengan **Bash** (Linux) dan **Batch** (Windows), sehingga tidak butuh runtime tambahan dan bisa langsung dijalankan dari flash drive USB.

| Menu | Fitur | Linux (`Tachys.sh`) | Windows (`Tachys.cmd`) |
|:----:|-------|:-------------------:|:----------------------:|
| – | Script install (`Install.sh`, `Uninstall.sh`) | ✅ | ❌ |
| `1` | Cek kesehatan SSD/HDD | ✅ | ✅ |
| `2` | Cek Wi-Fi adapter / konektivitas | ✅ | ✅ |
| `3` | Tes keyboard | ✅ | ✅ |
| `4` | Tes audio output | ✅ | ✅ |
| `5` | Cek kesehatan baterai | ✅ | ✅ |
| `6` | Cek proses berat (resource-intensive) | ✅ | ✅ |
| `7` | Nonaktifkan Fast Startup | ❌ | ✅ |
| `S` | Buka Windows Security | ❌ | ✅ |
| `0` | Keluar | ✅ | ✅ |

**Ruang lingkup:** Windows 10, Windows 11, dan Ubuntu Linux pada **laptop**. PC desktop, distro Linux lain, macOS, dan versi Windows lama tidak termasuk. Tachys tidak memuat perintah destruktif (tidak ada penghapusan data atau format).

---

## 5. Hasil Uji Fungsional

Setiap opsi menu (`S`, `1`–`7`, `0`) dijalankan di setiap perangkat. Tanda strip (`–`) berarti opsi tersebut tidak ada di OS itu.

### 5.1 Sistem operasi yang didukung (15 laptop)

**Hasil: 13 dari 15 laptop menjalankan semua opsi yang tersedia tanpa masalah.** Kegagalan hanya terjadi di dua laptop Windows, dan tidak ada laptop yang gagal di semua opsi.

| # | Model laptop | Sistem operasi | S | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 0 |
|--:|--------------|----------------|:-:|:-:|:-:|:-:|:-:|:-:|:-:|:-:|:-:|
| 1 | Advan Soulmate 1405 | Linux Ubuntu 26.04.1 LTS | – | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | – | ✅ |
| 2 | Acer Aspire Lite 14-37P | Windows 11 Home | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| 3 | Acer Aspire A314-21 | Windows 10 Home | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| 4 | ASUSTek X441BA | Windows 10 Home | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| 5 | Acer Aspire A314-22 | Windows 10 Pro | ❌ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| 6 | Lenovo 83DV | Windows 11 Home | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| 7 | ASUSTek TUF Gaming F15 FX506HCC | Windows 11 Home | ✅ | ✅ | ✅ | ✅ | ✅ | ❌ | ❌ | ✅ | ✅ |
| 8 | Lenovo 81X7 | Windows 11 Home | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| 9 | ASUSTek TUF Gaming FX504GE FX80GE 323 | Windows 11 Home | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| 10 | Lenovo 82V6 | Windows 11 Pro | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| 11 | ASUSTeK TUF GAMING FX504GD.322 | Windows 11 Pro | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| 12 | Lenovo 82KT | Windows 11 Home | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| 13 | Lenovo 20LNS0BN00 | Windows 10 Pro | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| 14 | HP ProBook 430 G1 | Windows 10 Pro | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| 15 | Acer Aspire A314-41 | Windows 10 Pro | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |

**Keterangan menu:** `S` Windows Security · `1` SSD/HDD · `2` Wi-Fi · `3` Keyboard · `4` Audio output · `5` Baterai · `6` Proses berat · `7` Fast Startup · `0` Keluar

**Rincian pengujian:** 14 laptop Windows (8 × Windows 11, 6 × Windows 10) dan 1 laptop Linux Ubuntu.

**Kedua kegagalan melibatkan security software** (lihat [Bagian 7](#7-kendala-di-lapangan)):

| Laptop | Opsi yang gagal | Penyebab |
|--------|-----------------|----------|
| Acer Aspire A314-22 (Windows 10 Pro) | `S` | Antivirus pihak ketiga (Smadav) dan akses ke Windows Security terbatas |
| ASUS TUF Gaming F15 FX506HCC (Windows 11 Home) | `5`, `6` | RAV Endpoint Protection menandai PowerShell sebagai *suspicious process* |

### 5.2 Tes tambahan: Windows 7 (3 laptop)

Windows 7 **tidak didukung**. Laptop ini diuji hanya untuk mengetahui batas kompatibilitas.

| # | Model laptop | Sistem operasi | S | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 0 |
|--:|--------------|----------------|:-:|:-:|:-:|:-:|:-:|:-:|:-:|:-:|:-:|
| 1 | Acer Aspire E1-432 | Windows 7 | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ |
| 2 | Acer Aspire 4349 | Windows 7 Ultimate | ✅ | ❌ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| 3 | Axioo Pico | Windows 7 Ultimate | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ |

Tachys tidak kompatibel dengan Windows 7. Tidak selalu gagal total, tetapi hasilnya tidak konsisten antar perangkat.

### 5.3 Ringkasan

| Kelompok | Laptop | Lolos semua | Gagal sebagian | Gagal total |
|----------|-------:|------------:|---------------:|------------:|
| Windows 10 / 11 + Linux (didukung) | 15 | 13 | 2 | 0 |
| Windows 7 (tidak didukung) | 3 | 0 | 1 | 2 |

---

## 6. Efisiensi Waktu: Manual vs Tachys

### 6.1 Baseline pemeriksaan manual

| ID | Laptop | Kondisi | Durasi (detik) | Durasi (menit) |
|----|--------|---------|---------------:|---------------:|
| ID01 | Acer Aspire L14-37P | Sangat baik | 226 | 3,77 |
| ID02 | Lenovo 20LNS0BN00 | Baik | 212 | 3,53 |
| ID03 | ASUSTeK TUF GAMING FX504GD.322 | Tampilan layar glitch | 364 | 6,07 |
| ID04 | Acer Aspire A314-22 | OS tidak stabil, sering crash | 248 | 4,13 |
| ID05 | HP ProBook 430 G1 | Windows lambat, touchpad dan keyboard tidak berfungsi | 226 | 3,77 |
| | **Rata-rata** | | **255** | **4,25** |

### 6.2 Manual vs Tachys

| ID | Manual (detik) | Tachys (detik) | Selisih (detik) | Efisiensi (%) |
|----|---------------:|---------------:|----------------:|--------------:|
| ID01 | 226 | 85,67 | 140 | 62,09 |
| ID02 | 212 | 105,50 | 107 | 50,24 |
| ID03 | 364 | 84,57 | 279 | 76,77 |
| ID04 | 248 | 97,08 | 151 | 60,85 |
| ID05 | 226 | 143,09 | 83 | 36,69 |
| **Rata-rata** | **255** | **103** | **152** | **57,33** |

```
Manual   ██████████████████████████  255 detik
Tachys   ██████████                  103 detik
```

### 6.3 Observasi

- Tachys lebih cepat daripada pemeriksaan manual di **kelima laptop**. Waktu rata-rata turun dari **255 detik menjadi 103 detik**, rata-rata hemat **152 detik** dengan efisiensi rata-rata **57,33%**.
- Efisiensi tertinggi ada di **ID03 (76,77%)**, yang juga punya waktu manual paling lama (364 detik) karena masalah glitch di layar.
- Efisiensi terendah ada di **ID05 (36,69%)**, yang juga punya waktu Tachys paling lama (143,09 detik). Laptop itu Windows-nya lambat dan keyboard serta touchpad-nya tidak berfungsi, sehingga proses kemungkinan jadi lebih lama (ini asumsi dan tidak diukur).
- Efisiensi tidak ditentukan oleh durasi manual saja: ID01 dan ID05 sama-sama 226 detik secara manual, tetapi efisiensinya sangat berbeda (62,09% vs 36,69%).

> Pengecekan baterai 10 menit tidak dihitung, karena waktunya sama saja di kedua metode.

---

## 7. Kendala di Lapangan

### 7.1 Security software

**Smadav USB Protect memblokir `Tachys.cmd`** (Acer Aspire A314-22)
Smadav mendeteksi dan memblokir script saat dijalankan dari flash drive USB.
**Solusi:** jalankan `Tachys.cmd` dengan *Run as administrator*.

**Halaman Virus & Threat Protection tidak bisa diakses** (Windows 10 Pro)
Real-time protection tidak bisa dimatikan lewat halaman biasa, karena opsi `gpedit.msc` hanya tersedia di edisi Windows tertentu.
**Solusi:** setelah real-time protection dimatikan lewat pengaturan yang tersedia, opsi `S` di Tachys berjalan tanpa perlu membuka Windows Security lagi.

**RAV Endpoint Protection menandai PowerShell** (ASUS TUF Gaming F15 FX506HCC)
Opsi `5` dan `6` gagal karena PowerShell terdeteksi sebagai *suspicious process*.
**Solusi:** pilih *Resume process* pada jendela notifikasi, lalu opsi `5` dan `6` berjalan normal.

### 7.2 Versi sistem operasi

**Cakupan Linux terbatas.** Hanya satu laptop Linux Ubuntu yang bisa diuji karena laptop Linux jarang masuk ke toko.

**Acer Aspire E1-432, Windows 7 (2017): gagal total.**
Menu utama tampil, tetapi ukurannya kecil dan tanpa banner, dan tidak ada opsi yang bisa dijalankan.

**Acer Aspire 4349, Windows 7 Ultimate (2011): gagal sebagian.**

| Opsi | Hasil | Dugaan penyebab |
|:----:|-------|-----------------|
| `S` | Membuka Windows Security, padahal tidak ada di Windows 7 | Fitur tidak tersedia di OS ini |
| `1` | Gagal dan melaporkan "disk tidak terdeteksi" padahal disk ada | PowerShell tidak mengenali `Get-PhysicalDisk` (cmdlet kemungkinan tidak ada di PowerShell bawaan Windows 7) |
| `2`, `3`, `4` | Berjalan | – |
| `5` | Melaporkan "baterai tidak ditemukan" padahal laptop punya baterai lepasan | Perintah baterai berbeda di Windows 7 |
| `6`, `7` | Berjalan | – |

### 7.3 Masalah di luar Tachys

Beberapa laptop pelanggan terkena serangan siber, kerusakan motherboard, sistem yang dimodifikasi, atau kerusakan lain yang membuat Windows tidak bisa booting. Masalah ini diselesaikan dengan install ulang Windows dari bootable media (DLC Boot) setelah partisi lama dihapus.

---

## 8. Desain: Computational Thinking

Tachys dirancang dengan empat konsep computational thinking:

| # | Konsep | Penerapan di Tachys |
|--:|--------|---------------------|
| 1 | **Decomposition** | Tachys dipecah menjadi function kecil, satu per fitur (disk, Wi-Fi, keyboard, audio, baterai, proses berat, Fast Startup, Windows Security), yang digabung lewat satu menu utama. Linux menambahkan install / uninstall. |
| 2 | **Pattern recognition** | `Tachys.sh` (Bash) dan `Tachys.cmd` (Batch) memakai pola yang sama: tampilkan menu → user pilih fitur → jalankan → tampilkan hasil → kembali ke menu. |
| 3 | **Abstraction** | Output mentah dari command disembunyikan, difilter, dan diringkas menjadi hasil singkat seperti status baik/buruk atau nilai kesehatan. |
| 4 | **Algorithm** | Setiap fitur punya alur langkah demi langkah yang jelas (pengecekan kondisi, cabang Yes/No, hasil akhir), dimodelkan dalam flowchart sebelum ditulis menjadi script. |

Output dikelompokkan menjadi tiga label: `[INFO]` informasi, `[WARN]` peringatan, dan `[ERROR]` kegagalan.

---

## 9. Desain: Alur Program

Setiap alur dimodelkan dalam flowchart sebelum script-nya ditulis. Flowchart-nya ada di laporan PKL; bagian ini merangkum logika masing-masing.

### 9.1 Linux

**`Install.sh`** mendaftarkan launcher (desktop entry) supaya `Tachys.sh` bisa dibuka dengan double click, bahkan di drive FAT32 / exFAT / NTFS yang tidak mendukung Unix execute permission. Script ini juga mengubah CRLF menjadi LF jika diperlukan.

**`Uninstall.sh`** menghapus desktop entry dan wrapper yang dibuat oleh `Install.sh`.

**Alur utama `Tachys.sh`** mencakup inisialisasi (cek CRLF, direktori temp dengan `trap cleanup`, penyesuaian ukuran terminal) dan loop menu utama.

### 9.2 Windows

**Alur utama `Tachys.cmd`** mencakup inisialisasi (UTF-8, relaunch `KEEP_OPEN`, direktori `%TEMP%\Tachys`) dan menu utama. Mode tampilan bergantung pada ukuran terminal: *mini* (tinggi < 17 baris), *full* (tinggi ≥ 34 baris dan lebar ≥ 64 kolom), atau *compact* (selain itu).

### 9.3 Alur tiap fitur

#### Opsi 1: Kesehatan SSD/HDD

- **Linux:** memakai `smartctl` (`smartctl --scan`, dengan `lsblk` sebagai fallback, lalu `smartctl -i -H -A`, dicoba ulang dengan `-d sat`). Jika SMART tidak didukung, fallback ke data eMMC.
- **Windows:** `Get-PhysicalDisk` untuk `HealthStatus`, ditambah *Storage Reliability Counter* untuk wear level, power-on hours, jumlah error, dan suhu. Memberi peringatan jika health bukan *Healthy* atau wear level **≥ 80%**.

#### Opsi 2: Konektivitas Wi-Fi

- **Linux:** mendeteksi interface lewat `/sys` (phy80211), `iw dev`, dan `nmcli`; mengecek `rfkill`; ping gateway **10×** (packet loss dan kualitas), lalu `google.com` **3×**.
- **Windows:** `Get-NetAdapter`, ping gateway, `netsh wlan show interfaces` (state, SSID, sinyal, channel, band), lalu `google.com` **3×**.

#### Opsi 3: Tes keyboard

- **Linux:** mencari atau membangun binary `keyboard-tester` (dikompilasi dengan `gcc`, source diunduh lewat `git` / `curl` / `wget` jika belum ada), mengecek library dengan `ldd`, lalu menjalankannya. Exit code 126 / 127 menyarankan hapus binary lama dan coba lagi.
- **Windows:** mencari `KeyboardTestUtility.exe`, mengecek status Real-Time Protection, menyalin aplikasi ke direktori temp, lalu menjalankannya.

#### Opsi 4: Audio output

- **Linux:** `speaker-test` (dari `alsa-utils`) memutar nada tes stereo. Kiri lalu kanan berarti normal.
- **Windows:** PowerShell memutar file WAV sistem dua kali, fallback ke `SystemSounds`, lalu ke beep dua nada, dan menawarkan untuk membuka Sound Settings.

#### Opsi 5: Kesehatan baterai

Battery health dihitung dari `full charge capacity ÷ design capacity`, dengan klasifikasi:

| Battery health | Kategori |
|:--------------:|----------|
| ≥ 80% | Baik |
| 60% – < 80% | Cukup, mulai menurun |
| < 60% | Buruk, pertimbangkan ganti baterai |

- **Linux:** membaca `/sys/class/power_supply/BAT*` (ditambah `upower` jika tersedia).
- **Windows:** PowerShell ditambah laporan XML `powercfg` (kapasitas dalam mWh), cycle count dari `powercfg` / WMI, dan laporan baterai HTML opsional.

#### Opsi 6: Proses berat (resource-intensive)

| | Linux | Windows |
|---|-------|---------|
| Sumber data | `ps` | `Get-Process` (sampel CPU 1 detik) |
| Batas "berat" | CPU **atau** memori **> 20%** | Memori **> 500 MB** atau CPU **> 50%** |
| Perintah kill | `kill` | `Stop-Process` |
| Ditampilkan | Top 10 berdasarkan CPU + proses antivirus/security | Top 10 berdasarkan CPU + antivirus dari Security Center |

PID yang dimasukkan divalidasi (harus numerik, harus ada, dan tidak boleh proses sistem, Tachys sendiri, kernel thread, atau zombie process), dan user harus konfirmasi (Y/N) sebelum proses dihentikan.

#### Opsi 7: Nonaktifkan Fast Startup (khusus Windows)

Mengecek hak administrator dengan `fltmc`, membaca nilai registry `HiberbootEnabled`, mengubahnya menjadi `0` jika perlu, dan mengingatkan user untuk restart.

#### Opsi S: Windows Security (khusus Windows)

Membuka halaman *Virus & threat protection* lewat `windowsdefender://threatsettings` (fallback: `ms-settings:windowsdefender`) dan mengingatkan user untuk mematikan Real-Time Protection secara manual.

---

## 10. Lingkungan Pengembangan & Dependensi

### 10.1 Lingkungan pengembangan

| Tool | Fungsi |
|------|--------|
| Laptop Windows 11 dan Linux Ubuntu | Development dan testing di kedua OS |
| Visual Studio Code | Code editor |
| Windows Terminal, GNOME Terminal | Menjalankan dan mengamati script |
| Git / GitHub | Version control dan distribusi |
| Flash drive USB | Distribusi portabel ke perangkat pelanggan |
| Koneksi internet | Referensi dan akses repository |

### 10.2 Dependensi runtime

Tidak butuh runtime tambahan. Bash dan Batch sudah bawaan Linux dan Windows.

| Sistem | Dependensi | Digunakan untuk |
|--------|------------|-----------------|
| Linux | `smartmontools` (`smartctl`) | Kesehatan SSD/HDD |
| Linux | `alsa-utils` (`speaker-test`) | Tes audio output |
| Linux | `gcc`, `git` / `curl` / `wget` | Build / download keyboard tester |
| Linux | `nmcli`, `iw`, `rfkill` | Konektivitas Wi-Fi |
| Linux | `upower` | Info baterai tambahan |
| Windows | PowerShell 5.1 (bawaan) | Cek disk, baterai, dan proses |
| Windows | `netsh`, `powercfg` (bawaan) | Wi-Fi (`netsh`) dan baterai (`powercfg`) |
| Windows | `KeyboardTestUtility.exe` | Tes keyboard (disertakan di folder aplikasi) |

Format storage flash drive USB yang didukung: FAT32, exFAT, NTFS, Btrfs, XFS, dan ext4.

---

## 11. Keterbatasan

- **Sampel pengukuran waktu kecil:** hanya 5 laptop, masing-masing diukur satu kali per metode. Hasilnya bersifat indikatif dan tidak boleh digeneralisasi.
- **Pengukuran stopwatch manual:** ada kemungkinan selisih kecil akibat waktu reaksi manusia, meskipun semua pengukuran dilakukan oleh orang yang sama.
- **Pengujian Linux terbatas:** hanya 1 laptop Linux Ubuntu yang diuji.
- **Tidak didukung:** Windows 7 ke bawah, macOS, distro Linux lain, dan PC desktop.
- **Security software:** beberapa antivirus pihak ketiga bisa menandai atau memblokir script.
- **Belum ada logging otomatis** untuk hasil pemeriksaan.

---

## 12. Kesimpulan & Pengembangan Lanjutan

**Kesimpulan**

- Tachys berjalan di Windows 10, Windows 11, dan Linux Ubuntu pada berbagai merek, model, dan edisi Windows. **13 dari 15** laptop yang didukung lolos di semua opsi yang tersedia.
- Waktu pemeriksaan rata-rata turun dari **255 detik** (manual) menjadi **103 detik** (Tachys), atau hemat waktu rata-rata **57,33%**.
- Kegagalan yang ditemukan berasal dari security software pihak ketiga dan versi OS yang tidak didukung, dan masalah security software sudah punya solusi yang berhasil.

**Pengembangan lanjutan**

- Menambahkan dukungan macOS.
- Memperluas ke distro Linux lain, PC desktop, dan versi Windows lama seperti Windows 7.
- Menguji di lebih banyak perangkat dan varian Linux.
- Mengurangi false detection oleh antivirus pihak ketiga (Smadav, RAV Endpoint Protection).
- Menambahkan logging otomatis untuk hasil pemeriksaan.
