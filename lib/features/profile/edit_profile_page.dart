import 'package:flutter/material.dart';

// TODO [Semua]: Halaman edit profil
//
// Tampilan:
//   - Avatar foto profil bisa di-tap → ImagePicker.gallery
//     → upload via CloudinaryService.uploadImage(path, folder: 'profiles')
//     → simpan URL ke Firestore users/{uid}.photoUrl
//   - TextField displayName (pre-filled dari userModel.displayName)
//   - Tombol "Simpan Perubahan"
//
// Logika:
//   - Simpan: AuthService.updateUserProfile(uid, {displayName, photoUrl})
//   - Setelah berhasil: AuthProvider.refreshProfile() lalu Navigator.pop(context)

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('Edit Profile — TODO')),
    );
  }
}
