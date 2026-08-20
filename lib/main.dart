import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:sqflite/sqflite.dart';

import 'app/smartnote_app.dart';
import 'features/auth/application/auth_controller.dart';
import 'features/auth/data/auth_api_client.dart';
import 'features/auth/data/local_auth_gateway.dart';
import 'features/auth/data/secure_auth_store.dart';
import 'features/notes/data/smartnote_database.dart';
import 'features/notes/data/sqlite_note_repository.dart';
import 'features/notes/data/sqlite_note_draft_repository.dart';
import 'features/notes/domain/note.dart';
import 'features/sync/data/api_config.dart';
import 'features/sync/data/logging_http_client.dart';
import 'features/sync/data/outbox_sync_service.dart';
import 'features/sync/data/rest_cloud_note_store.dart';
import 'features/sync/data/resume_sync_coordinator.dart';
import 'features/settings/data/app_settings_repository.dart';
import 'features/security/data/pin_lock_service.dart';
import 'features/reminders/data/local_notification_scheduler.dart';
import 'features/reminders/data/sqlite_reminder_repository.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final preferences = await SharedPreferences.getInstance();
  final settingsStore = AppSettingsRepository(preferences);
  final reminderScheduler = LocalNotificationScheduler();
  await reminderScheduler.initialize();
  const deviceIdKey = 'smartnote.device_id';
  var deviceId = preferences.getString(deviceIdKey);
  if (deviceId == null) {
    deviceId = const Uuid().v4();
    await preferences.setString(deviceIdKey, deviceId);
  }
  final config = ApiConfig.fromEnvironment();
  if (config == null) {
    developer.log(
      'No remote API configured; using the on-device SQLite database.',
      name: 'smartnote.storage',
    );
  }

  runApp(
    _SmartNoteHost(
      preferences: preferences,
      settingsStore: settingsStore,
      reminderScheduler: reminderScheduler,
      deviceId: deviceId,
      config: config,
    ),
  );
}

class _SmartNoteHost extends StatefulWidget {
  const _SmartNoteHost({
    required this.preferences,
    required this.settingsStore,
    required this.reminderScheduler,
    required this.deviceId,
    required this.config,
  });

  final SharedPreferences preferences;
  final AppSettingsRepository settingsStore;
  final LocalNotificationScheduler reminderScheduler;
  final String deviceId;
  final ApiConfig? config;

  @override
  State<_SmartNoteHost> createState() => _SmartNoteHostState();
}

class _SmartNoteHostState extends State<_SmartNoteHost>
    with WidgetsBindingObserver {
  final store = SecureAuthStore();
  final client = LoggingHttpClient(http.Client());
  AuthController? auth;
  Database? localAuthDatabase;
  _Runtime? runtime;
  Object? loadError;
  late final ResumeSyncCoordinator resumeSync;
  int syncRevision = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    resumeSync = ResumeSyncCoordinator(_syncCurrentSession);
    _initialize();
  }

  Future<void> _syncCurrentSession() async {
    final session = auth?.session;
    final target = runtime;
    if (session == null || target == null || widget.config == null) return;
    await _sync(target, session);
    if (mounted) setState(() => syncRevision++);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      resumeSync.sync().catchError((Object error) {
        developer.log('Resume sync failed: $error', name: 'smartnote.sync');
      });
    }
  }

  Future<void> _initialize() async {
    try {
      final session = await store.read();
      final AuthGateway api;
      if (widget.config == null) {
        localAuthDatabase = await openLocalAuthDatabase();
        api = LocalAuthGateway(localAuthDatabase!);
      } else {
        api = AuthApiClient(client, baseUrl: widget.config!.baseUrl);
      }
      final initialRuntime = await _createRuntime(session);
      if (session != null && widget.config != null) {
        await _sync(initialRuntime, session);
      }
      if (!mounted) return;
      setState(() {
        runtime = initialRuntime;
        auth = AuthController(
          api: api,
          store: store,
          deviceId: widget.deviceId,
          session: session,
          onSessionChanged: _switchSession,
        );
      });
    } catch (error) {
      if (mounted) setState(() => loadError = error);
    }
  }

  Future<void> _switchSession(AuthSession? previous, AuthSession next) async {
    final oldRuntime = runtime!;
    if (previous != null && widget.config != null) {
      final pushed = await _sync(oldRuntime, previous);
      if (pushed.failed != 0) {
        throw StateError(
          'Không thể đồng bộ dữ liệu hiện tại trước khi chuyển tài khoản.',
        );
      }
    }
    final nextProfileKey = next.kind == AuthKind.user
        ? next.profileId
        : 'guest:${widget.deviceId}';
    if (oldRuntime.profileKey == nextProfileKey) {
      if (widget.config != null) await _sync(oldRuntime, next);
      return;
    }
    if (widget.config != null &&
        previous?.kind == AuthKind.guest &&
        next.kind == AuthKind.user) {
      await auth!.api!.claimGuest(next.accessToken, previous!.accessToken);
    }
    final newRuntime = await _createRuntime(next);
    final result = widget.config == null
        ? const SyncResult(synced: 0, failed: 0)
        : await _sync(newRuntime, next);
    if (result.failed != 0) {
      await newRuntime.database.close();
      throw StateError(
        'Không thể tải cache của tài khoản. Dữ liệu Guest vẫn được giữ nguyên.',
      );
    }
    if (widget.config != null &&
        previous?.kind == AuthKind.guest &&
        next.kind == AuthKind.user) {
      await clearSmartNoteProfile(oldRuntime.database);
    }
    if (!mounted) return;
    setState(() => runtime = newRuntime);
    await oldRuntime.database.close();
  }

  Future<_Runtime> _createRuntime(AuthSession? session) async {
    final profileKey = session?.kind == AuthKind.user
        ? session!.profileId
        : 'guest:${widget.deviceId}';
    final database = await openSmartNoteProfileDatabase(profileKey);
    final repository = SqliteNoteRepository(database);
    if (session?.kind != AuthKind.user) await _seedDemoNotes(repository);
    return _Runtime(profileKey, database, repository);
  }

  Future<SyncResult> _sync(_Runtime target, AuthSession session) {
    return OutboxSyncService(
      database: target.database,
      notes: target.repository,
      cloud: RestCloudNoteStore(
        client,
        baseUrl: widget.config!.baseUrl,
        accessToken: session.accessToken,
      ),
    ).syncPending();
  }

  @override
  Widget build(BuildContext context) {
    if (loadError != null) {
      return MaterialApp(
        home: Scaffold(
          body: Center(child: Text('Không thể mở SmartNote: $loadError')),
        ),
      );
    }
    if (runtime == null) {
      return const MaterialApp(
        home: Scaffold(body: Center(child: CircularProgressIndicator())),
      );
    }
    return SmartNoteApp(
      key: ValueKey(
        '${auth?.session?.profileId ?? 'local'}-'
        '${runtime.hashCode}-$syncRevision',
      ),
      repository: runtime!.repository,
      draftRepository: SqliteNoteDraftRepository(runtime!.database),
      settingsStore: widget.settingsStore,
      authController: auth,
      pinLockService: PinLockService(widget.preferences),
      reminderRepository: SqliteReminderRepository(runtime!.database),
      reminderScheduler: widget.reminderScheduler,
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    client.close();
    localAuthDatabase?.close();
    runtime?.database.close();
    super.dispose();
  }
}

class _Runtime {
  const _Runtime(this.profileKey, this.database, this.repository);
  final String profileKey;
  final Database database;
  final SqliteNoteRepository repository;
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
