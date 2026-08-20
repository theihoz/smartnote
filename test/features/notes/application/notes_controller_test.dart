import 'package:flutter_test/flutter_test.dart';
import 'package:smartnote/features/notes/application/notes_controller.dart';
import 'package:smartnote/features/notes/domain/note.dart';
import 'package:smartnote/features/notes/domain/note_query.dart';
import 'package:smartnote/features/notes/domain/note_repository.dart';
import 'package:smartnote/features/notes/domain/note_validator.dart';

void main() {
  test('loads notes and reapplies a search query', () async {
    final repository = _MemoryNoteRepository([
      _note(id: '1', title: 'Flutter'),
      _note(id: '2', title: 'Đi chợ'),
    ]);
    final controller = NotesController(
      repository,
      now: () => DateTime(2026, 7, 31),
      newId: () => 'new-id',
    );

    await controller.load();
    controller.setQuery(const NoteQuery(searchText: 'flutter'));

    expect(controller.state.visibleNotes.map((note) => note.id), ['1']);
  });

  test('rejects an invalid draft without writing to repository', () async {
    final repository = _MemoryNoteRepository([]);
    final controller = NotesController(
      repository,
      now: () => DateTime(2026, 7, 31),
      newId: () => 'new-id',
    );

    final result = await controller.saveDraft(
      const NoteDraft(title: '', body: '', kind: NoteKind.text),
    );

    expect(result.generalError, NoteValidationError.emptyNote);
    expect(repository.notes, isEmpty);
  });

  test('creates a valid note then exposes it in state', () async {
    final repository = _MemoryNoteRepository([]);
    final controller = NotesController(
      repository,
      now: () => DateTime(2026, 7, 31, 10),
      newId: () => 'new-id',
    );

    final result = await controller.saveDraft(
      const NoteDraft(
        title: 'Bài mới',
        body: 'Nội dung',
        kind: NoteKind.text,
        tags: ['Học tập'],
      ),
    );

    expect(result.isValid, isTrue);
    expect(controller.state.visibleNotes.single.id, 'new-id');
    expect(controller.state.visibleNotes.single.tags, ['Học tập']);
  });

  test('toggles favorite and persists the changed note', () async {
    final repository = _MemoryNoteRepository([
      _note(id: '1', title: 'Flutter'),
    ]);
    final controller = NotesController(
      repository,
      now: () => DateTime(2026, 7, 31, 11),
      newId: () => 'new-id',
    );
    await controller.load();

    await controller.toggleFavorite('1');

    expect(repository.notes.single.isFavorite, isTrue);
    expect(controller.state.visibleNotes.single.isFavorite, isTrue);
  });

  test('undo restores the previous note after an edit', () async {
    final repository = _MemoryNoteRepository([_note(id: '1', title: 'Bản cũ')]);
    final controller = NotesController(
      repository,
      now: () => DateTime(2026, 7, 31, 12),
      newId: () => 'new-id',
    );
    await controller.load();

    await controller.saveDraft(
      const NoteDraft(title: 'Bản mới', body: '', kind: NoteKind.text),
      id: '1',
      createdAt: DateTime(2026, 7, 30),
    );

    expect(controller.canUndo, isTrue);
    expect(await controller.undo(), isTrue);
    expect((await repository.getById('1'))!.title, 'Bản cũ');
  });

  test('undo restores a deleted note', () async {
    final repository = _MemoryNoteRepository([
      _note(id: '1', title: 'Cần giữ lại'),
    ]);
    final controller = NotesController(
      repository,
      now: () => DateTime(2026, 7, 31, 12),
      newId: () => 'new-id',
    );
    await controller.load();

    await controller.delete('1');
    expect(await repository.getById('1'), isNull);
    expect(await controller.undo(), isTrue);
    expect((await repository.getById('1'))!.title, 'Cần giữ lại');
  });

  test('locks and unlocks a note while persisting the state', () async {
    final repository = _MemoryNoteRepository([
      _note(id: '1', title: 'Riêng tư'),
    ]);
    final controller = NotesController(
      repository,
      now: () => DateTime(2026, 7, 31, 12),
      newId: () => 'new-id',
    );
    await controller.load();

    await controller.setLocked('1', true);
    expect(repository.notes.single.isLocked, isTrue);

    await controller.setLocked('1', false);
    expect(repository.notes.single.isLocked, isFalse);
  });
}

class _MemoryNoteRepository implements NoteRepository {
  _MemoryNoteRepository(this.notes);

  final List<Note> notes;

  @override
  Future<void> delete(String id) async {
    notes.removeWhere((note) => note.id == id);
  }

  @override
  Future<Note?> getById(String id) async {
    for (final note in notes) {
      if (note.id == id) return note;
    }
    return null;
  }

  @override
  Future<List<Note>> list([NoteQuery query = const NoteQuery()]) async {
    return query.apply(notes);
  }

  @override
  Future<void> save(Note note) async {
    notes.removeWhere((existing) => existing.id == note.id);
    notes.add(note);
  }
}

Note _note({required String id, required String title}) {
  return Note(
    id: id,
    title: title,
    body: '',
    kind: NoteKind.text,
    checklist: const [],
    tags: const [],
    isFavorite: false,
    colorKey: 'lavender',
    imagePaths: const [],
    createdAt: DateTime(2026, 7, 30),
    updatedAt: DateTime(2026, 7, 30),
  );
}
