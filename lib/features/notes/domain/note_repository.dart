import 'note.dart';
import 'note_query.dart';

abstract interface class NoteRepository {
  Future<List<Note>> list([NoteQuery query = const NoteQuery()]);

  Future<Note?> getById(String id);

  Future<void> save(Note note);

  Future<void> delete(String id);
}
