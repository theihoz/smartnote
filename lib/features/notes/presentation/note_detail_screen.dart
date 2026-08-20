import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers.dart';
import '../../../app/app_keys.dart';
import '../../../l10n/app_localizations.dart';
import '../../../l10n/feature_text.dart';
import '../domain/note.dart';
import '../../security/data/pin_lock_service.dart';
import '../../reminders/presentation/reminder_sheet.dart';

class NoteDetailScreen extends ConsumerStatefulWidget {
  const NoteDetailScreen({super.key, required this.noteId});

  final String noteId;

  @override
  ConsumerState<NoteDetailScreen> createState() => _NoteDetailScreenState();
}

class _NoteDetailScreenState extends ConsumerState<NoteDetailScreen> {
  var _sessionUnlocked = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = Theme.of(context).colorScheme;
    final state = ref.watch(notesControllerProvider);
    Note? note;
    for (final candidate in state.allNotes) {
      if (candidate.id == widget.noteId) note = candidate;
    }
    if (note == null) {
      return Scaffold(
        backgroundColor: colors.surface,
        body: Center(child: CircularProgressIndicator()),
      );
    }
    final current = note;
    if (current.isLocked && !_sessionUnlocked) {
      return _buildLockedGate(context);
    }
    return Scaffold(
      backgroundColor: colors.surface,
      appBar: AppBar(
        backgroundColor: colors.surface,
        foregroundColor: colors.onSurface,
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
            tooltip: featureText(context, vi: 'Nhắc việc', en: 'Reminder'),
            onPressed: () => showModalBottomSheet<void>(
              context: context,
              isScrollControlled: true,
              showDragHandle: false,
              builder: (_) => ReminderSheet(
                note: current,
                repository: ref.read(reminderRepositoryProvider),
                scheduler: ref.read(reminderSchedulerProvider),
              ),
            ),
            icon: const Icon(Icons.notifications_none_rounded),
          ),
          IconButton(
            tooltip: current.isLocked
                ? featureText(context, vi: 'Bỏ khóa', en: 'Remove lock')
                : featureText(context, vi: 'Khóa ghi chú', en: 'Lock note'),
            onPressed: () => _toggleLock(context, ref, current),
            icon: Icon(
              current.isLocked ? Icons.lock_rounded : Icons.lock_open_rounded,
            ),
          ),
          IconButton(
            tooltip: l10n.favorite,
            onPressed: () => ref
                .read(notesControllerProvider.notifier)
                .toggleFavorite(current.id),
            icon: Icon(
              current.isFavorite
                  ? Icons.favorite_rounded
                  : Icons.favorite_border_rounded,
              color: colors.error,
            ),
          ),
          IconButton(
            tooltip: l10n.share,
            onPressed: () {},
            icon: const Icon(Icons.share_outlined),
          ),
          IconButton(
            tooltip: featureText(
              context,
              vi: 'Lịch sử phiên bản',
              en: 'Version history',
            ),
            onPressed: () => _showVersionHistory(context, ref, current),
            icon: const Icon(Icons.history_rounded),
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
                        style: TextStyle(
                          color: colors.onSurface,
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
                            Icons.label_outline_rounded,
                            size: 15,
                          ),
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
                      style: TextStyle(
                        color: colors.onSurfaceVariant,
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
                    backgroundColor: colors.primary,
                    foregroundColor: colors.onPrimary,
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

  Future<void> _showVersionHistory(
    BuildContext context,
    WidgetRef ref,
    Note current,
  ) async {
    final repository = ref.read(noteVersionRepositoryProvider);
    final versions = await repository?.listVersions(current.id) ?? const [];
    if (!context.mounted) return;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                featureText(
                  sheetContext,
                  vi: 'Lịch sử phiên bản',
                  en: 'Version history',
                ),
                style: Theme.of(sheetContext).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              if (versions.isEmpty)
                Text(
                  featureText(
                    sheetContext,
                    vi: 'Chưa có phiên bản trước đó.',
                    en: 'No previous versions yet.',
                  ),
                )
              else
                Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: versions.length,
                    itemBuilder: (context, index) {
                      final version = versions[index];
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(
                          version.title.isEmpty
                              ? featureText(
                                  context,
                                  vi: 'Ghi chú không tiêu đề',
                                  en: 'Untitled note',
                                )
                              : version.title,
                        ),
                        subtitle: Text(
                          '${version.createdAt.toLocal()}\n${version.body}',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: TextButton(
                          onPressed: () async {
                            await ref
                                .read(notesControllerProvider.notifier)
                                .restore(
                                  current.copyWith(
                                    title: version.title,
                                    body: version.body,
                                    kind: version.kind,
                                    checklist: version.checklist,
                                    tags: version.tags,
                                    isFavorite: version.isFavorite,
                                    colorKey: version.colorKey,
                                    imagePaths: version.imagePaths,
                                    updatedAt: DateTime.now(),
                                  ),
                                );
                            if (sheetContext.mounted) {
                              Navigator.pop(sheetContext);
                            }
                          },
                          child: Text(
                            featureText(
                              context,
                              vi: 'Khôi phục',
                              en: 'Restore',
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLockedGate(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final service = ref.read(pinLockServiceProvider);
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: context.pop,
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        title: Text(
          featureText(context, vi: 'Ghi chú đã khóa', en: 'Locked note'),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(28),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircleAvatar(
                      radius: 34,
                      backgroundColor: colors.primaryContainer,
                      child: Icon(
                        Icons.lock_rounded,
                        size: 34,
                        color: colors.onPrimaryContainer,
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      featureText(
                        context,
                        vi: 'Nội dung được bảo vệ bằng PIN',
                        en: 'Content is protected by a PIN',
                      ),
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      featureText(
                        context,
                        vi: 'Mở khóa chỉ có hiệu lực trong lần xem này.',
                        en: 'Unlocking only applies to this viewing session.',
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 22),
                    FilledButton.icon(
                      onPressed: service == null
                          ? () => context.push('/security')
                          : () async {
                              if (await _verifyPin(context, service) &&
                                  mounted) {
                                setState(() => _sessionUnlocked = true);
                              }
                            },
                      icon: const Icon(Icons.key_rounded),
                      label: Text(
                        service == null
                            ? featureText(
                                context,
                                vi: 'Thiết lập PIN',
                                en: 'Set up PIN',
                              )
                            : featureText(
                                context,
                                vi: 'Nhập PIN để xem',
                                en: 'Enter PIN to view',
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
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
        action: SnackBarAction(label: l10n.undo, onPressed: controller.undo),
      ),
    );
  }

  Future<void> _toggleLock(
    BuildContext context,
    WidgetRef ref,
    Note note,
  ) async {
    final service = ref.read(pinLockServiceProvider);
    if (service == null || !service.isConfigured) {
      await context.push('/security');
      return;
    }
    if (!note.isLocked) {
      await ref.read(notesControllerProvider.notifier).setLocked(note.id, true);
      return;
    }
    if (await _verifyPin(context, service) && context.mounted) {
      await ref
          .read(notesControllerProvider.notifier)
          .setLocked(note.id, false);
      setState(() => _sessionUnlocked = true);
    }
  }

  Future<bool> _verifyPin(BuildContext context, PinLockService service) async {
    final pin = TextEditingController();
    final submitted = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(
          featureText(
            context,
            vi: 'Nhập PIN để mở khóa',
            en: 'Enter PIN to unlock',
          ),
        ),
        content: TextField(
          controller: pin,
          autofocus: true,
          obscureText: true,
          keyboardType: TextInputType.number,
          maxLength: 6,
          decoration: const InputDecoration(labelText: 'PIN'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(featureText(context, vi: 'Hủy', en: 'Cancel')),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(featureText(context, vi: 'Mở khóa', en: 'Unlock')),
          ),
        ],
      ),
    );
    if (submitted != true) {
      pin.dispose();
      return false;
    }
    final result = await service.verify(pin.text);
    pin.dispose();
    if (!context.mounted) return false;
    if (result == PinVerification.verified) {
      return true;
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            result == PinVerification.locked
                ? featureText(
                    context,
                    vi: 'Đã khóa thử lại trong 30 giây.',
                    en: 'Retries are locked for 30 seconds.',
                  )
                : featureText(
                    context,
                    vi: 'PIN không đúng.',
                    en: 'Incorrect PIN.',
                  ),
          ),
        ),
      );
      return false;
    }
  }
}

class _Checklist extends StatelessWidget {
  const _Checklist({required this.note, required this.title});

  final Note note;
  final String title;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: colors.outlineVariant),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.checklist_rounded, color: colors.onSurface),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  color: colors.onSurface,
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
                    color: item.isDone ? colors.primary : colors.outline,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      item.text,
                      style: TextStyle(
                        color: item.isDone
                            ? colors.onSurfaceVariant
                            : colors.onSurface,
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
