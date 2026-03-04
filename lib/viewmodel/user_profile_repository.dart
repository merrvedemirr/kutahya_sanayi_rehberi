import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sanayi_websites/model/user_profile_model.dart';
import 'package:sanayi_websites/services/user_profile_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final userProfileServiceProvider =
    Provider<UserProfileService>((ref) => UserProfileService());

final myProfileProvider = StreamProvider<UserProfileModel?>((ref) {
  final userId = Supabase.instance.client.auth.currentUser?.id;
  if (userId == null) return Stream<UserProfileModel?>.value(null);
  final service = ref.watch(userProfileServiceProvider);
  return service.watchMyProfile(userId);
});

