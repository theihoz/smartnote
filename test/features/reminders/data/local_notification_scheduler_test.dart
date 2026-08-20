import 'package:flutter_test/flutter_test.dart';
import 'package:smartnote/features/reminders/data/local_notification_scheduler.dart';

void main() {
  test('reports denied notification permission', () {
    expect(
      () => ensureNotificationPermission(false),
      throwsA(isA<ReminderPermissionDenied>()),
    );
  });

  test('accepts granted or unsupported notification permission', () {
    expect(() => ensureNotificationPermission(true), returnsNormally);
    expect(() => ensureNotificationPermission(null), returnsNormally);
  });
}
