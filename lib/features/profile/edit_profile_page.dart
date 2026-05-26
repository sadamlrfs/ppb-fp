import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../services/auth_service.dart';
import '../../services/cloudinary_service.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _nameCtrl = TextEditingController();
  final _cloudinary = CloudinaryService();
  final _authService = AuthService();
  String? _newImagePath;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().userModel;
    _nameCtrl.text = user?.displayName ?? '';
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final img = await picker.pickImage(source: ImageSource.gallery);
    if (img != null) setState(() => _newImagePath = img.path);
  }

  Future<void> _save() async {
    if (_nameCtrl.text.trim().isEmpty) return;
    setState(() => _saving = true);

    final auth = context.read<AuthProvider>();
    final uid = auth.firebaseUser?.uid ?? '';
    final data = <String, dynamic>{
      'displayName': _nameCtrl.text.trim(),
    };

    if (_newImagePath != null) {
      final url = await _cloudinary.uploadImage(
          _newImagePath!, folder: 'profiles');
      data['photoUrl'] = url;
    }

    await _authService.updateUserProfile(uid, data);
    await auth.refreshProfile();

    if (!mounted) return;
    setState(() => _saving = false);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().userModel;
    final photoUrl = user?.photoUrl ?? '';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profil'),
        actions: [
          _saving
              ? const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2)))
              : TextButton(
                  onPressed: _save,
                  child: const Text('Simpan',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 16),
            GestureDetector(
              onTap: _pickImage,
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 56,
                    backgroundColor:
                        AppColors.primary.withValues(alpha: 0.15),
                    backgroundImage: _newImagePath != null
                        ? null
                        : (photoUrl.isNotEmpty
                            ? NetworkImage(photoUrl)
                            : null),
                    child: (_newImagePath == null && photoUrl.isEmpty)
                        ? const Icon(Icons.person,
                            size: 56, color: AppColors.primary)
                        : null,
                  ),
                  Positioned(
                    bottom: 4,
                    right: 4,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.camera_alt,
                          size: 16, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
            if (_newImagePath != null)
              const Padding(
                padding: EdgeInsets.only(top: 8),
                child: Text('Foto baru dipilih',
                    style: TextStyle(
                        color: AppColors.primary, fontSize: 13)),
              ),
            const SizedBox(height: 32),
            TextField(
              controller: _nameCtrl,
              decoration: const InputDecoration(
                labelText: 'Nama Tampilan',
                prefixIcon: Icon(Icons.person_outline),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              enabled: false,
              controller: TextEditingController(text: user?.email ?? ''),
              decoration: const InputDecoration(
                labelText: 'Email',
                prefixIcon: Icon(Icons.email_outlined),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
