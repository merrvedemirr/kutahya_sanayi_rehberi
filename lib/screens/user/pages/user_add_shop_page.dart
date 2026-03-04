import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sanayi_websites/core/constants/app_text_styles.dart';
import 'package:sanayi_websites/viewmodel/user_profile_repository.dart';

class UserAddShopPage extends ConsumerWidget {
  const UserAddShopPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(myProfileProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Dükkan Ekle', style: AppTextStyles.displayMedium),
        const SizedBox(height: 8),
        profileAsync.when(
          data: (p) => Text(
            p?.username.isNotEmpty == true
                ? 'Merhaba, ${p!.username}'
                : 'Buradan dükkan ekleyebilirsin.',
            style: AppTextStyles.bodySmall,
          ),
          loading: () => Text('...', style: AppTextStyles.bodySmall),
          error: (_, __) => Text(
            'Buradan dükkan ekleyebilirsin.',
            style: AppTextStyles.bodySmall,
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 48,
          child: ElevatedButton.icon(
            onPressed: () => context.push('/ekle'),
            icon: const Icon(Icons.add, size: 18),
            label: Text(
              'DÜKKAN EKLE',
              style: AppTextStyles.chipLabel.copyWith(color: Colors.black),
            ),
          ),
        ),
      ],
    );
  }
}

