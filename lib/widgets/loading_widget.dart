import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';

// Widget loading spinner reusable.
// Gunakan di mana saja saat state loading == true.
// Contoh: if (provider.loading) return const LoadingWidget();

class LoadingWidget extends StatelessWidget {
  final String? message;

  const LoadingWidget({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(color: AppColors.primary),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(message!,
                style: const TextStyle(color: AppColors.textSecondary)),
          ],
        ],
      ),
    );
  }
}
