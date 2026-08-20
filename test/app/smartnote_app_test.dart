import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smartnote/app/smartnote_app.dart';
import 'package:smartnote/features/notes/domain/note.dart';
import 'package:smartnote/features/notes/domain/note_query.dart';
import 'package:smartnote/features/notes/domain/note_repository.dart';
import 'package:smartnote/features/notes/presentation/note_widgets.dart';

void main() {
  testWidgets('home renders repository notes and opens search', (tester) async {
    await tester.pumpWidget(
      SmartNoteApp(repository: _MemoryNoteRepository([_dalatNote()])),
    );
    await tester.pumpAndSettle();

    expect(find.text('SmartNote'), findsWidgets);
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
    await _scrollTo(tester, find.text('Hãy nhập tiêu đề hoặc nội dung.'));

    expect(find.text('Hãy nhập tiêu đề hoặc nội dung.'), findsOneWidget);
  });

  testWidgets('note card opens a detail screen that follows the active theme', (
    tester,
  ) async {
    await tester.pumpWidget(
      SmartNoteApp(repository: _MemoryNoteRepository([_dalatNote()])),
    );
    await tester.pumpAndSettle();

    await _scrollTo(tester, find.text('Lịch trình du lịch Đà Lạt'));
    await tester.tap(find.text('Lịch trình du lịch Đà Lạt'));
    await tester.pumpAndSettle();

    expect(find.text('Cần chuẩn bị'), findsOneWidget);
    expect(find.text('Chỉnh sửa'), findsOneWidget);
    final scaffold = tester.widget<Scaffold>(find.byType(Scaffold).last);
    final context = tester.element(find.byType(Scaffold).last);
    expect(scaffold.backgroundColor, Theme.of(context).colorScheme.surface);
  });

  testWidgets('note detail opens reminder editor', (tester) async {
    await tester.pumpWidget(
      SmartNoteApp(repository: _MemoryNoteRepository([_dalatNote()])),
    );
    await tester.pumpAndSettle();

    await _scrollTo(tester, find.byType(NoteCard));
    await tester.tap(find.byType(NoteCard));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.notifications_none_rounded));
    await tester.pumpAndSettle();

    expect(find.text('Nhắc việc'), findsOneWidget);
    expect(find.text('Ngày và giờ'), findsOneWidget);
    expect(find.text('Lặp lại'), findsOneWidget);
  });

  testWidgets('locked note hides its content until PIN verification', (
    tester,
  ) async {
    await tester.pumpWidget(
      SmartNoteApp(
        repository: _MemoryNoteRepository([
          _dalatNote().copyWith(isLocked: true),
        ]),
      ),
    );
    await tester.pumpAndSettle();

    await _scrollTo(tester, find.byType(NoteCard));
    await tester.tap(find.byType(NoteCard));
    await tester.pumpAndSettle();

    expect(find.text('Ghi chú đã khóa'), findsOneWidget);
    expect(find.textContaining('Lịch trình ngày 1'), findsNothing);
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
    await _scrollTo(tester, find.text('Export Data'));
    expect(find.text('Export Data'), findsOneWidget);
  });

  testWidgets('settings opens the trash screen', (tester) async {
    await tester.pumpWidget(
      SmartNoteApp(repository: _MemoryNoteRepository([])),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.settings_outlined));
    await tester.pumpAndSettle();
    await _scrollTo(tester, find.text('Thùng rác'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Thùng rác'));
    await tester.pumpAndSettle();

    expect(find.text('Ghi chú đã xóa'), findsOneWidget);
  });

  testWidgets('settings opens multi-note export screen', (tester) async {
    await tester.pumpWidget(
      SmartNoteApp(repository: _MemoryNoteRepository([_dalatNote()])),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.settings_outlined));
    await tester.pumpAndSettle();
    await _scrollTo(tester, find.text('Xuất ghi chú'));
    await tester.tap(find.text('Xuất ghi chú'));
    await tester.pumpAndSettle();

    expect(find.text('Chọn ghi chú để xuất'), findsOneWidget);
    expect(find.text('Xuất PDF'), findsOneWidget);
    expect(find.text('Xuất Markdown'), findsOneWidget);
  });

  testWidgets('delete snackbar action restores the deleted note', (
    tester,
  ) async {
    final repository = _MemoryNoteRepository([_dalatNote()]);
    await tester.pumpWidget(SmartNoteApp(repository: repository));
    await tester.pumpAndSettle();

    await _scrollTo(tester, find.text('Lịch trình du lịch Đà Lạt'));
    await tester.tap(find.text('Lịch trình du lịch Đà Lạt'));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.delete_outline_rounded));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Xóa').last);
    await tester.pumpAndSettle();

    expect(repository.notes, isEmpty);
    await tester.tap(find.text('Hoàn tác'));
    await tester.pumpAndSettle();

    expect(repository.notes, hasLength(1));
    expect(find.text('Lịch trình du lịch Đà Lạt'), findsOneWidget);
  });
}

Future<void> _scrollTo(WidgetTester tester, Finder finder) async {
  await tester.scrollUntilVisible(
    finder,
    250,
    scrollable: find.byType(Scrollable).first,
  );
  await Scrollable.ensureVisible(
    tester.element(finder),
    alignment: 0.5,
    duration: Duration.zero,
  );
  await tester.pump();
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
