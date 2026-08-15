class NoteAutosaveDraft {
  const NoteAutosaveDraft({
    required this.noteId,
    required this.title,
    required this.body,
    required this.updatedAt,
  });

  final String noteId;
  final String title;
  final String body;
  final DateTime updatedAt;

  @override
  bool operator ==(Object other) =>
      other is NoteAutosaveDraft &&
      other.noteId == noteId &&
      other.title == title &&
      other.body == body &&
      other.updatedAt == updatedAt;

  @override
  int get hashCode => Object.hash(noteId, title, body, updatedAt);
}

abstract interface class NoteDraftRepository {
  Future<void> save(NoteAutosaveDraft draft);

  Future<NoteAutosaveDraft?> getByNoteId(String noteId);

  Future<void> delete(String noteId);
}
