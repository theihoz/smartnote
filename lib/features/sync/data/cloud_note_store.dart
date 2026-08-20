abstract interface class CloudNoteStore {
  Future<void> upsert(Map<String, Object?> note);

  Future<void> delete(String noteId, {DateTime? deletedAt});

  Future<List<Map<String, Object?>>> fetchNotes({DateTime? updatedAfter});
}
