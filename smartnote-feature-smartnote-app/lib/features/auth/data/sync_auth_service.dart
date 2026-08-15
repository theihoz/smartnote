import 'package:supabase_flutter/supabase_flutter.dart';

abstract interface class SyncAuthService {
  String? get currentEmail;

  Future<void> signIn({required String email, required String password});

  Future<void> signUp({required String email, required String password});

  Future<void> signOut();
}

class SupabaseSyncAuthService implements SyncAuthService {
  SupabaseSyncAuthService(this._client);

  final SupabaseClient _client;

  @override
  String? get currentEmail => _client.auth.currentUser?.email;

  @override
  Future<void> signIn({required String email, required String password}) async {
    await _client.auth.signInWithPassword(email: email, password: password);
  }

  @override
  Future<void> signUp({required String email, required String password}) async {
    await _client.auth.signUp(email: email, password: password);
  }

  @override
  Future<void> signOut() => _client.auth.signOut();
}
