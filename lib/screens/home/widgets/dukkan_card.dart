import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:sanayi_websites/core/constants/image_extensions.dart';
import 'package:sanayi_websites/data/brand_data.dart';
import 'package:sanayi_websites/model/dukkan_model.dart';
import 'package:sanayi_websites/core/utils/storage_url.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';

class DukkanCard extends StatelessWidget {
  final DukkanModel dukkan;
  final VoidCallback onTap;

  const DukkanCard({super.key, required this.dukkan, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final dpr = MediaQuery.devicePixelRatioOf(context);
    final catColor = AppColors.categoryColor(dukkan.kategori);
    final logoUrl = StorageUrl.fromPath(dukkan.kapakFoto ?? dukkan.logoUrl);
    final total = dukkan.markalar.length;
    final visibleLogosCount = total.clamp(0, 2);
    final moreCount = total - visibleLogosCount;
    final isMobile = MediaQuery.sizeOf(context).width < 600;

    final brands = dukkan.markalar
        .take(visibleLogosCount)
        .map((id) => BrandData.getBrand(id))
        .whereType<Map<String, String>>()
        .toList();

    final logoMemH = (64 * dpr).round();
    final logoMemW = (220 * dpr).round();
    final miniMem = (52 * dpr).round();

    return RepaintBoundary(
      child: GestureDetector(
        onTap: onTap,
        child: Card(
          elevation: 5,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          color: AppColors.surface2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Üst: numara + kategori
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(dukkan.idFormatted, style: AppTextStyles.cardNum),
                    _CategoryBadge(kategori: dukkan.kategori, color: catColor),
                  ],
                ),
              ),

              if (logoUrl != null) ...[
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      height: 64,
                      width: double.infinity,
                      color: AppColors.surface,
                      alignment: Alignment.center,
                      child: CachedNetworkImage(
                        imageUrl: logoUrl,
                        memCacheWidth: logoMemW,
                        memCacheHeight: logoMemH,
                        maxWidthDiskCache: logoMemW,
                        maxHeightDiskCache: logoMemH,
                        fadeInDuration: Duration.zero,
                        fadeOutDuration: Duration.zero,
                        // Prevent "blurry/pixelated" look when scaling logos.
                        filterQuality: FilterQuality.high,
                        // Keep logo in a reasonable max width so it doesn't upscale too much.
                        imageBuilder: (context, provider) => ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 220),
                          child: Image(
                            image: provider,
                            height: 64,
                            fit: BoxFit.contain,
                            filterQuality: FilterQuality.high,
                          ),
                        ),
                        placeholder: (_, __) => const SizedBox(
                          height: 64,
                          child: Center(
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.accent,
                            ),
                          ),
                        ),
                        errorWidget: (_, __, ___) => const SizedBox(
                          height: 64,
                          child: Center(
                            child: Icon(
                              Icons.storefront,
                              color: AppColors.textMuted,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],

              // İsim
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 2),
                child: Text(
                  dukkan.isim.toUpperCase(),
                  style: AppTextStyles.cardTitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),

              // Sahip
              if (dukkan.sahipAdi != null)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                  child: Text(dukkan.sahipAdi!, style: AppTextStyles.bodySmall),
                ),

              const SizedBox(height: 10),

              // Bilgiler
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    if (dukkan.telefon.isNotEmpty)
                      InfoRow(icon: ImageItems.phoneicon, text: dukkan.telefon),
                    if (dukkan.adres.isNotEmpty)
                      InfoRow(icon: ImageItems.mapicon, text: dukkan.adres),
                    if (dukkan.calismaSaatleri != null)
                      InfoRow(
                        icon: ImageItems.clockicon,
                        text: dukkan.calismaSaatleri!,
                        color: AppColors.textPrimary,
                      ),
                  ],
                ),
              ),

              // Mini marka logoları
              if (brands.isNotEmpty) ...[
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      for (final b in brands) ...[
                        MiniBrandLogo(brand: b, memCache: miniMem),
                        const SizedBox(width: 6),
                      ],
                      if (moreCount > 0)
                        SizedBox(
                          width: 52,
                          height: 40,
                          child: Card(
                            elevation: 3,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            margin: EdgeInsets.zero,
                            color: AppColors.surface,
                            child: Container(
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                border: Border.all(color: AppColors.border),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                '+$moreCount',
                                style: AppTextStyles.labelUppercase.copyWith(
                                  fontSize: 9,
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
              if (!isMobile) const Spacer(),
              // Alt: durum + ok
              Container(
                margin: const EdgeInsets.fromLTRB(16, 8, 16, 14),
                padding: const EdgeInsets.only(top: 10),
                decoration: const BoxDecoration(
                  border: Border(top: BorderSide(color: AppColors.border)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    StatusBadge(acikMi: dukkan.acikMi),
                    const Icon(
                      Icons.arrow_forward,
                      size: 16,
                      color: AppColors.textMuted,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MiniBrandLogo extends StatelessWidget {
  final Map<String, String> brand;
  final int memCache;
  const MiniBrandLogo({super.key, required this.brand, required this.memCache});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 50,
      height: 40,
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.only(right: 4),
        color: AppColors.border,
        child: CachedNetworkImage(
          imageUrl: brand['logo'] ?? '',
          fit: BoxFit.contain,
          filterQuality: FilterQuality.high,
          memCacheWidth: memCache,
          memCacheHeight: memCache,
          maxWidthDiskCache: memCache,
          maxHeightDiskCache: memCache,
          fadeInDuration: Duration.zero,
          fadeOutDuration: Duration.zero,
          errorWidget: (_, __, ___) => Center(
            child: Text(
              (brand['name'] ?? '??').substring(0, 2).toUpperCase(),
              style: AppTextStyles.labelUppercase.copyWith(fontSize: 8),
            ),
          ),
        ),
      ),
    );
  }
}

class _CategoryBadge extends StatelessWidget {
  final String kategori;
  final Color color;
  const _CategoryBadge({required this.kategori, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        border: Border.all(color: color, width: 1),
      ),
      child: Text(
        kategori.toUpperCase(),
        style: AppTextStyles.chipLabel.copyWith(color: color, fontSize: 10),
      ),
    );
  }
}

class InfoRow extends StatelessWidget {
  final ImageItems icon;
  final String text;
  final Color? color;
  const InfoRow({
    super.key,
    required this.icon,
    required this.text,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Image.asset(icon.imagePath, width: 17, height: 17, color: color),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              style: AppTextStyles.bodySmall.copyWith(fontSize: 12),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class StatusBadge extends StatelessWidget {
  final bool acikMi;
  final double? size;
  const StatusBadge({super.key, required this.acikMi, this.size = 20.0});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        acikMi
            ? Image.asset(
                ImageItems.open.imagePath,
                width: size,
                height: size,
                color: Colors.green,
              )
            : Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.closed,
                ),
              ),
        const SizedBox(width: 6),
        Text(
          acikMi ? 'AÇIK' : 'KAPALI',
          style: AppTextStyles.statusLabel.copyWith(
            color: acikMi ? AppColors.open : AppColors.closed,
          ),
        ),
      ],
    );
  }
}
