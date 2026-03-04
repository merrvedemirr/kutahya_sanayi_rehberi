import 'package:flutter/material.dart';
import 'package:sanayi_websites/core/constants/app_colors.dart';

class PanelCard extends StatelessWidget {
  final Widget child;
  const PanelCard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface2,
        border: Border.all(color: AppColors.border),
      ),
      child: child,
    );
  }
}

