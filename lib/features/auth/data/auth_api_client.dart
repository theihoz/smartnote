import 'dart:convert';

import 'package:http/http.dart' as http;

import '../domain/auth_session.dart';

export '../domain/auth_session.dart';

abstract interface class AuthGateway {
  Future<AuthSession> guest(String deviceId, {String? guestSecret});
  Future<AuthSession> register(String email, String password);
  Future<AuthSession> login(String email, String password);
  Future<void> logout(String token);
  Future<void> changePassword(
    String token,
    String currentPassword,
    String newPassword,
  );
  Future<void> claimGuest(String accountToken, String guestToken);
}

class AuthApiClient implements AuthGateway {
  AuthApiClient(this._client, {required this.baseUrl});

  final http.Client _client;
  final String baseUrl;

  @override
  Future<AuthSession> guest(String deviceId, {String? guestSecret}) async {
    final data = await _send(
      '/v1/auth/guest',
      body: {'deviceId': deviceId, 'guestSecret': ?guestSecret},
    );
    return AuthSession(
      profileId: deviceId,
      kind: AuthKind.guest,
      accessToken: data['accessToken']! as String,
      expiresAt: DateTime.parse(data['expiresAt']! as String),
      guestSecret: (data['guestSecret'] as String?) ?? guestSecret,
    );
  }

  @override
  Future<AuthSession> register(String email, String password) async =>
      _accountSession(
        await _send(
          '/v1/auth/register',
          body: {'email': email, 'password': password},
        ),
      );

  @override
  Future<AuthSession> login(String email, String password) async =>
      _accountSession(
        await _send(
          '/v1/auth/login',
          body: {'email': email, 'password': password},
        ),
      );

  @override
  Future<void> logout(String token) => _send('/v1/auth/logout', token: token);

  @override
  Future<void> changePassword(
    String token,
    String currentPassword,
    String newPassword,
  ) => _send(
    '/v1/auth/password',
    method: 'PUT',
    token: token,
    body: {'currentPassword': currentPassword, 'newPassword': newPassword},
  );

  @override
  Future<void> claimGuest(String accountToken, String guestToken) => _send(
    '/v1/auth/claim-guest',
    token: accountToken,
    headers: {'x-guest-token': guestToken},
  );

  AuthSession _accountSession(Map<String, Object?> data) {
    final user = Map<String, Object?>.from(data['user']! as Map);
    return AuthSession(
      profileId: user['id']! as String,
      kind: AuthKind.user,
      accessToken: data['accessToken']! as String,
      expiresAt: DateTime.parse(data['expiresAt']! as String),
      email: user['email']! as String,
    );
  }

  Future<Map<String, Object?>> _send(
    String path, {
    String method = 'POST',
    String? token,
    Map<String, String> headers = const {},
    Map<String, Object?>? body,
  }) async {
    final request = http.Request(method, Uri.parse('$baseUrl$path'))
      ..headers.addAll({
        'content-type': 'application/json',
        if (token != null) 'authorization': 'Bearer $token',
        ...headers,
      })
      ..body = jsonEncode(body ?? const {});
    final streamed = await _client
        .send(request)
        .timeout(const Duration(seconds: 10));
    final response = await http.Response.fromStream(streamed);
    final json = jsonDecode(response.body) as Map<String, Object?>;
    if (response.statusCode < 200 || response.statusCode >= 300) {
      final error = Map<String, Object?>.from(json['error']! as Map);
      throw AuthApiException(
        response.statusCode,
        error['code']! as String,
        error['message']! as String,
      );
    }
    return Map<String, Object?>.from(json['data']! as Map);
  }
}

class AuthApiException implements Exception {
  const AuthApiException(this.statusCode, this.code, this.message);
  final int statusCode;
  final String code;
  final String message;
  @override
  String toString() => message;
}
