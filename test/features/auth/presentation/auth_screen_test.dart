import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smartnote/features/auth/application/auth_controller.dart';
import 'package:smartnote/features/auth/data/secure_auth_store.dart';
import 'package:smartnote/features/auth/presentation/auth_screen.dart';

void main() {
  testWidgets('login screen credits all three project members', (tester) async {
    final controller = AuthController(
      api: null,
      store: SecureAuthStore(),
      deviceId: 'test-device',
      onSessionChanged: (_, _) async {},
    );

    await tester.pumpWidget(
      MaterialApp(home: AuthScreen(controller: controller)),
    );

    expect(find.text('Diệp Yến Khoa'), findsOneWidget);
    expect(find.text('Nguyễn Trường Diễm Quỳnh'), findsOneWidget);
    expect(find.text('Trần Thái Hòa'), findsOneWidget);
  });
}
