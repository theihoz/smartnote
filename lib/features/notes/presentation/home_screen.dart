import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/app_theme.dart';
import '../../../app/providers.dart';
import '../../../l10n/app_localizations.dart';
import '../../../l10n/feature_text.dart';
import '../domain/note_query.dart';
import 'note_widgets.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(notesControllerProvider);
    final l10n = AppLocalizations.of(context);
    final notes = state.visibleNotes;
    final activeTag = state.query.tag;
    final taskCount = state.allNotes
        .expand((note) => note.checklist)
        .where((item) => !item.isDone)
        .length;

    return SafeArea(
      child: Stack(
        children: [
          RefreshIndicator(
            onRefresh: () => ref.read(notesControllerProvider.notifier).load(),
            child: CustomScrollView(
              slivers: [
                // Top AppBar Header
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(18, 14, 18, 8),
                  sliver: SliverToBoxAdapter(
                    child: Row(
                      children: [
                        const CircleAvatar(
                          radius: 18,
                          backgroundColor: AppTheme.peach,
                          child: Icon(
                            Icons.person_rounded,
                            color: AppTheme.coral,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'SmartNote',
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.primary,
                                      fontWeight: FontWeight.w800,
                                    ),
                              ),
                              Text(
                                featureText(
                                  context,
                                  vi: 'Ghi chú của bạn',
                                  en: 'Your notes',
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Team Members Glass Hero Card Banner (Synced with CANVAS_DESIGN_UI.md)
                const SliverPadding(
                  padding: EdgeInsets.fromLTRB(18, 10, 18, 12),
                  sliver: SliverToBoxAdapter(child: _TeamHeroBannerCard()),
                ),

                // Inspiration Quote Card
                const SliverPadding(
                  padding: EdgeInsets.fromLTRB(18, 0, 18, 12),
                  sliver: SliverToBoxAdapter(child: _InspirationCard()),
                ),

                // Tag Filter Chips Carousel (Synced with NotesController backend query)
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: 48,
                    child: ListView(
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                      scrollDirection: Axis.horizontal,
                      children: [
                        _TagChip(
                          label: l10n.all,
                          isSelected: activeTag == null,
                          onSelected: () {
                            ref
                                .read(notesControllerProvider.notifier)
                                .setQuery(
                                  state.query.copyWithTag(clearTag: true),
                                );
                          },
                        ),
                        for (final tag in [
                          'Study',
                          'Projects',
                          'Ideas',
                          'Personal',
                        ])
                          _TagChip(
                            label: _translateTag(context, tag),
                            isSelected: activeTag == tag,
                            onSelected: () {
                              ref
                                  .read(notesControllerProvider.notifier)
                                  .setQuery(state.query.copyWithTag(tag: tag));
                            },
                          ),
                      ],
                    ),
                  ),
                ),

                // Section Header & Controls
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(18, 14, 18, 10),
                  sliver: SliverToBoxAdapter(
                    child: Row(
                      children: [
                        Flexible(
                          child: Text(
                            l10n.recentNotes,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (taskCount > 0)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.peach,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.task_alt_rounded,
                                  size: 15,
                                  color: AppTheme.coral,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  l10n.taskCount(taskCount),
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: AppTheme.coral,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        const Spacer(),
                        IconButton(
                          onPressed: () {},
                          icon: const Icon(Icons.grid_view_rounded),
                        ),
                      ],
                    ),
                  ),
                ),

                // Note Grid / List
                if (state.isLoading && notes.isEmpty)
                  const SliverFillRemaining(
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (notes.isEmpty)
                  const SliverFillRemaining(
                    hasScrollBody: false,
                    child: _EmptyNotes(),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(18, 0, 18, 100),
                    sliver: SliverGrid(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final note = notes[index];
                        return Hero(
                          tag: 'note-${note.id}',
                          child: NoteCard(
                            note: note,
                            onFavorite: () => ref
                                .read(notesControllerProvider.notifier)
                                .toggleFavorite(note.id),
                          ),
                        );
                      }, childCount: notes.length),
                      gridDelegate:
                          const SliverGridDelegateWithMaxCrossAxisExtent(
                            maxCrossAxisExtent: 280,
                            mainAxisExtent: 260,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                          ),
                    ),
                  ),
              ],
            ),
          ),

          // Floating Action Button
          Positioned(
            right: 22,
            bottom: 22,
            child: FloatingActionButton.large(
              key: const Key('create-note-fab'),
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              onPressed: () => context.push('/editor'),
              child: const Icon(Icons.add_rounded, size: 36),
            ),
          ),
        ],
      ),
    );
  }
}

class _TagChip extends StatelessWidget {
  const _TagChip({
    required this.label,
    required this.isSelected,
    required this.onSelected,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        selected: isSelected,
        showCheckmark: false,
        backgroundColor: theme.colorScheme.surfaceContainerHighest.withValues(
          alpha: 0.5,
        ),
        selectedColor: theme.colorScheme.primary,
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : theme.colorScheme.onSurfaceVariant,
          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        side: BorderSide.none,
        label: Text(label),
        onSelected: (_) => onSelected(),
      ),
    );
  }
}

String _translateTag(BuildContext context, String tag) {
  final l10n = AppLocalizations.of(context);
  switch (tag.toLowerCase()) {
    case 'study':
      return l10n.study;
    case 'projects':
    case 'project':
      return l10n.project;
    case 'ideas':
    case 'idea':
      return l10n.idea;
    case 'personal':
      return l10n.personal;
    default:
      return tag;
  }
}

extension _NoteQueryCopy on NoteQuery {
  NoteQuery copyWithTag({String? tag, bool clearTag = false}) {
    return NoteQuery(
      searchText: searchText,
      tag: clearTag ? null : tag ?? this.tag,
      favoritesOnly: favoritesOnly,
      kind: kind,
      sort: sort,
    );
  }
}

class _TeamHeroBannerCard extends StatelessWidget {
  const _TeamHeroBannerCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF5A5791), Color(0xFF423F78)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF423F78).withValues(alpha: 0.25),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Bài Giữa Kỳ',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              const Spacer(),
              const Icon(
                Icons.auto_awesome_rounded,
                color: Color(0xFFFFDAD7),
                size: 20,
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'SmartNote',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Thành viên: Diệp Yến Khoa • Nguyễn Trương Diễm Quỳnh • Trần Thái Hòa',
            style: TextStyle(
              color: Color(0xFFE3DFFF),
              fontSize: 13,
              fontWeight: FontWeight.w500,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFFDAD7),
              foregroundColor: const Color(0xFF423F78),
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            onPressed: () => context.push('/editor'),
            icon: const Icon(Icons.add_circle_outline_rounded, size: 18),
            label: const Text(
              'Tạo ghi chú ngay',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}

class _InspirationCard extends ConsumerWidget {
  const _InspirationCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final quote = ref.watch(quoteProvider);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Theme.of(
            context,
          ).colorScheme.outlineVariant.withValues(alpha: 0.3),
        ),
      ),
      child: quote.when(
        loading: () => Row(
          children: [
            const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(AppLocalizations.of(context).inspirationLoading),
            ),
          ],
        ),
        error: (_, _) => Row(
          children: [
            Expanded(
              child: Text(AppLocalizations.of(context).inspirationError),
            ),
            IconButton(
              tooltip: AppLocalizations.of(context).retry,
              onPressed: () => ref.invalidate(quoteProvider),
              icon: const Icon(Icons.refresh_rounded),
            ),
          ],
        ),
        data: (quote) => Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.format_quote_rounded,
              color: Theme.of(context).colorScheme.primary,
              size: 26,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '“${quote.text}”',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    AppLocalizations.of(context).quoteAuthor(quote.author),
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
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
}

class _EmptyNotes extends StatelessWidget {
  const _EmptyNotes();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.note_add_outlined,
              size: 64,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              AppLocalizations.of(context).emptyNotesTitle,
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
            ),
            const SizedBox(height: 6),
            Text(
              AppLocalizations.of(context).emptyNotesBody,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppTheme.muted),
            ),
          ],
        ),
      ),
    );
  }
}
