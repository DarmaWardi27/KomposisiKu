# KomposisiKu

Proyek Flutter baru untuk membaca komposisi dan Informasi Nilai Gizi dari foto kemasan. Proyek ini berdiri sendiri dalam repositori KomposisiKu.

## Fitur yang ditulis

- Foto kamera atau pilih gambar galeri, lalu baca teks Latin menggunakan Google ML Kit pada perangkat Android.
- Koreksi hasil OCR sebelum memproses label; masukkan teks manual bila foto sulit terbaca.
- Ketuk bahan komposisi untuk membuka informasi edukasi dari kamus lokal. Bahan tak dikenal ditandai secara eksplisit.
- Tampilkan nilai gizi dalam tabel menyerupai label: takaran saji, jumlah per sajian, dan % AKG yang tercantum. Data hilang tidak diisi nol dan AKG tidak dihitung ulang.
- Estimasi Nutri-Level A–D untuk minuman olahan siap saji berdasarkan ambang KMK HK.01.07/MENKES/301/2026, setelah konfirmasi volume, angka gizi, dan BTP pemanis. Lihat [catatan regulasi dan interpretasi](docs/NUTRI_LEVEL.md).

OCR membutuhkan perangkat Android; web/desktop tidak didukung oleh plugin OCR ini. Foto tidak dikirim oleh aplikasi ke backend. Belum ada riwayat persisten, akun, atau backend.

## Pengembangan Android

Prasyarat: Flutter 3.35.7, Android SDK dengan platform yang diminta Flutter, JDK 17 atau versi kompatibel Gradle, dan perangkat/emulator Android API 24+.

```bash
flutter --version
flutter doctor -v
flutter pub get
flutter analyze
flutter test
flutter build apk --debug
flutter run
```

Flutter dapat membuat Gradle wrapper saat build pertama. `android/local.properties` merupakan konfigurasi lokal yang diabaikan Git. Jangan menyimpan path SDK mesin lain di repositori. Dependensi dikunci dalam `pubspec.lock`; gunakan `flutter pub get --enforce-lockfile` untuk instalasi ulang.

### Uji perangkat yang diperlukan

1. Foto komposisi asli dan pastikan teks OCR muncul serta dapat dikoreksi.
2. Ketuk bahan, periksa penjelasan bahan dan fallback bahan tak dikenal.
3. Foto tabel gizi, koreksi agar satu zat gizi berada pada satu baris, lalu cocokkan angka tabel dengan kemasan.
4. Batalkan pemilihan foto dan uji penolakan akses kamera/galeri.
5. Konfirmasi jenis minuman, volume, dan BTP pemanis. Pastikan data kosong serta produk di luar cakupan tidak dinilai; cocokkan contoh batas dengan lampiran resmi.

Parser memakai nama zat gizi Bahasa Indonesia. Kolom OCR yang terpisah disusun berdasarkan posisi vertikal teks sehingga jumlah dan % AKG dapat mengikuti nama zat gizinya. Foto miring, baris terbungkus, atau format yang ambigu tetap perlu dikoreksi manual. Ini bukan parser semua format label.

## Status validasi lingkungan

Flutter 3.35.7 disiapkan di `/workspace/toolchains/flutter`. Aktifkan alat pada cloud ini:

```bash
source /workspace/toolchains/activate-komposisiku.sh
cd /workspace/KomposisiKu
flutter --suppress-analytics pub get --enforce-lockfile
flutter --suppress-analytics analyze
flutter --suppress-analytics test
```

Instalasi dependensi terkunci berhasil. Analisis Flutter bersih dan 14 pengujian otomatis lulus. PDF Kemenkes berhasil diunduh dan disimpan sebagai rujukan. Build APK debug berhasil. Kamera/OCR nyata belum diuji pada perangkat Android karena tidak ada perangkat/emulator Android yang terhubung.

APK: `build/app/outputs/flutter-apk/app-debug.apk`. Pasang pada perangkat Android API 24+ untuk menjalankan uji foto di atas. APK ini merupakan build pengembangan, bukan build rilis untuk Play Store.

Environment menggunakan cache lokal di `/workspace/toolchains` untuk Dart, Gradle, dan Android. Akses jaringan khusus `storage.googleapis.com` dan `kesprimkom.kemkes.go.id` disimpan dalam draf. Review/simpan dan publish environment untuk menyimpan konfigurasi dan snapshot; publikasi belum dilakukan oleh agen.
