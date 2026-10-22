# TACHYS

**TACHYS** (ταχύς, bahasa Yunani: "cepat") adalah toolkit diagnostik portabel berbasis *scripting* untuk memeriksa komponen dasar laptop lewat terminal: kesehatan HDD/SSD, Wi-Fi, keyboard, audio, baterai, dan program berat. Tersedia untuk **Windows** (`Tachys.cmd`) dan **Linux** (`Tachys.sh`), tanpa compiler dan tanpa instalasi permanen di laptop pelanggan.

Dikembangkan selama PKL di Bandung Computer Banjarbaru oleh Ali Rahman (SMK PGRI 1 Martapura).

**Keterbatasan:**

- Hanya untuk **laptop** dengan **Windows 10/11** atau **Ubuntu**. Windows 7 ke bawah, distro Linux lain, macOS, dan PC desktop tidak didukung.
- Di Linux, butuh `smartmontools` dan `alsa-utils`, serta akses `sudo` untuk membaca data SMART.
- Sebagian antivirus (Smadav, RAV Endpoint Protection) bisa memblokir script. Jalankan sebagai administrator.
- Pengujian di Linux masih terbatas.

---

## Tampilan

### Windows

![Tampilan depan TACHYS di Windows](https://github.com/user-attachments/assets/6ca1944f-a7db-41e9-b282-f8534ca5b9b2)

### Linux

![Tampilan depan TACHYS di Linux](https://github.com/user-attachments/assets/9668a125-79a7-48b2-af9b-c74dfb32c03e)

---

## Cara Install

Unduh sekali di laptop teknisi, langsung ke flash drive (FAT32 disarankan):

```bash
git clone https://github.com/Ali-Rahman-BJB/TACHYS.git
cd TACHYS
```

### Windows

Tidak perlu instalasi. Buka folder `Windows`, lalu klik dua kali `Tachys.cmd`. Jalankan menu **`S`** lebih dulu agar Windows Security tidak menghalangi script.

### Linux

```bash
bash Linux/Install.sh     # pasang launcher (tambahkan --yes untuk melewati pertanyaan)
bash Linux/Tachys.sh      # jalankan
bash Linux/Uninstall.sh   # hapus launcher
```

---

## Video Tutorial

[Tonton di YouTube](https://youtube.com/playlist?list=PLNE-O9vAVa0k&si=0ACbZA3UNMsbmNdk)

---

## Laporan PKL

Flowchart, kode lengkap, dan pengujian dibahas di [alirahman.my.id/docs](https://www.alirahman.my.id/docs). Data dan hasil pengujian ringkas ada di [EXPERIMENTS.md](EXPERIMENTS.md).

---

## Lisensi

[MIT](LICENSE)

---

## Kontak

**Ali Rahman**

- WhatsApp: [+1 (873) 280-0862](https://wa.me/18732800862)
- Email: [pesan@alirahman.my.id](mailto:pesan@alirahman.my.id)
