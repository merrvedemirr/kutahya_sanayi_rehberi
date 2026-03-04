import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sanayi_websites/core/constants/app_colors.dart';
import 'package:sanayi_websites/core/constants/app_text_styles.dart';
import 'package:sanayi_websites/model/dukkan_model.dart';

class MyShopTile extends StatelessWidget {
  final DukkanModel shop;
  final Future<void> Function() onDelete;

  const MyShopTile({
    super.key,
    required this.shop,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = shop.onaylandiMi ? AppColors.open : AppColors.accent;
    final statusText = shop.onaylandiMi ? 'ONAYLANDI' : 'BEKLEMEDE';

    return InkWell(
      onTap: () => context.push('/dukkan/${shop.id}'),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Container(width: 3, height: 28, color: statusColor),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    shop.isim,
                    style: AppTextStyles.bodyMedium,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    statusText,
                    style: AppTextStyles.labelUppercase.copyWith(
                      color: statusColor,
                    ),
                  ),
                ],
              ),
            ),
            PopupMenuButton<String>(
              tooltip: 'İşlemler',
              onSelected: (v) {
                if (v == 'edit') context.push('/dukkan/${shop.id}/edit');
                if (v == 'delete') onDelete();
              },
              itemBuilder: (_) => const [
                PopupMenuItem(value: 'edit', child: Text('Düzenle')),
                PopupMenuItem(value: 'delete', child: Text('Sil')),
              ],
              icon: const Icon(Icons.more_vert, color: AppColors.textMuted),
            ),
          ],
        ),
      ),
    );
  }
}

