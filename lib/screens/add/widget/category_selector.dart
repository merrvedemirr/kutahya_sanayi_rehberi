import 'package:flutter/material.dart';
import 'package:sanayi_websites/core/constants/app_colors.dart';
import 'package:sanayi_websites/core/constants/app_text_styles.dart';

class KategoriSelector extends StatelessWidget {
  final String? selected;
  final List<String> kategoriler;
  final ValueChanged<String> onSelected;

  const KategoriSelector({
    super.key,
    required this.selected,
    required this.kategoriler,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: kategoriler.map((k) {
        final isSelected = (selected == k);
        final color = AppColors.categoryColor(k);
        return GestureDetector(
          onTap: () => onSelected(k),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected ? color.withOpacity(0.12) : AppColors.surface2,
              border: Border.all(
                color: isSelected ? color : AppColors.border,
                width: 1.5,
              ),
            ),
            child: Text(
              k.toUpperCase(),
              style: AppTextStyles.chipLabel.copyWith(
                color: isSelected ? color : AppColors.textMuted,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
