import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';

import '../features/inspiration/data/quote_api_repository.dart';
import '../features/notes/application/notes_controller.dart';
import '../features/notes/domain/note_repository.dart';
import '../features/settings/data/app_settings_repository.dart';
import '../features/auth/data/sync_auth_service.dart';
import '../features/security/data/pin_lock_service.dart';
import '../features/reminders/data/local_notification_scheduler.dart';
import '../features/reminders/domain/note_reminder.dart';

final noteRepositoryProvider = Provider<NoteRepository>(
  (ref) => throw StateError('noteRepositoryProvider must be overridden'),
);

final trashNoteRepositoryProvider = Provider<TrashNoteRepository?>((ref) {
  final repository = ref.watch(noteRepositoryProvider);
  return repository is TrashNoteRepository
      ? repository as TrashNoteRepository
      : null;
});

final appSettingsStoreProvider = Provider<AppSettingsStore>(
  (_) => MemoryAppSettingsStore(),
);

final syncAuthServiceProvider = Provider<SyncAuthService?>((_) => null);
final pinLockServiceProvider = Provider<PinLockService?>((_) => null);
final reminderRepositoryProvider = Provider<ReminderRepository?>((_) => null);
final reminderSchedulerProvider = Provider<ReminderScheduler?>((_) => null);

final notesControllerProvider =
    StateNotifierProvider<NotesController, NotesState>((ref) {
      final controller = NotesController(
        ref.watch(noteRepositoryProvider),
        now: DateTime.now,
        newId: const Uuid().v4,
      );
      controller.load();
      return controller;
    });

final quoteProvider = FutureProvider<Quote>((ref) async {
  final client = http.Client();
  ref.onDispose(client.close);
  return QuoteApiRepository(client).fetchRandom();
});

final themeModeProvider = StateProvider<ThemeMode>(
  (ref) => ref.watch(appSettingsStoreProvider).loadThemeMode(),
);
final localeProvider = StateProvider<Locale>(
  (ref) => ref.watch(appSettingsStoreProvider).loadLocale(),
);
