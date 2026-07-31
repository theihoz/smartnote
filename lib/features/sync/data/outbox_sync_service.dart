import 'package:sqflite/sqflite.dart';

import '../../notes/domain/note.dart';
import '../../notes/domain/note_repository.dart';
import 'cloud_note_store.dart';

class SyncResult {
  const SyncResult({required this.synced, required this.failed});

  final int synced;
  final int failed;
}

class OutboxSyncService {
  OutboxSyncService({
    required this.database,
    required this.notes,
    required this.cloud,
  });

  final Database database;
  final NoteRepository notes;
  final CloudNoteStore cloud;

  Future<SyncResult> syncPending() async {
    final rows = await database.query('sync_outbox', orderBy: 'created_at ASC');
    var synced = 0;
    var failed = 0;

    for (final row in rows) {
      final outboxId = row['id']! as int;
      final noteId = row['note_id']! as String;
      final operation = row['operation']! as String;
      try {
        if (operation == 'delete') {
          await cloud.delete(noteId);
        } else {
          final note = await notes.getById(noteId);
          if (note != null) await cloud.upsert(_toCloudPayload(note));
        }
        await database.delete(
          'sync_outbox',
          where: 'id = ?',
          whereArgs: [outboxId],
        );
        synced++;
      } catch (_) {
        await database.rawUpdate(
          'UPDATE sync_outbox SET attempts = attempts + 1 WHERE id = ?',
          [outboxId],
        );
        failed++;
      }
    }

    return SyncResult(synced: synced, failed: failed);
  }

  Map<String, Object?> _toCloudPayload(Note note) {
    return {
      'id': note.id,
      'title': note.title,
      'body': note.body,
      'kind': note.kind.name,
      'is_favorite': note.isFavorite,
      'color_key': note.colorKey,
      'tags': note.tags,
      'image_paths': note.imagePaths,
      'checklist': note.checklist
          .map(
            (item) => <String, Object?>{
              'id': item.id,
              'text': item.text,
              'is_done': item.isDone,
              'position': item.position,
            },
          )
          .toList(),
      'created_at': note.createdAt.toIso8601String(),
      'updated_at': note.updatedAt.toIso8601String(),
    };
  }
}
