class ResumeSyncCoordinator {
  ResumeSyncCoordinator(this._run);

  final Future<void> Function() _run;
  Future<void>? _active;

  Future<void> sync() => _active ??= _run().whenComplete(() => _active = null);
}
