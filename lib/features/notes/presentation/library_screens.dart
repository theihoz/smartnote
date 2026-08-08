import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../l10n/app_localizations.dart';
import '../domain/note_query.dart';
import 'note_widgets.dart';

class SearchScreen extends ConsumerWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(notesControllerProvider);
    final l10n = AppLocalizations.of(context);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.search,
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 16),
            TextField(
              key: const Key('search-field'),
              autofocus: false,
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.search_rounded),
                hintText: l10n.searchHint,
                suffixIcon: Icon(Icons.tune_rounded),
              ),
              onChanged: (value) => ref
                  .read(notesControllerProvider.notifier)
                  .setQuery(NoteQuery(searchText: value)),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: state.visibleNotes.isEmpty
                  ? Center(child: Text(l10n.noSearchResults))
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
    final l10n = AppLocalizations.of(context);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.favorites,
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: notes.isEmpty
                  ? Center(
                      child: Text(l10n.emptyFavorites),
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
