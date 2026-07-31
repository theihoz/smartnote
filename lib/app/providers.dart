import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';

import '../features/inspiration/data/quote_api_repository.dart';
import '../features/notes/application/notes_controller.dart';
import '../features/notes/domain/note_repository.dart';

final noteRepositoryProvider = Provider<NoteRepository>(
  (ref) => throw StateError('noteRepositoryProvider must be overridden'),
);

final notesControllerProvider =
    StateNotifierProvider<NotesController, NotesState>((ref) {
      final controller = NotesController(
        ref.watch(noteRepositoryProvider),
        now: DateTime.now,
        newId: const Uuid().v4,
      );
      controller.load();
      return controller;
    });

final quoteProvider = FutureProvider<Quote>((ref) async {
  final client = http.Client();
  ref.onDispose(client.close);
  return QuoteApiRepository(client).fetchRandom();
});

final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.system);
final localeProvider = StateProvider<Locale>((ref) => const Locale('vi'));
