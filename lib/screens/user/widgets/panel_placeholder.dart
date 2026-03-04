import 'package:flutter/material.dart';
import 'package:sanayi_websites/core/constants/app_colors.dart';
import 'package:sanayi_websites/core/constants/app_text_styles.dart';

class PanelPlaceholder extends StatelessWidget {
  final String title;
  const PanelPlaceholder({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(width: 3, height: 22, color: AppColors.accent),
          const SizedBox(width: 10),
          Expanded(child: Text(title, style: AppTextStyles.bodyMedium)),
          const Icon(Icons.chevron_right, color: AppColors.textMuted),
        ],
      ),
    );
  }
}

