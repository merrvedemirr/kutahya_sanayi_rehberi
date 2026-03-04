import 'package:flutter/material.dart';
import 'package:sanayi_websites/core/constants/app_colors.dart';
import 'package:sanayi_websites/core/constants/app_text_styles.dart';
import 'package:sanayi_websites/model/dukkan_model.dart';

class StatsBar extends StatelessWidget {
  final List<DukkanModel> dukkanlar;
  const StatsBar({super.key, required this.dukkanlar});

  @override
  Widget build(BuildContext context) {
    final acik = dukkanlar.where((d) => d.acikMi).length;
    final kategoriler = dukkanlar.map((d) => d.kategori).toSet().length;

    return Card(
      color: Colors.transparent,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _StatItem(value: '${dukkanlar.length}', label: 'DÜKKAN'),
            _StatItem(
              value: '$acik',
              label: 'ŞU AN AÇIK',
              valueColor: AppColors.open,
            ),
            _StatItem(value: '$kategoriler', label: 'KATEGORİ'),
          ],
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String value;
  final String label;
  final Color? valueColor;
  const _StatItem({required this.value, required this.label, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: AppTextStyles.displayMedium.copyWith(
            fontSize: 30,
            color: valueColor ?? AppColors.accent,
          ),
        ),
        Text(label, style: AppTextStyles.labelUppercase),
      ],
    );
  }
}
