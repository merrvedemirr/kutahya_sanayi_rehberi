import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sanayi_websites/model/reklam_model.dart';
import 'package:sanayi_websites/services/reklam_service.dart';

final reklamServiceProvider = Provider<ReklamService>((ref) => ReklamService());

final reklamlarProvider =
    FutureProvider.family<List<ReklamModel>, String>((ref, placement) async {
  return ref.read(reklamServiceProvider).getReklamlar(placement: placement);
});

