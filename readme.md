# TACHYS

<div align="center">
    <p>
        <a name="stars"><img src="https://img.shields.io/github/stars/Ali-Rahman-BJB/TACHYS?style=for-the-badge"></a>
        <a name="forks"><img src="https://img.shields.io/github/forks/Ali-Rahman-BJB/TACHYS?logoColor=green&style=for-the-badge"></a>
        <a name="contributions"><img src="https://img.shields.io/github/contributors/Ali-Rahman-BJB/TACHYS?logoColor=green&style=for-the-badge"></a>
        <a name="madeWith"><img src="https://img.shields.io/badge/Made%20with-Markdown-1f425f.svg?style=for-the-badge"></a>
        <a name="license"><img src="https://img.shields.io/github/license/Ali-Rahman-BJB/TACHYS?style=for-the-badge"></a>
    </p>
</div>

**TACHYS** (ταχύς, bahasa Yunani: "cepat") adalah toolkit diagnostik portabel berbasis *scripting* untuk membantu teknisi, siswa, dan peserta magang memeriksa komponen dasar laptop lewat terminal. Tersedia untuk **Windows** (`Tachys.cmd`) dan **Linux** (`Tachys.sh`), ditulis dengan Batch dan Bash, tanpa compiler dan tanpa instalasi permanen di laptop pelanggan.

TACHYS dikembangkan selama Praktik Kerja Lapangan (PKL) di Bandung Computer Banjarbaru untuk mempercepat pemeriksaan awal laptop yang sebelumnya dilakukan manual satu per satu.

---

## Tentang Saya

| | |
|---|---|
| **Nama** | Ali Rahman |
| **Sekolah** | SMK PGRI 1 Martapura |
| **Peran** | Pembuat dan pengembang TACHYS |

TACHYS saya buat sebagai proyek belajar sekaligus alat bantu praktis untuk pemeriksaan komputer di lab, saat magang, maupun layanan servis.

---

## Fitur

Menu pada TACHYS diberi pengaman input, jadi pengguna bebas memilih program mana pun lebih dulu.

| Menu | Fungsi | Linux | Windows |
|:---:|---|:---:|:---:|
| `S` | Buka Windows Security | ❌ | ✅ |
| `1` | Cek kesehatan HDD/SSD (data SMART) | ✅ | ✅ |
| `2` | Cek Wi-Fi card dan uji koneksi | ✅ | ✅ |
| `3` | Tes keyboard | ✅ | ✅ |
| `4` | Tes audio output | ✅ | ✅ |
| `5` | Cek kesehatan baterai | ✅ | ✅ |
| `6` | Cek program berat (CPU/RAM) dan opsi menghentikannya | ✅ | ✅ |
| `7` | Nonaktifkan Fast Startup | ❌ | ✅ |
| `0` | Keluar | ✅ | ✅ |
| — | Script `Install.sh` / `Uninstall.sh` (launcher) | ✅ | ❌ |

Beberapa batasan keamanan bawaan: TACHYS tidak memuat perintah destruktif, dan program tidak akan mematikan proses sistem maupun proses TACHYS sendiri.

---

## Spesifikasi yang Dibutuhkan

### Perangkat dan sistem operasi

| Kebutuhan | Keterangan |
|---|---|
| **Jenis perangkat** | Laptop (fitur seperti cek baterai bergantung pada laptop; PC desktop tidak termasuk ruang lingkup) |
| **Windows** | Windows 10 dan Windows 11 |
| **Linux** | Ubuntu (diuji pada Ubuntu 26.04.1 LTS) |
| **Tidak didukung** | Windows 7 dan versi lebih lama, distribusi Linux selain Ubuntu, macOS |

### Media penyimpanan

| Kebutuhan | Keterangan |
|---|---|
| **Ukuran TACHYS** | Sekitar 2,08 MB, jadi flash drive berkapasitas berapa pun cukup |
| **Sistem berkas** | **FAT32** disarankan karena terbaca di Windows, Linux, dan macOS. Sistem berkas lain seperti exFAT, NTFS, Btrfs, XFS, dan ext4 juga bisa |
| **Perhatian** | Memformat flash drive menghapus semua datanya, cadangkan dulu data penting |

### Aplikasi pendukung

| Sistem | Kebutuhan |
|---|---|
| **Windows** | Tidak perlu aplikasi tambahan. TACHYS memakai PowerShell dan fitur bawaan Windows. Disarankan menjalankan sebagai administrator bila ada fitur yang diblokir |
| **Linux** | `bash`, `smartmontools` (`smartctl`) untuk cek HDD/SSD, `alsa-utils` (`speaker-test`) untuk tes audio. `upower` bersifat opsional untuk info baterai tambahan |
| **Keyboard Tester (Linux)** | Dibangun otomatis memakai `gcc`. Jika dependensi belum lengkap dan ada `sudo`, TACHYS memasangnya lewat `apt`, `dnf`, `pacman`, atau `zypper` |
| **Git** | Dibutuhkan hanya di laptop teknisi untuk mengunduh TACHYS (`git clone`) dan memperbaruinya (`git pull`) |

Pembacaan data SMART di Linux butuh akses `root`/`sudo`. Tanpa itu, TACHYS tetap berjalan tetapi menampilkan peringatan.

---

## Cara Mengunduh (Git Clone)

Cukup dilakukan sekali di laptop teknisi, langsung ke flash drive.

```bash
git clone https://github.com/Ali-Rahman-BJB/TACHYS.git
cd TACHYS
```

Untuk memperbarui di kemudian hari: `git pull`.

---

## Cara Instalasi di Linux

Installer hanya memasang *launcher* (shortcut) agar file `.sh` bisa dibuka lewat terminal. Tidak ada aplikasi yang dipasang secara global.

1. Jalankan installer dari folder `TACHYS`:

   ```bash
   bash Linux/Install.sh
   ```

   Ketik `Y` saat ditanya. Untuk melewati pertanyaan, pakai `bash Linux/Install.sh --yes`.

2. Jalankan TACHYS dengan salah satu cara:
   - Klik kanan `Linux/Tachys.sh`, pilih **Open With** → **Other Application** → **Tachys | SMK PGRI 1 Martapura**, atau
   - Langsung lewat terminal:

     ```bash
     bash Linux/Tachys.sh
     ```

3. Jika sudah tidak dipakai, hapus launcher dengan:

   ```bash
   bash Linux/Uninstall.sh
   ```

## Cara Menjalankan di Windows

Tidak perlu instalasi. Buka folder `Windows`, lalu klik dua kali `Tachys.cmd`.

Sebelum memakai program lain, jalankan menu **`S`** lebih dulu untuk menyesuaikan Windows Security agar script bisa berjalan.

---

## Hasil Pengujian

TACHYS diuji pada **11 laptop** (1 Ubuntu dan 10 Windows 10/11) di Bandung Computer Banjarbaru. Hampir seluruh menu berjalan normal di semua laptop yang diuji.

**Perbandingan durasi pemeriksaan awal, manual vs TACHYS:**

| Laptop uji | Manual | TACHYS | Efisiensi |
|---|:---:|:---:|:---:|
| ID01 | 766 detik | 85,67 detik | 88,82% |
| ID02 | 964 detik | 105,5 detik | 89,06% |
| ID03 | 848 detik | 84,57 detik | 90,03% |
| **Rata-rata** | **859 detik** | **92 detik** | **89,30%** |

### Kendala yang diketahui

- **Antivirus**: Smadav USB Protect bisa memblokir `Tachys.cmd`. Solusinya jalankan dengan *Run as administrator*. RAV Endpoint Protection pernah menandai PowerShell sebagai *suspicious process* sehingga menu 5 dan 6 tertahan. Pilih **Resume process** pada notifikasi.
- **Windows Security**: pada sebagian versi Windows, *Virus & Threat Protection* tidak bisa diakses, sehingga menu `S` tidak berfungsi penuh.
- **Windows 7**: tidak didukung. Menu utama tampil kecil tanpa banner dan seluruh program tidak bisa dijalankan.
- **Linux**: pengujian terbatas karena laptop Linux jarang ditemui di toko servis.

---

## Tampilan

### Windows

![Tampilan depan TACHYS di Windows](https://github-production-user-asset-6210df.s3.amazonaws.com/215145832/675304906-9668a125-79a7-48b2-af9b-c74dfb32c03e.png?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=AKIAVCODYLSA53PQK4ZA%2F20261016%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20261016T010518Z&X-Amz-Expires=300&X-Amz-Signature=776a37da486c66319f969f318074c3344f0b4eca7838acaa7f0cbb20d38e95b1&X-Amz-SignedHeaders=host&response-content-type=image%2Fpng)

### Linux

![Tampilan depan TACHYS di Linux](https://github-production-user-asset-6210df.s3.amazonaws.com/215145832/675304864-6ca1944f-a7db-41e9-b282-f8534ca5b9b2.png?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=AKIAVCODYLSA53PQK4ZA%2F20261016%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20261016T010604Z&X-Amz-Expires=300&X-Amz-Signature=f7144f1a9346f5563698d10e4fc3993e48089d5e9f077ef0d698c57ca566a54c&X-Amz-SignedHeaders=host&response-content-type=image%2Fpng)

---

## Video Tutorial

Playlist tutorial penggunaan TACHYS ada di sini:

[Tonton di YouTube](https://youtube.com/playlist?list=PLNE-O9vAVa0k&si=0ACbZA3UNMsbmNdk)

---

## Laporan Praktik Kerja Lapangan

Perancangan, flowchart tiap program, kode lengkap, langkah penerapan, dan pengujian TACHYS dibahas lengkap di laporan PKL.

📄 **Baca laporan lengkapnya di [alirahman.my.id/docs](https://www.alirahman.my.id/docs)**

---

## Lisensi

TACHYS dirilis dengan lisensi **MIT**. Pengembangan lebih lanjut diperbolehkan sesuai ketentuan lisensi.

---

## Kontak

**Ali Rahman**

- WhatsApp: [+1 (873) 280-0862](https://wa.me/18732800862)
- Email: [pesan@alirahman.my.id](mailto:pesan@alirahman.my.id)