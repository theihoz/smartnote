import 'dart:typed_data';

import 'package:pdf/widgets.dart' as pw;

import '../../notes/domain/note.dart';

class NoteExportService {
  String toMarkdown(List<Note> notes) {
    final output = StringBuffer();
    for (final note in notes) {
      output.writeln(
        '# ${note.title.isEmpty ? 'Ghi chú không tiêu đề' : note.title}',
      );
      output.writeln();
      if (note.tags.isNotEmpty) {
        output.writeln(note.tags.map((tag) => '`#$tag`').join(' '));
        output.writeln();
      }
      if (note.body.isNotEmpty) {
        output.writeln(note.body);
        output.writeln();
      }
      for (final item in note.checklist) {
        output.writeln('- [${item.isDone ? 'x' : ' '}] ${item.text}');
      }
      output.writeln();
      output.writeln('---');
      output.writeln();
    }
    return output.toString().trimRight();
  }

  Future<Uint8List> toPdf(List<Note> notes, {pw.Font? font}) async {
    final document = pw.Document();
    final textStyle = pw.TextStyle(font: font);
    document.addPage(
      pw.MultiPage(
        build: (_) => [
          for (final note in notes) ...[
            pw.Header(
              level: 0,
              child: pw.Text(
                note.title.isEmpty ? 'Ghi chú không tiêu đề' : note.title,
                style: textStyle.copyWith(fontSize: 22),
              ),
            ),
            if (note.tags.isNotEmpty)
              pw.Text(
                note.tags.map((tag) => '#$tag').join('  '),
                style: textStyle,
              ),
            if (note.body.isNotEmpty) ...[
              pw.SizedBox(height: 10),
              pw.Text(note.body, style: textStyle),
            ],
            if (note.checklist.isNotEmpty) ...[
              pw.SizedBox(height: 10),
              for (final item in note.checklist)
                pw.Bullet(
                  text: '[${item.isDone ? 'x' : ' '}] ${item.text}',
                  style: textStyle,
                ),
            ],
            pw.SizedBox(height: 20),
            pw.Divider(),
          ],
        ],
      ),
    );
    return document.save();
  }
}
