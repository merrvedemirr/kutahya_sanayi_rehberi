import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:sanayi_websites/core/constants/image_extensions.dart';
import 'package:sanayi_websites/model/dukkan_model.dart';
import 'package:sanayi_websites/screens/add/widget/section_label.dart';
import 'package:sanayi_websites/screens/home/widgets/dukkan_card.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:sanayi_websites/core/utils/storage_url.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../services/dukkan_service.dart';
import 'widgets/brand_grid.dart';

final dukkanDetailProvider = FutureProvider.family<DukkanModel?, String>((
  ref,
  id,
) async {
  return DukkanService().getDukkan(id);
});

class DetailScreen extends ConsumerWidget {
  final String dukkanId;
  const DetailScreen({super.key, required this.dukkanId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dukkanAsync = ref.watch(dukkanDetailProvider(dukkanId));

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: dukkanAsync.when(
        data: (dukkan) {
          if (dukkan == null) {
            return const Center(child: Text('Dükkan bulunamadı'));
          }
          return _DetailContent(dukkan: dukkan);
        },
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.accent),
        ),
        error: (e, _) =>
            Center(child: Text('Hata: $e', style: AppTextStyles.bodyMedium)),
      ),
    );
  }
}

class _DetailContent extends StatelessWidget {
  final DukkanModel dukkan;
  const _DetailContent({required this.dukkan});

  @override
  Widget build(BuildContext context) {
    final catColor = AppColors.categoryColor(dukkan.kategori);
    final hasGallery =
        dukkan.kapakFoto != null || dukkan.fotograflar.isNotEmpty;
    final hasBrands = dukkan.markalar.isNotEmpty;
    final hasServices = dukkan.hizmetler.isNotEmpty;

    return CustomScrollView(
      slivers: [
        // APP BAR
        SliverAppBar(
          pinned: true,
          backgroundColor: AppColors.surface,
          automaticallyImplyLeading: false,
          title: Text('Dükkan Detayı', style: AppTextStyles.headlineMedium),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(2),
            child: Container(height: 2, color: AppColors.accent),
          ),
        ),

        SliverToBoxAdapter(
          child: LayoutBuilder(
            builder: (context, c) {
              final isWide = c.maxWidth >= 980;

              Widget header() {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _CategoryBadge(kategori: dukkan.kategori, color: catColor),
                    const SizedBox(height: 12),
                    Text(
                      dukkan.isim.toUpperCase(),
                      style: AppTextStyles.displayMedium,
                    ),
                    if (dukkan.sahipAdi != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        dukkan.sahipAdi!.toUpperCase(),
                        style: AppTextStyles.bodyMedium,
                      ),
                    ],
                    const SizedBox(height: 8),
                    StatusBadge(acikMi: dukkan.acikMi, size: 35),
                  ],
                );
              }

              Widget contact() {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SectionLabel("İLETİŞİM"),
                    const SizedBox(height: 12),
                    _PhoneButton(phone: dukkan.telefon),
                    if (dukkan.telefon2 != null) ...[
                      const SizedBox(height: 8),
                      _PhoneButton(
                        phone: dukkan.telefon2!,
                        label: 'İkinci Hat',
                      ),
                    ],
                    if (dukkan.whatsapp != null) ...[
                      const SizedBox(height: 8),
                      _WhatsappButton(phone: dukkan.whatsapp!),
                    ],
                  ],
                );
              }

              Widget info() {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SectionLabel("BİLGİLER"),
                    const SizedBox(height: 12),
                    if (dukkan.adres.isNotEmpty)
                      InfoRow(icon: ImageItems.mapicon, text: dukkan.adres),
                    if (dukkan.calismaSaatleri != null)
                      InfoRow(
                        icon: ImageItems.clockicon,
                        text: dukkan.calismaSaatleri!,
                        color: AppColors.textPrimary,
                      ),
                    if (dukkan.tatilGunleri != null)
                      InfoRow(
                        icon: ImageItems.calendar,
                        text: dukkan.tatilGunleri!,
                      ),
                    if (dukkan.aciklama != null) ...[
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        color: AppColors.surface2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'AÇIKLAMA',
                              style: AppTextStyles.labelUppercase,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              dukkan.aciklama!,
                              style: AppTextStyles.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                );
              }

              Widget servicesAndBrands() {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (hasServices) ...[
                      SectionLabel("HİZMETLER"),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: dukkan.hizmetler
                            .map(
                              (h) => Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.surface2,
                                  border: Border.all(color: AppColors.border),
                                ),
                                child: Text(
                                  h.toUpperCase(),
                                  style: AppTextStyles.chipLabel.copyWith(
                                    color: AppColors.textMuted,
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ],
                    if (hasBrands) ...[
                      if (hasServices) const SizedBox(height: 24),
                      SectionLabel("ÇALIŞTIĞI MARKALAR"),
                      const SizedBox(height: 12),
                      BrandGrid(brandIds: dukkan.markalar),
                    ],
                  ],
                );
              }

              Widget gallery() {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SectionLabel("FOTOĞRAFLAR"),
                    const SizedBox(height: 12),
                    _ImageGallery(
                      cover: dukkan.kapakFoto,
                      photos: dukkan.fotograflar,
                      logo: dukkan.logoUrl,
                    ),
                  ],
                );
              }

              Widget mobileBody() {
                return Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      header(),
                      const SizedBox(height: 24),
                      contact(),
                      const SizedBox(height: 24),
                      info(),
                      if (hasServices) ...[
                        const SizedBox(height: 24),
                        SectionLabel("HİZMETLER"),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: dukkan.hizmetler
                              .map(
                                (h) => Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.surface2,
                                    border: Border.all(color: AppColors.border),
                                  ),
                                  child: Text(
                                    h.toUpperCase(),
                                    style: AppTextStyles.chipLabel.copyWith(
                                      color: AppColors.textMuted,
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                      ],
                      if (hasBrands) ...[
                        const SizedBox(height: 24),
                        SectionLabel("ÇALIŞTIĞI MARKALAR"),
                        const SizedBox(height: 12),
                        BrandGrid(brandIds: dukkan.markalar),
                      ],
                      if (hasGallery) ...[
                        const SizedBox(height: 18),
                        gallery(),
                      ],
                      const SizedBox(height: 40),
                    ],
                  ),
                );
              }

              Widget desktopBody() {
                return Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1100),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          header(),
                          const SizedBox(height: 24),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(child: contact()),
                              const SizedBox(width: 24),
                              Expanded(child: info()),
                            ],
                          ),
                          if (hasServices || hasBrands || hasGallery) ...[
                            const SizedBox(height: 28),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (hasServices || hasBrands)
                                  Expanded(child: servicesAndBrands()),
                                if ((hasServices || hasBrands) && hasGallery)
                                  const SizedBox(width: 24),
                                if (hasGallery) Expanded(child: gallery()),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                );
              }

              return isWide ? desktopBody() : mobileBody();
            },
          ),
        ),
      ],
    );
  }
}

// ── WIDGETS ──────────────────────────────────────────────────────────────────

class _ImageGallery extends StatefulWidget {
  final String? cover;
  final String? logo;
  final List<String> photos;

  const _ImageGallery({
    required this.cover,
    required this.photos,
    required this.logo,
  });

  @override
  State<_ImageGallery> createState() => _ImageGalleryState();
}

class _ImageGalleryState extends State<_ImageGallery> {
  late final List<String> _urls;
  int _active = 0;

  @override
  void initState() {
    super.initState();
    final items = <String>[
      if (widget.cover != null) widget.cover!,
      ...widget.photos,
      if (widget.logo != null) widget.logo!,
    ];
    final urls = items
        .map(StorageUrl.fromPath)
        .whereType<String>()
        .toList(growable: false);
    _urls = urls;
  }

  @override
  Widget build(BuildContext context) {
    if (_urls.isEmpty) return const SizedBox.shrink();

    final dpr = MediaQuery.devicePixelRatioOf(context);

    return LayoutBuilder(
      builder: (context, c) {
        final w = c.maxWidth;
        const aspect = 16 / 9;
        final maxHeroH = w < 600 ? 240.0 : 320.0;
        final heroH = (w / aspect).clamp(200.0, maxHeroH);
        final heroMemW = (w * dpr).round();
        final heroMemH = (heroH * dpr).round();

        return Column(
          children: [
            SizedBox(
              height: heroH,
              width: double.infinity,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: GestureDetector(
                  onTap: () => _openViewer(context),
                  child: Container(
                    color: AppColors.surface2,
                    child: CachedNetworkImage(
                      imageUrl: _urls[_active],
                      // `contain` reduces "portrait vs landscape" zoom/crop differences.
                      fit: BoxFit.contain,
                      memCacheWidth: heroMemW,
                      memCacheHeight: heroMemH,
                      maxWidthDiskCache: heroMemW,
                      maxHeightDiskCache: heroMemH,
                      fadeInDuration: Duration.zero,
                      fadeOutDuration: Duration.zero,
                      placeholder: (_, __) => const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.accent,
                        ),
                      ),
                      errorWidget: (_, __, ___) => const Center(
                        child: Icon(
                          Icons.broken_image,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            if (_urls.length > 1) ...[
              const SizedBox(height: 10),
              SizedBox(
                height: 56,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _urls.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, i) {
                    final isActive = i == _active;
                    final thumbMemW = (78 * dpr).round();
                    final thumbMemH = (56 * dpr).round();
                    return GestureDetector(
                      onTap: () => setState(() => _active = i),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          width: 78,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color:
                                  isActive ? AppColors.accent : AppColors.border,
                              width: isActive ? 2 : 1,
                            ),
                          ),
                          child: CachedNetworkImage(
                            imageUrl: _urls[i],
                            fit: BoxFit.cover,
                            memCacheWidth: thumbMemW,
                            memCacheHeight: thumbMemH,
                            maxWidthDiskCache: thumbMemW,
                            maxHeightDiskCache: thumbMemH,
                            fadeInDuration: Duration.zero,
                            fadeOutDuration: Duration.zero,
                            placeholder: (_, __) =>
                                Container(color: AppColors.surface2),
                            errorWidget: (_, __, ___) => const Center(
                              child: Icon(
                                Icons.image_not_supported,
                                color: AppColors.textMuted,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 6),
              // no extra hint text
            ],
          ],
        );
      },
    );
  }

  void _openViewer(BuildContext context) {
    showDialog<void>(
      context: context,
      barrierColor: Colors.black.withOpacity(0.8),
      builder: (_) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(16),
          child: GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: InteractiveViewer(
              minScale: 0.8,
              maxScale: 4,
              child: CachedNetworkImage(
                imageUrl: _urls[_active],
                fit: BoxFit.contain,
                placeholder: (_, __) => const Center(
                  child: CircularProgressIndicator(color: AppColors.accent),
                ),
                errorWidget: (_, __, ___) => const Center(
                  child: Icon(Icons.broken_image, color: AppColors.textMuted),
                ),
              ),
            ),
          ),
        );
      },
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        border: Border.all(color: color, width: 1),
      ),
      child: Text(
        kategori.toUpperCase(),
        style: AppTextStyles.chipLabel.copyWith(color: color),
      ),
    );
  }
}

class _PhoneButton extends StatelessWidget {
  final String phone;
  final String label;
  const _PhoneButton({required this.phone, this.label = 'Ara'});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => launchUrl(Uri.parse('tel:$phone')),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        color: AppColors.accent,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '📞  $label  ·  $phone',
              style: AppTextStyles.phone.copyWith(
                color: Colors.black,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WhatsappButton extends StatelessWidget {
  final String phone;
  const _WhatsappButton({required this.phone});

  @override
  Widget build(BuildContext context) {
    final clean = phone.replaceAll(RegExp(r'[^0-9]'), '');
    return GestureDetector(
      onTap: () => launchUrl(Uri.parse('https://wa.me/90$clean')),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF25D366).withOpacity(0.1),
          border: Border.all(color: const Color(0xFF25D366), width: 1.5),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.chat, color: Color(0xFF25D366), size: 18),
            const SizedBox(width: 10),
            Text(
              'WhatsApp ile Yaz',
              style: AppTextStyles.phone.copyWith(
                color: const Color(0xFF25D366),
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
