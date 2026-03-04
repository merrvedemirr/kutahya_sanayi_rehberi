import 'package:flutter/material.dart';
import 'package:sanayi_websites/core/constants/app_colors.dart';
import 'package:sanayi_websites/core/constants/app_text_styles.dart';
import 'package:sanayi_websites/core/constants/image_extensions.dart';

class HomeCard extends StatelessWidget {
  const HomeCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(5),
        child: Stack(
          children: [
            // Arka plan görsel (köşede, dekor gibi)
            Positioned(
              top: -30,
              right: -20,
              child: IgnorePointer(
                child: Opacity(
                  opacity: 0.18, // istediğine göre 0.10–0.25 arası güzel durur
                  child: Image.asset(
                    ImageItems.homebanner.imagePath,
                    width: 220,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),

            // Öndeki içerik
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('TÜM', style: AppTextStyles.displayLarge),
                  Text(
                    'DÜKKANLAR',
                    style: AppTextStyles.displayLarge.copyWith(
                      color: AppColors.accent,
                    ),
                  ),
                  Text('BİR YERDE', style: AppTextStyles.displayLarge),
                  const SizedBox(height: 15),
                  Text(
                    'Sanayi sitenizdeki tüm esnafı anında bulun. Telefon, konum, kategori — hepsi burada.',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
