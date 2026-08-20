import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:smartnote/features/auth/data/auth_api_client.dart';

void main() {
  test('register returns the active account session immediately', () async {
    final client = AuthApiClient(
      MockClient((request) async {
        expect(request.url.path, '/v1/auth/register');
        return http.Response(
          '{"data":{"user":{"id":"user-1","email":"owner@example.com"},"accessToken":"token-1","expiresAt":"2026-09-20T00:00:00.000Z"}}',
          201,
        );
      }),
      baseUrl: 'http://localhost:8787',
    );

    final session = await client.register('owner@example.com', 'password-123');
    expect(session.kind, AuthKind.user);
    expect(session.accessToken, 'token-1');
  });

  test('login maps the account session and bearer token', () async {
    final client = AuthApiClient(
      MockClient((request) async {
        expect(request.url.path, '/v1/auth/login');
        return http.Response(
          '{"data":{"user":{"id":"user-1","email":"owner@example.com"},"accessToken":"token-1","expiresAt":"2026-09-20T00:00:00.000Z"}}',
          200,
        );
      }),
      baseUrl: 'http://localhost:8787',
    );

    final session = await client.login('owner@example.com', 'password-123');
    expect(session.profileId, 'user-1');
    expect(session.kind, AuthKind.user);
    expect(session.accessToken, 'token-1');
  });

  test('guest creates a secure server session for the device', () async {
    final client = AuthApiClient(
      MockClient(
        (request) async => http.Response(
          '{"data":{"accessToken":"guest-token","guestSecret":"guest-secret","expiresAt":"2026-09-20T00:00:00.000Z"}}',
          200,
        ),
      ),
      baseUrl: 'http://localhost:8787',
    );

    final session = await client.guest('11111111-1111-4111-8111-111111111111');
    expect(session.kind, AuthKind.guest);
    expect(session.guestSecret, 'guest-secret');
  });
}
