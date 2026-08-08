import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/notes/domain/note_repository.dart';
import '../features/notes/presentation/home_screen.dart';
import '../features/notes/presentation/library_screens.dart';
import '../features/notes/presentation/note_detail_screen.dart';
import '../features/notes/presentation/note_editor_screen.dart';
import '../features/settings/presentation/settings_screen.dart';
import '../features/settings/data/app_settings_repository.dart';
import 'app_theme.dart';
import 'app_keys.dart';
import 'providers.dart';
import '../l10n/app_localizations.dart';

class SmartNoteApp extends StatelessWidget {
  const SmartNoteApp({super.key, required this.repository, this.settingsStore});

  final NoteRepository repository;
  final AppSettingsStore? settingsStore;

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      overrides: [
        noteRepositoryProvider.overrideWithValue(repository),
        if (settingsStore != null)
          appSettingsStoreProvider.overrideWithValue(settingsStore!),
      ],
      child: const _SmartNoteRouterApp(),
    );
  }
}

class _SmartNoteRouterApp extends ConsumerStatefulWidget {
  const _SmartNoteRouterApp();

  @override
  ConsumerState<_SmartNoteRouterApp> createState() =>
      _SmartNoteRouterAppState();
}

class _SmartNoteRouterAppState extends ConsumerState<_SmartNoteRouterApp> {
  late final GoRouter _router = GoRouter(
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) =>
            const AppShell(selectedIndex: 0, child: HomeScreen()),
      ),
      GoRoute(
        path: '/search',
        builder: (context, state) =>
            const AppShell(selectedIndex: 1, child: SearchScreen()),
      ),
      GoRoute(
        path: '/favorites',
        builder: (context, state) =>
            const AppShell(selectedIndex: 2, child: FavoritesScreen()),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) =>
            const AppShell(selectedIndex: 3, child: SettingsScreen()),
      ),
      GoRoute(
        path: '/notes/:id',
        builder: (context, state) =>
            NoteDetailScreen(noteId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/editor',
        builder: (context, state) => const NoteEditorScreen(),
      ),
      GoRoute(
        path: '/editor/:id',
        builder: (context, state) =>
            NoteEditorScreen(noteId: state.pathParameters['id']),
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      scaffoldMessengerKey: scaffoldMessengerKey,
      title: 'SmartNote',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ref.watch(themeModeProvider),
      locale: ref.watch(localeProvider),
      supportedLocales: const [Locale('vi'), Locale('en')],
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      routerConfig: _router,
    );
  }
}

class AppShell extends ConsumerWidget {
  const AppShell({super.key, required this.selectedIndex, required this.child});

  final int selectedIndex;
  final Widget child;

  static const _paths = ['/', '/search', '/favorites', '/settings'];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isWide = MediaQuery.sizeOf(context).width >= 700;
    final l10n = AppLocalizations.of(context);
    final destinations = [
      NavigationDestination(
        icon: const Icon(Icons.home_outlined),
        selectedIcon: const Icon(Icons.home_rounded),
        label: l10n.home,
      ),
      NavigationDestination(
        icon: const Icon(Icons.search_rounded),
        label: l10n.search,
      ),
      NavigationDestination(
        icon: const Icon(Icons.favorite_border_rounded),
        selectedIcon: const Icon(Icons.favorite_rounded),
        label: l10n.favorites,
      ),
      NavigationDestination(
        icon: const Icon(Icons.settings_outlined),
        selectedIcon: const Icon(Icons.settings_rounded),
        label: l10n.settings,
      ),
    ];

    if (isWide) {
      return Scaffold(
        body: Row(
          children: [
            NavigationRail(
              selectedIndex: selectedIndex,
              onDestinationSelected: (index) => context.go(_paths[index]),
              labelType: NavigationRailLabelType.all,
              destinations: destinations
                  .map(
                    (item) => NavigationRailDestination(
                      icon: item.icon,
                      selectedIcon: item.selectedIcon,
                      label: Text(item.label),
                    ),
                  )
                  .toList(),
            ),
            const VerticalDivider(width: 1),
            Expanded(child: child),
          ],
        ),
      );
    }

    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: (index) => context.go(_paths[index]),
        destinations: destinations,
      ),
    );
  }
}
