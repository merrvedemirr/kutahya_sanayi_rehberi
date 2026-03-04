import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../data/brand_data.dart';

class BrandGrid extends StatelessWidget {
  final List<String> brandIds;

  const BrandGrid({super.key, required this.brandIds});

  @override
  Widget build(BuildContext context) {
    if (brandIds.isEmpty) return const SizedBox.shrink();

    final brands = brandIds
        .map((id) => BrandData.getBrand(id))
        .where((b) => b != null)
        .toList();

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 100,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        childAspectRatio: 1.4,
      ),
      itemCount: brands.length,
      itemBuilder: (context, i) => _BrandItem(brand: brands[i]!),
    );
  }
}

class _BrandItem extends StatelessWidget {
  final Map<String, String> brand;
  const _BrandItem({required this.brand});

  @override
  Widget build(BuildContext context) {
    final dpr = MediaQuery.devicePixelRatioOf(context);
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface2,
        border: Border.all(color: AppColors.border, width: 1),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: LayoutBuilder(
              builder: (context, c) {
                final w = (c.maxWidth * dpr).round();
                final h = (c.maxHeight * dpr).round();
                return CachedNetworkImage(
                  imageUrl: brand['logo'] ?? '',
                  fit: BoxFit.contain,
                  memCacheWidth: w > 0 ? w : null,
                  memCacheHeight: h > 0 ? h : null,
                  maxWidthDiskCache: w > 0 ? w : null,
                  maxHeightDiskCache: h > 0 ? h : null,
                  fadeInDuration: Duration.zero,
                  fadeOutDuration: Duration.zero,
                  errorWidget: (_, __, ___) => Center(
                    child: Text(
                      (brand['name'] ?? '??').substring(0, 2).toUpperCase(),
                      style: AppTextStyles.headlineMedium.copyWith(
                        color: AppColors.textMuted,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 6),
          Text(
            brand['name'] ?? '',
            style: AppTextStyles.labelUppercase.copyWith(fontSize: 9),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

// Marka seçim widgeti (form için)
class BrandSelector extends StatelessWidget {
  final String kategori;
  final List<String> selected;
  final ValueChanged<List<String>> onChanged;

  const BrandSelector({
    super.key,
    required this.kategori,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final dpr = MediaQuery.devicePixelRatioOf(context);
    final brands = BrandData.getBrandsForCategory(kategori);
    if (brands.isEmpty) return const SizedBox.shrink();

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 100,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        childAspectRatio: 1.3,
      ),
      itemCount: brands.length,
      itemBuilder: (context, i) {
        final brand = brands[i];
        final isSelected = selected.contains(brand['id']);
        return GestureDetector(
          onTap: () {
            final newSelected = List<String>.from(selected);
            if (isSelected) {
              newSelected.remove(brand['id']);
            } else {
              newSelected.add(brand['id']!);
            }
            onChanged(newSelected);
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.accent.withOpacity(0.1)
                  : AppColors.bg,
              border: Border.all(
                color: isSelected ? AppColors.accent : AppColors.border,
                width: 1.5,
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, c) {
                      final w = (c.maxWidth * dpr).round();
                      final h = (c.maxHeight * dpr).round();
                      return CachedNetworkImage(
                        imageUrl: brand['logo'] ?? '',
                        fit: BoxFit.contain,
                        memCacheWidth: w > 0 ? w : null,
                        memCacheHeight: h > 0 ? h : null,
                        maxWidthDiskCache: w > 0 ? w : null,
                        maxHeightDiskCache: h > 0 ? h : null,
                        fadeInDuration: Duration.zero,
                        fadeOutDuration: Duration.zero,
                        colorBlendMode: isSelected ? null : BlendMode.srcIn,
                        errorWidget: (_, __, ___) => Center(
                          child: Text(
                            (brand['name'] ?? '??')
                                .substring(0, 2)
                                .toUpperCase(),
                            style: AppTextStyles.bodySmall,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  brand['name'] ?? '',
                  style: AppTextStyles.labelUppercase.copyWith(
                    fontSize: 8,
                    color: isSelected ? AppColors.accent : AppColors.textMuted,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
