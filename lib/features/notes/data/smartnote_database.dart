import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

Future<Database> openSmartNoteDatabase({
  DatabaseFactory? factory,
  String? path,
}) async {
  final selectedFactory = factory ?? databaseFactory;
  final databasePath =
      path ?? p.join(await selectedFactory.getDatabasesPath(), 'smartnote.db');

  return selectedFactory.openDatabase(
    databasePath,
    options: OpenDatabaseOptions(
      version: 5,
      onConfigure: (database) => database.execute('PRAGMA foreign_keys = ON'),
      onCreate: _createSchema,
      onUpgrade: _upgradeSchema,
    ),
  );
}

Future<Database> openSmartNoteProfileDatabase(String? profileId) async {
  if (profileId == null || profileId.startsWith('guest:')) {
    return openSmartNoteDatabase();
  }
  final safeId = profileId.replaceAll(RegExp('[^a-zA-Z0-9_-]'), '_');
  return openSmartNoteDatabase(
    path: p.join(
      await databaseFactory.getDatabasesPath(),
      'smartnote_$safeId.db',
    ),
  );
}

Future<void> clearSmartNoteProfile(Database database) async {
  await database.transaction((transaction) async {
    for (final table in [
      'sync_outbox',
      'sync_state',
      'note_drafts',
      'notes',
      'tags',
    ]) {
      await transaction.delete(table);
    }
  });
}

Future<void> _createSchema(Database database, int version) async {
  await database.execute('''
    CREATE TABLE notes (
      id TEXT PRIMARY KEY,
      title TEXT NOT NULL,
      body TEXT NOT NULL,
      kind TEXT NOT NULL,
      is_favorite INTEGER NOT NULL,
      color_key TEXT NOT NULL,
      deleted_at TEXT,
      is_locked INTEGER NOT NULL DEFAULT 0,
      created_at TEXT NOT NULL,
      updated_at TEXT NOT NULL
    )
  ''');
  await database.execute('''
    CREATE TABLE tags (
      name TEXT PRIMARY KEY COLLATE NOCASE
    )
  ''');
  await database.execute('''
    CREATE TABLE note_tags (
      note_id TEXT NOT NULL,
      tag_name TEXT NOT NULL,
      position INTEGER NOT NULL,
      PRIMARY KEY (note_id, tag_name),
      FOREIGN KEY (note_id) REFERENCES notes(id) ON DELETE CASCADE,
      FOREIGN KEY (tag_name) REFERENCES tags(name)
    )
  ''');
  await database.execute('''
    CREATE TABLE checklist_items (
      id TEXT PRIMARY KEY,
      note_id TEXT NOT NULL,
      text TEXT NOT NULL,
      is_done INTEGER NOT NULL,
      position INTEGER NOT NULL,
      FOREIGN KEY (note_id) REFERENCES notes(id) ON DELETE CASCADE
    )
  ''');
  await database.execute('''
    CREATE TABLE note_images (
      note_id TEXT NOT NULL,
      path TEXT NOT NULL,
      position INTEGER NOT NULL,
      PRIMARY KEY (note_id, path),
      FOREIGN KEY (note_id) REFERENCES notes(id) ON DELETE CASCADE
    )
  ''');
  await database.execute('''
    CREATE TABLE sync_outbox (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      note_id TEXT NOT NULL,
      operation TEXT NOT NULL,
      created_at TEXT NOT NULL,
      attempts INTEGER NOT NULL DEFAULT 0
    )
  ''');
  await _createReminderAndVersionSchema(database);
  await _createSyncStateSchema(database);
  await _createDraftSchema(database);
}

Future<void> _upgradeSchema(
  Database database,
  int oldVersion,
  int newVersion,
) async {
  if (oldVersion < 2) {
    await database.execute('ALTER TABLE notes ADD COLUMN deleted_at TEXT');
    await database.execute(
      'ALTER TABLE notes ADD COLUMN is_locked INTEGER NOT NULL DEFAULT 0',
    );
    await database.execute(
      'CREATE INDEX IF NOT EXISTS notes_deleted_at_idx ON notes(deleted_at)',
    );
  }
  if (oldVersion < 3) {
    await _createReminderAndVersionSchema(database);
  }
  if (oldVersion < 4) {
    await _createSyncStateSchema(database);
  }
  if (oldVersion < 5) {
    await _createDraftSchema(database);
  }
}

Future<void> _createReminderAndVersionSchema(Database database) async {
  await database.execute('''
    CREATE TABLE IF NOT EXISTS note_reminders (
      note_id TEXT PRIMARY KEY,
      scheduled_at TEXT NOT NULL,
      timezone TEXT NOT NULL,
      repeat_type TEXT NOT NULL DEFAULT 'none',
      repeat_interval INTEGER NOT NULL DEFAULT 1,
      weekdays TEXT NOT NULL DEFAULT '[]',
      ends_at TEXT,
      enabled INTEGER NOT NULL DEFAULT 1,
      created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
      updated_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
      FOREIGN KEY (note_id) REFERENCES notes(id) ON DELETE CASCADE
    )
  ''');
  await database.execute('''
    CREATE TABLE IF NOT EXISTS note_versions (
      id TEXT PRIMARY KEY,
      note_id TEXT NOT NULL,
      snapshot TEXT NOT NULL,
      created_at TEXT NOT NULL,
      FOREIGN KEY (note_id) REFERENCES notes(id) ON DELETE CASCADE
    )
  ''');
  await database.execute('''
    CREATE INDEX IF NOT EXISTS note_versions_note_created_idx
    ON note_versions(note_id, created_at DESC)
  ''');
}

Future<void> _createSyncStateSchema(Database database) {
  return database.execute('''
    CREATE TABLE IF NOT EXISTS sync_state (
      key TEXT PRIMARY KEY,
      last_synced_at TEXT NOT NULL
    )
  ''');
}

Future<void> _createDraftSchema(Database database) {
  return database.execute('''
    CREATE TABLE IF NOT EXISTS note_drafts (
      note_id TEXT PRIMARY KEY,
      title TEXT NOT NULL,
      body TEXT NOT NULL,
      updated_at TEXT NOT NULL
    )
  ''');
}
