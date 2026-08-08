import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app/smartnote_app.dart';
import 'features/notes/data/smartnote_database.dart';
import 'features/notes/data/sqlite_note_repository.dart';
import 'features/notes/domain/note.dart';
import 'features/sync/data/cloud_note_store.dart';
import 'features/sync/data/outbox_sync_service.dart';
import 'features/sync/data/supabase_config.dart';
import 'features/settings/data/app_settings_repository.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final preferences = await SharedPreferences.getInstance();
  final settingsStore = AppSettingsRepository(preferences);
  final database = await openSmartNoteDatabase();
  final repository = SqliteNoteRepository(database);
  await _seedDemoNotes(repository);

  final config = SupabaseConfig.fromEnvironment();
  if (config != null) {
    try {
      await Supabase.initialize(
        url: config.url,
        publishableKey: config.publishableKey,
      );
      final client = Supabase.instance.client;
      if (client.auth.currentSession == null) {
        await client.auth.signInAnonymously();
      }
      await OutboxSyncService(
        database: database,
        notes: repository,
        cloud: SupabaseCloudNoteStore(client),
      ).syncPending();
    } catch (_) {
      // Local SQLite remains fully functional when cloud is unavailable.
    }
  }

  runApp(SmartNoteApp(repository: repository, settingsStore: settingsStore));
}

Future<void> _seedDemoNotes(SqliteNoteRepository repository) async {
  if ((await repository.list()).isNotEmpty) return;
  final now = DateTime.now();
  await repository.save(
    Note(
      id: 'demo-dalat',
      title: 'Lịch trình du lịch Đà Lạt',
      body:
          'Lịch trình ngày 1 dự kiến sẽ bắt đầu bằng việc đi ăn bánh mì '
          'xíu mại Hoàng Diệu ngay sau khi nhận phòng. Buổi chiều ghé '
          'Cà phê Túi Mơ To để ngắm hoàng hôn.',
      kind: NoteKind.checklist,
      checklist: const [
        ChecklistItem(
          id: 'demo-item-1',
          text: 'Đặt vé máy bay / xe khách',
          isDone: true,
          position: 0,
        ),
        ChecklistItem(
          id: 'demo-item-2',
          text: 'Thuê homestay gần trung tâm',
          isDone: true,
          position: 1,
        ),
        ChecklistItem(
          id: 'demo-item-3',
          text: 'Lên danh sách quán ăn ngon',
          isDone: false,
          position: 2,
        ),
      ],
      tags: const ['Cá nhân', 'Du lịch'],
      isFavorite: true,
      colorKey: 'lavender',
      imagePaths: const ['assets/images/dalat_food.jpg'],
      createdAt: now.subtract(const Duration(days: 2)),
      updatedAt: now,
    ),
  );
  await repository.save(
    Note(
      id: 'demo-flutter',
      title: 'Ôn tập Flutter',
      body: 'Riverpod, GoRouter, SQLite và Material Design 3.',
      kind: NoteKind.text,
      checklist: const [],
      tags: const ['Học tập'],
      isFavorite: false,
      colorKey: 'sage',
      imagePaths: const [],
      createdAt: now.subtract(const Duration(days: 4)),
      updatedAt: now.subtract(const Duration(hours: 3)),
    ),
  );
}
