import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sanayi_websites/core/constants/app_colors.dart';
import 'package:sanayi_websites/core/constants/app_text_styles.dart';
import 'package:sanayi_websites/core/utils/storage_url.dart';
import 'package:sanayi_websites/viewmodel/reklam_repository.dart';
import 'package:url_launcher/url_launcher.dart';

class ReklamPanel extends ConsumerWidget {
  final String title;
  final double height;
  final String placement;

  const ReklamPanel({
    super.key,
    required this.title,
    required this.height,
    required this.placement,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reklamlarAsync = ref.watch(reklamlarProvider(placement));

    return Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: AppColors.surface2,
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: height,
            width: double.infinity,
            child: reklamlarAsync.when(
              loading: () => Container(
                color: AppColors.bg,
                alignment: Alignment.center,
                child: const CircularProgressIndicator(color: AppColors.accent),
              ),
              error: (e, _) => Container(
                color: AppColors.bg,
                alignment: Alignment.center,
                padding: const EdgeInsets.all(12),
                child: Text(
                  'Reklam yüklenemedi: $e',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textMuted,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              data: (list) {
                if (list.isEmpty) {
                  return Container(
                    color: AppColors.bg,
                    alignment: Alignment.center,
                    child: Text(
                      'Reklam Alanı',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textMuted,
                      ),
                    ),
                  );
                }

                // Show the latest ad.
                final ad = list.first;
                final imageUrl = StorageUrl.fromPath(ad.image);
                final link = ad.link?.trim();

                final child = (imageUrl == null)
                    ? Container(
                        color: AppColors.bg,
                        alignment: Alignment.center,
                        padding: const EdgeInsets.all(12),
                        child: Text(
                          ad.title,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textMuted,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      )
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: CachedNetworkImage(
                          imageUrl: imageUrl,
                          fit: BoxFit.cover,
                          placeholder: (_, __) => Container(
                            color: AppColors.bg,
                            alignment: Alignment.center,
                            child: const CircularProgressIndicator(
                              color: AppColors.accent,
                              strokeWidth: 2,
                            ),
                          ),
                          errorWidget: (_, __, ___) => Container(
                            color: AppColors.bg,
                            alignment: Alignment.center,
                            padding: const EdgeInsets.all(12),
                            child: Text(
                              ad.title,
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.textMuted,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      );

                if (link == null || link.isEmpty) return child;

                return InkWell(
                  onTap: () => launchUrl(Uri.parse(link)),
                  child: child,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
