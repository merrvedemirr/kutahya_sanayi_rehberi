import 'package:sanayi_websites/model/dukkan_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/constants/supabase_constants.dart';

abstract class DukkanServices {
  Future<List<DukkanModel>> getDukkanlar({String? kategori, String? arama});
  Future<DukkanModel?> getDukkan(String id);
  Future<DukkanModel> addDukkan(DukkanModel dukkan);
  Future<DukkanModel> updateDukkan(String id, Map<String, dynamic> data);
  Future<void> deleteDukkan(String id);
  Stream<List<DukkanModel>> watchMyDukkanlar(String userId);
}

class DukkanService implements DukkanServices {
  final _supabase = Supabase.instance.client;

  // Tüm dükkanları getir
  @override
  Future<List<DukkanModel>> getDukkanlar({
    String? kategori,
    String? arama,
  }) async {
    //sorgumuz oluşturuldu
    var query = _supabase
        .from(SupabaseConstants.dukkanlarTable)
        .select()
        .eq('onaylandi_mi', true)
        .order('created_at', ascending: false);

    final response = await query;
    List<DukkanModel> dukkanlar = (response as List)
        .map((e) => DukkanModel.fromJson(e as Map<String, dynamic>))
        .toList();

    // Kategori filtresi
    if (kategori != null && kategori.isNotEmpty) {
      dukkanlar = dukkanlar.where((d) => d.kategori == kategori).toList();
    }

    // Arama filtresi (client-side)
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

  // Tek dükkan getir
  @override
  Future<DukkanModel?> getDukkan(String id) async {
    final response = await _supabase
        .from(SupabaseConstants.dukkanlarTable)
        .select()
        .eq('id', id)
        .single();

    return DukkanModel.fromJson(response);
  }

  // Dükkan ekle
  @override
  Future<DukkanModel> addDukkan(DukkanModel dukkan) async {
    final response = await _supabase
        .from(SupabaseConstants.dukkanlarTable)
        .insert(dukkan.toJson())
        .select()
        .single();

    return DukkanModel.fromJson(response);
  }

  // Dükkan güncelle
  @override
  Future<DukkanModel> updateDukkan(String id, Map<String, dynamic> data) async {
    final response = await _supabase
        .from(SupabaseConstants.dukkanlarTable)
        .update(data)
        .eq('id', id)
        .select()
        .single();

    return DukkanModel.fromJson(response);
  }

  // Dükkan sil
  @override
  Future<void> deleteDukkan(String id) async {
    final userId = _supabase.auth.currentUser?.id;
    var q = _supabase
        .from(SupabaseConstants.dukkanlarTable)
        .delete()
        .eq('id', id);

    // Extra safety: only allow deleting own shop.
    if (userId != null) {
      q = q.eq('user_id', userId);
    }

    // If RLS blocks or row doesn't exist, Supabase can return an empty list
    // without throwing. Force a concrete result.
    final res = await q.select('id') as List;
    final deleted = res.length;
    if (deleted == 0) {
      throw Exception('Silinemedi (yetki yok veya dükkan bulunamadı).');
    }
  }

  // Açık/kapalı durumunu güncelle
  Future<void> updateAcikMi(String id, bool acikMi) async {
    await _supabase
        .from(SupabaseConstants.dukkanlarTable)
        .update({'acik_mi': acikMi})
        .eq('id', id);
  }

  // Kategorilere göre sayı
  Future<Map<String, int>> getKategoriSayilari() async {
    final response = await _supabase
        .from(SupabaseConstants.dukkanlarTable)
        .select('kategori')
        .eq('onaylandi_mi', true);

    final Map<String, int> sayilar = {};
    for (final item in response as List) {
      final kategori = item['kategori'] as String;
      sayilar[kategori] = (sayilar[kategori] ?? 0) + 1;
    }
    return sayilar;
  }

  // Realtime: dükkanları dinle
  Stream<List<DukkanModel>> watchDukkanlar() {
    return _supabase
        .from(SupabaseConstants.dukkanlarTable)
        .stream(primaryKey: ['id'])
        .eq('onaylandi_mi', true)
        .order('created_at', ascending: true)
        .map((data) => data.map((e) => DukkanModel.fromJson(e)).toList());
  }

  // Realtime: kullanıcının dükkanlarını dinle (onaylı + beklemede)
  @override
  Stream<List<DukkanModel>> watchMyDukkanlar(String userId) {
    return _supabase
        .from(SupabaseConstants.dukkanlarTable)
        .stream(primaryKey: ['id'])
        .eq('user_id', userId)
        .order('created_at', ascending: false)
        .map((data) => data.map((e) => DukkanModel.fromJson(e)).toList());
  }
}
