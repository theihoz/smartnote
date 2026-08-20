import 'dart:convert';

import 'package:sqflite/sqflite.dart';

import '../domain/note.dart';
import '../domain/note_query.dart';
import '../domain/note_repository.dart';

class SqliteNoteRepository
    implements NoteRepository, TrashNoteRepository, NoteVersionRepository {
  SqliteNoteRepository(this._database);

  final Database _database;

  @override
  Future<void> save(Note note) {
    return _database.transaction((transaction) async {
      final noteRow = {
        'id': note.id,
        'title': note.title,
        'body': note.body,
        'kind': note.kind.name,
        'is_favorite': note.isFavorite ? 1 : 0,
        'color_key': note.colorKey,
        'is_locked': note.isLocked ? 1 : 0,
        'created_at': note.createdAt.toIso8601String(),
        'updated_at': note.updatedAt.toIso8601String(),
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
        whereArgs: [note.id],
      );

      await transaction.delete(
        'note_tags',
        where: 'note_id = ?',
        whereArgs: [note.id],
      );
      await transaction.delete(
        'checklist_items',
        where: 'note_id = ?',
        whereArgs: [note.id],
      );
      await transaction.delete(
        'note_images',
        where: 'note_id = ?',
        whereArgs: [note.id],
      );

      for (final (position, tag) in note.tags.indexed) {
        await transaction.insert('tags', {
          'name': tag,
        }, conflictAlgorithm: ConflictAlgorithm.ignore);
        await transaction.insert('note_tags', {
          'note_id': note.id,
          'tag_name': tag,
          'position': position,
        });
      }
      for (final (position, item) in note.checklist.indexed) {
        await transaction.insert('checklist_items', {
          'id': item.id,
          'note_id': note.id,
          'text': item.text,
          'is_done': item.isDone ? 1 : 0,
          'position': position,
        });
      }
      for (final (position, imagePath) in note.imagePaths.indexed) {
        await transaction.insert('note_images', {
          'note_id': note.id,
          'path': imagePath,
          'position': position,
        });
      }
      await transaction.insert('note_versions', {
        'id': '${note.id}-${DateTime.now().microsecondsSinceEpoch}',
        'note_id': note.id,
        'snapshot': jsonEncode(_versionSnapshot(note)),
        'created_at': note.updatedAt.toUtc().toIso8601String(),
      });
      await transaction.rawDelete(
        '''
          DELETE FROM note_versions
          WHERE note_id = ? AND id NOT IN (
            SELECT id FROM note_versions
            WHERE note_id = ?
            ORDER BY created_at DESC
            LIMIT 20
          )
        ''',
        [note.id, note.id],
      );
      await _recordOutbox(transaction, note.id, 'upsert');
    });
  }

  @override
  Future<void> delete(String id) {
    return _database.transaction((transaction) async {
      await transaction.update(
        'notes',
        {'deleted_at': DateTime.now().toUtc().toIso8601String()},
        where: 'id = ?',
        whereArgs: [id],
      );
      await _recordOutbox(transaction, id, 'delete');
    });
  }

  @override
  Future<Note?> getById(String id) async {
    final rows = await _database.query(
      'notes',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return _hydrate(rows.single);
  }

  @override
  Future<List<Note>> list([NoteQuery query = const NoteQuery()]) async {
    final rows = await _database.query('notes', where: 'deleted_at IS NULL');
    final notes = <Note>[];
    for (final row in rows) {
      notes.add(await _hydrate(row));
    }
    return query.apply(notes);
  }

  @override
  Future<List<Note>> listTrash() async {
    final rows = await _database.query(
      'notes',
      where: 'deleted_at IS NOT NULL',
      orderBy: 'deleted_at DESC',
    );
    final notes = <Note>[];
    for (final row in rows) {
      notes.add(await _hydrate(row));
    }
    return notes;
  }

  @override
  Future<void> restoreFromTrash(String id) {
    return _database.transaction((transaction) async {
      await transaction.update(
        'notes',
        {
          'deleted_at': null,
          'updated_at': DateTime.now().toUtc().toIso8601String(),
        },
        where: 'id = ?',
        whereArgs: [id],
      );
      await _recordOutbox(transaction, id, 'upsert');
    });
  }

  @override
  Future<int> purgeExpiredTrash(DateTime now) {
    final cutoff = now.toUtc().subtract(const Duration(days: 30));
    return _database.delete(
      'notes',
      where: 'deleted_at IS NOT NULL AND deleted_at <= ?',
      whereArgs: [cutoff.toIso8601String()],
    );
  }

  @override
  Future<List<NoteVersion>> listVersions(String noteId) async {
    final rows = await _database.query(
      'note_versions',
      where: 'note_id = ?',
      whereArgs: [noteId],
      orderBy: 'created_at DESC',
    );
    return rows.map((row) {
      final snapshot =
          jsonDecode(row['snapshot']! as String) as Map<String, dynamic>;
      return NoteVersion(
        title: snapshot['title'] as String? ?? '',
        body: snapshot['body'] as String? ?? '',
        kind: NoteKind.values.byName(snapshot['kind'] as String? ?? 'text'),
        checklist: (snapshot['checklist'] as List<dynamic>? ?? const []).map((
          value,
        ) {
          final item = value as Map<String, dynamic>;
          return ChecklistItem(
            id: item['id'] as String,
            text: item['text'] as String,
            isDone: item['is_done'] as bool? ?? false,
            position: item['position'] as int? ?? 0,
          );
        }).toList(),
        tags: (snapshot['tags'] as List<dynamic>? ?? const []).cast<String>(),
        isFavorite: snapshot['is_favorite'] as bool? ?? false,
        colorKey: snapshot['color_key'] as String? ?? 'lavender',
        imagePaths: (snapshot['image_paths'] as List<dynamic>? ?? const [])
            .cast<String>(),
        createdAt: DateTime.parse(row['created_at']! as String),
      );
    }).toList();
  }

  Future<Note> _hydrate(Map<String, Object?> row) async {
    final id = row['id']! as String;
    final tagRows = await _database.query(
      'note_tags',
      columns: ['tag_name'],
      where: 'note_id = ?',
      whereArgs: [id],
      orderBy: 'position ASC',
    );
    final checklistRows = await _database.query(
      'checklist_items',
      where: 'note_id = ?',
      whereArgs: [id],
      orderBy: 'position ASC',
    );
    final imageRows = await _database.query(
      'note_images',
      columns: ['path'],
      where: 'note_id = ?',
      whereArgs: [id],
      orderBy: 'position ASC',
    );

    return Note(
      id: id,
      title: row['title']! as String,
      body: row['body']! as String,
      kind: NoteKind.values.byName(row['kind']! as String),
      checklist: checklistRows
          .map(
            (item) => ChecklistItem(
              id: item['id']! as String,
              text: item['text']! as String,
              isDone: item['is_done'] == 1,
              position: item['position']! as int,
            ),
          )
          .toList(),
      tags: tagRows.map((tag) => tag['tag_name']! as String).toList(),
      isFavorite: row['is_favorite'] == 1,
      colorKey: row['color_key']! as String,
      imagePaths: imageRows.map((image) => image['path']! as String).toList(),
      createdAt: DateTime.parse(row['created_at']! as String),
      updatedAt: DateTime.parse(row['updated_at']! as String),
      isLocked: row['is_locked'] == 1,
    );
  }

  Future<void> _recordOutbox(
    DatabaseExecutor executor,
    String noteId,
    String operation,
  ) {
    return executor.insert('sync_outbox', {
      'note_id': noteId,
      'operation': operation,
      'created_at': DateTime.now().toUtc().toIso8601String(),
      'attempts': 0,
    });
  }

  Map<String, Object?> _versionSnapshot(Note note) {
    return {
      'title': note.title,
      'body': note.body,
      'kind': note.kind.name,
      'is_favorite': note.isFavorite,
      'color_key': note.colorKey,
      'tags': note.tags,
      'image_paths': note.imagePaths,
      'checklist': note.checklist
          .map(
            (item) => {
              'id': item.id,
              'text': item.text,
              'is_done': item.isDone,
              'position': item.position,
            },
          )
          .toList(),
    };
  }
}
