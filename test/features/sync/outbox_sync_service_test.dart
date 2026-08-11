import 'package:flutter_test/flutter_test.dart';
import 'package:smartnote/features/notes/data/smartnote_database.dart';
import 'package:smartnote/features/notes/data/sqlite_note_repository.dart';
import 'package:smartnote/features/notes/domain/note.dart';
import 'package:smartnote/features/sync/data/cloud_note_store.dart';
import 'package:smartnote/features/sync/data/outbox_sync_service.dart';
import 'package:smartnote/features/sync/data/supabase_config.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  setUpAll(sqfliteFfiInit);

  test('treats missing Supabase values as local-only configuration', () {
    expect(SupabaseConfig.fromValues(url: '', publishableKey: ''), isNull);
    expect(
      SupabaseConfig.fromValues(
        url: 'https://project.supabase.co',
        publishableKey: 'publishable-key',
      ),
      isNotNull,
    );
  });

  test('uploads a pending note and clears its outbox row', () async {
    final database = await openSmartNoteDatabase(
      factory: databaseFactoryFfi,
      path: inMemoryDatabasePath,
    );
    addTearDown(database.close);
    final repository = SqliteNoteRepository(database);
    final cloud = _RecordingCloudStore();
    final service = OutboxSyncService(
      database: database,
      notes: repository,
      cloud: cloud,
    );
    await repository.save(_note());

    final result = await service.syncPending();

    expect(result.synced, 1);
    expect(result.failed, 0);
    expect(cloud.upserts.single, {
      'id': 'note-1',
      'title': 'Đồng bộ',
      'body': 'Nội dung',
      'kind': 'text',
      'is_favorite': true,
      'is_locked': false,
      'color_key': 'lavender',
      'tags': ['Dự án'],
      'image_paths': <String>[],
      'checklist': <Map<String, Object?>>[],
      'created_at': '2026-07-31T08:00:00.000',
      'updated_at': '2026-07-31T09:00:00.000',
    });
    expect(await database.query('sync_outbox'), isEmpty);
    expect(
      (await database.query('sync_state')).single['last_synced_at'],
      isNotNull,
    );
  });

  test('keeps a failed outbox row and increments attempts', () async {
    final database = await openSmartNoteDatabase(
      factory: databaseFactoryFfi,
      path: inMemoryDatabasePath,
    );
    addTearDown(database.close);
    final repository = SqliteNoteRepository(database);
    final service = OutboxSyncService(
      database: database,
      notes: repository,
      cloud: _RecordingCloudStore(shouldFail: true),
    );
    await repository.save(_note());

    final result = await service.syncPending();
    final row = (await database.query('sync_outbox')).single;

    expect(result.failed, 1);
    expect(row['attempts'], 1);
  });

  test('syncs a deleted note as a cloud tombstone', () async {
    final database = await openSmartNoteDatabase(
      factory: databaseFactoryFfi,
      path: inMemoryDatabasePath,
    );
    addTearDown(database.close);
    final repository = SqliteNoteRepository(database);
    final cloud = _RecordingCloudStore();
    final service = OutboxSyncService(
      database: database,
      notes: repository,
      cloud: cloud,
    );
    final note = _note();
    await repository.save(note);
    await service.syncPending();

    await repository.delete(note.id);
    await service.syncPending();

    expect(cloud.deletedAtByNote[note.id], isA<DateTime>());
  });

  test(
    'pulls a newer cloud note without adding it to the local outbox',
    () async {
      final database = await openSmartNoteDatabase(
        factory: databaseFactoryFfi,
        path: inMemoryDatabasePath,
      );
      addTearDown(database.close);
      final repository = SqliteNoteRepository(database);
      final cloud = _RecordingCloudStore(
        remoteNotes: [
          {
            'id': 'remote-note',
            'title': 'Từ cloud',
            'body': 'Đồng bộ hai chiều',
            'kind': 'text',
            'is_favorite': false,
            'color_key': 'sage',
            'tags': ['Cloud'],
            'image_paths': <String>[],
            'checklist': <Map<String, Object?>>[],
            'created_at': '2026-08-10T08:00:00.000Z',
            'updated_at': '2026-08-10T09:00:00.000Z',
            'deleted_at': null,
          },
        ],
      );
      final service = OutboxSyncService(
        database: database,
        notes: repository,
        cloud: cloud,
      );

      await service.syncPending();

      expect((await database.query('notes')).single['title'], 'Từ cloud');
      expect(await database.query('sync_outbox'), isEmpty);
    },
  );
}

class _RecordingCloudStore implements CloudNoteStore {
  _RecordingCloudStore({this.shouldFail = false, this.remoteNotes = const []});

  final bool shouldFail;
  final List<Map<String, Object?>> remoteNotes;
  final List<Map<String, Object?>> upserts = [];
  final Map<String, DateTime?> deletedAtByNote = {};

  @override
  Future<void> delete(String noteId, {DateTime? deletedAt}) async {
    if (shouldFail) throw Exception('offline');
    deletedAtByNote[noteId] = deletedAt;
  }

  @override
  Future<void> upsert(Map<String, Object?> note) async {
    if (shouldFail) throw Exception('offline');
    upserts.add(note);
  }

  @override
  Future<List<Map<String, Object?>>> fetchNotes({
    DateTime? updatedAfter,
  }) async {
    if (shouldFail) throw Exception('offline');
    return remoteNotes;
  }
}

Note _note() {
  return Note(
    id: 'note-1',
    title: 'Đồng bộ',
    body: 'Nội dung',
    kind: NoteKind.text,
    checklist: const [],
    tags: const ['Dự án'],
    isFavorite: true,
    colorKey: 'lavender',
    imagePaths: const [],
    createdAt: DateTime(2026, 7, 31, 8),
    updatedAt: DateTime(2026, 7, 31, 9),
  );
}
