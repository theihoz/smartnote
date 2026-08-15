import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum PinVerification { verified, incorrect, locked, notConfigured }

class PinLockService {
  PinLockService(
    this._preferences, {
    DateTime Function()? now,
    this.iterations = 120000,
  }) : _now = now ?? DateTime.now;

  static const _saltKey = 'note_lock_pin_salt';
  static const _hashKey = 'note_lock_pin_hash';
  static const _failedAttemptsKey = 'note_lock_failed_attempts';
  static const _lockedUntilKey = 'note_lock_locked_until';

  final SharedPreferences _preferences;
  final DateTime Function() _now;
  final int iterations;

  bool get isConfigured => _preferences.containsKey(_hashKey);

  Future<void> setPin(String pin) async {
    if (!RegExp(r'^\d{4,6}$').hasMatch(pin)) {
      throw const FormatException('PIN must have 4 to 6 digits');
    }
    final salt = List<int>.generate(16, (_) => Random.secure().nextInt(256));
    await _preferences.setString(_saltKey, base64Encode(salt));
    await _preferences.setString(_hashKey, base64Encode(_derive(pin, salt)));
    await _clearFailures();
  }

  Future<PinVerification> verify(String pin) async {
    final saltValue = _preferences.getString(_saltKey);
    final hashValue = _preferences.getString(_hashKey);
    if (saltValue == null || hashValue == null) {
      return PinVerification.notConfigured;
    }
    final lockedUntil = _preferences.getString(_lockedUntilKey);
    if (lockedUntil != null && _now().isBefore(DateTime.parse(lockedUntil))) {
      return PinVerification.locked;
    }

    final actual = _derive(pin, base64Decode(saltValue));
    final expected = base64Decode(hashValue);
    if (_constantTimeEquals(actual, expected)) {
      await _clearFailures();
      return PinVerification.verified;
    }

    final attempts = (_preferences.getInt(_failedAttemptsKey) ?? 0) + 1;
    await _preferences.setInt(_failedAttemptsKey, attempts);
    if (attempts >= 5) {
      await _preferences.setString(
        _lockedUntilKey,
        _now().add(const Duration(seconds: 30)).toUtc().toIso8601String(),
      );
      return PinVerification.locked;
    }
    return PinVerification.incorrect;
  }

  Future<void> removePin() async {
    await _preferences.remove(_saltKey);
    await _preferences.remove(_hashKey);
    await _clearFailures();
  }

  List<int> _derive(String pin, List<int> salt) {
    final mac = Hmac(sha256, utf8.encode(pin));
    var block = mac.convert([...salt, 0, 0, 0, 1]).bytes;
    final output = List<int>.from(block);
    for (var index = 1; index < iterations; index++) {
      block = mac.convert(block).bytes;
      for (var byte = 0; byte < output.length; byte++) {
        output[byte] ^= block[byte];
      }
    }
    return output;
  }

  bool _constantTimeEquals(List<int> left, List<int> right) {
    if (left.length != right.length) return false;
    var difference = 0;
    for (var index = 0; index < left.length; index++) {
      difference |= left[index] ^ right[index];
    }
    return difference == 0;
  }

  Future<void> _clearFailures() async {
    await _preferences.remove(_failedAttemptsKey);
    await _preferences.remove(_lockedUntilKey);
  }
}
