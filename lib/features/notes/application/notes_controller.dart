import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/note.dart';
import '../domain/note_query.dart';
import '../domain/note_repository.dart';
import '../domain/note_validator.dart';

class NotesState {
  const NotesState({
    this.allNotes = const [],
    this.query = const NoteQuery(),
    this.isLoading = false,
    this.error,
  });

  final List<Note> allNotes;
  final NoteQuery query;
  final bool isLoading;
  final Object? error;

  List<Note> get visibleNotes => query.apply(allNotes);

  NotesState copyWith({
    List<Note>? allNotes,
    NoteQuery? query,
    bool? isLoading,
    Object? error,
    bool clearError = false,
  }) {
    return NotesState(
      allNotes: allNotes ?? this.allNotes,
      query: query ?? this.query,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : error ?? this.error,
    );
  }
}

class NotesController extends StateNotifier<NotesState> {
  NotesController(this._repository, {required this._now, required this._newId})
    : super(const NotesState());

  final NoteRepository _repository;
  final DateTime Function() _now;
  final String Function() _newId;
  UndoEntry? _undoEntry;

  bool get canUndo => _undoEntry != null && !_isUndoExpired;

  bool get _isUndoExpired {
    final entry = _undoEntry;
    return entry == null || !_now().isBefore(entry.expiresAt);
  }

  Future<void> load() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      state = state.copyWith(
        allNotes: await _repository.list(),
        isLoading: false,
      );
    } catch (error) {
      state = state.copyWith(isLoading: false, error: error);
    }
  }

  void setQuery(NoteQuery query) {
    state = state.copyWith(query: query);
  }

  Future<NoteValidationResult> saveDraft(
    NoteDraft draft, {
    String? id,
    DateTime? createdAt,
  }) async {
    final validation = NoteValidator.validate(draft);
    if (!validation.isValid) return validation;

    final timestamp = _now();
    final previous = id == null ? null : await _repository.getById(id);
    final note = Note(
      id: id ?? _newId(),
      title: draft.title.trim(),
      body: draft.body.trim(),
      kind: draft.kind,
      checklist: draft.checklist
          .where((item) => item.text.trim().isNotEmpty)
          .toList(),
      tags: draft.tags,
      isFavorite: draft.isFavorite,
      colorKey: draft.colorKey,
      imagePaths: draft.imagePaths,
      createdAt: createdAt ?? timestamp,
      updatedAt: timestamp,
    );
    await _repository.save(note);
    _undoEntry = UndoEntry(
      noteId: note.id,
      previous: previous,
      created: previous == null,
      expiresAt: timestamp.add(const Duration(seconds: 5)),
    );
    await load();
    return validation;
  }

  Future<void> toggleFavorite(String id) async {
    final note = await _repository.getById(id);
    if (note == null) return;
    await _repository.save(
      note.copyWith(isFavorite: !note.isFavorite, updatedAt: _now()),
    );
    await load();
  }

  Future<Note?> delete(String id) async {
    final note = await _repository.getById(id);
    if (note == null) return null;
    await _repository.delete(id);
    _undoEntry = UndoEntry(
      noteId: note.id,
      previous: note,
      created: false,
      expiresAt: _now().add(const Duration(seconds: 5)),
    );
    await load();
    return note;
  }

  Future<void> setLocked(String id, bool isLocked) async {
    final note = await _repository.getById(id);
    if (note == null) return;
    await _repository.save(
      note.copyWith(isLocked: isLocked, updatedAt: _now()),
    );
    await load();
  }

  Future<bool> undo() async {
    final entry = _undoEntry;
    if (entry == null || _isUndoExpired) {
      _undoEntry = null;
      return false;
    }

    if (entry.created) {
      await _repository.delete(entry.noteId);
    } else if (entry.previous != null) {
      await _repository.save(entry.previous!);
    }
    _undoEntry = null;
    await load();
    return true;
  }

  Future<void> restore(Note note) async {
    await _repository.save(note);
    await load();
  }
}

class UndoEntry {
  const UndoEntry({
    required this.noteId,
    required this.previous,
    required this.created,
    required this.expiresAt,
  });

  final String noteId;
  final Note? previous;
  final bool created;
  final DateTime expiresAt;
}
