import 'note.dart';

enum NoteSort { newest, oldest, title }

class NoteQuery {
  const NoteQuery({
    this.searchText = '',
    this.tag,
    this.favoritesOnly = false,
    this.kind,
    this.sort = NoteSort.newest,
  });

  final String searchText;
  final String? tag;
  final bool favoritesOnly;
  final NoteKind? kind;
  final NoteSort sort;

  List<Note> apply(Iterable<Note> source) {
    final normalizedSearch = searchText.trim().toLowerCase();
    final filtered = source.where((note) {
      final matchesSearch =
          normalizedSearch.isEmpty ||
          note.title.toLowerCase().contains(normalizedSearch) ||
          note.body.toLowerCase().contains(normalizedSearch);
      final matchesTag = tag == null || note.tags.contains(tag);
      final matchesFavorite = !favoritesOnly || note.isFavorite;
      final matchesKind = kind == null || note.kind == kind;
      return matchesSearch && matchesTag && matchesFavorite && matchesKind;
    }).toList();

    switch (sort) {
      case NoteSort.newest:
        filtered.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
      case NoteSort.oldest:
        filtered.sort((a, b) => a.updatedAt.compareTo(b.updatedAt));
      case NoteSort.title:
        filtered.sort(
          (a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()),
        );
    }
    return filtered;
  }
}
