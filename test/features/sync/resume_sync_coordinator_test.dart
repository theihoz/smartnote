import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:smartnote/features/sync/data/resume_sync_coordinator.dart';

void main() {
  test('coalesces concurrent resume sync requests', () async {
    final gate = Completer<void>();
    var calls = 0;
    final coordinator = ResumeSyncCoordinator(() async {
      calls++;
      await gate.future;
    });

    final first = coordinator.sync();
    final second = coordinator.sync();
    expect(calls, 1);

    gate.complete();
    await Future.wait([first, second]);
    expect(calls, 1);
  });
}
