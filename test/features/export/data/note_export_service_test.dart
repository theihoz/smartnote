import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:smartnote/features/export/data/note_export_service.dart';
import 'package:smartnote/features/notes/domain/note.dart';

void main() {
  final notes = [
    Note(
      id: '1',
      title: 'Kế hoạch',
      body: 'Nội dung quan trọng',
      kind: NoteKind.checklist,
      checklist: const [
        ChecklistItem(id: 'a', text: 'Hoàn thành', isDone: true),
        ChecklistItem(id: 'b', text: 'Tiếp tục', isDone: false),
      ],
      tags: const ['Công việc'],
      isFavorite: false,
      colorKey: 'sage',
      imagePaths: const [],
      createdAt: DateTime.utc(2026, 8, 1),
      updatedAt: DateTime.utc(2026, 8, 2),
    ),
  ];

  test('renders selected notes as combined Markdown', () {
    final markdown = NoteExportService().toMarkdown(notes);

    expect(markdown, contains('# Kế hoạch'));
    expect(markdown, contains('- [x] Hoàn thành'));
    expect(markdown, contains('- [ ] Tiếp tục'));
  });

  test('creates a valid PDF document', () async {
    final fontBytes = await File(
      'assets/fonts/Roboto-Regular.ttf',
    ).readAsBytes();
    final font = pw.Font.ttf(ByteData.sublistView(fontBytes));
    final bytes = await NoteExportService().toPdf(notes, font: font);

    expect(utf8.decode(bytes.take(4).toList()), '%PDF');
  });
}
