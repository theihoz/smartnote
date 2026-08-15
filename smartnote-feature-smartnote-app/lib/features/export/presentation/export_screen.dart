import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';

import '../../../app/providers.dart';
import '../../../l10n/feature_text.dart';
import '../../notes/domain/note.dart';
import '../data/note_export_service.dart';

class ExportScreen extends ConsumerStatefulWidget {
  const ExportScreen({super.key});

  @override
  ConsumerState<ExportScreen> createState() => _ExportScreenState();
}

class _ExportScreenState extends ConsumerState<ExportScreen> {
  final _selected = <String>{};
  bool _isExporting = false;

  List<Note> _selectedNotes(List<Note> notes) =>
      notes.where((note) => _selected.contains(note.id)).toList();

  Future<void> _export(List<Note> notes, {required bool pdf}) async {
    final selected = _selectedNotes(notes);
    if (selected.isEmpty || _isExporting) return;
    final shareText = featureText(
      context,
      vi: 'Ghi chú được xuất từ SmartNote',
      en: 'Notes exported from SmartNote',
    );
    setState(() => _isExporting = true);
    try {
      final directory = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      late final File file;
      if (pdf) {
        final data = await rootBundle.load('assets/fonts/Roboto-Regular.ttf');
        final font = pw.Font.ttf(ByteData.sublistView(data));
        final bytes = await NoteExportService().toPdf(selected, font: font);
        file = File('${directory.path}/smartnote-$timestamp.pdf');
        await file.writeAsBytes(bytes, flush: true);
      } else {
        file = File('${directory.path}/smartnote-$timestamp.md');
        await file.writeAsString(
          NoteExportService().toMarkdown(selected),
          flush: true,
        );
      }
      await SharePlus.instance.share(
        ShareParams(
          title: 'SmartNote',
          text: shareText,
          files: [XFile(file.path)],
        ),
      );
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final notes = ref.watch(notesControllerProvider).allNotes;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          featureText(
            context,
            vi: 'Chọn ghi chú để xuất',
            en: 'Select notes to export',
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: notes.isEmpty
                ? Center(
                    child: Text(
                      featureText(
                        context,
                        vi: 'Chưa có ghi chú để xuất',
                        en: 'There are no notes to export',
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(18),
                    itemCount: notes.length,
                    itemBuilder: (context, index) {
                      final note = notes[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 10),
                        child: CheckboxListTile(
                          value: _selected.contains(note.id),
                          title: Text(
                            note.title.isEmpty
                                ? featureText(
                                    context,
                                    vi: 'Ghi chú không tiêu đề',
                                    en: 'Untitled note',
                                  )
                                : note.title,
                          ),
                          subtitle: Text(
                            note.body,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          onChanged: (value) => setState(() {
                            value == true
                                ? _selected.add(note.id)
                                : _selected.remove(note.id);
                          }),
                        ),
                      );
                    },
                  ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _selected.isEmpty || _isExporting
                          ? null
                          : () => _export(notes, pdf: false),
                      icon: const Icon(Icons.code_rounded),
                      label: Text(
                        featureText(
                          context,
                          vi: 'Xuất Markdown',
                          en: 'Export Markdown',
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: _selected.isEmpty || _isExporting
                          ? null
                          : () => _export(notes, pdf: true),
                      icon: const Icon(Icons.picture_as_pdf_outlined),
                      label: Text(
                        featureText(context, vi: 'Xuất PDF', en: 'Export PDF'),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
