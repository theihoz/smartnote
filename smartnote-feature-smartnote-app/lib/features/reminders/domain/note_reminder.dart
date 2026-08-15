enum ReminderRepeatType { none, daily, weekly, monthly, custom }

class NoteReminder {
  const NoteReminder({
    required this.noteId,
    required this.scheduledAt,
    required this.timezone,
    this.repeatType = ReminderRepeatType.none,
    this.repeatInterval = 1,
    this.weekdays = const [],
    this.endsAt,
    this.enabled = true,
  });

  final String noteId;
  final DateTime scheduledAt;
  final String timezone;
  final ReminderRepeatType repeatType;
  final int repeatInterval;
  final List<int> weekdays;
  final DateTime? endsAt;
  final bool enabled;

  @override
  bool operator ==(Object other) =>
      other is NoteReminder &&
      other.noteId == noteId &&
      other.scheduledAt == scheduledAt &&
      other.timezone == timezone &&
      other.repeatType == repeatType &&
      other.repeatInterval == repeatInterval &&
      _sameList(other.weekdays, weekdays) &&
      other.endsAt == endsAt &&
      other.enabled == enabled;

  @override
  int get hashCode => Object.hash(
    noteId,
    scheduledAt,
    timezone,
    repeatType,
    repeatInterval,
    Object.hashAll(weekdays),
    endsAt,
    enabled,
  );

  static bool _sameList(List<int> left, List<int> right) {
    if (left.length != right.length) return false;
    for (var index = 0; index < left.length; index++) {
      if (left[index] != right[index]) return false;
    }
    return true;
  }
}

abstract interface class ReminderRepository {
  Future<void> save(NoteReminder reminder);

  Future<NoteReminder?> getByNoteId(String noteId);

  Future<void> delete(String noteId);
}
