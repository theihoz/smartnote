import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

import '../../../app/app_keys.dart';
import '../../../app/app_theme.dart';
import '../../../app/providers.dart';
import '../../../l10n/app_localizations.dart';
import '../domain/note.dart';
import '../domain/note_validator.dart';

class NoteEditorScreen extends ConsumerStatefulWidget {
  const NoteEditorScreen({super.key, this.noteId});

  final String? noteId;

  @override
  ConsumerState<NoteEditorScreen> createState() => _NoteEditorScreenState();
}

class _NoteEditorScreenState extends ConsumerState<NoteEditorScreen> {
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();
  final _checklist = <ChecklistItem>[];
  final _images = <String>[];
  final _tags = <String>[];
  NoteKind _kind = NoteKind.text;
  String? _error;
  Note? _original;
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    _initialized = true;
    if (widget.noteId != null) {
      for (final note in ref.read(notesControllerProvider).allNotes) {
        if (note.id == widget.noteId) {
          _original = note;
          _titleController.text = note.title;
          _bodyController.text = note.body;
          _kind = note.kind;
          _checklist.addAll(note.checklist);
          _images.addAll(note.imagePaths);
          _tags.addAll(note.tags);
        }
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _original == null ? l10n.newNote : l10n.editNote,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: FilledButton.icon(
              key: const Key('save-note-button'),
              style: FilledButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              onPressed: _save,
              icon: const Icon(Icons.save_rounded, size: 18),
              label: Text(l10n.save),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(18, 12, 18, 100),
                children: [
                  // Segmented control (Text vs Checklist)
                  SegmentedButton<NoteKind>(
                    segments: [
                      ButtonSegment(
                        value: NoteKind.text,
                        icon: const Icon(Icons.notes_rounded),
                        label: Text(l10n.text),
                      ),
                      ButtonSegment(
                        value: NoteKind.checklist,
                        icon: const Icon(Icons.checklist_rounded),
                        label: Text(l10n.taskList),
                      ),
                    ],
                    selected: {_kind},
                    onSelectionChanged: (value) =>
                        setState(() => _kind = value.single),
                  ),
                  const SizedBox(height: 16),

                  // Title TextField
                  TextField(
                    controller: _titleController,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                    decoration: InputDecoration(
                      hintText: l10n.titleHint,
                      filled: false,
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Metadata & Attachment Chips
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      if (_images.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.peach,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.image_rounded,
                                size: 14,
                                color: AppTheme.coral,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${_images.length} hình ảnh đính kèm',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.coral,
                                ),
                              ),
                            ],
                          ),
                        ),
                      for (final tag in _tags)
                        Chip(
                          visualDensity: VisualDensity.compact,
                          label: Text(tag),
                          onDeleted: () => setState(() => _tags.remove(tag)),
                        ),
                      ActionChip(
                        avatar: const Icon(Icons.add_rounded, size: 16),
                        label: const Text('Thêm thẻ'),
                        onPressed: _showAddTagDialog,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Image attachments preview grid
                  if (_images.isNotEmpty) ...[
                    SizedBox(
                      height: 100,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _images.length,
                        itemBuilder: (context, index) {
                          final path = _images[index];
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(14),
                                  child: SizedBox(
                                    width: 100,
                                    height: 100,
                                    child: _EditorImage(path: path),
                                  ),
                                ),
                                Positioned(
                                  top: 4,
                                  right: 4,
                                  child: GestureDetector(
                                    onTap: () => setState(() => _images.removeAt(index)),
                                    child: Container(
                                      padding: const EdgeInsets.all(2),
                                      decoration: const BoxDecoration(
                                        color: Colors.black54,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.close_rounded,
                                        size: 16,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Body input or Checklist Editor
                  if (_kind == NoteKind.text)
                    TextField(
                      controller: _bodyController,
                      minLines: 12,
                      maxLines: null,
                      style: const TextStyle(fontSize: 16, height: 1.5),
                      decoration: InputDecoration(
                        hintText: l10n.bodyHint,
                        border: InputBorder.none,
                        filled: false,
                      ),
                    )
                  else
                    _ChecklistEditor(
                      items: _checklist,
                      onChanged: () => setState(() {}),
                    ),

                  if (_error != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      _error!,
                      style: TextStyle(
                        color: theme.colorScheme.error,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Bottom Tool Ribbon Bar (Synced with CANVAS_DESIGN_UI.md)
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHigh.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                  color: theme.colorScheme.outlineVariant.withValues(alpha: 0.4),
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 16,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  IconButton(
                    tooltip: l10n.camera,
                    onPressed: () => _pick(ImageSource.camera),
                    icon: const Icon(Icons.photo_camera_outlined),
                  ),
                  IconButton(
                    tooltip: l10n.gallery,
                    onPressed: () => _pick(ImageSource.gallery),
                    icon: const Icon(Icons.image_outlined),
                  ),
                  IconButton(
                    tooltip: l10n.addLabel,
                    onPressed: _showAddTagDialog,
                    icon: const Icon(Icons.label_outline_rounded),
                  ),
                  IconButton(
                    tooltip: l10n.chooseColor,
                    onPressed: () {},
                    icon: const Icon(Icons.palette_outlined),
                  ),
                  const Spacer(),
                  const Icon(
                    Icons.cloud_done_outlined,
                    size: 16,
                    color: AppTheme.indigo,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    l10n.savedOnDevice,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.indigo,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddTagDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Thêm thẻ ghi chú'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Tên thẻ (vd: Study, Projects)'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          FilledButton(
            onPressed: () {
              final tag = controller.text.trim();
              if (tag.isNotEmpty && !_tags.contains(tag)) {
                setState(() => _tags.add(tag));
              }
              Navigator.pop(context);
            },
            child: const Text('Thêm'),
          ),
        ],
      ),
    );
  }

  Future<void> _pick(ImageSource source) async {
    final image = await ImagePicker().pickImage(
      source: source,
      imageQuality: 85,
    );
    if (image != null) setState(() => _images.add(image.path));
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context);
    final controller = ref.read(notesControllerProvider.notifier);
    final result = await controller.saveDraft(
      NoteDraft(
        title: _titleController.text,
        body: _bodyController.text,
        kind: _kind,
        checklist: _checklist,
        tags: _tags,
        colorKey: _original?.colorKey ?? 'lavender',
        imagePaths: _images,
        isFavorite: _original?.isFavorite ?? false,
      ),
      id: _original?.id,
      createdAt: _original?.createdAt,
    );
    if (!mounted) return;
    if (!result.isValid) {
      setState(() {
        _error = switch (result.generalError) {
          NoteValidationError.emptyChecklist => l10n.emptyChecklistError,
          _ => l10n.emptyNoteError,
        };
      });
      return;
    }
    context.go('/');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      scaffoldMessengerKey.currentState?.showSnackBar(
        SnackBar(
          content: Text(
            _original == null ? l10n.createdNote : l10n.updatedNote,
          ),
          action: SnackBarAction(label: l10n.undo, onPressed: controller.undo),
        ),
      );
    });
  }
}

class _EditorImage extends StatelessWidget {
  const _EditorImage({required this.path});

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

class _ChecklistEditor extends StatelessWidget {
  const _ChecklistEditor({required this.items, required this.onChanged});

  final List<ChecklistItem> items;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      children: [
        for (var index = 0; index < items.length; index++)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Checkbox(
                  value: items[index].isDone,
                  onChanged: (value) {
                    items[index] = items[index].copyWith(isDone: value ?? false);
                    onChanged();
                  },
                ),
                Expanded(
                  child: TextFormField(
                    initialValue: items[index].text,
                    onChanged: (value) {
                      items[index] = items[index].copyWith(text: value);
                    },
                    decoration: InputDecoration(hintText: l10n.taskHint),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    items.removeAt(index);
                    onChanged();
                  },
                  icon: const Icon(Icons.close_rounded),
                ),
              ],
            ),
          ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: () {
            items.add(
              ChecklistItem(
                id: const Uuid().v4(),
                text: '',
                isDone: false,
                position: items.length,
              ),
            );
            onChanged();
          },
          icon: const Icon(Icons.add_rounded),
          label: Text(l10n.addTask),
        ),
      ],
    );
  }
}
