import 'note.dart';
import 'note_query.dart';

abstract interface class NoteRepository {
  Future<List<Note>> list([NoteQuery query = const NoteQuery()]);

  Future<Note?> getById(String id);

  Future<void> save(Note note);

  Future<void> delete(String id);
}

abstract interface class TrashNoteRepository {
  Future<List<Note>> listTrash();

  Future<void> restoreFromTrash(String id);

  Future<int> purgeExpiredTrash(DateTime now);
}

class NoteVersion {
  const NoteVersion({
    required this.title,
    required this.body,
    required this.kind,
    required this.checklist,
    required this.tags,
    required this.isFavorite,
    required this.colorKey,
    required this.imagePaths,
    required this.createdAt,
  });

  final String title;
  final String body;
  final NoteKind kind;
  final List<ChecklistItem> checklist;
  final List<String> tags;
  final bool isFavorite;
  final String colorKey;
  final List<String> imagePaths;
  final DateTime createdAt;
}

abstract interface class NoteVersionRepository {
  Future<List<NoteVersion>> listVersions(String noteId);
}
