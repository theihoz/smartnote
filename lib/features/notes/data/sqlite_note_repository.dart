import 'package:sqflite/sqflite.dart';

import '../domain/note.dart';
import '../domain/note_query.dart';
import '../domain/note_repository.dart';

class SqliteNoteRepository implements NoteRepository {
  SqliteNoteRepository(this._database);

  final Database _database;

  @override
  Future<void> save(Note note) {
    return _database.transaction((transaction) async {
      await transaction.insert('notes', {
        'id': note.id,
        'title': note.title,
        'body': note.body,
        'kind': note.kind.name,
        'is_favorite': note.isFavorite ? 1 : 0,
        'color_key': note.colorKey,
        'created_at': note.createdAt.toIso8601String(),
        'updated_at': note.updatedAt.toIso8601String(),
      }, conflictAlgorithm: ConflictAlgorithm.replace);

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
      await _recordOutbox(transaction, note.id, 'upsert');
    });
  }

  @override
  Future<void> delete(String id) {
    return _database.transaction((transaction) async {
      await transaction.delete('notes', where: 'id = ?', whereArgs: [id]);
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
    final rows = await _database.query('notes');
    final notes = <Note>[];
    for (final row in rows) {
      notes.add(await _hydrate(row));
    }
    return query.apply(notes);
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
}
