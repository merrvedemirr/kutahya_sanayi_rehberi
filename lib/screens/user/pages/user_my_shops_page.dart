import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sanayi_websites/core/constants/app_colors.dart';
import 'package:sanayi_websites/core/constants/app_text_styles.dart';
import 'package:sanayi_websites/viewmodel/dukkans_repository.dart';
import 'package:sanayi_websites/screens/user/widgets/my_shop_tile.dart';

class UserMyShopsPage extends ConsumerWidget {
  const UserMyShopsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final myDukkanlarAsync = ref.watch(myDukkanlarStreamProvider);

    Future<void> deleteShop(String id, String name) async {
      final ok = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Dükkanı sil?'),
          content: Text(
            '"$name" dükkanını silmek istediğine emin misin?',
            style: AppTextStyles.bodyMedium,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('İptal'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Sil'),
            ),
          ],
        ),
      );
      if (ok != true) return;

      try {
        await ref.read(dukkanServiceProvider).deleteDukkan(id);
        // Even if realtime is off, force refresh.
        ref.invalidate(myDukkanlarStreamProvider);
        // Wait for the refreshed provider to emit once.
        await ref.read(myDukkanlarStreamProvider.future);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Dükkan silindi.')),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Silme hatası: $e')),
          );
        }
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Dükkanlarım', style: AppTextStyles.displayMedium),
        const SizedBox(height: 8),
        Text('Onay durumu burada görünür.', style: AppTextStyles.bodySmall),
        const SizedBox(height: 16),
        myDukkanlarAsync.when(
          data: (list) {
            if (list.isEmpty) {
              return Text(
                'Henüz dükkan eklemediniz.',
                style: AppTextStyles.bodySmall,
              );
            }

            final approved = list.where((d) => d.onaylandiMi).toList();
            final pending = list.where((d) => !d.onaylandiMi).toList();

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (pending.isNotEmpty) ...[
                  Text('BEKLEMEDE', style: AppTextStyles.labelUppercase),
                  const SizedBox(height: 8),
                  ...pending.map(
                    (d) => MyShopTile(
                      shop: d,
                      onDelete: () => deleteShop(d.id, d.isim),
                    ),
                  ),
                  const SizedBox(height: 18),
                ],
                if (approved.isNotEmpty) ...[
                  Text('ONAYLANDI', style: AppTextStyles.labelUppercase),
                  const SizedBox(height: 8),
                  ...approved.map(
                    (d) => MyShopTile(
                      shop: d,
                      onDelete: () => deleteShop(d.id, d.isim),
                    ),
                  ),
                ],
              ],
            );
          },
          loading: () => Text('Yükleniyor...', style: AppTextStyles.bodySmall),
          error: (e, _) => Text(
            'Hata: $e',
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.accentDark),
          ),
        ),
      ],
    );
  }
}

