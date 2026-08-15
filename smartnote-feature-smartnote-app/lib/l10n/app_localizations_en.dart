// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'SmartNote';

  @override
  String get home => 'Home';

  @override
  String get search => 'Search';

  @override
  String get favorites => 'Favorites';

  @override
  String get settings => 'Settings';

  @override
  String get greeting => 'Hello 👋';

  @override
  String get homeSubtitle => 'Capture what matters today.';

  @override
  String taskCount(int count) {
    return '$count tasks';
  }

  @override
  String get all => 'All';

  @override
  String get study => 'Study';

  @override
  String get project => 'Projects';

  @override
  String get idea => 'Ideas';

  @override
  String get personal => 'Personal';

  @override
  String get recentNotes => 'Recent notes';

  @override
  String get saved => 'Saved';

  @override
  String get inspirationLoading => 'Finding a little inspiration...';

  @override
  String get inspirationError => 'The quote could not load. Try again.';

  @override
  String get retry => 'Try again';

  @override
  String get emptyNotesTitle => 'No notes yet';

  @override
  String get emptyNotesBody => 'Tap + to capture your first idea.';

  @override
  String get searchHint => 'Search by title or content...';

  @override
  String get noSearchResults => 'No matching notes found.';

  @override
  String get emptyFavorites => 'Notes you favorite will appear here.';

  @override
  String get themeSection => 'Appearance';

  @override
  String get themeMode => 'Color mode';

  @override
  String get system => 'System';

  @override
  String get light => 'Light';

  @override
  String get dark => 'Dark';

  @override
  String get language => 'Language';

  @override
  String get storageSection => 'Storage and sync';

  @override
  String get cloudSync => 'Cloud sync';

  @override
  String get cloudReady => 'Ready • SQLite remains your offline source';

  @override
  String get cloudUnavailable => 'Not configured • Running locally';

  @override
  String get sync => 'Sync';

  @override
  String get localStorage => 'Saved on this device';

  @override
  String get localStorageDescription =>
      'Notes and photos are stored safely on your phone';

  @override
  String get about => 'App';

  @override
  String get version => 'Version 1.0.0 • vn.edu.smartnote';

  @override
  String get newNote => 'New note';

  @override
  String get editNote => 'Edit note';

  @override
  String get done => 'Done';

  @override
  String get save => 'Save';

  @override
  String get titleHint => 'Title';

  @override
  String get text => 'Note';

  @override
  String get taskList => 'Task list';

  @override
  String get bodyHint => 'Write what is on your mind...';

  @override
  String imageCount(int count) {
    return '$count photos added';
  }

  @override
  String get camera => 'Take photo';

  @override
  String get gallery => 'Choose photo';

  @override
  String get addLabel => 'Add label';

  @override
  String get chooseColor => 'Choose color';

  @override
  String get savedOnDevice => 'Saved automatically on this device';

  @override
  String get taskHint => 'What needs doing?';

  @override
  String get addTask => 'Add task';

  @override
  String get favorite => 'Favorite';

  @override
  String get share => 'Share';

  @override
  String get deleteNote => 'Delete note';

  @override
  String get deleteNoteTitle => 'Delete this note?';

  @override
  String get deleteNoteContent => 'You can undo this right after deleting.';

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get deletedNote => 'Note deleted';

  @override
  String get updatedNote => 'Note updated';

  @override
  String get createdNote => 'Note saved';

  @override
  String get undo => 'Undo';

  @override
  String get addTag => 'Add label';

  @override
  String get checklistTitle => 'To prepare';

  @override
  String completedCount(int done, int total) {
    return '$done/$total complete';
  }

  @override
  String get untitled => 'Untitled note';

  @override
  String get today => 'Today';

  @override
  String get yesterday => 'Yesterday';

  @override
  String daysAgo(int count) {
    return '$count days ago';
  }

  @override
  String get emptyNoteError => 'Add a title or some content.';

  @override
  String get emptyChecklistError => 'Add at least one task.';

  @override
  String quoteAuthor(String author) {
    return '— $author';
  }
}
