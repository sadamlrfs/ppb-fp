import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_routes.dart';
import '../../core/utils/date_formatter.dart';
import '../../models/meditation_session_model.dart';
import '../../providers/meditation_provider.dart';

class SessionListPage extends StatelessWidget {
  const SessionListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<MeditationProvider>();

    if (prov.loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (prov.sessions.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.self_improvement, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('Belum ada sesi meditasi',
                style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text('Sesi Meditasi',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        ...prov.sessions.map((s) => _SessionCard(session: s)),
        if (prov.userSessions.isNotEmpty) ...[
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Riwayat Sesi',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              TextButton(
                onPressed: () =>
                    Navigator.pushNamed(context, AppRoutes.sessionHistory),
                child: const Text('Lihat Semua'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...prov.userSessions.take(3).map((us) {
            final session = prov.getSessionById(us.sessionId);
            return ListTile(
              leading: const Icon(Icons.check_circle,
                  color: AppColors.secondary),
              title: Text(session?.title ?? 'Sesi tidak ditemukan'),
              subtitle: Text(DateFormatter.toRelative(us.completedAt)),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(
                  5,
                  (i) => Icon(
                    i < us.rating ? Icons.star : Icons.star_border,
                    size: 14,
                    color: Colors.amber,
                  ),
                ),
              ),
            );
          }),
        ],
      ],
    );
  }
}

class _SessionCard extends StatelessWidget {
  final MeditationSessionModel session;
  const _SessionCard({required this.session});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => Navigator.pushNamed(context, AppRoutes.sessionPlayer,
            arguments: session),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, AppColors.primaryLight],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.self_improvement,
                    color: Colors.white, size: 28),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(session.title,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 15)),
                    const SizedBox(height: 4),
                    Text(session.description,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            color: AppColors.textSecondary, fontSize: 12)),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.timer_outlined,
                            size: 14, color: AppColors.textHint),
                        const SizedBox(width: 4),
                        Text(session.durationLabel,
                            style: const TextStyle(
                                color: AppColors.textHint, fontSize: 12)),
                        const SizedBox(width: 12),
                        Chip(
                          label: Text(session.category.label,
                              style: const TextStyle(fontSize: 10)),
                          padding: EdgeInsets.zero,
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                          side: BorderSide.none,
                          backgroundColor:
                              AppColors.secondary.withValues(alpha: 0.15),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(Icons.play_circle_filled,
                  color: AppColors.primary, size: 36),
            ],
          ),
        ),
      ),
    );
  }
}
