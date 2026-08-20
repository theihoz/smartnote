import 'package:flutter_test/flutter_test.dart';
import 'package:smartnote/features/auth/data/auth_api_client.dart';
import 'package:smartnote/features/auth/data/local_auth_gateway.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  setUpAll(sqfliteFfiInit);

  test('registers and logs in locally without storing the password', () async {
    final database = await openLocalAuthDatabase(
      factory: databaseFactoryFfi,
      path: inMemoryDatabasePath,
    );
    addTearDown(database.close);
    final auth = LocalAuthGateway(database);

    final registered = await auth.register(
      ' Demo@Example.com ',
      'password-123',
    );
    final loggedIn = await auth.login('demo@example.com', 'password-123');
    final row = (await database.query('local_users')).single;

    expect(registered.profileId, loggedIn.profileId);
    expect(loggedIn.email, 'demo@example.com');
    expect(row.values, isNot(contains('password-123')));
  });

  test(
    'guest works without a server and invalid password is rejected',
    () async {
      final database = await openLocalAuthDatabase(
        factory: databaseFactoryFfi,
        path: inMemoryDatabasePath,
      );
      addTearDown(database.close);
      final auth = LocalAuthGateway(database);
      await auth.register('demo@example.com', 'password-123');

      expect((await auth.guest('device-1')).profileId, 'device-1');
      expect(
        () => auth.login('demo@example.com', 'wrong-password'),
        throwsA(
          isA<AuthApiException>().having(
            (error) => error.code,
            'code',
            'INVALID_CREDENTIALS',
          ),
        ),
      );
    },
  );
}
