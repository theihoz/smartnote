import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:smartnote/features/sync/data/api_config.dart';
import 'package:smartnote/features/sync/data/rest_cloud_note_store.dart';

void main() {
  test('empty API URL keeps the app in local-only mode', () {
    expect(ApiConfig.fromValue(''), isNull);
    expect(
      ApiConfig.fromValue(' https://api.example.com ')?.baseUrl,
      'https://api.example.com',
    );
  });

  test(
    'upsert sends bearer token and maps the existing cloud payload',
    () async {
      late http.Request recorded;
      final client = MockClient((request) async {
        recorded = request;
        return http.Response(
          jsonEncode({
            'data': jsonDecode(request.body),
            'meta': {'requestId': 'request-1'},
          }),
          200,
        );
      });
      final store = RestCloudNoteStore(
        client,
        baseUrl: 'https://api.example.com',
        accessToken: 'token-1',
      );

      await store.upsert({
        'id': '22222222-2222-4222-8222-222222222222',
        'title': 'REST note',
        'body': '',
        'kind': 'text',
        'checklist': const [
          {'id': 'item-1', 'text': 'Task', 'is_done': true, 'position': 0},
        ],
        'tags': const [],
        'image_paths': const [],
        'is_favorite': false,
        'is_locked': false,
        'color_key': 'lavender',
        'created_at': '2026-08-20T00:00:00.000Z',
        'updated_at': '2026-08-20T00:00:00.000Z',
      });

      expect(recorded.method, 'PUT');
      expect(recorded.headers['authorization'], 'Bearer token-1');
      expect(jsonDecode(recorded.body)['imagePaths'], const []);
      expect(jsonDecode(recorded.body)['checklist'][0]['isDone'], isTrue);
    },
  );

  test('fetch maps REST notes back to the sync payload', () async {
    final client = MockClient(
      (request) async => http.Response(
        jsonEncode({
          'data': [
            {
              'id': '22222222-2222-4222-8222-222222222222',
              'title': 'REST note',
              'body': '',
              'kind': 'text',
              'checklist': [
                {'id': 'item-1', 'text': 'Task', 'isDone': true, 'position': 0},
              ],
              'tags': [],
              'imagePaths': [],
              'isFavorite': false,
              'isLocked': false,
              'colorKey': 'lavender',
              'createdAt': '2026-08-20T00:00:00.000Z',
              'updatedAt': '2026-08-20T00:00:00.000Z',
              'deletedAt': null,
            },
          ],
          'meta': {'requestId': 'request-2'},
        }),
        200,
      ),
    );
    final store = RestCloudNoteStore(
      client,
      baseUrl: 'https://api.example.com',
      accessToken: 'token-1',
    );

    final notes = await store.fetchNotes();

    expect(notes.single['updated_at'], '2026-08-20T00:00:00.000Z');
    expect(notes.single['image_paths'], const []);
    expect((notes.single['checklist'] as List).single['is_done'], isTrue);
  });
}
