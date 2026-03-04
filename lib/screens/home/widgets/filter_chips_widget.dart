import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';

class FilterChipsWidget extends StatelessWidget {
  final List<String> kategoriler;
  final String? selected;
  final ValueChanged<String?> onSelected;

  const FilterChipsWidget({
    super.key,
    required this.kategoriler,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    const rows = 3;
    const spacing = 8.0;
    const tileWidth = 140.0; // yazılar uzunsa 160-180 yap
    const tileHeight = 36.0;

    final itemCount = kategoriler.length + 1; // +1 = "Tümü"

    return SizedBox(
      height: rows * tileHeight + (rows - 1) * spacing,
      child: GridView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: rows, // 3 satır
          mainAxisSpacing: spacing, // yatay aralık
          crossAxisSpacing: spacing, // dikey aralık
          mainAxisExtent: tileWidth, // her chip kutusunun genişliği
        ),
        itemCount: itemCount,
        itemBuilder: (context, index) {
          if (index == 0) return _buildChip('Tümü', null);
          final k = kategoriler[index - 1];
          return _buildChip(k, k);
        },
      ),
    );
  }

  Widget _buildChip(String label, String? value) {
    final isActive = selected == value;
    final color = value != null
        ? AppColors.categoryColor(value)
        : AppColors.accent;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: () => onSelected(value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 0),
          decoration: BoxDecoration(
            color: isActive ? color.withOpacity(0.12) : AppColors.bg,
            border: Border.all(
              color: isActive ? color : AppColors.border,
              width: 1.5,
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            label.toUpperCase(),
            style: AppTextStyles.chipLabel.copyWith(
              color: isActive ? color : AppColors.textMuted,
            ),
          ),
        ),
      ),
    );
  }
}
