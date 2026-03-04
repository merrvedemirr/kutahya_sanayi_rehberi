import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sanayi_websites/core/constants/app_colors.dart';
import 'package:sanayi_websites/core/constants/app_text_styles.dart';
import 'package:sanayi_websites/core/routing/route_utils.dart';
import 'package:sanayi_websites/screens/add/add_dukkan_screen.dart';
import 'package:sanayi_websites/screens/add/add_dukkan_usecase.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class AddDukkanModel extends ConsumerState<AddDukkanScreen> {
  final formKey = GlobalKey<FormState>();
  bool loading = false;

  // Controllers
  final isimCtrl = TextEditingController();
  final telefonCtrl = TextEditingController();
  final telefon2Ctrl = TextEditingController();
  final whatsappCtrl = TextEditingController();
  final blokCtrl = TextEditingController();
  final kapiNoCtrl = TextEditingController();
  final aciklamaCtrl = TextEditingController();

  String? kategori;
  List<String> selectedBrands = [];

  final ValueNotifier<PlatformFile?> logoFile = ValueNotifier<PlatformFile?>(
    null,
  );
  final ValueNotifier<PlatformFile?> coverFile = ValueNotifier<PlatformFile?>(
    null,
  );
  final ValueNotifier<List<PlatformFile>> photoFiles =
      ValueNotifier<List<PlatformFile>>(<PlatformFile>[]);

  final ValueNotifier<TimeOfDay?> startTime = ValueNotifier<TimeOfDay?>(null);
  final ValueNotifier<TimeOfDay?> endTime = ValueNotifier<TimeOfDay?>(null);
  final ValueNotifier<Set<int>> closedDays = ValueNotifier<Set<int>>(<int>{});

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

  String fmtTime(TimeOfDay t) {
    //saat dakika formatı
    final h = t.hour.toString().padLeft(2, '0');
    final m = t.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  int toMinutes(TimeOfDay t) => t.hour * 60 + t.minute;

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

  //?WİDGET //////////////////////////////////////////////////////////////
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

  Future<void> pickLogoCover(ValueNotifier<PlatformFile?> files) async {
    //!Logo ve kapak Seçiyoruz. tek dosya seçilir
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
    //!Çoklu seçim bi bakalım test aşamasında
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
    photoFiles.value = files.take(5).toList(growable: false);
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
      _showError('Dükkan eklemek için giriş yapmalısınız');
      if (mounted) context.go('/login?redirect=%2Fekle');
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

      await ref.read(addDukkanUseCaseProvider).execute(
            payload: payload,
            media: media,
          );

      if (mounted) {
        _showSuccess();
        RouteUtils.back(context, fallback: '/user');
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

  void _showSuccess() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Dükkan eklendi! Onay bekleniyor.',
          style: AppTextStyles.bodySmall.copyWith(color: Colors.black),
        ),
        backgroundColor: AppColors.accent,
        behavior: SnackBarBehavior.floating,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      ),
    );
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
}
