import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

import '../../../app/providers.dart';
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
    return Scaffold(
      appBar: AppBar(
        title: Text(_original == null ? 'Ghi chú mới' : 'Chỉnh sửa'),
        actions: [
          TextButton(
            key: const Key('save-note-button'),
            onPressed: _save,
            child: const Text('Lưu'),
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
                  TextField(
                    controller: _titleController,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                    decoration: const InputDecoration(
                      hintText: 'Tiêu đề',
                      filled: false,
                      border: InputBorder.none,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SegmentedButton<NoteKind>(
                    segments: const [
                      ButtonSegment(
                        value: NoteKind.text,
                        icon: Icon(Icons.notes_rounded),
                        label: Text('Văn bản'),
                      ),
                      ButtonSegment(
                        value: NoteKind.checklist,
                        icon: Icon(Icons.checklist_rounded),
                        label: Text('Checklist'),
                      ),
                    ],
                    selected: {_kind},
                    onSelectionChanged: (value) =>
                        setState(() => _kind = value.single),
                  ),
                  const SizedBox(height: 18),
                  if (_kind == NoteKind.text)
                    TextField(
                      controller: _bodyController,
                      minLines: 10,
                      maxLines: null,
                      decoration: const InputDecoration(
                        hintText: 'Bắt đầu viết...',
                        alignLabelWithHint: true,
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
                        color: Theme.of(context).colorScheme.error,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                  if (_images.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Text('${_images.length} ảnh đã đính kèm'),
                  ],
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                boxShadow: const [
                  BoxShadow(color: Colors.black12, blurRadius: 18),
                ],
              ),
              child: Row(
                children: [
                  IconButton(
                    tooltip: 'Máy ảnh',
                    onPressed: () => _pick(ImageSource.camera),
                    icon: const Icon(Icons.photo_camera_outlined),
                  ),
                  IconButton(
                    tooltip: 'Thư viện',
                    onPressed: () => _pick(ImageSource.gallery),
                    icon: const Icon(Icons.image_outlined),
                  ),
                  IconButton(
                    tooltip: 'Tag',
                    onPressed: () {},
                    icon: const Icon(Icons.sell_outlined),
                  ),
                  IconButton(
                    tooltip: 'Màu',
                    onPressed: () {},
                    icon: const Icon(Icons.palette_outlined),
                  ),
                  const Spacer(),
                  const Text('Tự động lưu cục bộ'),
                ],
              ),
            ),
          ],
        ),
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
    final result = await ref
        .read(notesControllerProvider.notifier)
        .saveDraft(
          NoteDraft(
            title: _titleController.text,
            body: _bodyController.text,
            kind: _kind,
            checklist: _checklist,
            tags: _original?.tags ?? const [],
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
          NoteValidationError.emptyChecklist =>
            'Hãy thêm ít nhất một mục checklist.',
          _ => 'Hãy nhập tiêu đề hoặc nội dung.',
        };
      });
      return;
    }
    context.go('/');
  }
}

class _ChecklistEditor extends StatelessWidget {
  const _ChecklistEditor({required this.items, required this.onChanged});

  final List<ChecklistItem> items;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var index = 0; index < items.length; index++)
          Row(
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
                  decoration: const InputDecoration(hintText: 'Nội dung việc'),
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
        TextButton.icon(
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
          label: const Text('Thêm mục'),
        ),
      ],
    );
  }
}
