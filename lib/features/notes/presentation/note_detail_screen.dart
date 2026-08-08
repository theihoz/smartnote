import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers.dart';
import '../../../app/app_keys.dart';
import '../../../l10n/app_localizations.dart';
import '../domain/note.dart';

class NoteDetailScreen extends ConsumerWidget {
  const NoteDetailScreen({super.key, required this.noteId});

  final String noteId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final state = ref.watch(notesControllerProvider);
    Note? note;
    for (final candidate in state.allNotes) {
      if (candidate.id == noteId) note = candidate;
    }
    if (note == null) {
      return const Scaffold(
        backgroundColor: Color(0xFF141316),
        body: Center(child: CircularProgressIndicator()),
      );
    }
    final current = note;
    return Scaffold(
      backgroundColor: const Color(0xFF141316),
      appBar: AppBar(
        backgroundColor: const Color(0xFF141316),
        foregroundColor: const Color(0xFFE5E1FF),
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          onPressed: context.pop,
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_done_outlined, size: 17),
            const SizedBox(width: 7),
            Text(l10n.saved, style: const TextStyle(fontSize: 14)),
          ],
        ),
        actions: [
          IconButton(
            tooltip: l10n.favorite,
            onPressed: () => ref
                .read(notesControllerProvider.notifier)
                .toggleFavorite(current.id),
            icon: Icon(
              current.isFavorite
                  ? Icons.favorite_rounded
                  : Icons.favorite_border_rounded,
              color: const Color(0xFFFFA5A5),
            ),
          ),
          IconButton(
            tooltip: l10n.share,
            onPressed: () {},
            icon: const Icon(Icons.share_outlined),
          ),
          IconButton(
            tooltip: l10n.delete,
            onPressed: () => _delete(context, ref, current),
            icon: const Icon(Icons.delete_outline_rounded),
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 28, 20, 150),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Hero(
                    tag: 'note-${current.id}',
                    child: Material(
                      color: Colors.transparent,
                      child: Text(
                        current.title,
                        style: const TextStyle(
                          color: Color(0xFFE5E1FF),
                          fontSize: 28,
                          height: 1.28,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final tag in current.tags)
                        Chip(
                          avatar: const Icon(Icons.label_outline_rounded, size: 15),
                          label: Text(tag),
                        ),
                      Chip(
                        avatar: const Icon(Icons.add_rounded, size: 15),
                        label: Text(l10n.addTag),
                      ),
                    ],
                  ),
                  if (current.checklist.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    _Checklist(note: current, title: l10n.checklistTitle),
                  ],
                  if (current.body.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    Text(
                      current.body,
                      style: const TextStyle(
                        color: Color(0xFFE5E1E5),
                        fontSize: 16,
                        height: 1.5,
                      ),
                    ),
                  ],
                  for (final path in current.imagePaths) ...[
                    const SizedBox(height: 24),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: AspectRatio(
                        aspectRatio: 16 / 9,
                        child: path.startsWith('assets/')
                            ? Image.asset(path, fit: BoxFit.cover)
                            : Image.file(File(path), fit: BoxFit.cover),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: FilledButton.icon(
                  onPressed: () => context.push('/editor/${current.id}'),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(48),
                    backgroundColor: const Color(0xFFE5E1FF),
                    foregroundColor: const Color(0xFF2F2C52),
                  ),
                  icon: const Icon(Icons.edit_rounded),
                  label: Text(l10n.editNote),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _delete(BuildContext context, WidgetRef ref, Note note) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteNoteTitle),
        content: Text(l10n.deleteNoteContent),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    final controller = ref.read(notesControllerProvider.notifier);
    final deleted = await controller.delete(note.id);
    if (!context.mounted || deleted == null) return;
    context.go('/');
    scaffoldMessengerKey.currentState?.showSnackBar(
      SnackBar(
        content: Text(l10n.deletedNote),
        action: SnackBarAction(
          label: l10n.undo,
          onPressed: controller.undo,
        ),
      ),
    );
  }
}

class _Checklist extends StatelessWidget {
  const _Checklist({required this.note, required this.title});

  final Note note;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0x33928F99)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.checklist_rounded, color: Color(0xFFE5E1FF)),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  color: Color(0xFFE5E1FF),
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          for (final item in note.checklist)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    item.isDone
                        ? Icons.check_box_rounded
                        : Icons.check_box_outline_blank_rounded,
                    color: item.isDone
                        ? const Color(0xFFE5E1FF)
                        : const Color(0xFF928F99),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      item.text,
                      style: TextStyle(
                        color: item.isDone
                            ? const Color(0xFFC9C5CF)
                            : const Color(0xFFE5E1E5),
                        fontSize: 16,
                        decoration: item.isDone ? TextDecoration.lineThrough : null,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
