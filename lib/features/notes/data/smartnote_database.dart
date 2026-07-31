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
      version: 1,
      onConfigure: (database) => database.execute('PRAGMA foreign_keys = ON'),
      onCreate: _createSchema,
    ),
  );
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
}
