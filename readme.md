# PROGRAM TACHYS (ταχύς)

**Program Tachys** merupakan program *toolkit diagnostik portabel* yang dikembangkan untuk tujuan mengotomasi tugas pemeriksaan perangkat komputer pelanggan di Bandung Komputer Banjarbaru. Program Tachys dikembangkan khusus untuk sistem operasi **Windows** (`Tachys.cmd`) dan sistem operasi **Linux Ubuntu** (`Tachys.sh`) karena kedua sistem operasi tersebut umum di masyarakat Indonesia.

**PERLU DIINGAT:**

Program sudah di uji kompatibilitas pada versi Windows dibawah 10 11, diketahui bahwa program terbatas karena banyak ketidaksesuaian perintah dan local page setting yang berbeda. 
Program juga diketahui sering terkena karantina oleh perangkat lunak keamanan seperti antivirus Smadav, RAV Endpoint Protection, jadi ya jalankan run as administrator dan allow jika ada notification, kalau enggak ya file program hilang.

---

## CARA MENYIAPKAN PROGRAM DI FLASHDRIVE

Git pull repository ini di perangkat komputer, pastikan direktori instalasi nya langsung ke flash drive (dengan file system FAT32 ya):

```bash
git clone https://github.com/Ali-Rahman-BJB/TACHYS.git
cd TACHYS
```

### INGAT

Menjalankan program di Windows cukup klik dua kali pada file `Tachys.cmd` terus jalankan perintah opsi **`S`** lebih dulu agar Windows Security gak nganuin script.

Kalau linux agak beda ya.. ini ada file instalasi program agar terdaftar pada sistem, biar mudah aja klik dua kali.. kalau mau langsung dijalankan bisa tinggal bash Tachys.sh, tapi ya tetap aja ya lebih baik install.sh aja.

```bash
bash Linux/Install.sh     # pasang launcher (tambahkan --yes untuk melewati pertanyaan)
bash Linux/Tachys.sh      # jalankan
bash Linux/Uninstall.sh   # hapus launcher
```

Kalau ngontenin program, bisa tambahkan di playlist youtube ini ya, kalian juga bisa lihat dokumentasi dari program Tachys

[Link Playlist](https://youtube.com/playlist?list=PLNE-O9vAVa0k&si=0ACbZA3UNMsbmNdk)

---

## BACA BIAR PINTER

Penjelasan panjang, lengkap, superkompleks, megakompleks, ada di website pribadi ku ya, baca aja gratis kok wkwkwk [alirahman.my.id/docs](https://www.alirahman.my.id/docs). 

---

## KONTAK

**Ali Rahman**

- WhatsApp: [+1 (873) 280-0862](https://wa.me/18732800862)
- Email: [pesan@alirahman.my.id](mailto:pesan@alirahman.my.id)
