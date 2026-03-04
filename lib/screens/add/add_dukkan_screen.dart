import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:sanayi_websites/screens/add/add_dukkan_model.dart';
import 'package:sanayi_websites/screens/add/widget/category_selector.dart';
import 'package:sanayi_websites/screens/add/widget/field.dart';
import 'package:sanayi_websites/screens/add/widget/section_label.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../detail/widgets/brand_grid.dart';

class AddDukkanScreen extends ConsumerStatefulWidget {
  const AddDukkanScreen({super.key});

  @override
  ConsumerState<AddDukkanScreen> createState() => _AddDukkanScreenState();
}

class _AddDukkanScreenState extends AddDukkanModel {
  @override
  Widget build(BuildContext context) {
    final formChildren = <Widget>[
      SectionLabel('LOGO / FOTOĞRAFLAR'),
      const SizedBox(height: 12),
      Wrap(
        spacing: 10,
        runSpacing: 10,
        children: [
          OutlinedButton.icon(
            onPressed: loading ? null : () => pickLogoCover(logoFile),
            icon: const Icon(Icons.image_outlined, size: 18),
            label: Text('Logo seç', style: AppTextStyles.chipLabel),
          ),
          OutlinedButton.icon(
            onPressed: loading ? null : () => pickLogoCover(coverFile),
            icon: const Icon(Icons.photo_outlined, size: 18),
            label: Text('Kapak seç', style: AppTextStyles.chipLabel),
          ),
          OutlinedButton.icon(
            onPressed: loading ? null : pickPhotos,
            icon: const Icon(Icons.collections_outlined, size: 18),
            label: Text('Fotoğraf seç', style: AppTextStyles.chipLabel),
          ),
        ],
      ),
      const SizedBox(height: 10),
      ValueListenableBuilder<PlatformFile?>(
        valueListenable: logoFile,
        builder: (context, logo, _) {
          return ValueListenableBuilder<PlatformFile?>(
            valueListenable: coverFile,
            builder: (context, cover, __) {
              if (logo?.bytes == null && cover?.bytes == null) {
                return const SizedBox.shrink();
              }
              return Column(
                children: [
                  Row(
                    children: [
                      if (logo?.bytes != null) ...[
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: RepaintBoundary(
                            child: Image.memory(
                              logo!.bytes!,
                              width: 60,
                              height: 60,
                              fit: BoxFit.cover,
                              filterQuality: FilterQuality.medium,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                      ],
                      if (cover?.bytes != null)
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: RepaintBoundary(
                              child: Image.memory(
                                cover!.bytes!,
                                height: 60,
                                fit: BoxFit.cover,
                                filterQuality: FilterQuality.medium,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 10),
                ],
              );
            },
          );
        },
      ),
      ValueListenableBuilder<List<PlatformFile>>(
        valueListenable: photoFiles,
        builder: (context, photos, _) {
          if (photos.isEmpty) return const SizedBox.shrink();
          return Column(
            children: [
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final f in photos)
                    Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: RepaintBoundary(
                            child: Image.memory(
                              f.bytes!,
                              width: 64,
                              height: 64,
                              fit: BoxFit.cover,
                              filterQuality: FilterQuality.low,
                            ),
                          ),
                        ),
                        Positioned(
                          right: 0,
                          top: 0,
                          child: InkWell(
                            onTap: loading
                                ? null
                                : () {
                                    final next = List<PlatformFile>.from(
                                      photos,
                                    );
                                    next.remove(f);
                                    photoFiles.value = next;
                                  },
                            child: Container(
                              width: 22,
                              height: 22,
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.6),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              alignment: Alignment.center,
                              child: const Icon(
                                Icons.close,
                                size: 14,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
              const SizedBox(height: 24),
            ],
          );
        },
      ),
      SectionLabel('TEMEL BİLGİLER'),
      const SizedBox(height: 12),
      Field(
        ctrl: isimCtrl,
        label: 'Dükkan Adı *',
        hint: 'Örn: Yıldız Tornacılık',
        requireds: true,
        keyboard: TextInputType.text,
      ),
      const SizedBox(height: 10),
      Field(
        ctrl: telefonCtrl,
        label: 'Telefon *',
        hint: '0532 xxx xx xx',
        requireds: true,
        keyboard: TextInputType.phone,
      ),
      const SizedBox(height: 10),
      Field(
        ctrl: telefon2Ctrl,
        label: 'İkinci Telefon',
        hint: 'Opsiyonel',
        keyboard: TextInputType.phone,
      ),
      const SizedBox(height: 10),
      Field(
        ctrl: whatsappCtrl,
        label: 'WhatsApp',
        hint: 'Opsiyonel',
        keyboard: TextInputType.phone,
      ),
      const SizedBox(height: 24),
      SectionLabel('KATEGORİ '),
      const SizedBox(height: 12),
      KategoriSelector(
        selected: kategori,
        kategoriler: AddDukkanModel.kategoriler,
        onSelected: (k) => setState(() {
          kategori = k;
          selectedBrands = [];
        }),
      ),
    ];

    final brandChildren = <Widget>[
      // Marka seçici (kategori seçildiyse göster)
      if (kategori != null) ...[
        const SizedBox(height: 24),
        SectionLabel('${kategori!.toUpperCase()} MARKALARI'),
        const SizedBox(height: 4),
        Text('Çalıştığınız markaları seçin', style: AppTextStyles.bodySmall),
        const SizedBox(height: 12),
        BrandSelector(
          kategori: kategori!,
          selected: selectedBrands,
          onChanged: (brands) => setState(() => selectedBrands = brands),
        ),
      ],
    ];

    final detailsChildren = <Widget>[
      SectionLabel('KONUM'),
      const SizedBox(height: 12),
      Row(
        children: [
          Expanded(
            child: Field(
              ctrl: blokCtrl,
              label: 'Blok',
              hint: 'Örn: A Blok',
              keyboard: TextInputType.text,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Field(
              ctrl: kapiNoCtrl,
              label: 'Kapı No',
              hint: 'Örn: 12',
              keyboard: TextInputType.text,
            ),
          ),
        ],
      ),
      const SizedBox(height: 24),
      SectionLabel('ÇALIŞMA BİLGİLERİ'),
      const SizedBox(height: 12),
      ValueListenableBuilder<TimeOfDay?>(
        valueListenable: startTime,
        builder: (context, start, _) {
          return ValueListenableBuilder<TimeOfDay?>(
            valueListenable: endTime,
            builder: (context, end, __) {
              return Row(
                children: [
                  Expanded(
                    child: timeBox(
                      label: 'Başlangıç',
                      value: start == null ? 'Seçin' : fmtTime(start),
                      onTap: () => pickTime(isStart: true),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: timeBox(
                      label: 'Bitiş',
                      value: end == null ? 'Seçin' : fmtTime(end),
                      onTap: () => pickTime(isStart: false),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
      const SizedBox(height: 10),
      Text('Tatil olan günleri seçin', style: AppTextStyles.bodySmall),
      const SizedBox(height: 10),
      Wrap(
        spacing: 8,
        runSpacing: 8,
        children: List.generate(AddDukkanModel.dayLabels.length, dayBox),
      ),
      const SizedBox(height: 16),
      Field(
        ctrl: aciklamaCtrl,
        label: 'Açıklama / Hizmetler',
        hint: 'Sunduğunuz hizmetleri yazın...',
        maxLines: 4,
        keyboard: TextInputType.text,
      ),
      const SizedBox(height: 32),
      SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: loading ? null : submit,
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
          child: loading
              ? const SizedBox(
                  height: 18,
                  width: 18,
                  child: CircularProgressIndicator(
                    color: Colors.black,
                    strokeWidth: 2,
                  ),
                )
              : Text(
                  'KAYDET',
                  style: AppTextStyles.chipLabel.copyWith(
                    color: Colors.black,
                    fontSize: 15,
                    letterSpacing: 2,
                  ),
                ),
        ),
      ),
      const SizedBox(height: 8),
      Text(
        'Dükkanınız onaylandıktan sonra listede görünecektir.',
        style: AppTextStyles.bodySmall.copyWith(fontSize: 11),
        textAlign: TextAlign.center,
      ),
      const SizedBox(height: 40),
    ];

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        automaticallyImplyLeading: false,
        title: Text('DÜKKAN EKLE', style: AppTextStyles.headlineMedium),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(2),
          child: Container(height: 2, color: AppColors.accent),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, c) {
          final isWide = c.maxWidth >= 900;

          if (!isWide) {
            return Form(
              key: formKey,
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  ...formChildren,
                  ...detailsChildren,
                  ...brandChildren,
                ],
              ),
            );
          }

          return Form(
            key: formKey,
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1100),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [...formChildren, ...brandChildren],
                        ),
                      ),
                      const SizedBox(width: 24),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [...detailsChildren],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
