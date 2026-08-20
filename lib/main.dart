import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import 'app/smartnote_app.dart';
import 'features/notes/data/smartnote_database.dart';
import 'features/notes/data/sqlite_note_repository.dart';
import 'features/notes/domain/note.dart';
import 'features/sync/data/api_config.dart';
import 'features/sync/data/logging_http_client.dart';
import 'features/sync/data/outbox_sync_service.dart';
import 'features/sync/data/rest_cloud_note_store.dart';
import 'features/settings/data/app_settings_repository.dart';
import 'features/security/data/pin_lock_service.dart';
import 'features/reminders/data/local_notification_scheduler.dart';
import 'features/reminders/data/sqlite_reminder_repository.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final preferences = await SharedPreferences.getInstance();
  final settingsStore = AppSettingsRepository(preferences);
  final database = await openSmartNoteDatabase();
  final repository = SqliteNoteRepository(database);
  final reminderScheduler = LocalNotificationScheduler();
  await reminderScheduler.initialize();
  await _seedDemoNotes(repository);

  const deviceIdKey = 'smartnote.device_id';
  var deviceId = preferences.getString(deviceIdKey);
  if (deviceId == null) {
    deviceId = const Uuid().v4();
    await preferences.setString(deviceIdKey, deviceId);
  }
  final config = ApiConfig.fromEnvironment();
  final syncOnStartup = config == null
      ? null
      : () => OutboxSyncService(
          database: database,
          notes: repository,
          cloud: RestCloudNoteStore(
            LoggingHttpClient(http.Client()),
            baseUrl: config.baseUrl,
            deviceId: deviceId!,
          ),
        ).syncPending();
  if (config == null) {
    developer.log(
      'API_BASE_URL is not configured; running local-only.',
      name: 'smartnote.api',
    );
  }

  runApp(
    SmartNoteApp(
      repository: repository,
      settingsStore: settingsStore,
      syncOnStartup: syncOnStartup,
      pinLockService: PinLockService(preferences),
      reminderRepository: SqliteReminderRepository(database),
      reminderScheduler: reminderScheduler,
    ),
  );
}

Future<void> _seedDemoNotes(SqliteNoteRepository repository) async {
  if ((await repository.list()).isNotEmpty) return;
  final now = DateTime.now();
  await repository.save(
    Note(
      id: '00000000-0000-4000-8000-000000000001',
      title: 'Lịch trình du lịch Đà Lạt',
      body:
          'Lịch trình ngày 1 dự kiến sẽ bắt đầu bằng việc đi ăn bánh mì '
          'xíu mại Hoàng Diệu ngay sau khi nhận phòng. Buổi chiều ghé '
          'Cà phê Túi Mơ To để ngắm hoàng hôn.',
      kind: NoteKind.checklist,
      checklist: const [
        ChecklistItem(
          id: '00000000-0000-4000-8000-000000000011',
          text: 'Đặt vé máy bay / xe khách',
          isDone: true,
          position: 0,
        ),
        ChecklistItem(
          id: '00000000-0000-4000-8000-000000000012',
          text: 'Thuê homestay gần trung tâm',
          isDone: true,
          position: 1,
        ),
        ChecklistItem(
          id: '00000000-0000-4000-8000-000000000013',
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
      id: '00000000-0000-4000-8000-000000000002',
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
