import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/app_theme.dart';
import '../../../app/providers.dart';
import '../../../l10n/app_localizations.dart';
import 'note_widgets.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(notesControllerProvider);
    final l10n = AppLocalizations.of(context);
    final notes = state.visibleNotes;
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
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(18, 14, 18, 8),
                  sliver: SliverToBoxAdapter(
                    child: Row(
                      children: [
                        Text(
                          'SmartNote',
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(
                                color: AppTheme.indigo,
                                fontWeight: FontWeight.w800,
                              ),
                        ),
                        const Spacer(),
                        const _SyncBadge(),
                        const SizedBox(width: 8),
                        const CircleAvatar(
                          radius: 20,
                          backgroundColor: AppTheme.peach,
                          child: Icon(
                            Icons.person_outline_rounded,
                            color: AppTheme.ink,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(18, 14, 18, 8),
                  sliver: SliverToBoxAdapter(
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.greeting,
                                style: Theme.of(context).textTheme.titleLarge
                                    ?.copyWith(fontWeight: FontWeight.w700),
                              ),
                              Text(
                                l10n.homeSubtitle,
                                style: TextStyle(color: AppTheme.muted),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 9,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.peach,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.task_alt_rounded,
                                size: 19,
                                color: AppTheme.coral,
                              ),
                              const SizedBox(width: 7),
                              Text(
                                l10n.taskCount(taskCount),
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SliverPadding(
                  padding: EdgeInsets.fromLTRB(18, 12, 18, 8),
                  sliver: SliverToBoxAdapter(child: _InspirationCard()),
                ),
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: 52,
                    child: ListView(
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                      scrollDirection: Axis.horizontal,
                      children: [
                        for (final tag in [
                          l10n.all,
                          l10n.study,
                          l10n.project,
                          l10n.idea,
                          l10n.personal,
                        ])
                          Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: FilterChip(
                              selected: tag == 'Tất cả',
                              label: Text(tag),
                              onSelected: (_) {},
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(18, 8, 18, 12),
                  sliver: SliverToBoxAdapter(
                    child: Row(
                      children: [
                        Text(
                          l10n.recentNotes,
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        const Spacer(),
                        IconButton(
                          onPressed: () {},
                          icon: const Icon(Icons.grid_view_rounded),
                        ),
                        IconButton(
                          onPressed: () {},
                          icon: const Icon(Icons.swap_vert_rounded),
                        ),
                      ],
                    ),
                  ),
                ),
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
                            mainAxisExtent: 334,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                          ),
                    ),
                  ),
              ],
            ),
          ),
          Positioned(
            right: 22,
            bottom: 22,
            child: FloatingActionButton.large(
              key: const Key('create-note-fab'),
              onPressed: () => context.push('/editor'),
              child: const Icon(Icons.add_rounded),
            ),
          ),
        ],
      ),
    );
  }
}

class _SyncBadge extends StatelessWidget {
  const _SyncBadge();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppTheme.lavender,
        borderRadius: BorderRadius.circular(999),
      ),
      child: const Padding(
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        child: Row(
          children: [
            Icon(Icons.cloud_done_outlined, size: 16, color: AppTheme.indigo),
            SizedBox(width: 5),
            Text(
              'Đã lưu',
              style: TextStyle(
                color: AppTheme.indigo,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
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
        color: AppTheme.lavender,
        borderRadius: BorderRadius.circular(20),
      ),
      child: quote.when(
        loading: () => Row(
          children: [
            SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            SizedBox(width: 12),
            Text(AppLocalizations.of(context).inspirationLoading),
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
            const Icon(Icons.auto_awesome_rounded, color: AppTheme.indigo),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '“${quote.text}”',
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    AppLocalizations.of(context).quoteAuthor(quote.author),
                    style: const TextStyle(
                      color: AppTheme.indigo,
                      fontSize: 12,
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
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.note_add_outlined, size: 64, color: AppTheme.indigo),
            SizedBox(height: 16),
            Text(AppLocalizations.of(context).emptyNotesTitle),
            SizedBox(height: 6),
            Text(
              AppLocalizations.of(context).emptyNotesBody,
              style: TextStyle(color: AppTheme.muted),
            ),
          ],
        ),
      ),
    );
  }
}
