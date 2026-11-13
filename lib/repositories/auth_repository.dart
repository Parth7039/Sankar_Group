import 'package:supabase_flutter/supabase_flutter.dart';

/// A small, UI-independent wrapper around Supabase email/password auth.
class AuthRepository {
  AuthRepository({required SupabaseClient? client}) : _client = client;

  final SupabaseClient? _client;

  SupabaseClient get _supabase {
    final client = _client;
    if (client == null) {
      throw const BackendNotConfiguredException();
    }
    return client;
  }

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    await _supabase.auth.signInWithPassword(
      email: email.trim(),
      password: password,
    );
  }

  /// Returns true when Supabase starts a session immediately.
  /// If email confirmation is enabled, false means the user must verify email.
  Future<bool> signUp({
    required String fullName,
    required String email,
    required String password,
  }) async {
    final response = await _supabase.auth.signUp(
      email: email.trim(),
      password: password,
      data: {'full_name': fullName.trim()},
    );
    return response.session != null;
  }

  Future<void> sendPasswordReset(String email) async {
    await _supabase.auth.resetPasswordForEmail(email.trim());
  }

  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }
}

class BackendNotConfiguredException implements Exception {
  const BackendNotConfiguredException();

  @override
  String toString() =>
      'Connect your Supabase project before using authentication. '
      'Follow STEP_2_AUTH_SETUP.md.';
}
