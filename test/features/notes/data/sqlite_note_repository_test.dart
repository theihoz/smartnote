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

  test('deletes a note and its aggregate', () async {
    final note = _note();
    await repository.save(note);

    await repository.delete(note.id);

    expect(await repository.getById(note.id), isNull);
    expect(await repository.list(), isEmpty);
  });

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
