enum NoteKind { text, checklist }

class ChecklistItem {
  const ChecklistItem({
    required this.id,
    required this.text,
    required this.isDone,
    this.position = 0,
  });

  final String id;
  final String text;
  final bool isDone;
  final int position;

  ChecklistItem copyWith({String? text, bool? isDone, int? position}) {
    return ChecklistItem(
      id: id,
      text: text ?? this.text,
      isDone: isDone ?? this.isDone,
      position: position ?? this.position,
    );
  }
}

class NoteDraft {
  const NoteDraft({
    required this.title,
    required this.body,
    required this.kind,
    this.checklist = const [],
    this.tags = const [],
    this.colorKey = 'lavender',
    this.imagePaths = const [],
    this.isFavorite = false,
  });

  final String title;
  final String body;
  final NoteKind kind;
  final List<ChecklistItem> checklist;
  final List<String> tags;
  final String colorKey;
  final List<String> imagePaths;
  final bool isFavorite;
}

class Note {
  const Note({
    required this.id,
    required this.title,
    required this.body,
    required this.kind,
    required this.checklist,
    required this.tags,
    required this.isFavorite,
    required this.colorKey,
    required this.imagePaths,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String title;
  final String body;
  final NoteKind kind;
  final List<ChecklistItem> checklist;
  final List<String> tags;
  final bool isFavorite;
  final String colorKey;
  final List<String> imagePaths;
  final DateTime createdAt;
  final DateTime updatedAt;

  int get completedChecklistItems =>
      checklist.where((item) => item.isDone).length;

  double get checklistProgress =>
      checklist.isEmpty ? 0 : completedChecklistItems / checklist.length;

  Note copyWith({
    String? title,
    String? body,
    NoteKind? kind,
    List<ChecklistItem>? checklist,
    List<String>? tags,
    bool? isFavorite,
    String? colorKey,
    List<String>? imagePaths,
    DateTime? updatedAt,
  }) {
    return Note(
      id: id,
      title: title ?? this.title,
      body: body ?? this.body,
      kind: kind ?? this.kind,
      checklist: checklist ?? this.checklist,
      tags: tags ?? this.tags,
      isFavorite: isFavorite ?? this.isFavorite,
      colorKey: colorKey ?? this.colorKey,
      imagePaths: imagePaths ?? this.imagePaths,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
