import 'package:flutter_test/flutter_test.dart';
import 'package:smartnote/features/notes/data/smartnote_database.dart';
import 'package:smartnote/features/notes/data/sqlite_note_draft_repository.dart';
import 'package:smartnote/features/notes/domain/note_draft_repository.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  setUpAll(sqfliteFfiInit);

  test('saves and restores the most recent draft for a note', () async {
    final database = await openSmartNoteDatabase(
      factory: databaseFactoryFfi,
      path: inMemoryDatabasePath,
    );
    addTearDown(database.close);
    final repository = SqliteNoteDraftRepository(database);
    final draft = NoteAutosaveDraft(
      noteId: 'note-1',
      title: 'Bản nháp',
      body: 'Nội dung đang viết',
      updatedAt: DateTime.utc(2026, 8, 11, 9),
    );

    await repository.save(draft);

    expect(await repository.getByNoteId('note-1'), draft);
  });
}
