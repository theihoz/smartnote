import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../l10n/feature_text.dart';
import '../domain/note.dart';

class TrashScreen extends ConsumerStatefulWidget {
  const TrashScreen({super.key});

  @override
  ConsumerState<TrashScreen> createState() => _TrashScreenState();
}

class _TrashScreenState extends ConsumerState<TrashScreen> {
  late Future<List<Note>> _notes = _load();

  Future<List<Note>> _load() async {
    final repository = ref.read(trashNoteRepositoryProvider);
    if (repository == null) return const [];
    await repository.purgeExpiredTrash(DateTime.now());
    return repository.listTrash();
  }

  Future<void> _restore(String id) async {
    await ref.read(trashNoteRepositoryProvider)?.restoreFromTrash(id);
    await ref.read(notesControllerProvider.notifier).load();
    setState(() => _notes = _load());
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          featureText(context, vi: 'Ghi chú đã xóa', en: 'Deleted notes'),
        ),
      ),
      body: FutureBuilder<List<Note>>(
        future: _notes,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          final notes = snapshot.data ?? const [];
          if (notes.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.delete_sweep_outlined, size: 64),
                    const SizedBox(height: 12),
                    Text(
                      featureText(
                        context,
                        vi: 'Thùng rác đang trống',
                        en: 'Trash is empty',
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      featureText(
                        context,
                        vi: 'Ghi chú sẽ tự xóa vĩnh viễn sau 30 ngày.',
                        en: 'Notes are permanently deleted after 30 days.',
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(18),
            itemCount: notes.length,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final note = notes[index];
              return Card(
                child: Material(
                  type: MaterialType.transparency,
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: colors.errorContainer,
                      child: Icon(
                        Icons.delete_outline,
                        color: colors.onErrorContainer,
                      ),
                    ),
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
                      featureText(
                        context,
                        vi: 'Tự xóa sau 30 ngày',
                        en: 'Deletes automatically after 30 days',
                      ),
                    ),
                    trailing: FilledButton.tonalIcon(
                      onPressed: () => _restore(note.id),
                      icon: const Icon(Icons.restore_rounded),
                      label: Text(
                        featureText(context, vi: 'Khôi phục', en: 'Restore'),
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
