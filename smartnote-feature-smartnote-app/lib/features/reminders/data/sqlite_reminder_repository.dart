import 'dart:convert';

import 'package:sqflite/sqflite.dart';

import '../domain/note_reminder.dart';

class SqliteReminderRepository implements ReminderRepository {
  SqliteReminderRepository(this._database);

  final Database _database;

  @override
  Future<void> save(NoteReminder reminder) {
    final now = DateTime.now().toUtc().toIso8601String();
    return _database.insert('note_reminders', {
      'note_id': reminder.noteId,
      'scheduled_at': reminder.scheduledAt.toUtc().toIso8601String(),
      'timezone': reminder.timezone,
      'repeat_type': reminder.repeatType.name,
      'repeat_interval': reminder.repeatInterval,
      'weekdays': jsonEncode(reminder.weekdays),
      'ends_at': reminder.endsAt?.toUtc().toIso8601String(),
      'enabled': reminder.enabled ? 1 : 0,
      'created_at': now,
      'updated_at': now,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  @override
  Future<NoteReminder?> getByNoteId(String noteId) async {
    final rows = await _database.query(
      'note_reminders',
      where: 'note_id = ?',
      whereArgs: [noteId],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    final row = rows.single;
    return NoteReminder(
      noteId: row['note_id']! as String,
      scheduledAt: DateTime.parse(row['scheduled_at']! as String),
      timezone: row['timezone']! as String,
      repeatType: ReminderRepeatType.values.byName(
        row['repeat_type']! as String,
      ),
      repeatInterval: row['repeat_interval']! as int,
      weekdays: (jsonDecode(row['weekdays']! as String) as List).cast<int>(),
      endsAt: row['ends_at'] == null
          ? null
          : DateTime.parse(row['ends_at']! as String),
      enabled: row['enabled'] == 1,
    );
  }

  @override
  Future<void> delete(String noteId) {
    return _database.delete(
      'note_reminders',
      where: 'note_id = ?',
      whereArgs: [noteId],
    );
  }
}
