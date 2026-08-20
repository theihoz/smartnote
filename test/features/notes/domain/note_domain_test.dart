import 'package:flutter_test/flutter_test.dart';
import 'package:smartnote/features/notes/domain/note.dart';
import 'package:smartnote/features/notes/domain/note_query.dart';
import 'package:smartnote/features/notes/domain/note_validator.dart';

void main() {
  group('NoteValidator', () {
    test('rejects a text note when both title and body are blank', () {
      const draft = NoteDraft(title: '  ', body: '\n', kind: NoteKind.text);

      final result = NoteValidator.validate(draft);

      expect(result.isValid, isFalse);
      expect(result.generalError, NoteValidationError.emptyNote);
    });

    test('rejects a checklist note without a non-empty checklist item', () {
      const draft = NoteDraft(
        title: 'Việc hôm nay',
        body: '',
        kind: NoteKind.checklist,
        checklist: [ChecklistItem(id: '1', text: '  ', isDone: false)],
      );

      final result = NoteValidator.validate(draft);

      expect(result.isValid, isFalse);
      expect(result.generalError, NoteValidationError.emptyChecklist);
    });

    test('accepts a text note containing a title', () {
      const draft = NoteDraft(
        title: 'Ôn Flutter',
        body: '',
        kind: NoteKind.text,
      );

      expect(NoteValidator.validate(draft).isValid, isTrue);
    });
  });

  group('Note', () {
    test('reports completed checklist progress from real item state', () {
      final note = _note(
        id: 'checklist',
        title: 'Mua đồ',
        kind: NoteKind.checklist,
        checklist: const [
          ChecklistItem(id: '1', text: 'Sữa', isDone: true),
          ChecklistItem(id: '2', text: 'Bánh mì', isDone: false),
        ],
      );

      expect(note.completedChecklistItems, 1);
      expect(note.checklistProgress, 0.5);
    });

    test('reports zero progress for a checklist without items', () {
      final note = _note(
        id: 'empty',
        title: 'Việc mới',
        kind: NoteKind.checklist,
      );

      expect(note.checklistProgress, 0);
    });
  });

  group('NoteQuery', () {
    final notes = [
      _note(
        id: '1',
        title: 'Ôn Flutter',
        body: 'Riverpod và SQLite',
        tags: const ['Học tập'],
        isFavorite: true,
        updatedAt: DateTime(2026, 7, 31, 9),
      ),
      _note(
        id: '2',
        title: 'Đi chợ',
        body: 'Mua trái cây',
        tags: const ['Cá nhân'],
        updatedAt: DateTime(2026, 7, 30, 9),
      ),
      _note(
        id: '3',
        title: 'Ý tưởng dự án',
        body: 'SMARTNOTE cho sinh viên',
        tags: const ['Học tập', 'Dự án'],
        updatedAt: DateTime(2026, 7, 29, 9),
      ),
    ];

    test('searches title and body without case sensitivity', () {
      const query = NoteQuery(searchText: 'smartnote');

      expect(query.apply(notes).map((note) => note.id), ['3']);
    });

    test('combines favorite and tag filters', () {
      const query = NoteQuery(tag: 'Học tập', favoritesOnly: true);

      expect(query.apply(notes).map((note) => note.id), ['1']);
    });

    test('sorts oldest notes first when requested', () {
      const query = NoteQuery(sort: NoteSort.oldest);

      expect(query.apply(notes).map((note) => note.id), ['3', '2', '1']);
    });
  });
}

Note _note({
  required String id,
  required String title,
  String body = '',
  NoteKind kind = NoteKind.text,
  List<ChecklistItem> checklist = const [],
  List<String> tags = const [],
  bool isFavorite = false,
  DateTime? updatedAt,
}) {
  return Note(
    id: id,
    title: title,
    body: body,
    kind: kind,
    checklist: checklist,
    tags: tags,
    isFavorite: isFavorite,
    colorKey: 'lavender',
    imagePaths: const [],
    createdAt: DateTime(2026, 7, 1),
    updatedAt: updatedAt ?? DateTime(2026, 7, 1),
  );
}
