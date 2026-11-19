# Diet & Workout Tracker - Mobile/Web App (Flutter)

Aplikasi Frontend **Personal Diet & Workout Tracker** menggunakan **Flutter (Material 3)** yang terhubung dengan Backend REST API Golang.

## Fitur Utama
* **Dashboard Kalori Harian:** Memantau total kalori makanan yang masuk hari ini dibandingkan dengan batas kalori harian.
* **Progres Target Olahraga (Harian, Mingguan, Bulanan):** Memantau durasi menit, jarak (KM), kalori terbakar, serta *progress bar* persentase untuk olahraga **Jalan Kaki** dan **Jogging**.
* **Pencatatan Makanan Otomatis:** Memilih makanan langsung dari database Kamus Makanan sehingga total kalori dihitung otomatis berdasarkan jumlah porsi.
* **Tambah Menu ke Kamus Database:** Menambahkan daftar makanan baru beserta nilai kalorinya langsung dari aplikasi.
* **Manajemen Riwayat:** Melihat dan menghapus riwayat makanan maupun olahraga.

## Cara Menjalankan
1. Pastikan **Backend API (Golang)** sudah berjalan di `http://localhost:8080`.
2. Jalankan aplikasi Flutter:
   ```bash
   flutter run -d chrome
   ```
   *(Atau gunakan `-d edge` / `-d windows` / perangkat Android Anda).*
