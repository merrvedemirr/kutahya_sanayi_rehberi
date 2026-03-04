// ── EMPTY STATE ──────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:sanayi_websites/core/constants/app_colors.dart';
import 'package:sanayi_websites/core/constants/app_text_styles.dart';

class EmptyState extends StatelessWidget {
  const EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'BULUNAMADI',
            style: AppTextStyles.displayLarge.copyWith(
              color: AppColors.border,
              fontSize: 40,
            ),
          ),
          const SizedBox(height: 8),
          Text('Farklı bir arama deneyin', style: AppTextStyles.bodySmall),
        ],
      ),
    );
  }
}
