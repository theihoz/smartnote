import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../domain/auth_session.dart';

class SecureAuthStore {
  SecureAuthStore([FlutterSecureStorage? storage])
    : _storage = storage ?? const FlutterSecureStorage();
  static const _key = 'smartnote.auth_session';
  final FlutterSecureStorage _storage;

  Future<AuthSession?> read() async {
    final value = await _storage.read(key: _key);
    return value == null
        ? null
        : AuthSession.fromJson(
            Map<String, Object?>.from(jsonDecode(value) as Map),
          );
  }

  Future<void> write(AuthSession session) =>
      _storage.write(key: _key, value: jsonEncode(session.toJson()));
  Future<void> clear() => _storage.delete(key: _key);
}
