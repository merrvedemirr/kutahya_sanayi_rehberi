import 'package:sanayi_websites/core/constants/supabase_constants.dart';
import 'package:sanayi_websites/model/reklam_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ReklamService {
  final _supabase = Supabase.instance.client;

  Future<List<ReklamModel>> getReklamlar({
    required String placement,
    int limit = 10,
  }) async {
    final res = await _supabase
        .from(SupabaseConstants.reklamlarTable)
        .select()
        .eq('active', true)
        .eq('placement', placement)
        .order('created_at', ascending: false)
        .limit(limit);

    return (res as List)
        .map((e) => ReklamModel.fromJson(e as Map<String, dynamic>))
        .toList(growable: false);
  }
}

