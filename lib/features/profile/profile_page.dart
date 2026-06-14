import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_routes.dart';
import '../../providers/auth_provider.dart';
import '../../providers/journal_provider.dart';
import '../../providers/meditation_provider.dart';
import '../../providers/mood_provider.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.userModel;
    final moodCount = context.watch<MoodProvider>().moods.length;
    final journalCount = context.watch<JournalProvider>().journals.length;
    final sessionCount =
        context.watch<MeditationProvider>().userSessions.length;

    return Scaffold(
      appBar: AppBar(title: const Text('Profil')),
      body: ListView(
        children: [
          const SizedBox(height: 24),
          Center(
            child: GestureDetector(
              onTap: () =>
                  Navigator.pushNamed(context, AppRoutes.editProfile),
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 52,
                    backgroundColor: AppColors.primary.withValues(alpha: 0.15),
                    backgroundImage: (user?.photoUrl != null &&
                            user!.photoUrl.isNotEmpty)
                        ? NetworkImage(user.photoUrl)
                        : null,
                    child: (user?.photoUrl == null || user!.photoUrl.isEmpty)
                        ? const Icon(Icons.person,
                            size: 52, color: AppColors.primary)
                        : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.edit,
                          size: 14, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Center(
            child: Text(
              user?.displayName ?? 'Pengguna',
              style: const TextStyle(
                  fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          Center(
            child: Text(
              user?.email ?? '',
              style: const TextStyle(
                  color: AppColors.textSecondary, fontSize: 14),
            ),
          ),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _StatCard(
                    value: moodCount.toString(),
                    label: 'Mood'),
                const SizedBox(width: 10),
                _StatCard(
                    value: journalCount.toString(),
                    label: 'Jurnal'),
                const SizedBox(width: 10),
                _StatCard(
                    value: sessionCount.toString(),
                    label: 'Sesi'),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text('Pengaturan',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textSecondary,
                    fontSize: 13)),
          ),
          const Divider(height: 8),
          ListTile(
            leading: const Icon(Icons.person_outline,
                color: AppColors.primary),
            title: const Text('Edit Profil'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () =>
                Navigator.pushNamed(context, AppRoutes.editProfile),
          ),
          const _NotificationTile(),
          const Divider(),
          ListTile(
            leading:
                const Icon(Icons.logout, color: Colors.red),
            title: const Text('Keluar',
                style: TextStyle(color: Colors.red)),
            onTap: () => _confirmSignOut(context),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmSignOut(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Keluar?'),
        content: const Text('Kamu akan keluar dari akun ini.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Batal')),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child:
                  const Text('Keluar', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (ok == true && context.mounted) {
      await context.read<AuthProvider>().signOut();
      if (context.mounted) {
        Navigator.pushNamedAndRemoveUntil(
            context, AppRoutes.login, (_) => false);
      }
    }
  }
}

class _StatCard extends StatelessWidget {
  final String value;
  final String label;
  const _StatCard({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(value,
                style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary)),
            const SizedBox(height: 4),
            Text(label,
                style: const TextStyle(
                    fontSize: 12, color: AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  const _NotificationTile();

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.notifications_outlined, color: AppColors.primary),
      title: const Text('Notifikasi'),
      subtitle: const Text('Atur jadwal pengingat harian',
          style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => Navigator.pushNamed(context, AppRoutes.notificationSettings),
    );
  }
}
