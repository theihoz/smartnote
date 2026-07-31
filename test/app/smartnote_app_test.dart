import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smartnote/app/smartnote_app.dart';
import 'package:smartnote/features/notes/domain/note.dart';
import 'package:smartnote/features/notes/domain/note_query.dart';
import 'package:smartnote/features/notes/domain/note_repository.dart';

void main() {
  testWidgets('home renders repository notes and opens search', (tester) async {
    await tester.pumpWidget(
      SmartNoteApp(repository: _MemoryNoteRepository([_dalatNote()])),
    );
    await tester.pumpAndSettle();

    expect(find.text('SmartNote'), findsOneWidget);
    expect(find.text('Lịch trình du lịch Đà Lạt'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.search_rounded));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('search-field')), findsOneWidget);
    expect(find.text('Tìm kiếm'), findsWidgets);
  });

  testWidgets('editor rejects an empty note', (tester) async {
    await tester.pumpWidget(
      SmartNoteApp(repository: _MemoryNoteRepository([])),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('create-note-fab')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('save-note-button')));
    await tester.pump();

    expect(find.text('Hãy nhập tiêu đề hoặc nội dung.'), findsOneWidget);
  });

  testWidgets('note card opens the Figma-inspired dark detail screen', (
    tester,
  ) async {
    await tester.pumpWidget(
      SmartNoteApp(repository: _MemoryNoteRepository([_dalatNote()])),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Lịch trình du lịch Đà Lạt'));
    await tester.pumpAndSettle();

    expect(find.text('Cần chuẩn bị'), findsOneWidget);
    expect(find.text('Xong'), findsOneWidget);
    final scaffold = tester.widget<Scaffold>(find.byType(Scaffold).last);
    expect(scaffold.backgroundColor, const Color(0xFF141316));
  });

  testWidgets('switching to English updates navigation labels', (tester) async {
    await tester.pumpWidget(
      SmartNoteApp(repository: _MemoryNoteRepository([])),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.settings_outlined));
    await tester.pumpAndSettle();
    await tester.tap(find.text('EN'));
    await tester.pumpAndSettle();

    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Settings'), findsWidgets);
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

Note _dalatNote() {
  return Note(
    id: 'dalat',
    title: 'Lịch trình du lịch Đà Lạt',
    body:
        'Lịch trình ngày 1 dự kiến sẽ bắt đầu bằng việc đi ăn bánh mì '
        'xíu mại Hoàng Diệu ngay sau khi nhận phòng.',
    kind: NoteKind.checklist,
    checklist: const [
      ChecklistItem(id: '1', text: 'Đặt vé máy bay / xe khách', isDone: true),
      ChecklistItem(id: '2', text: 'Thuê homestay gần trung tâm', isDone: true),
      ChecklistItem(id: '3', text: 'Lên danh sách quán ăn ngon', isDone: false),
    ],
    tags: const ['Cá nhân', 'Du lịch'],
    isFavorite: true,
    colorKey: 'lavender',
    imagePaths: const ['assets/images/dalat_food.jpg'],
    createdAt: DateTime(2026, 7, 30),
    updatedAt: DateTime(2026, 7, 31),
  );
}
