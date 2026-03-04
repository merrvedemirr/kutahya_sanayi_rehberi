import 'package:sanayi_websites/core/constants/supabase_constants.dart';
import 'package:sanayi_websites/model/user_profile_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UserProfileService {
  SupabaseClient get _client => Supabase.instance.client;

  Future<void> upsertMyProfile({
    required String userId,
    required String username,
    String? email,
  }) async {
    final trimmed = username.trim();
    if (trimmed.isEmpty) return;

    await _client.from(SupabaseConstants.profilesTable).upsert({
      'id': userId,
      'username': trimmed,
      if (email != null) 'email': email.trim(),
    });
  }

  Future<UserProfileModel?> getMyProfile(String userId) async {
    final res = await _client
        .from(SupabaseConstants.profilesTable)
        .select()
        .eq('id', userId)
        .maybeSingle();

    if (res == null) return null;
    return UserProfileModel.fromJson(res);
  }

  Stream<UserProfileModel?> watchMyProfile(String userId) {
    return _client
        .from(SupabaseConstants.profilesTable)
        .stream(primaryKey: const ['id'])
        .eq('id', userId)
        .map((rows) {
      if (rows.isEmpty) return null;
      return UserProfileModel.fromJson(rows.first);
    });
  }
}

