import 'package:cached_network_image/cached_network_image.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sanayi_websites/core/constants/app_colors.dart';
import 'package:sanayi_websites/core/constants/app_text_styles.dart';
import 'package:sanayi_websites/core/utils/storage_url.dart';
import 'package:sanayi_websites/model/dukkan_model.dart';
import 'package:sanayi_websites/screens/add/add_dukkan_usecase.dart';
import 'package:sanayi_websites/screens/add/widget/category_selector.dart';
import 'package:sanayi_websites/screens/add/widget/field.dart';
import 'package:sanayi_websites/screens/add/widget/section_label.dart';
import 'package:sanayi_websites/screens/detail/widgets/brand_grid.dart';
import 'package:sanayi_websites/services/dukkan_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final editDukkanProvider = FutureProvider.family<DukkanModel?, String>((ref, id) {
  return DukkanService().getDukkan(id);
});

class EditDukkanScreen extends ConsumerStatefulWidget {
  final String dukkanId;
  const EditDukkanScreen({super.key, required this.dukkanId});

  @override
  ConsumerState<EditDukkanScreen> createState() => _EditDukkanScreenState();
}

class _EditDukkanScreenState extends ConsumerState<EditDukkanScreen> {
  final formKey = GlobalKey<FormState>();
  bool loading = false;

  final isimCtrl = TextEditingController();
  final telefonCtrl = TextEditingController();
  final telefon2Ctrl = TextEditingController();
  final whatsappCtrl = TextEditingController();
  final blokCtrl = TextEditingController();
  final kapiNoCtrl = TextEditingController();
  final aciklamaCtrl = TextEditingController();

  String? kategori;
  List<String> selectedBrands = [];

  final ValueNotifier<PlatformFile?> logoFile = ValueNotifier<PlatformFile?>(null);
  final ValueNotifier<PlatformFile?> coverFile =
      ValueNotifier<PlatformFile?>(null);
  final ValueNotifier<List<PlatformFile>> photoFiles =
      ValueNotifier<List<PlatformFile>>(<PlatformFile>[]);

  final ValueNotifier<TimeOfDay?> startTime = ValueNotifier<TimeOfDay?>(null);
  final ValueNotifier<TimeOfDay?> endTime = ValueNotifier<TimeOfDay?>(null);
  final ValueNotifier<Set<int>> closedDays = ValueNotifier<Set<int>>(<int>{});

  bool _initialized = false;
  DukkanModel? _initial;

  @override
  void dispose() {
    isimCtrl.dispose();
    telefonCtrl.dispose();
    telefon2Ctrl.dispose();
    whatsappCtrl.dispose();
    blokCtrl.dispose();
    kapiNoCtrl.dispose();
    aciklamaCtrl.dispose();
    logoFile.dispose();
    coverFile.dispose();
    photoFiles.dispose();
    startTime.dispose();
    endTime.dispose();
    closedDays.dispose();
    super.dispose();
  }

  static const List<String> dayLabels = [
    'Pzt',
    'Sal',
    'Çar',
    'Per',
    'Cum',
    'Cmt',
    'Paz',
  ];

  static const List<String> kategoriler = [
    'Metal İşleme',
    'Elektrik',
    'Boya',
    'Otomotiv',
    'İnşaat',
    'Ahşap',
    'Hidrolik',
    'Diğer',
  ];

  String fmtTime(TimeOfDay t) {
    final h = t.hour.toString().padLeft(2, '0');
    final m = t.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  int toMinutes(TimeOfDay t) => t.hour * 60 + t.minute;

  TimeOfDay? _parseTime(String s) {
    final parts = s.trim().split(':');
    if (parts.length != 2) return null;
    final h = int.tryParse(parts[0]);
    final m = int.tryParse(parts[1]);
    if (h == null || m == null) return null;
    if (h < 0 || h > 23 || m < 0 || m > 59) return null;
    return TimeOfDay(hour: h, minute: m);
  }

  void _initFrom(DukkanModel d) {
    _initial = d;
    isimCtrl.text = d.isim;
    telefonCtrl.text = d.telefon;
    telefon2Ctrl.text = d.telefon2 ?? '';
    whatsappCtrl.text = d.whatsapp ?? '';
    blokCtrl.text = d.blok ?? '';
    kapiNoCtrl.text = d.kapiNo ?? '';
    aciklamaCtrl.text = d.aciklama ?? '';
    kategori = d.kategori;
    selectedBrands = List<String>.from(d.markalar);

    if (d.calismaSaatleri != null) {
      final parts = d.calismaSaatleri!.split('-');
      if (parts.length == 2) {
        startTime.value = _parseTime(parts[0]);
        endTime.value = _parseTime(parts[1]);
      }
    }

    if (d.tatilGunleri != null && d.tatilGunleri!.trim().isNotEmpty) {
      final tokens = d.tatilGunleri!.split(',').map((e) => e.trim()).toList();
      final set = <int>{};
      for (final t in tokens) {
        final i = dayLabels.indexOf(t);
        if (i >= 0) set.add(i);
      }
      closedDays.value = set;
    }
  }

  Future<void> pickLogoCover(ValueNotifier<PlatformFile?> files) async {
    final res = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: true,
      allowMultiple: false,
    );
    if (!mounted) return;
    final file = res?.files.single;
    if (file == null) return;
    if (file.bytes == null) {
      _showError('Dosya okunamadı (bytes yok).');
      return;
    }
    files.value = file;
  }

  Future<void> pickPhotos() async {
    final res = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: true,
      allowMultiple: true,
    );
    if (!mounted) return;
    final files = res?.files ?? [];
    if (files.isEmpty) return;
    if (files.any((f) => f.bytes == null)) {
      _showError('Bazı dosyalar okunamadı (bytes yok).');
      return;
    }
    photoFiles.value = files.take(12).toList(growable: false);
  }

  Future<void> pickTime({required bool isStart}) async {
    final initial = isStart
        ? (startTime.value ?? const TimeOfDay(hour: 8, minute: 0))
        : (endTime.value ?? const TimeOfDay(hour: 18, minute: 0));
    final picked = await showTimePicker(context: context, initialTime: initial);
    if (!mounted || picked == null) return;
    if (isStart) {
      startTime.value = picked;
    } else {
      endTime.value = picked;
    }
  }

  Widget timeBox({
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: loading ? null : onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.surface2,
          border: Border.all(color: AppColors.border, width: 1),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label.toUpperCase(),
                    style: AppTextStyles.labelUppercase.copyWith(fontSize: 10),
                  ),
                  const SizedBox(height: 6),
                  Text(value, style: AppTextStyles.bodyMedium),
                ],
              ),
            ),
            const Icon(Icons.access_time, color: AppColors.textMuted, size: 18),
          ],
        ),
      ),
    );
  }

  Widget dayBox(int idx) {
    return ValueListenableBuilder<Set<int>>(
      valueListenable: closedDays,
      builder: (context, days, _) {
        final selected = days.contains(idx);
        return GestureDetector(
          onTap: loading
              ? null
              : () {
                  final next = Set<int>.from(days);
                  if (selected) {
                    next.remove(idx);
                  } else {
                    next.add(idx);
                  }
                  closedDays.value = next;
                },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: selected
                  ? AppColors.accent.withOpacity(0.12)
                  : AppColors.surface2,
              border: Border.all(
                color: selected ? AppColors.accent : AppColors.border,
                width: 1.5,
              ),
            ),
            child: Text(
              dayLabels[idx].toUpperCase(),
              style: AppTextStyles.chipLabel.copyWith(
                color: selected ? AppColors.accent : AppColors.textMuted,
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> submit() async {
    if (!formKey.currentState!.validate()) return;
    if (kategori == null) {
      _showError('Lütfen kategori seçin');
      return;
    }

    final hasStart = startTime.value != null;
    final hasEnd = endTime.value != null;
    if (hasStart != hasEnd) {
      _showError('Lütfen başlangıç ve bitiş saatini birlikte seçin');
      return;
    }
    if (hasStart && hasEnd) {
      if (toMinutes(endTime.value!) <= toMinutes(startTime.value!)) {
        _showError('Bitiş saati başlangıç saatinden sonra olmalı');
        return;
      }
    }

    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) {
      _showError('Dükkan düzenlemek için giriş yapmalısınız');
      return;
    }

    setState(() => loading = true);

    try {
      final username =
          (Supabase.instance.client.auth.currentUser?.userMetadata?['username']
                  as String?)
              ?.trim();

      final calismaSaatleri = (hasStart && hasEnd)
          ? '${fmtTime(startTime.value!)} - ${fmtTime(endTime.value!)}'
          : null;

      String? tatilGunleri;
      if (closedDays.value.isNotEmpty) {
        final days = closedDays.value.toList()..sort();
        tatilGunleri = days.map((i) => dayLabels[i]).join(', ');
      }

      final payload = AddDukkanPayload(
        isim: isimCtrl.text.trim(),
        telefon: telefonCtrl.text.trim(),
        telefon2:
            telefon2Ctrl.text.trim().isNotEmpty ? telefon2Ctrl.text.trim() : null,
        whatsapp:
            whatsappCtrl.text.trim().isNotEmpty ? whatsappCtrl.text.trim() : null,
        blok: blokCtrl.text.trim().isNotEmpty ? blokCtrl.text.trim() : null,
        kapiNo: kapiNoCtrl.text.trim().isNotEmpty ? kapiNoCtrl.text.trim() : null,
        kategori: kategori!,
        acikMi: true,
        calismaSaatleri: calismaSaatleri,
        tatilGunleri: tatilGunleri,
        aciklama: aciklamaCtrl.text.trim().isNotEmpty
            ? aciklamaCtrl.text.trim()
            : null,
        markalar: List<String>.from(selectedBrands),
        userId: userId,
        sahipAdi: (username != null && username.isNotEmpty) ? username : null,
      );

      final media = AddDukkanMedia(
        logo: logoFile.value,
        cover: coverFile.value,
        photos: List<PlatformFile>.from(photoFiles.value),
      );

      await ref.read(updateDukkanUseCaseProvider).execute(
            dukkanId: widget.dukkanId,
            payload: payload,
            media: media,
          );

      if (mounted) {
        _showSuccess('Dükkan güncellendi.');
        Navigator.of(context).pop();
      }
    } catch (e) {
      _showError('Hata: $e');
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          msg,
          style: AppTextStyles.bodySmall.copyWith(color: Colors.white),
        ),
        backgroundColor: AppColors.accentDark,
        behavior: SnackBarBehavior.floating,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      ),
    );
  }

  void _showSuccess(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          msg,
          style: AppTextStyles.bodySmall.copyWith(color: Colors.black),
        ),
        backgroundColor: AppColors.accent,
        behavior: SnackBarBehavior.floating,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dukkanAsync = ref.watch(editDukkanProvider(widget.dukkanId));

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        automaticallyImplyLeading: false,
        title: Text('DÜKKAN DÜZENLE', style: AppTextStyles.headlineMedium),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(2),
          child: Container(height: 2, color: AppColors.accent),
        ),
      ),
      body: dukkanAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.accent),
        ),
        error: (e, _) => Center(
          child: Text('Hata: $e', style: AppTextStyles.bodyMedium),
        ),
        data: (d) {
          if (d == null) {
            return const Center(child: Text('Dükkan bulunamadı'));
          }

          if (!_initialized) {
            _initialized = true;
            _initFrom(d);
          }

          final logoUrl = StorageUrl.fromPath(_initial?.logoUrl);
          final coverUrl = StorageUrl.fromPath(_initial?.kapakFoto);
          final existingPhotos = _initial?.fotograflar
                  .map(StorageUrl.fromPath)
                  .whereType<String>()
                  .toList() ??
              const <String>[];

          return Form(
            key: formKey,
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
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

                // Existing / new logo + cover preview
                ValueListenableBuilder<PlatformFile?>(
                  valueListenable: logoFile,
                  builder: (context, logo, _) {
                    return ValueListenableBuilder<PlatformFile?>(
                      valueListenable: coverFile,
                      builder: (context, cover, __) {
                        final showLogoMem = logo?.bytes != null;
                        final showCoverMem = cover?.bytes != null;
                        final showLogoNet = !showLogoMem && logoUrl != null;
                        final showCoverNet = !showCoverMem && coverUrl != null;

                        if (!showLogoMem &&
                            !showCoverMem &&
                            !showLogoNet &&
                            !showCoverNet) {
                          return const SizedBox.shrink();
                        }

                        return Column(
                          children: [
                            Row(
                              children: [
                                if (showLogoMem) ...[
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: Image.memory(
                                      logo!.bytes!,
                                      width: 60,
                                      height: 60,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                ] else if (showLogoNet) ...[
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: CachedNetworkImage(
                                      imageUrl: logoUrl,
                                      width: 60,
                                      height: 60,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                ],
                                if (showCoverMem)
                                  Expanded(
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: Image.memory(
                                        cover!.bytes!,
                                        height: 60,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  )
                                else if (showCoverNet)
                                  Expanded(
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: CachedNetworkImage(
                                        imageUrl: coverUrl,
                                        height: 60,
                                        fit: BoxFit.cover,
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

                // Existing / new photo thumbnails
                ValueListenableBuilder<List<PlatformFile>>(
                  valueListenable: photoFiles,
                  builder: (context, photos, _) {
                    final showNew = photos.isNotEmpty;
                    final showExisting = !showNew && existingPhotos.isNotEmpty;
                    if (!showNew && !showExisting) return const SizedBox.shrink();

                    final items = showNew ? null : existingPhotos.take(12).toList();

                    return Column(
                      children: [
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            if (showNew)
                              for (final f in photos)
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Image.memory(
                                    f.bytes!,
                                    width: 64,
                                    height: 64,
                                    fit: BoxFit.cover,
                                  ),
                                )
                            else
                              for (final url in items!)
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: CachedNetworkImage(
                                    imageUrl: url,
                                    width: 64,
                                    height: 64,
                                    fit: BoxFit.cover,
                                  ),
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
                SectionLabel('KATEGORİ *'),
                const SizedBox(height: 12),
                KategoriSelector(
                  selected: kategori,
                  kategoriler: kategoriler,
                  onSelected: (k) => setState(() {
                    kategori = k;
                    selectedBrands = [];
                  }),
                ),
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
                const SizedBox(height: 24),
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
                  children: List.generate(dayLabels.length, dayBox),
                ),
                const SizedBox(height: 16),
                Field(
                  ctrl: aciklamaCtrl,
                  label: 'Açıklama / Hizmetler',
                  hint: 'Sunduğunuz hizmetleri yazın...',
                  maxLines: 4,
                  keyboard: TextInputType.multiline,
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
                            'GÜNCELLE',
                            style: AppTextStyles.chipLabel.copyWith(
                              color: Colors.black,
                              fontSize: 15,
                              letterSpacing: 2,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          );
        },
      ),
    );
  }
}

