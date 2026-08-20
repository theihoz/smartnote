import 'package:flutter/foundation.dart';

import '../data/auth_api_client.dart';
import '../data/secure_auth_store.dart';

class AuthController extends ChangeNotifier {
  AuthController({
    required this.api,
    required this.store,
    required this.deviceId,
    required this.onSessionChanged,
    this.session,
  });

  final AuthGateway? api;
  final SecureAuthStore store;
  final String deviceId;
  final Future<void> Function(AuthSession? previous, AuthSession next)
  onSessionChanged;
  AuthSession? session;
  bool busy = false;
  String? error;

  Future<void> continueAsGuest() => _run(() async {
    final next = await _requireApi().guest(
      deviceId,
      guestSecret: session?.guestSecret,
    );
    await _activate(next);
  });

  Future<void> login(String email, String password) => _run(() async {
    final next = await _requireApi().login(email, password);
    await _activate(next);
  });

  Future<void> register(String email, String password) => _run(() async {
    final next = await _requireApi().register(email, password);
    await _activate(next);
  });

  Future<void> changePassword(String currentPassword, String newPassword) =>
      _run(
        () => _requireApi().changePassword(
          session!.accessToken,
          currentPassword,
          newPassword,
        ),
      );

  Future<void> logout() => _run(() async {
    final current = session;
    if (current != null) {
      try {
        await _requireApi().logout(current.accessToken);
      } catch (_) {}
    }
    await store.clear();
    session = null;
    notifyListeners();
  });

  Future<void> _activate(AuthSession next) async {
    final previous = session;
    await onSessionChanged(previous, next);
    await store.write(next);
    session = next;
    notifyListeners();
  }

  AuthGateway _requireApi() =>
      api ??
      (throw const AuthApiException(
        0,
        'API_NOT_CONFIGURED',
        'Không thể kết nối máy chủ. Hãy kiểm tra Docker đang chạy.',
      ));

  Future<void> _run(Future<void> Function() action) async {
    busy = true;
    error = null;
    notifyListeners();
    try {
      await action();
    } catch (exception) {
      error = exception.toString();
      rethrow;
    } finally {
      busy = false;
      notifyListeners();
    }
  }
}
