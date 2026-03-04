// ── CARD SKELETON ────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:sanayi_websites/core/constants/app_colors.dart';

class CardSkeleton extends StatelessWidget {
  const CardSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _shimmer(height: 10, width: 60),
          const SizedBox(height: 16),
          _shimmer(height: 18, width: double.infinity),
          const SizedBox(height: 8),
          _shimmer(height: 12, width: 120),
          const SizedBox(height: 24),
          _shimmer(height: 10, width: 140),
          const SizedBox(height: 8),
          _shimmer(height: 10, width: 100),
        ],
      ),
    );
  }

  Widget _shimmer({required double height, required double width}) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: AppColors.surface2,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}

class StatsBarSkeleton extends StatelessWidget {
  const StatsBarSkeleton({super.key});
  @override
  Widget build(BuildContext context) =>
      Container(height: 72, color: AppColors.surface);
}
