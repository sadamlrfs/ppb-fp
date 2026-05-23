# MindEase — Mental Wellness Companion App

Aplikasi Flutter untuk kesehatan mental: jurnal harian, mood tracker, meditasi, dan AI companion berbasis Gemini.

---

## Prasyarat

| Tool | Versi minimum |
|------|---------------|
| Flutter SDK | 3.2.0 |
| Dart SDK | 3.2.0 |
| Android Studio / VS Code | terbaru |
| Node.js | 18.x (untuk Appium tests) |
| Firebase CLI | terbaru (`npm i -g firebase-tools`) |
| FlutterFire CLI | terbaru (`dart pub global activate flutterfire_cli`) |
| Appium | 2.x (`npm i -g appium`) |

---

## Setup Pertama Kali

### 1. Clone & inisialisasi Flutter project

```bash
git clone <repo-url>
cd ppb-fp

# Jika folder belum berisi project Flutter (tidak ada android/, ios/)
flutter create . --project-name mindease --org com.example

flutter pub get
```

> **Catatan:** Error merah `package:flutter/material.dart doesn't exist` di IDE akan hilang setelah `flutter pub get` berhasil.

---

### 2. Konfigurasi environment variables

```bash
cp .env.example .env
```

Buka `.env` dan isi nilai berikut:

```dotenv
CLOUDINARY_CLOUD_NAME=nama_cloud_kamu
CLOUDINARY_UPLOAD_PRESET=nama_preset_unsigned
GEMINI_API_KEY=AIza...
ZENQUOTES_BASE_URL=https://zenquotes.io/api
```

- **Cloudinary** — daftar di [cloudinary.com](https://cloudinary.com), buat *unsigned upload preset*
- **Gemini API Key** — buat di [Google AI Studio](https://aistudio.google.com/app/apikey)
- File `.env` sudah di-gitignore, **jangan di-commit**

---

### 3. Setup Firebase

```bash
# Login Firebase
firebase login

# Hubungkan project Flutter ke Firebase (jalankan dari root repo)
flutterfire configure
```

Pilih Firebase project yang sudah dibuat, centang platform **Android** (dan **iOS** jika perlu).  
Perintah ini akan men-generate `lib/core/config/firebase_options.dart` secara otomatis.

Setelah itu, pastikan file berikut ada di tempatnya:

| File | Platform | Sumber |
|------|----------|--------|
| `android/app/google-services.json` | Android | Firebase Console → Project Settings → Your apps |
| `ios/Runner/GoogleService-Info.plist` | iOS | Firebase Console → Project Settings → Your apps |

> Kedua file ini sudah di-gitignore. Minta dari ketua tim atau unduh langsung dari Firebase Console.

---

### 4. Verifikasi setup

```bash
flutter doctor
flutter analyze
flutter run
```

---

## Struktur Folder

```
lib/
├── main.dart                   # Entry point, init Firebase + dotenv + providers
├── app.dart                    # MaterialApp, routes, SplashScreen
├── core/
│   ├── config/                 # Firebase, Cloudinary, Gemini config
│   ├── constants/              # AppColors, AppStrings, AppRoutes
│   ├── theme/                  # AppTheme
│   └── utils/                  # DateFormatter, Validators
├── models/                     # Data models (Firestore-mapped)
├── services/                   # AuthService, FirestoreService, GeminiService, dll
├── providers/                  # ChangeNotifier state (AuthProvider, JournalProvider, dll)
├── widgets/                    # Shared widgets (BottomNavBar, LoadingWidget, dll)
└── features/
    ├── auth/                   # Login, Register, ForgotPassword (SUDAH LENGKAP)
    ├── home/                   # Mood tracker — TODO [Anggota 2]
    ├── journal/                # Jurnal — TODO [Anggota 1]
    ├── meditation/             # Meditasi + AI Chat — TODO [Anggota 3]
    ├── ai_chat/                # AI Companion — TODO [Anggota 3]
    └── profile/                # Profil — TODO [Semua]

assets/
├── images/                     # Tempatkan gambar/ilustrasi di sini
└── icons/                      # Tempatkan ikon custom di sini

appium_tests/                   # Automated UI tests (Appium + WebdriverIO)
```

---

## Pembagian Tugas

| Anggota | Fitur | Folder |
|---------|-------|--------|
| Anggota 1 | Jurnal Harian | `lib/features/journal/` |
| Anggota 2 | Mood Tracker + Home | `lib/features/home/` |
| Anggota 3 | Meditasi + AI Chat | `lib/features/meditation/`, `lib/features/ai_chat/` |
| Semua | Profil + Auth (sudah jadi) | `lib/features/profile/`, `lib/features/auth/` |

Baca komentar `// TODO [Anggota X]` di dalam masing-masing file stub untuk panduan implementasi.

---

## Menjalankan Automated UI Tests (Appium)

### Prasyarat Appium

```bash
# Install Appium global
npm install -g appium

# Install driver Android
appium driver install uiautomator2

# Verifikasi
appium doctor --plugin uiautomator2
```

### Setup test

```bash
cd appium_tests
npm install
```

Buka `appium_tests/helpers/driver.js` dan ganti `APK_PATH` dengan path absolut ke APK debug:

```
android/app/build/outputs/flutter-apk/app-debug.apk
```

Build APK debug terlebih dahulu:

```bash
flutter build apk --debug
```

### Jalankan Appium server (terminal terpisah)

```bash
appium
```

### Jalankan tests

```bash
cd appium_tests

npm test              # semua test
npm run test:auth     # hanya auth
npm run test:journal  # hanya journal
npm run test:mood     # hanya mood
npm run test:chat     # hanya chat
```

---

## Semantics Identifiers (untuk Appium)

Widget Flutter perlu dibungkus `Semantics(identifier: '...')` agar bisa dilokasi oleh Appium.  
Lokasi di test: `driver.$('//*[@content-desc="namaIdentifier"]')`

| Identifier | Widget | Halaman |
|------------|--------|---------|
| `emailField` | TextField email | LoginPage |
| `passwordField` | TextField password | LoginPage |
| `loginButton` | Tombol masuk | LoginPage |
| `homeTitle` | AppBar title | HomePage |
| `addMoodButton` | FAB catat mood | HomePage |
| `moodEmojiLevel1`–`5` | Emoji mood | MoodInputPage |
| `saveMoodButton` | Tombol simpan | MoodInputPage |
| `todayMoodCard` | Card mood hari ini | HomePage |
| `addJournalButton` | FAB jurnal | JournalListPage |
| `journalTitleField` | TextField judul | JournalFormPage |
| `journalContentField` | TextField konten | JournalFormPage |
| `saveJournalButton` | Tombol simpan | JournalFormPage |
| `newChatButton` | FAB chat baru | ChatListPage |
| `chatInputField` | TextField pesan | ChatRoomPage |
| `sendMessageButton` | Tombol kirim | ChatRoomPage |

---

## Troubleshooting

**Error: `package:flutter/material.dart doesn't exist`**  
→ Jalankan `flutter pub get`. Ini false positive sebelum dependencies terinstall.

**Error: `firebase_options.dart not found`**  
→ Jalankan `flutterfire configure`.

**Error: `google-services.json not found` saat build Android**  
→ Unduh dari Firebase Console dan letakkan di `android/app/`.

**Appium: `SessionNotCreatedException`**  
→ Pastikan emulator/device terhubung (`adb devices`), Appium server berjalan, dan `APK_PATH` benar.
