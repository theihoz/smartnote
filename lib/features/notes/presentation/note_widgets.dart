import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/app_theme.dart';
import '../domain/note.dart';

class NoteCard extends StatelessWidget {
  const NoteCard({super.key, required this.note, required this.onFavorite});

  final Note note;
  final VoidCallback onFavorite;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.push('/notes/${note.id}'),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (note.imagePaths.isNotEmpty) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: SizedBox(
                    height: 70,
                    width: double.infinity,
                    child: _NoteImage(path: note.imagePaths.first),
                  ),
                ),
                const SizedBox(height: 12),
              ],
              Text(
                note.title.isEmpty ? 'Ghi chú không tiêu đề' : note.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 6),
              if (note.kind == NoteKind.checklist)
                _ChecklistPreview(note: note)
              else
                Text(
                  note.body,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: AppTheme.muted),
                ),
              const SizedBox(height: 8),
              if (note.tags.isNotEmpty) ...[
                const SizedBox(height: 10),
                Wrap(
                  spacing: 5,
                  runSpacing: 5,
                  children: note.tags
                      .take(2)
                      .map(
                        (tag) => Chip(
                          visualDensity: VisualDensity.compact,
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                          side: BorderSide.none,
                          backgroundColor: AppTheme.lavender,
                          label: Text(
                            tag,
                            style: const TextStyle(
                              color: AppTheme.indigo,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ],
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      _relativeDate(note.updatedAt),
                      style: Theme.of(
                        context,
                      ).textTheme.labelSmall?.copyWith(color: AppTheme.muted),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Yêu thích',
                    visualDensity: VisualDensity.compact,
                    onPressed: onFavorite,
                    icon: Icon(
                      note.isFavorite
                          ? Icons.favorite_rounded
                          : Icons.favorite_border_rounded,
                      color: note.isFavorite ? AppTheme.coral : AppTheme.muted,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChecklistPreview extends StatelessWidget {
  const _ChecklistPreview({required this.note});

  final Note note;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final item in note.checklist.take(2))
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              children: [
                Icon(
                  item.isDone
                      ? Icons.check_box_rounded
                      : Icons.check_box_outline_blank_rounded,
                  size: 17,
                  color: item.isDone ? AppTheme.indigo : AppTheme.muted,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    item.text,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13,
                      color: AppTheme.muted,
                      decoration: item.isDone
                          ? TextDecoration.lineThrough
                          : null,
                    ),
                  ),
                ),
              ],
            ),
          ),
        Text(
          '${note.completedChecklistItems}/${note.checklist.length} hoàn thành',
          style: const TextStyle(
            color: AppTheme.indigo,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _NoteImage extends StatelessWidget {
  const _NoteImage({required this.path});

  final String path;

  @override
  Widget build(BuildContext context) {
    if (path.startsWith('assets/')) {
      return Image.asset(path, fit: BoxFit.cover);
    }
    return Image.file(
      File(path),
      fit: BoxFit.cover,
      errorBuilder: (_, _, _) => const ColoredBox(
        color: AppTheme.lavender,
        child: Icon(Icons.broken_image_outlined),
      ),
    );
  }
}

String _relativeDate(DateTime date) {
  final difference = DateTime.now().difference(date);
  if (difference.inDays <= 0) return 'Hôm nay';
  if (difference.inDays == 1) return 'Hôm qua';
  return '${difference.inDays} ngày trước';
}
