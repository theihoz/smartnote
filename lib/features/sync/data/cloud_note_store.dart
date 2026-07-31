import 'package:supabase_flutter/supabase_flutter.dart';

abstract interface class CloudNoteStore {
  Future<void> upsert(Map<String, Object?> note);

  Future<void> delete(String noteId);
}

class SupabaseCloudNoteStore implements CloudNoteStore {
  SupabaseCloudNoteStore(this._client);

  final SupabaseClient _client;

  @override
  Future<void> upsert(Map<String, Object?> note) {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) {
      throw StateError('Supabase user is not authenticated');
    }
    return _client.from('notes').upsert({...note, 'user_id': userId});
  }

  @override
  Future<void> delete(String noteId) {
    return _client.from('notes').delete().eq('id', noteId);
  }
}
