import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:sanayi_websites/model/dukkan_model.dart';
import 'package:sanayi_websites/services/dukkan_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final dukkanServiceProvider = Provider<DukkanService>((ref) => DukkanService());

final searchQueryProvider = StateProvider<String>((ref) => '');
final selectedKategoriProvider = StateProvider<String?>((ref) => null);

final dukkanlarProvider = FutureProvider<List<DukkanModel>>((ref) async {
  final service = ref.watch(dukkanServiceProvider);
  final arama = ref.watch(searchQueryProvider);
  final kategori = ref.watch(selectedKategoriProvider);
  return service.getDukkanlar(kategori: kategori, arama: arama);
});

final dukkanlarStreamProvider = StreamProvider<List<DukkanModel>>((ref) {
  final service = ref.watch(dukkanServiceProvider);
  return service.watchDukkanlar();
});

/// Ana sayfa: stream + kategori + arama ile filtrelenmiş liste (realtime + filtre).
final filteredDukkanlarStreamProvider =
    StreamProvider<List<DukkanModel>>((ref) {
  final service = ref.watch(dukkanServiceProvider);
  final kategori = ref.watch(selectedKategoriProvider);
  final arama = ref.watch(searchQueryProvider);
  return service
      .watchDukkanlar()
      .map((list) => _filterDukkanlar(list, kategori: kategori, arama: arama));
});

List<DukkanModel> _filterDukkanlar(
  List<DukkanModel> dukkanlar, {
  String? kategori,
  String? arama,
}) {
  if (kategori != null && kategori.isNotEmpty) {
    dukkanlar = dukkanlar.where((d) => d.kategori == kategori).toList();
  }
  if (arama != null && arama.isNotEmpty) {
    final q = arama.toLowerCase();
    dukkanlar = dukkanlar.where((d) {
      return d.isim.toLowerCase().contains(q) ||
          d.kategori.toLowerCase().contains(q) ||
          (d.aciklama?.toLowerCase().contains(q) ?? false) ||
          (d.sahipAdi?.toLowerCase().contains(q) ?? false) ||
          d.hizmetler.any((h) => h.toLowerCase().contains(q)) ||
          d.markalar.any((m) => m.toLowerCase().contains(q));
    }).toList();
  }
  return dukkanlar;
}

final myDukkanlarStreamProvider = StreamProvider.autoDispose<List<DukkanModel>>(
  (ref) {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return Stream<List<DukkanModel>>.value(const []);
    final service = ref.watch(dukkanServiceProvider);
    return service.watchMyDukkanlar(userId);
  },
);
