import 'package:flutter/material.dart';
import 'package:sanayi_websites/core/constants/app_text_styles.dart';
import 'package:sanayi_websites/screens/user/widgets/panel_placeholder.dart';

class UserStatsPage extends StatelessWidget {
  const UserStatsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('İstatistik', style: AppTextStyles.displayMedium),
        const SizedBox(height: 8),
        Text('Şimdilik sahte içerik.', style: AppTextStyles.bodySmall),
        const SizedBox(height: 16),
        const PanelPlaceholder(title: 'Günlük görüntülenme'),
        const SizedBox(height: 12),
        const PanelPlaceholder(title: 'Toplam dükkan'),
      ],
    );
  }
}

