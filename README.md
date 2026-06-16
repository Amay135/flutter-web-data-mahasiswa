# Flutter Web Data Mahasiswa 

Aplikasi sederhana berbasis **Flutter Web** untuk mengelola data mahasiswa. Aplikasi ini mendemonstrasikan cara mengakses kamera perangkat keras secara langsung di lingkungan web, mengambil gambar, mengonversinya ke format Base64, dan mengirimkannya ke REST API beserta data teks.

## Fitur Utama

* **Akses Kamera Web Asli:** Menggunakan `dart:html` dan `dart:ui_web` untuk mengakses kamera perangkat secara langsung (HTML5 `getUserMedia`).
* **Capture & Preview Foto:** Mengambil gambar dari *video stream* menggunakan elemen Canvas dan menampilkannya sebagai *preview*.
* **Integrasi REST API (HTTP):**
    * `POST`: Mengirim data mahasiswa (NPM, Nama) beserta foto (format Base64) ke server.
    * `GET`: Mengambil daftar data mahasiswa dari server.
* **Tampilan Responsif:** Menggunakan antarmuka Material Design yang rapi dengan `ListView` untuk menampilkan daftar mahasiswa beserta avatar fotonya.

## Catatan Penting

Proyek ini menggunakan pustaka khusus web (`dart:html` dan `dart:ui_web`). Oleh karena itu, aplikasi ini **hanya dapat dijalankan di platform Web (Chrome, Edge, Safari, dll.)**. Jika Anda mencoba mengompilasinya untuk Android atau iOS, Anda akan menemui error. Untuk dukungan multi-platform, diperlukan penyesuaian menggunakan *conditional imports* atau menggunakan *package* `camera` dari pub.dev.

## Cara Menjalankan Proyek

1. **Pastikan Flutter SDK terinstal dan mendukung Web**
   Cek apakah web sudah diaktifkan di konfigurasi Flutter Anda:
   ```bash
   flutter config --enable-web
   flutter devices
   
2. Kloning repositori ini
     ```bash
     git clone https://github.com/Amay135/flutter-web-data-mahasiswa.git
     cd flutter-web-data-mahasiswa

4. Unduh dependensi
    ```bash
   flutter run -d chrome

5. Jalankan aplikasi di browser (Chrome)
     ```bash
   flutter run -d chrome

Dependensi yang Digunakan
Flutter (Framework)

http (Untuk melakukan HTTP request ke REST API)

ndpoint API
Aplikasi ini menggunakan API publik berikut untuk keperluan demonstrasi:

URL: https://asnawi.web.id/mhsapi/

Method: GET (Mendapatkan data) dan POST (Menyimpan data)

Payload POST: JSON berisi npm, nama, dan foto (Base64).
