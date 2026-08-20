import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';

import 'auth_api_client.dart';

Future<Database> openLocalAuthDatabase({
  DatabaseFactory? factory,
  String? path,
}) async {
  final selectedFactory = factory ?? databaseFactory;
  final selectedPath =
      path ??
      p.join(await selectedFactory.getDatabasesPath(), 'smartnote_auth.db');
  return selectedFactory.openDatabase(
    selectedPath,
    options: OpenDatabaseOptions(
      version: 1,
      onCreate: (database, _) async {
        await database.execute('''
          CREATE TABLE local_users (
            id TEXT PRIMARY KEY,
            email TEXT NOT NULL UNIQUE,
            password_hash TEXT NOT NULL,
            password_salt TEXT NOT NULL
          )
        ''');
        await database.execute('''
          CREATE TABLE local_sessions (
            token_hash TEXT PRIMARY KEY,
            user_id TEXT NOT NULL REFERENCES local_users(id) ON DELETE CASCADE
          )
        ''');
      },
    ),
  );
}

class LocalAuthGateway implements AuthGateway {
  LocalAuthGateway(this._database);

  final Database _database;
  static final _emailPattern = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');

  @override
  Future<AuthSession> guest(String deviceId, {String? guestSecret}) async =>
      AuthSession(
        profileId: deviceId,
        kind: AuthKind.guest,
        accessToken: 'local-guest:$deviceId',
        expiresAt: DateTime.now().toUtc().add(const Duration(days: 3650)),
        guestSecret: guestSecret ?? deviceId,
      );

  @override
  Future<AuthSession> register(String email, String password) async {
    final normalized = _validate(email, password);
    final salt = _randomBytes(16);
    final id = const Uuid().v4();
    try {
      await _database.insert('local_users', {
        'id': id,
        'email': normalized,
        'password_hash': _hashPassword(password, salt),
        'password_salt': base64UrlEncode(salt),
      });
    } on DatabaseException catch (error) {
      if (error.isUniqueConstraintError()) {
        throw const AuthApiException(
          409,
          'EMAIL_EXISTS',
          'Email đã được đăng ký.',
        );
      }
      rethrow;
    }
    return _createSession(id, normalized);
  }

  @override
  Future<AuthSession> login(String email, String password) async {
    final normalized = email.trim().toLowerCase();
    final rows = await _database.query(
      'local_users',
      where: 'email = ?',
      whereArgs: [normalized],
      limit: 1,
    );
    if (rows.isEmpty || !_matchesPassword(password, rows.single)) {
      throw const AuthApiException(
        401,
        'INVALID_CREDENTIALS',
        'Email hoặc mật khẩu không đúng.',
      );
    }
    return _createSession(rows.single['id']! as String, normalized);
  }

  @override
  Future<void> logout(String token) => _database.delete(
    'local_sessions',
    where: 'token_hash = ?',
    whereArgs: [_tokenHash(token)],
  );

  @override
  Future<void> changePassword(
    String token,
    String currentPassword,
    String newPassword,
  ) async {
    final rows = await _database.rawQuery(
      '''
        SELECT u.* FROM local_users u
        JOIN local_sessions s ON s.user_id = u.id
        WHERE s.token_hash = ?
      ''',
      [_tokenHash(token)],
    );
    if (rows.isEmpty || !_matchesPassword(currentPassword, rows.single)) {
      throw const AuthApiException(
        401,
        'INVALID_CREDENTIALS',
        'Mật khẩu hiện tại không đúng.',
      );
    }
    _validate(rows.single['email']! as String, newPassword);
    final salt = _randomBytes(16);
    await _database.update(
      'local_users',
      {
        'password_hash': _hashPassword(newPassword, salt),
        'password_salt': base64UrlEncode(salt),
      },
      where: 'id = ?',
      whereArgs: [rows.single['id']],
    );
  }

  @override
  Future<void> claimGuest(String accountToken, String guestToken) async {}

  String _validate(String email, String password) {
    final normalized = email.trim().toLowerCase();
    if (!_emailPattern.hasMatch(normalized)) {
      throw const AuthApiException(400, 'INVALID_EMAIL', 'Email không hợp lệ.');
    }
    if (password.length < 8 || password.length > 72) {
      throw const AuthApiException(
        400,
        'INVALID_PASSWORD',
        'Mật khẩu phải có từ 8 đến 72 ký tự.',
      );
    }
    return normalized;
  }

  Future<AuthSession> _createSession(String userId, String email) async {
    final token = base64UrlEncode(_randomBytes(32));
    await _database.insert('local_sessions', {
      'token_hash': _tokenHash(token),
      'user_id': userId,
    });
    return AuthSession(
      profileId: userId,
      kind: AuthKind.user,
      accessToken: token,
      expiresAt: DateTime.now().toUtc().add(const Duration(days: 3650)),
      email: email,
    );
  }

  bool _matchesPassword(String password, Map<String, Object?> user) {
    final salt = base64Url.decode(user['password_salt']! as String);
    final actual = base64Url.decode(user['password_hash']! as String);
    final candidate = base64Url.decode(_hashPassword(password, salt));
    var difference = actual.length ^ candidate.length;
    for (var index = 0; index < min(actual.length, candidate.length); index++) {
      difference |= actual[index] ^ candidate[index];
    }
    return difference == 0;
  }
}

String _hashPassword(String password, List<int> salt) {
  final key = utf8.encode(password);
  var block = Uint8List.fromList([...salt, 0, 0, 0, 1]);
  var value = Hmac(sha256, key).convert(block).bytes;
  final result = Uint8List.fromList(value);
  for (var iteration = 1; iteration < 100000; iteration++) {
    value = Hmac(sha256, key).convert(value).bytes;
    for (var index = 0; index < result.length; index++) {
      result[index] ^= value[index];
    }
  }
  return base64UrlEncode(result);
}

String _tokenHash(String token) =>
    sha256.convert(utf8.encode(token)).toString();

List<int> _randomBytes(int length) {
  final random = Random.secure();
  return List.generate(length, (_) => random.nextInt(256));
}
