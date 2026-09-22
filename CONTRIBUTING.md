# Panduan Kontribusi TACHYS

Terima kasih telah tertarik untuk berkontribusi pada **TACHYS**.

TACHYS merupakan proyek scripting untuk membantu proses pemeriksaan dan diagnosis dasar komputer, terutama dalam kegiatan teknisi dan magang. Kontribusi dari siapa pun dipersilakan selama mengikuti panduan di bawah ini.

---

## 1. Jenis Kontribusi

Kamu dapat berkontribusi dalam berbagai bentuk, seperti:

* Memperbaiki bug atau kesalahan pada script.
* Menambahkan fitur baru.
* Meningkatkan kompatibilitas dengan sistem operasi tertentu.
* Memperbaiki dokumentasi.
* Meningkatkan struktur atau kualitas kode.
* Menambahkan pemeriksaan atau informasi sistem baru.
* Melaporkan bug atau masalah yang ditemukan.
* Memberikan saran untuk pengembangan TACHYS.

---

## 2. Melaporkan Masalah

Jika menemukan bug atau masalah, kamu dapat membuat **Issue** pada repository GitHub TACHYS.

Sertakan informasi yang cukup agar masalah dapat dipahami dan direproduksi, seperti:

* Sistem operasi yang digunakan.
* Versi sistem operasi.
* Versi TACHYS yang digunakan.
* Langkah untuk menyebabkan masalah.
* Pesan error yang muncul.
* Screenshot atau output terminal jika diperlukan.

Semakin lengkap informasi yang diberikan, semakin mudah masalah tersebut diperiksa.

---

## 3. Membuat Perubahan

Sebelum melakukan perubahan, disarankan untuk menggunakan branch terpisah.

Contoh:

```bash
git checkout -b fitur-nama-fitur
```

atau:

```bash
git checkout -b perbaikan-nama-masalah
```

Hindari melakukan perubahan langsung pada branch utama (`main`).

---

## 4. Commit

Gunakan commit message yang jelas dan menjelaskan perubahan yang dilakukan.

Contoh:

```text
Add system information check
```

```text
Fix Linux hardware detection
```

```text
Update installation instructions
```

Hindari commit message yang terlalu umum seperti:

```text
update
```

atau:

```text
fix
```

---

## 5. Pull Request

Setelah perubahan selesai, silakan buat **Pull Request (PR)** ke repository TACHYS.

Pull Request diperbolehkan untuk:

* Fitur baru.
* Perbaikan bug.
* Perbaikan dokumentasi.
* Perbaikan kompatibilitas.
* Perubahan struktur atau kode.

### Wajib menjelaskan perubahan

Setiap Pull Request **harus menjelaskan perubahan yang dibuat**.

Minimal sertakan:

* Apa yang diubah?
* Mengapa perubahan tersebut diperlukan?
* Bagian atau file apa saja yang terdampak?
* Bagaimana perubahan tersebut diuji?
* Apakah terdapat perubahan yang berpotensi memengaruhi fitur lain?

Contoh:

```text
## Perubahan

Menambahkan pemeriksaan informasi CPU pada Linux.

## Alasan

Informasi CPU belum tersedia pada output TACHYS untuk Linux.

## File yang Diubah

- Tachys.sh

## Pengujian

Telah diuji pada Ubuntu dan informasi CPU berhasil ditampilkan.

## Catatan

Perubahan hanya memengaruhi bagian pemeriksaan CPU.
```

---

## 6. Proses Review dan Persetujuan

Pull Request yang dibuat oleh kontributor **tidak akan langsung digabungkan ke branch utama**.

Setiap Pull Request akan diperiksa terlebih dahulu oleh maintainer TACHYS.

Prosesnya:

```text
Kontributor
    │
    ▼
Membuat perubahan
    │
    ▼
Membuat Pull Request
    │
    ▼
Menjelaskan perubahan
    │
    ▼
Review oleh maintainer
    │
    ├── Perlu perubahan ──► Kontributor melakukan revisi
    │                              │
    │                              └────► Review kembali
    │
    └── Disetujui
            │
            ▼
       Pull Request di-merge
```

**Pull Request hanya akan di-merge setelah perubahan diperiksa dan disetujui oleh maintainer.**

Dengan demikian, membuat Pull Request **tidak berarti perubahan akan otomatis diterima atau digabungkan**.

---

## 7. Hak Maintainer

Maintainer berhak untuk:

* Meminta perubahan pada Pull Request.
* Meminta penjelasan tambahan mengenai perubahan.
* Menolak perubahan yang tidak sesuai dengan tujuan TACHYS.
* Meminta kontributor memperbaiki kode atau dokumentasi.
* Menggabungkan Pull Request setelah perubahan dianggap sesuai.

Keputusan penggabungan dilakukan dengan mempertimbangkan stabilitas, keamanan, kompatibilitas, dan tujuan pengembangan TACHYS.

---

## 8. Gaya Kode

Usahakan perubahan tetap mengikuti struktur dan gaya kode yang sudah digunakan dalam proyek.

Hindari:

* Mengubah kode yang tidak berkaitan dengan kontribusi.
* Menghapus fitur tanpa alasan yang jelas.
* Menambahkan dependensi yang tidak diperlukan.
* Memasukkan informasi pribadi atau kredensial ke dalam repository.
* Mengubah konfigurasi penting tanpa menjelaskan alasannya.

---

## 9. Pengujian

Sebelum membuat Pull Request, lakukan pengujian terhadap perubahan yang dibuat.

Jika memungkinkan, jelaskan:

* Sistem operasi yang digunakan.
* Perintah yang dijalankan.
* Hasil yang diharapkan.
* Hasil yang diperoleh.

Jika perubahan hanya dapat diuji pada sistem tertentu, jelaskan keterbatasannya pada Pull Request.

---

## 10. Keamanan

Jangan memasukkan informasi sensitif ke dalam repository, termasuk:

* Password.
* API key.
* Token.
* Private key.
* Credential.
* Informasi pribadi milik pengguna atau customer.

Jika menemukan masalah keamanan, sebaiknya jangan langsung mempublikasikan informasi sensitif tersebut melalui Issue atau Pull Request.

---

## 11. Lisensi dan Kepemilikan Kontribusi

Dengan mengirimkan Pull Request, kamu menyatakan bahwa perubahan yang kamu kontribusikan dapat digunakan dalam proyek TACHYS sesuai dengan lisensi yang berlaku pada repository.

Pastikan kode, dokumentasi, atau aset yang kamu kontribusikan tidak melanggar hak cipta atau lisensi pihak lain.

---

## 12. Terima Kasih

Setiap kontribusi, baik berupa kode, dokumentasi, laporan bug, maupun saran, sangat membantu perkembangan TACHYS.

Terima kasih telah membantu mengembangkan TACHYS.
