import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../l10n/feature_text.dart';
import '../features/notes/domain/note_repository.dart';
import '../features/notes/domain/note_draft_repository.dart';
import '../features/notes/presentation/home_screen.dart';
import '../features/notes/presentation/library_screens.dart';
import '../features/notes/presentation/note_detail_screen.dart';
import '../features/notes/presentation/note_editor_screen.dart';
import '../features/notes/presentation/trash_screen.dart';
import '../features/export/presentation/export_screen.dart';
import '../features/settings/presentation/settings_screen.dart';
import '../features/settings/data/app_settings_repository.dart';
import '../features/security/data/pin_lock_service.dart';
import '../features/security/presentation/security_screen.dart';
import '../features/reminders/data/local_notification_scheduler.dart';
import '../features/reminders/domain/note_reminder.dart';
import '../features/auth/application/auth_controller.dart';
import '../features/auth/presentation/auth_screen.dart';
import 'app_theme.dart';
import 'app_keys.dart';
import 'providers.dart';
import '../l10n/app_localizations.dart';

class SmartNoteApp extends StatelessWidget {
  const SmartNoteApp({
    super.key,
    required this.repository,
    this.settingsStore,
    this.draftRepository,
    this.syncOnStartup,
    this.pinLockService,
    this.reminderRepository,
    this.reminderScheduler,
    this.authController,
  });

  final NoteRepository repository;
  final AppSettingsStore? settingsStore;
  final NoteDraftRepository? draftRepository;
  final Future<Object?> Function()? syncOnStartup;
  final PinLockService? pinLockService;
  final ReminderRepository? reminderRepository;
  final ReminderScheduler? reminderScheduler;
  final AuthController? authController;

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      overrides: [
        noteRepositoryProvider.overrideWithValue(repository),
        if (settingsStore != null)
          appSettingsStoreProvider.overrideWithValue(settingsStore!),
        if (draftRepository != null)
          noteDraftRepositoryProvider.overrideWithValue(draftRepository),
        if (pinLockService != null)
          pinLockServiceProvider.overrideWithValue(pinLockService),
        if (reminderRepository != null)
          reminderRepositoryProvider.overrideWithValue(reminderRepository),
        if (reminderScheduler != null)
          reminderSchedulerProvider.overrideWithValue(reminderScheduler),
        authEnabledProvider.overrideWithValue(authController != null),
      ],
      child: _SmartNoteRouterApp(
        syncOnStartup: syncOnStartup,
        authController: authController,
      ),
    );
  }
}

class _SmartNoteRouterApp extends ConsumerStatefulWidget {
  const _SmartNoteRouterApp({this.syncOnStartup, this.authController});

  final Future<Object?> Function()? syncOnStartup;
  final AuthController? authController;

  @override
  ConsumerState<_SmartNoteRouterApp> createState() =>
      _SmartNoteRouterAppState();
}

class _SmartNoteRouterAppState extends ConsumerState<_SmartNoteRouterApp> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await widget.syncOnStartup?.call();
      if (mounted) await ref.read(notesControllerProvider.notifier).load();
    });
  }

  late final GoRouter _router = GoRouter(
    refreshListenable: widget.authController,
    redirect: (context, state) {
      if (widget.authController != null &&
          widget.authController!.session == null &&
          state.uri.path != '/auth') {
        return '/auth';
      }
      return null;
    },
    routes: [
      GoRoute(
        path: '/auth',
        builder: (context, state) => widget.authController == null
            ? Scaffold(
                body: Center(
                  child: Text(
                    featureText(
                      context,
                      vi: 'Xác thực không khả dụng.',
                      en: 'Authentication is unavailable.',
                    ),
                  ),
                ),
              )
            : AuthScreen(controller: widget.authController!),
      ),
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
        path: '/security',
        builder: (context, state) => const SecurityScreen(),
      ),
      GoRoute(
        path: '/export',
        builder: (context, state) => const ExportScreen(),
      ),
      GoRoute(path: '/trash', builder: (context, state) => const TrashScreen()),
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
