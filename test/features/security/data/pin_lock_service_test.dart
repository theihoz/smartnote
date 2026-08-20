import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smartnote/features/security/data/pin_lock_service.dart';

void main() {
  test('locks for 30 seconds after five incorrect PIN attempts', () async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final clock = _Clock(DateTime.utc(2026, 8, 11, 9));
    final service = PinLockService(
      preferences,
      now: () => clock.value,
      iterations: 2,
    );
    await service.setPin('1234');

    for (var attempt = 0; attempt < 4; attempt++) {
      expect(await service.verify('0000'), PinVerification.incorrect);
    }
    expect(await service.verify('0000'), PinVerification.locked);
    expect(await service.verify('1234'), PinVerification.locked);

    clock.value = clock.value.add(const Duration(seconds: 30));
    expect(await service.verify('1234'), PinVerification.verified);
  });
}

class _Clock {
  _Clock(this.value);

  DateTime value;
}
