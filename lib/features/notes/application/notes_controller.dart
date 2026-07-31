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
    await load();
    return note;
  }

  Future<void> restore(Note note) async {
    await _repository.save(note);
    await load();
  }
}
