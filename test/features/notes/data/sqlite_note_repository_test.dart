import 'package:flutter_test/flutter_test.dart';
import 'package:smartnote/features/notes/data/smartnote_database.dart';
import 'package:smartnote/features/notes/data/sqlite_note_repository.dart';
import 'package:smartnote/features/notes/domain/note.dart';
import 'package:smartnote/features/notes/domain/note_query.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  late Database database;
  late SqliteNoteRepository repository;

  setUpAll(sqfliteFfiInit);

  setUp(() async {
    database = await openSmartNoteDatabase(
      factory: databaseFactoryFfi,
      path: inMemoryDatabasePath,
    );
    repository = SqliteNoteRepository(database);
  });

  tearDown(() => database.close());

  test('saves and restores a complete checklist note', () async {
    final note = _note(
      title: 'Chuẩn bị demo',
      body: 'Hoàn thiện ứng dụng',
      tags: const ['Học tập', 'Dự án'],
      imagePaths: const ['images/demo.png'],
      checklist: const [
        ChecklistItem(id: 'item-1', text: 'Build APK', isDone: true),
        ChecklistItem(id: 'item-2', text: 'Quay video', isDone: false),
      ],
    );

    await repository.save(note);
    final restored = await repository.getById(note.id);

    expect(restored, isNotNull);
    expect(restored!.title, 'Chuẩn bị demo');
    expect(restored.tags, ['Học tập', 'Dự án']);
    expect(restored.imagePaths, ['images/demo.png']);
    expect(restored.checklist.map((item) => item.text), [
      'Build APK',
      'Quay video',
    ]);
    expect(restored.checklist.first.isDone, isTrue);
  });

  test('updates child rows without leaving stale values', () async {
    final original = _note(
      title: 'Bản cũ',
      tags: const ['Cũ'],
      imagePaths: const ['old.png'],
      checklist: const [
        ChecklistItem(id: 'old', text: 'Việc cũ', isDone: false),
      ],
    );
    await repository.save(original);

    await repository.save(
      original.copyWith(
        title: 'Bản mới',
        tags: const ['Mới'],
        imagePaths: const ['new.png'],
        checklist: const [
          ChecklistItem(id: 'new', text: 'Việc mới', isDone: true),
        ],
        updatedAt: DateTime(2026, 7, 31, 12),
      ),
    );
    final restored = await repository.getById(original.id);

    expect(restored!.title, 'Bản mới');
    expect(restored.tags, ['Mới']);
    expect(restored.imagePaths, ['new.png']);
    expect(restored.checklist.single.text, 'Việc mới');
  });

  test('lists notes using search, favorite and tag filters', () async {
    await repository.save(
      _note(
        id: 'favorite',
        title: 'Ôn Flutter',
        body: 'Riverpod',
        tags: const ['Học tập'],
        isFavorite: true,
      ),
    );
    await repository.save(
      _note(
        id: 'other',
        title: 'Đi chợ',
        body: 'Mua sữa',
        tags: const ['Cá nhân'],
      ),
    );

    final notes = await repository.list(
      const NoteQuery(
        searchText: 'flutter',
        tag: 'Học tập',
        favoritesOnly: true,
      ),
    );

    expect(notes.map((note) => note.id), ['favorite']);
  });

  test(
    'soft deletes a note while retaining it for the 30-day trash window',
    () async {
      final note = _note();
      await repository.save(note);

      await repository.delete(note.id);

      final row = (await database.query(
        'notes',
        columns: ['deleted_at'],
        where: 'id = ?',
        whereArgs: [note.id],
      )).single;

      expect(row['deleted_at'], isNotNull);
      expect(await repository.list(), isEmpty);
    },
  );

  test('records an outbox row after each local save and delete', () async {
    final note = _note();

    await repository.save(note);
    await repository.delete(note.id);
    final outbox = await database.query(
      'sync_outbox',
      orderBy: 'created_at ASC',
    );

    expect(outbox.map((row) => row['operation']), ['upsert', 'delete']);
    expect(outbox.every((row) => row['note_id'] == note.id), isTrue);
  });

  test('persists a reminder and a version snapshot for a note', () async {
    final note = _note();
    await repository.save(note);

    await database.insert('note_reminders', {
      'note_id': note.id,
      'scheduled_at': '2026-08-12T09:00:00.000Z',
      'timezone': 'Asia/Ho_Chi_Minh',
      'repeat_type': 'weekly',
      'repeat_interval': 1,
      'weekdays': '[1, 3, 5]',
      'enabled': 1,
    });
    await database.insert('note_versions', {
      'id': 'version-1',
      'note_id': note.id,
      'snapshot': '{"title":"Ghi chú"}',
      'created_at': '2026-07-31T09:00:00.000Z',
    });

    expect(
      (await database.query('note_reminders')).single['repeat_type'],
      'weekly',
    );
    final versionRows = await database.query(
      'note_versions',
      where: 'id = ?',
      whereArgs: ['version-1'],
    );
    expect(versionRows.single['id'], 'version-1');
  });

  test('creates a version snapshot on every note save', () async {
    final note = _note(title: 'Bản đầu');
    await repository.save(note);
    await repository.save(
      note.copyWith(title: 'Bản đã sửa', updatedAt: DateTime(2026, 7, 31, 10)),
    );

    final versions = await database.query(
      'note_versions',
      where: 'note_id = ?',
      whereArgs: [note.id],
      orderBy: 'created_at ASC',
    );

    expect(versions, hasLength(2));
    expect(versions.last['snapshot'], contains('Bản đã sửa'));
  });

  test('returns version history newest first', () async {
    final note = _note(title: 'Bản đầu', body: 'Nội dung đầu');
    await repository.save(note);
    await repository.save(
      note.copyWith(
        title: 'Bản mới',
        body: 'Nội dung mới',
        updatedAt: DateTime(2026, 7, 31, 10),
      ),
    );

    final versions = await repository.listVersions(note.id);

    expect(versions.map((version) => version.title), ['Bản mới', 'Bản đầu']);
    expect(versions.first.body, 'Nội dung mới');
  });

  test('lists, restores and purges notes from the 30-day trash', () async {
    final note = _note();
    await repository.save(note);
    await repository.delete(note.id);

    expect((await repository.listTrash()).single.id, note.id);

    await repository.restoreFromTrash(note.id);
    expect((await repository.list()).single.id, note.id);

    await repository.delete(note.id);
    await database.update(
      'notes',
      {'deleted_at': '2026-06-01T00:00:00.000Z'},
      where: 'id = ?',
      whereArgs: [note.id],
    );
    await repository.purgeExpiredTrash(DateTime.utc(2026, 8, 1));

    expect(await repository.getById(note.id), isNull);
  });
}

Note _note({
  String id = 'note-1',
  String title = 'Ghi chú',
  String body = '',
  List<String> tags = const [],
  List<String> imagePaths = const [],
  List<ChecklistItem> checklist = const [],
  bool isFavorite = false,
}) {
  return Note(
    id: id,
    title: title,
    body: body,
    kind: checklist.isEmpty ? NoteKind.text : NoteKind.checklist,
    checklist: checklist,
    tags: tags,
    isFavorite: isFavorite,
    colorKey: 'lavender',
    imagePaths: imagePaths,
    createdAt: DateTime(2026, 7, 31, 8),
    updatedAt: DateTime(2026, 7, 31, 9),
  );
}
