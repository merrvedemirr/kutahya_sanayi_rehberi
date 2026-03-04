// ── SECTION DIVIDER ──────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:sanayi_websites/core/constants/app_colors.dart';
import 'package:sanayi_websites/core/constants/app_text_styles.dart';

class SectionDivider extends StatelessWidget {
  final int? count;
  const SectionDivider({super.key, this.count});
  //todo: Doğrudan dukkanalr listesini dinlemeli?
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
      child: Row(
        children: [
          Text('DÜKKANLAR', style: AppTextStyles.labelUppercase),
          const SizedBox(width: 12),
          Expanded(child: Container(height: 1, color: AppColors.border)),
          if (count != null) ...[
            const SizedBox(width: 12),
            Text('$count dükkan', style: AppTextStyles.labelAccent),
          ],
        ],
      ),
    );
  }
}
