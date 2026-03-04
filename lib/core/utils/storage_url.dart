import 'package:sanayi_websites/core/constants/supabase_constants.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class StorageUrl {
  StorageUrl._();

  /// Accepts either a full URL or a storage object path.
  /// Returns a public URL (bucket must allow reads).
  static String? fromPath(String? value) {
    final v = value?.trim();
    if (v == null || v.isEmpty) return null;
    if (v.startsWith('http://') || v.startsWith('https://')) return v;
    return Supabase.instance.client.storage
        .from(SupabaseConstants.storageBucket)
        .getPublicUrl(v);
  }
}

// class utils{
//   Utils._();


// }

