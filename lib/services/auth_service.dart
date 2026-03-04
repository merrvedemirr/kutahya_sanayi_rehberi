import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  SupabaseClient get _client => Supabase.instance.client;

  Session? get session => _client.auth.currentSession;

  User? get currentUser => _client.auth.currentUser;

  Stream<AuthState> get onAuthStateChange => _client.auth.onAuthStateChange;

  Future<AuthResponse> signUpWithEmail({
    required String username,
    required String email,
    required String password,
  }) async {
    final trimmedUsername = username.trim();
    final trimmedEmail = email.trim().toLowerCase();

    final res = await _client.auth.signUp(
      email: trimmedEmail,
      password: password,
      data: {
        'username': trimmedUsername,
      },
    );

    // If email confirmations are disabled, session/user are available here.
    // Keeping it lightweight: profile upsert is handled by caller/service layer.
    return res;
  }

  Future<AuthResponse> signInWithEmail({
    required String email,
    required String password,
  }) {
    return _client.auth.signInWithPassword(
      email: email.trim().toLowerCase(),
      password: password,
    );
  }

  Future<void> signOut() => _client.auth.signOut();
}

