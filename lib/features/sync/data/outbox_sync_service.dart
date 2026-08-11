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
          final deletedRow = await database.query(
            'notes',
            columns: ['deleted_at'],
            where: 'id = ?',
            whereArgs: [noteId],
            limit: 1,
          );
          final deletedAt = deletedRow.isEmpty
              ? DateTime.now().toUtc()
              : DateTime.parse(deletedRow.single['deleted_at']! as String);
          await cloud.delete(noteId, deletedAt: deletedAt);
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

    if (failed == 0) {
      final syncState = await database.query(
        'sync_state',
        columns: ['last_synced_at'],
        where: 'key = ?',
        whereArgs: ['notes'],
        limit: 1,
      );
      final lastSyncedAt = syncState.isEmpty
          ? null
          : DateTime.parse(syncState.single['last_synced_at']! as String);
      try {
        final remoteNotes = await cloud.fetchNotes(updatedAfter: lastSyncedAt);
        for (final remoteNote in remoteNotes) {
          await _applyRemoteNote(remoteNote);
        }
      } catch (_) {
        failed++;
      }
    }

    if (failed == 0) {
      await database.insert('sync_state', {
        'key': 'notes',
        'last_synced_at': DateTime.now().toUtc().toIso8601String(),
      }, conflictAlgorithm: ConflictAlgorithm.replace);
    }

    return SyncResult(synced: synced, failed: failed);
  }

  Future<void> _applyRemoteNote(Map<String, Object?> remote) async {
    final id = remote['id']! as String;
    final remoteUpdatedAt = DateTime.parse(remote['updated_at']! as String);
    final localRows = await database.query(
      'notes',
      columns: ['updated_at'],
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (localRows.isNotEmpty) {
      final localUpdatedAt = DateTime.parse(
        localRows.single['updated_at']! as String,
      );
      if (!remoteUpdatedAt.isAfter(localUpdatedAt)) return;
    }

    await database.transaction((transaction) async {
      final noteRow = <String, Object?>{
        'id': id,
        'title': remote['title']! as String,
        'body': remote['body']! as String,
        'kind': remote['kind']! as String,
        'is_favorite': _asSqliteBool(remote['is_favorite']),
        'color_key': remote['color_key']! as String,
        'deleted_at': remote['deleted_at'],
        'is_locked': _asSqliteBool(remote['is_locked']),
        'created_at': remote['created_at']! as String,
        'updated_at': remote['updated_at']! as String,
      };
      await transaction.insert(
        'notes',
        noteRow,
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
      await transaction.update(
        'notes',
        noteRow,
        where: 'id = ?',
        whereArgs: [id],
      );

      if (remote['deleted_at'] != null) return;

      await transaction.delete(
        'note_tags',
        where: 'note_id = ?',
        whereArgs: [id],
      );
      await transaction.delete(
        'checklist_items',
        where: 'note_id = ?',
        whereArgs: [id],
      );
      await transaction.delete(
        'note_images',
        where: 'note_id = ?',
        whereArgs: [id],
      );

      for (final (position, tag) in _asList(remote['tags']).indexed) {
        await transaction.insert('tags', {
          'name': tag as String,
        }, conflictAlgorithm: ConflictAlgorithm.ignore);
        await transaction.insert('note_tags', {
          'note_id': id,
          'tag_name': tag,
          'position': position,
        });
      }
      for (final (position, item) in _asList(remote['checklist']).indexed) {
        final map = Map<String, Object?>.from(item as Map);
        await transaction.insert('checklist_items', {
          'id': map['id'],
          'note_id': id,
          'text': map['text'],
          'is_done': _asSqliteBool(map['is_done']),
          'position': map['position'] ?? position,
        });
      }
      for (final (position, imagePath) in _asList(
        remote['image_paths'],
      ).indexed) {
        await transaction.insert('note_images', {
          'note_id': id,
          'path': imagePath,
          'position': position,
        });
      }
    });
  }

  int _asSqliteBool(Object? value) => value == true || value == 1 ? 1 : 0;

  List<Object?> _asList(Object? value) => value is List ? value : const [];

  Map<String, Object?> _toCloudPayload(Note note) {
    return {
      'id': note.id,
      'title': note.title,
      'body': note.body,
      'kind': note.kind.name,
      'is_favorite': note.isFavorite,
      'is_locked': note.isLocked,
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
