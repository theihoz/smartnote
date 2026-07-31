import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers.dart';
import '../domain/note.dart';

class NoteDetailScreen extends ConsumerWidget {
  const NoteDetailScreen({super.key, required this.noteId});

  final String noteId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cloud_done_outlined, size: 17),
            SizedBox(width: 7),
            Text('Đã lưu', style: TextStyle(fontSize: 14)),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Yêu thích',
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
            tooltip: 'Chia sẻ',
            onPressed: () {},
            icon: const Icon(Icons.share_outlined),
          ),
          IconButton(
            tooltip: 'Xóa',
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
                          avatar: const Icon(
                            Icons.person_outline_rounded,
                            size: 15,
                            color: Color(0xFFC9C5CF),
                          ),
                          label: Text(tag),
                          backgroundColor: const Color(0xFF353437),
                          side: const BorderSide(color: Color(0x33928F99)),
                          labelStyle: const TextStyle(color: Color(0xFFC9C5CF)),
                        ),
                      const Chip(
                        avatar: Icon(
                          Icons.add_rounded,
                          size: 15,
                          color: Color(0xFFE5E1FF),
                        ),
                        label: Text('Thêm tag'),
                        backgroundColor: Colors.transparent,
                        side: BorderSide(
                          color: Color(0xFF928F99),
                          style: BorderStyle.solid,
                        ),
                        labelStyle: TextStyle(color: Color(0xFFE5E1FF)),
                      ),
                    ],
                  ),
                  if (current.checklist.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    _DarkChecklist(note: current),
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
              child: Container(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
                decoration: const BoxDecoration(
                  color: Color(0xF2201F22),
                  border: Border(top: BorderSide(color: Color(0x33928F99))),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black54,
                      blurRadius: 30,
                      offset: Offset(0, -4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DecoratedBox(
                      decoration: BoxDecoration(
                        color: const Color(0xFF2A292C),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              onPressed: null,
                              icon: Icon(Icons.photo_camera_outlined),
                            ),
                            IconButton(
                              onPressed: null,
                              icon: Icon(Icons.image_outlined),
                            ),
                            IconButton(
                              onPressed: null,
                              icon: Icon(Icons.checklist_rounded),
                            ),
                            IconButton(
                              onPressed: null,
                              icon: Icon(Icons.sell_outlined),
                            ),
                            IconButton(
                              onPressed: null,
                              icon: Icon(Icons.palette_outlined),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    FilledButton.icon(
                      onPressed: () => context.push('/editor/${current.id}'),
                      style: FilledButton.styleFrom(
                        minimumSize: const Size.fromHeight(48),
                        backgroundColor: const Color(0xFFE5E1FF),
                        foregroundColor: const Color(0xFF2F2C52),
                      ),
                      icon: const Icon(Icons.check_rounded),
                      label: const Text(
                        'Xong',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _delete(BuildContext context, WidgetRef ref, Note note) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xóa ghi chú?'),
        content: const Text('Bạn có thể hoàn tác ngay sau khi xóa.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    final deleted = await ref
        .read(notesControllerProvider.notifier)
        .delete(note.id);
    if (!context.mounted) return;
    context.go('/');
    if (deleted != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Đã xóa ghi chú'),
          action: SnackBarAction(
            label: 'Hoàn tác',
            onPressed: () =>
                ref.read(notesControllerProvider.notifier).restore(deleted),
          ),
        ),
      );
    }
  }
}

class _DarkChecklist extends StatelessWidget {
  const _DarkChecklist({required this.note});

  final Note note;

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
          const Row(
            children: [
              Icon(Icons.checklist_rounded, color: Color(0xFFE5E1FF)),
              SizedBox(width: 8),
              Text(
                'Cần chuẩn bị',
                style: TextStyle(
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
                        decoration: item.isDone
                            ? TextDecoration.lineThrough
                            : null,
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
