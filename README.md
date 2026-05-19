BLUEPRINT FITUR APLIKASI "TABUNGAN ONLINE"
1. Modul Core & Splash Screen (Pre-App State)
Fitur awal saat aplikasi pertama kali dimuat oleh pengguna.
•	Animasi Fade-In Welcome: Transisi halus selama 2 detik menggunakan AnimationController dan CurvedAnimation untuk memberikan kesan premium.
•	Auto-Routing/Navigation: Pengalihan otomatis (push replacement) ke Halaman Utama (HomePage) setelah 3 detik.
•	Dynamic Typography: Integrasi font Google (Outfit) yang dikonfigurasi langsung sejak aplikasi diinisialisasi.
2. Modul Manajemen Target Tabungan (Tabungan Screen)
Fitur utama untuk mengatur impian atau goals keuangan pengguna secara visual dan minimalis.
•	Pembuatan Target Baru (Goal Setting):
o	Input nama barang/impian.
o	Input nominal target dana (Format Rupiah otomatis pada UI).
o	Dropdown Siklus Nabung (Pilihan: Harian, Mingguan, Bulanan, Tahunan).
o	Date Picker tenggat waktu pencapaian target.
o	Image Picker dari galeri ponsel untuk visualisasi barang impian.
•	Visualisasi Progress (Progress Tracker):
o	Indikator visual menggunakan LinearProgressIndicator yang dinamis berdasarkan persentase dana terkumpul.
o	Conditional Card Box Alert: Ucapan selamat selebrasi otomatis saat target tabungan sudah mencapai 100% (penfull).
o	Remaining Budget Alert: Informasi teks kalkulasi sisa dana yang kurang untuk mencapai target secara real-time.
•	Aksi Cepat (Quick Action):
o	Tombol "Menabung" langsung di dalam card target untuk menambahkan saldo instan.
o	Fitur hapus seluruh data target beserta seluruh riwayatnya terkait via dialog konfirmasi.
3. Modul Pencatatan & Log (Riwayat Screen)
Fitur transparansi keuangan untuk memantau arus masuk dana tabungan.
•	Multi-Goal History Tracking: Pengelompokan riwayat transaksi yang dipisah secara jelas berdasarkan masing-masing target tabungan.
•	Sorting Transaksi: Riwayat diurutkan berdasarkan waktu terbaru menggunakan pencocokan DateTime (b.waktu.compareTo(a.waktu)).
•	Detail Transaksi Card: Menampilkan nominal penambahan (+ Rp X.XXX), tanggal, serta jam menit secara presisi (dd MMM yyyy • HH:mm).
•	Pembatalan Transaksi (Rollback Balance): Fitur hapus riwayat transaksi spesifik yang secara otomatis akan memotong/mengurangi saldo berjalan pada target terkait (dilengkapi proteksi agar saldo tidak minus dari 0).
4. Modul Utilitas & Preferensi (Pengaturan Screen)
Fitur kustomisasi aplikasi agar sesuai dengan kenyamanan pengguna.
•	Manajemen Tema (Dynamic Theme Mode):
o	Toggle Switch untuk berpindah dari Mode Terang (Light Mode) ke Mode Gelap (Dark Mode) secara global tanpa restart aplikasi memanfaatkan ThemeProvider.
o	Adaptasi palet warna otomatis (Warna latar belakang elegan #F4F9F4 pada mode terang dan #121212 pada mode gelap).
•	Sistem Pengingat Lokal (Daily Local Notification):
o	Toggle Switch untuk mengaktifkan/matikan Reminder menabung.
o	Time Picker Customization: Pengguna bebas mengatur jam dan menit spesifik kapan notifikasi harian akan muncul via NotificationService.
5. Modul Sistem & Data Lokal (Engine Layer)
Fitur di balik layar untuk memastikan data pengguna aman dan aplikasi berjalan lancar.
•	Data Persistence (SharedPreferences): Otomatisasi konversi objek Dart ke JSON string (jsonEncode) dan sebaliknya (jsonDecode) setiap kali ada penambahan target, pengisian saldo, atau penghapusan transaksi.
•	State Management (Provider): Distribusi status tema aplikasi secara reaktif ke seluruh komponen widget tree.
•	Sistem Caching Gambar: Konversi gambar ke format Base64 (Uint8List) agar foto target impian dapat disimpan langsung di memori lokal berupa teks tanpa memerlukan database eksternal.
________________________________________
Rekomendasi Pengembangan Selanjutnya (Next Backlog)
Jika kamu ingin mengembangkan blueprint ini lebih lanjut untuk kebutuhan ujian akhir (UAS) atau peluncuran produk, berikut beberapa fitur yang sangat bagus untuk ditambahkan:
1.	Fitur Tarik Dana: Saat ini kode baru mendukung fungsi menambah saldo (menabung). Menambahkan fungsi "Tarik Saldo" jika di tengah jalan pengguna membutuhkan dana darurat akan membuat aplikasi lebih realistis.
2.	Kategori Target Icon: Jika pengguna malas memasukkan foto, sediakan opsi default icon pack (misal: ikon mobil, gadget, rumah, atau liburan).
3.	Export Ringkasan: Fitur cetak riwayat menabung ke format PDF atau Excel sederhana.

