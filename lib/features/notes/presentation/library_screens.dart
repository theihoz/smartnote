import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../l10n/app_localizations.dart';
import '../../../l10n/feature_text.dart';
import '../domain/note.dart';
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
                prefixIcon: const Icon(Icons.search_rounded),
                hintText: 'Search notes',
                suffixIcon: IconButton(
                  key: const Key('search-filter-button'),
                  onPressed: () => _showFilters(context, ref),
                  icon: const Icon(Icons.tune_rounded),
                ),
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

  Future<void> _showFilters(BuildContext context, WidgetRef ref) async {
    final state = ref.read(notesControllerProvider);
    var favoritesOnly = state.query.favoritesOnly;
    var tag = state.query.tag;
    var kind = state.query.kind;
    var sort = state.query.sort;
    final tags = state.allNotes.expand((note) => note.tags).toSet().toList()
      ..sort();

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  featureText(
                    context,
                    vi: 'Bộ lọc ghi chú',
                    en: 'Note filters',
                  ),
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  value: favoritesOnly,
                  title: Text(
                    featureText(
                      context,
                      vi: 'Chỉ ghi chú yêu thích',
                      en: 'Favorites only',
                    ),
                  ),
                  onChanged: (value) =>
                      setModalState(() => favoritesOnly = value ?? false),
                ),
                DropdownButtonFormField<String?>(
                  initialValue: tag,
                  decoration: InputDecoration(
                    labelText: featureText(context, vi: 'Nhãn', en: 'Tag'),
                  ),
                  items: [
                    DropdownMenuItem<String?>(
                      value: null,
                      child: Text(
                        featureText(context, vi: 'Tất cả', en: 'All'),
                      ),
                    ),
                    ...tags.map(
                      (value) => DropdownMenuItem<String?>(
                        value: value,
                        child: Text(value),
                      ),
                    ),
                  ],
                  onChanged: (value) => setModalState(() => tag = value),
                ),
                const SizedBox(height: 12),
                SegmentedButton<NoteKind?>(
                  segments: [
                    ButtonSegment(
                      value: null,
                      label: Text(
                        featureText(context, vi: 'Tất cả', en: 'All'),
                      ),
                    ),
                    ButtonSegment(
                      value: NoteKind.text,
                      label: Text(
                        featureText(context, vi: 'Văn bản', en: 'Text'),
                      ),
                    ),
                    ButtonSegment(
                      value: NoteKind.checklist,
                      label: Text(
                        featureText(context, vi: 'Công việc', en: 'Tasks'),
                      ),
                    ),
                  ],
                  selected: {kind},
                  onSelectionChanged: (value) =>
                      setModalState(() => kind = value.single),
                ),
                const SizedBox(height: 12),
                RadioGroup<NoteSort>(
                  groupValue: sort,
                  onChanged: (value) => setModalState(() => sort = value!),
                  child: Column(
                    children: [
                      RadioListTile(
                        value: NoteSort.newest,
                        title: Text(
                          featureText(context, vi: 'Mới nhất', en: 'Newest'),
                        ),
                      ),
                      RadioListTile(
                        value: NoteSort.oldest,
                        title: Text(
                          featureText(context, vi: 'Cũ nhất', en: 'Oldest'),
                        ),
                      ),
                      RadioListTile(
                        value: NoteSort.title,
                        title: Text(
                          featureText(
                            context,
                            vi: 'Theo tiêu đề',
                            en: 'By title',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () {
                      ref
                          .read(notesControllerProvider.notifier)
                          .setQuery(
                            NoteQuery(
                              searchText: state.query.searchText,
                              tag: tag,
                              favoritesOnly: favoritesOnly,
                              kind: kind,
                              sort: sort,
                            ),
                          );
                      Navigator.pop(context);
                    },
                    child: Text(
                      featureText(context, vi: 'Áp dụng', en: 'Apply'),
                    ),
                  ),
                ),
              ],
            ),
          ),
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
                  ? Center(child: Text(l10n.emptyFavorites))
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
