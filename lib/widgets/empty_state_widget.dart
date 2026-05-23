import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';

// Widget empty state reusable.
// Gunakan saat list data kosong.
// Contoh:
//   if (journals.isEmpty) return EmptyStateWidget(
//     icon: Icons.book_outlined,
//     message: 'Belum ada jurnal',
//   );

class EmptyStateWidget extends StatelessWidget {
  final IconData icon;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  const EmptyStateWidget({
    super.key,
    required this.icon,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 64, color: AppColors.textHint),
          const SizedBox(height: 16),
          Text(message,
              style: const TextStyle(color: AppColors.textSecondary)),
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: onAction,
              child: Text(actionLabel!),
            ),
          ],
        ],
      ),
    );
  }
}
