import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import '../domain/note_reminder.dart';

abstract interface class ReminderScheduler {
  Future<void> initialize();

  Future<void> schedule({
    required NoteReminder reminder,
    required String title,
    required String body,
  });

  Future<void> cancel(String noteId);
}

class ReminderPermissionDenied implements Exception {
  const ReminderPermissionDenied();
}

void ensureNotificationPermission(bool? granted) {
  if (granted == false) throw const ReminderPermissionDenied();
}

class LocalNotificationScheduler implements ReminderScheduler {
  LocalNotificationScheduler([FlutterLocalNotificationsPlugin? plugin])
    : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  final FlutterLocalNotificationsPlugin _plugin;

  @override
  Future<void> initialize() async {
    tz_data.initializeTimeZones();
    await _plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(),
      ),
    );
  }

  @override
  Future<void> schedule({
    required NoteReminder reminder,
    required String title,
    required String body,
  }) async {
    final granted = await _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();
    ensureNotificationPermission(granted);
    await _plugin.cancel(id: notificationId(reminder.noteId));
    if (!reminder.enabled) return;

    await _plugin.zonedSchedule(
      id: notificationId(reminder.noteId),
      title: title,
      body: body.isEmpty ? 'Đã đến giờ xem lại ghi chú.' : body,
      scheduledDate: tz.TZDateTime.from(reminder.scheduledAt.toUtc(), tz.UTC),
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'smartnote_reminders',
          'Nhắc việc SmartNote',
          channelDescription: 'Thông báo nhắc việc cho ghi chú',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      payload: reminder.noteId,
      matchDateTimeComponents: switch (reminder.repeatType) {
        ReminderRepeatType.none || ReminderRepeatType.custom => null,
        ReminderRepeatType.daily => DateTimeComponents.time,
        ReminderRepeatType.weekly => DateTimeComponents.dayOfWeekAndTime,
        ReminderRepeatType.monthly => DateTimeComponents.dayOfMonthAndTime,
      },
    );
  }

  @override
  Future<void> cancel(String noteId) =>
      _plugin.cancel(id: notificationId(noteId));

  static int notificationId(String noteId) {
    var value = 17;
    for (final unit in noteId.codeUnits) {
      value = (value * 37 + unit) & 0x7fffffff;
    }
    return value;
  }
}
