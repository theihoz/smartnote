import 'package:flutter_test/flutter_test.dart';
import 'package:smartnote/features/notes/data/smartnote_database.dart';
import 'package:smartnote/features/notes/data/sqlite_note_repository.dart';
import 'package:smartnote/features/notes/domain/note.dart';
import 'package:smartnote/features/reminders/data/sqlite_reminder_repository.dart';
import 'package:smartnote/features/reminders/domain/note_reminder.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  setUpAll(sqfliteFfiInit);

  test('saves, reads and removes a note reminder', () async {
    final database = await openSmartNoteDatabase(
      factory: databaseFactoryFfi,
      path: inMemoryDatabasePath,
    );
    addTearDown(database.close);
    final notes = SqliteNoteRepository(database);
    await notes.save(
      Note(
        id: 'note-1',
        title: 'Nhắc tôi',
        body: '',
        kind: NoteKind.text,
        checklist: const [],
        tags: const [],
        isFavorite: false,
        colorKey: 'sage',
        imagePaths: const [],
        createdAt: DateTime.utc(2026, 8, 1),
        updatedAt: DateTime.utc(2026, 8, 1),
      ),
    );
    final repository = SqliteReminderRepository(database);
    final reminder = NoteReminder(
      noteId: 'note-1',
      scheduledAt: DateTime.utc(2026, 8, 12, 2),
      timezone: 'Asia/Ho_Chi_Minh',
      repeatType: ReminderRepeatType.weekly,
      repeatInterval: 1,
      weekdays: const [1, 3, 5],
      enabled: true,
    );

    await repository.save(reminder);
    expect(await repository.getByNoteId('note-1'), reminder);

    await repository.delete('note-1');
    expect(await repository.getByNoteId('note-1'), isNull);
  });
}
