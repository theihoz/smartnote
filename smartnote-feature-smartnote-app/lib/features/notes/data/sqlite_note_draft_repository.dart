import 'package:sqflite/sqflite.dart';

import '../domain/note_draft_repository.dart';

class SqliteNoteDraftRepository implements NoteDraftRepository {
  SqliteNoteDraftRepository(this._database);

  final Database _database;

  @override
  Future<void> save(NoteAutosaveDraft draft) {
    return _database.insert('note_drafts', {
      'note_id': draft.noteId,
      'title': draft.title,
      'body': draft.body,
      'updated_at': draft.updatedAt.toUtc().toIso8601String(),
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  @override
  Future<NoteAutosaveDraft?> getByNoteId(String noteId) async {
    final rows = await _database.query(
      'note_drafts',
      where: 'note_id = ?',
      whereArgs: [noteId],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    final row = rows.single;
    return NoteAutosaveDraft(
      noteId: row['note_id']! as String,
      title: row['title']! as String,
      body: row['body']! as String,
      updatedAt: DateTime.parse(row['updated_at']! as String),
    );
  }

  @override
  Future<void> delete(String noteId) {
    return _database.delete(
      'note_drafts',
      where: 'note_id = ?',
      whereArgs: [noteId],
    );
  }
}
