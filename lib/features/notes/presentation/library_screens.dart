import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../domain/note_query.dart';
import 'note_widgets.dart';

class SearchScreen extends ConsumerWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(notesControllerProvider);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tìm kiếm',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 16),
            TextField(
              key: const Key('search-field'),
              autofocus: false,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search_rounded),
                hintText: 'Tiêu đề hoặc nội dung...',
                suffixIcon: Icon(Icons.tune_rounded),
              ),
              onChanged: (value) => ref
                  .read(notesControllerProvider.notifier)
                  .setQuery(NoteQuery(searchText: value)),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: state.visibleNotes.isEmpty
                  ? const Center(child: Text('Không tìm thấy ghi chú phù hợp.'))
                  : GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithMaxCrossAxisExtent(
                            maxCrossAxisExtent: 300,
                            mainAxisExtent: 334,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                          ),
                      itemCount: state.visibleNotes.length,
                      itemBuilder: (context, index) {
                        final note = state.visibleNotes[index];
                        return NoteCard(
                          note: note,
                          onFavorite: () => ref
                              .read(notesControllerProvider.notifier)
                              .toggleFavorite(note.id),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notes = ref
        .watch(notesControllerProvider)
        .allNotes
        .where((note) => note.isFavorite)
        .toList();
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Yêu thích',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: notes.isEmpty
                  ? const Center(
                      child: Text(
                        'Những ghi chú yêu thích sẽ xuất hiện ở đây.',
                      ),
                    )
                  : GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithMaxCrossAxisExtent(
                            maxCrossAxisExtent: 300,
                            mainAxisExtent: 334,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                          ),
                      itemCount: notes.length,
                      itemBuilder: (context, index) {
                        final note = notes[index];
                        return NoteCard(
                          note: note,
                          onFavorite: () => ref
                              .read(notesControllerProvider.notifier)
                              .toggleFavorite(note.id),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
