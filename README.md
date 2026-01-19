# Reinventory - Aplikasi Inventory Management UMKM

<p align="center">
  <img src="assets/icons/logo.png" alt="Reinventory Logo" width="200" onerror="this.style.display='none'"/>
</p>

Aplikasi manajemen inventori sederhana dan modern untuk UMKM berbasis Flutter dengan Firebase sebagai backend.

## 📱 Fitur Utama

### ✅ Sudah Tersedia:
- ✨ **Authentication** - Login, Register, Logout dengan Firebase Auth
- 📊 **Dashboard** - Overview inventory, monitoring stok rendah
- 📦 **Product Management** - CRUD produk dengan foto (struktur siap)
- 🏢 **Supplier Management** - Kelola data supplier (struktur siap)
- 💰 **Transaction Tracking** - Catat penjualan dan pembelian (struktur siap)
- 🔔 **Stock Alerts** - Notifikasi otomatis untuk stok menipis
- 📱 **Barcode Scanner** - Scan barcode produk (dependency siap)
- 📄 **Report Generator** - Generate laporan PDF (dependency siap)

## 🚀 Teknologi

- **Flutter** 3.9+ - UI Framework
- **Firebase Firestore** - Database
- **Firebase Auth** - Authentication
- **Firebase Storage** - Cloud Storage
- **Provider** - State Management
- **mobile_scanner** - Barcode Scanner
- **pdf & printing** - Report Generator
- **fl_chart** - Data Visualization

## 📁 Struktur Project

```
lib/
├── constants/          # App constants, colors, themes
├── models/            # Data models (User, Product, Supplier, etc)
├── providers/         # State management dengan Provider
├── services/          # Firebase & business logic
│   ├── auth_service.dart
│   ├── product_service.dart
│   ├── supplier_service.dart
│   ├── transaction_service.dart
│   ├── storage_service.dart
│   └── notification_service.dart
├── views/             # UI Screens
│   ├── auth/         # Login & Register
│   ├── dashboard/    # Dashboard utama
│   ├── products/     # Manajemen produk
│   ├── suppliers/    # Manajemen supplier
│   └── reports/      # Laporan
├── widgets/          # Reusable widgets
└── main.dart         # Entry point
```

## 🛠️ Setup & Installation

### 1. Clone Repository
```bash
git clone <repository-url>
cd reinventory
```

### 2. Install Dependencies
```bash
flutter pub get
```

### 3. Setup Firebase

**PENTING**: Anda perlu mengkonfigurasi Firebase untuk aplikasi ini

#### Opsi 1: Menggunakan FlutterFire CLI (Recommended)
```bash
# Install FlutterFire CLI
dart pub global activate flutterfire_cli

# Login ke Firebase
firebase login

# Configure project
flutterfire configure
```

#### Opsi 2: Manual Setup
1. Buka [Firebase Console](https://console.firebase.google.com)
2. Buat project baru atau gunakan yang sudah ada
3. Tambahkan aplikasi Android/iOS
4. Download `google-services.json` (Android) dan `GoogleService-Info.plist` (iOS)
5. Letakkan file di tempat yang sesuai
6. Aktifkan Authentication, Firestore, dan Storage

Lihat **[FIREBASE_SETUP.md](FIREBASE_SETUP.md)** untuk panduan lengkap.

### 4. Setup Firestore & Storage Rules

Copy rules dari [SETUP_GUIDE.md](SETUP_GUIDE.md) ke Firebase Console Anda.

### 5. Run Aplikasi
```bash
flutter run
```

## 📖 Panduan Penggunaan

### Pertama Kali
1. Register akun baru dengan email dan password
2. Lengkapi informasi bisnis Anda
3. Login dan mulai gunakan aplikasi

### Mengelola Produk
1. Buka tab "Produk"
2. Klik tombol "+" untuk menambah produk baru
3. Isi detail produk dan upload foto
4. Gunakan barcode scanner untuk input cepat

### Monitoring Inventory
- Dashboard menampilkan ringkasan inventory
- Produk dengan stok rendah akan ditampilkan di dashboard
- Notifikasi otomatis saat stok mencapai batas minimum

### Generate Laporan
1. Buka tab "Laporan"
2. Pilih jenis laporan
3. Atur filter tanggal
4. Export ke PDF

## 🎨 Screenshots

<!-- Tambahkan screenshots di sini -->

## 📝 Development Status

### Sudah Selesai
- [x] Setup project structure
- [x] Authentication system (Login/Register)
- [x] Dashboard UI & Logic
- [x] Data models (User, Product, Supplier, Transaction, StockAlert)
- [x] Firebase services (Auth, Firestore, Storage)
- [x] State management dengan Provider
- [x] Notification service
- [x] Basic UI screens

### Dalam Pengembangan
- [ ] Complete Product Management UI
- [ ] Barcode Scanner Integration
- [ ] Complete Supplier Management
- [ ] Transaction Recording UI
- [ ] Sales Analytics & Charts
- [ ] Report Generator Implementation
- [ ] Settings & Profile Management
- [ ] Search & Filter functionality

## 🔧 Troubleshooting

### Error: Firebase not configured
Pastikan sudah menjalankan `flutterfire configure` atau setup manual Firebase dengan benar.

### Error: Dependencies conflict
```bash
flutter clean
flutter pub get
```

### Error: Build failed
- Pastikan Flutter SDK versi terbaru
- Untuk Android: Pastikan Android SDK terinstall
- Untuk iOS: Pastikan Xcode terinstall (Mac only)

## 📄 Dokumentasi Tambahan

- [Setup Guide](SETUP_GUIDE.md) - Panduan lengkap setup project
- [Firebase Setup](FIREBASE_SETUP.md) - Detail konfigurasi Firebase
- [API Documentation](docs/API.md) - Dokumentasi API (coming soon)

## 🤝 Kontribusi

Aplikasi ini dikembangkan untuk membantu UMKM mengelola inventory dengan lebih efisien.

## 📞 Support

Jika ada pertanyaan atau masalah, silakan buat issue di repository ini.

## 📜 Lisensi

Proyek ini untuk keperluan pribadi/komersial UMKM.

---

**Dibuat dengan ❤️ menggunakan Flutter**

