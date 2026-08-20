import 'dart:convert';

import 'package:http/http.dart' as http;

import 'cloud_note_store.dart';

class RestCloudNoteStore implements CloudNoteStore {
  RestCloudNoteStore(
    this._client, {
    required this.baseUrl,
    required this.deviceId,
  });

  final http.Client _client;
  final String baseUrl;
  final String deviceId;

  Map<String, String> get _headers => {
    'content-type': 'application/json',
    'x-device-id': deviceId,
  };

  @override
  Future<void> upsert(Map<String, Object?> note) async {
    final id = note['id']! as String;
    final response = await _client
        .put(
          Uri.parse('$baseUrl/v1/notes/$id'),
          headers: _headers,
          body: jsonEncode(_toRest(note)),
        )
        .timeout(const Duration(seconds: 8));
    _ensureSuccess(response);
  }

  @override
  Future<void> delete(String noteId, {DateTime? deletedAt}) async {
    final response = await _client
        .delete(Uri.parse('$baseUrl/v1/notes/$noteId'), headers: _headers)
        .timeout(const Duration(seconds: 8));
    _ensureSuccess(response);
  }

  @override
  Future<List<Map<String, Object?>>> fetchNotes({
    DateTime? updatedAfter,
  }) async {
    final uri = Uri.parse('$baseUrl/v1/notes').replace(
      queryParameters: updatedAfter == null
          ? null
          : {'updatedAfter': updatedAfter.toUtc().toIso8601String()},
    );
    final response = await _client
        .get(uri, headers: _headers)
        .timeout(const Duration(seconds: 8));
    _ensureSuccess(response);
    final body = jsonDecode(response.body) as Map<String, Object?>;
    final rows = body['data'] as List;
    return rows
        .map((row) => _fromRest(Map<String, Object?>.from(row as Map)))
        .toList();
  }

  void _ensureSuccess(http.Response response) {
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw RestApiException(response.statusCode, response.body);
    }
  }

  Map<String, Object?> _toRest(Map<String, Object?> note) => {
    'id': note['id'],
    'title': note['title'],
    'body': note['body'],
    'kind': note['kind'],
    'isFavorite': note['is_favorite'],
    'isLocked': note['is_locked'],
    'colorKey': note['color_key'],
    'tags': note['tags'],
    'imagePaths': note['image_paths'],
    'checklist': (note['checklist'] as List)
        .map((item) => Map<String, Object?>.from(item as Map))
        .map(
          (item) => {
            'id': item['id'],
            'text': item['text'],
            'isDone': item['is_done'],
            'position': item['position'],
          },
        )
        .toList(),
    'createdAt': note['created_at'],
    'updatedAt': note['updated_at'],
    'deletedAt': note['deleted_at'],
  };

  Map<String, Object?> _fromRest(Map<String, Object?> note) => {
    'id': note['id'],
    'title': note['title'],
    'body': note['body'],
    'kind': note['kind'],
    'is_favorite': note['isFavorite'],
    'is_locked': note['isLocked'],
    'color_key': note['colorKey'],
    'tags': note['tags'],
    'image_paths': note['imagePaths'],
    'checklist': (note['checklist'] as List)
        .map((item) => Map<String, Object?>.from(item as Map))
        .map(
          (item) => {
            'id': item['id'],
            'text': item['text'],
            'is_done': item['isDone'],
            'position': item['position'],
          },
        )
        .toList(),
    'created_at': note['createdAt'],
    'updated_at': note['updatedAt'],
    'deleted_at': note['deletedAt'],
  };
}

class RestApiException implements Exception {
  const RestApiException(this.statusCode, this.body);

  final int statusCode;
  final String body;
}
