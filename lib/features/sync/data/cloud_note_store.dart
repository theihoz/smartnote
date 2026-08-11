import 'package:supabase_flutter/supabase_flutter.dart';

abstract interface class CloudNoteStore {
  Future<void> upsert(Map<String, Object?> note);

  Future<void> delete(String noteId, {DateTime? deletedAt});

  Future<List<Map<String, Object?>>> fetchNotes({DateTime? updatedAfter});
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
  Future<void> delete(String noteId, {DateTime? deletedAt}) {
    final timestamp = deletedAt ?? DateTime.now().toUtc();
    return _client
        .from('notes')
        .update({
          'deleted_at': timestamp.toIso8601String(),
          'updated_at': timestamp.toIso8601String(),
        })
        .eq('id', noteId);
  }

  @override
  Future<List<Map<String, Object?>>> fetchNotes({
    DateTime? updatedAfter,
  }) async {
    final data = updatedAfter == null
        ? await _client.from('notes').select()
        : await _client
              .from('notes')
              .select()
              .gt('updated_at', updatedAfter.toUtc().toIso8601String());
    return (data as List)
        .map((row) => Map<String, Object?>.from(row as Map))
        .toList();
  }
}
