import 'note.dart';

enum NoteValidationError { emptyNote, emptyChecklist }

class NoteValidationResult {
  const NoteValidationResult._({required this.generalError});

  const NoteValidationResult.valid() : this._(generalError: null);

  const NoteValidationResult.invalid(NoteValidationError error)
    : this._(generalError: error);

  final NoteValidationError? generalError;

  bool get isValid => generalError == null;
}

abstract final class NoteValidator {
  static NoteValidationResult validate(NoteDraft draft) {
    if (draft.kind == NoteKind.checklist &&
        !draft.checklist.any((item) => item.text.trim().isNotEmpty)) {
      return const NoteValidationResult.invalid(
        NoteValidationError.emptyChecklist,
      );
    }

    if (draft.kind == NoteKind.text &&
        draft.title.trim().isEmpty &&
        draft.body.trim().isEmpty) {
      return const NoteValidationResult.invalid(
        NoteValidationError.emptyNote,
      );
    }

    return const NoteValidationResult.valid();
  }
}
