import 'dart:developer' as developer;

import 'package:http/http.dart' as http;

class LoggingHttpClient extends http.BaseClient {
  LoggingHttpClient(this._inner);

  final http.Client _inner;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    final stopwatch = Stopwatch()..start();
    try {
      final response = await _inner.send(request);
      developer.log(
        '${request.method} ${request.url.path} ${response.statusCode} '
        '${stopwatch.elapsedMilliseconds}ms '
        'requestId=${response.headers['x-request-id'] ?? '-'}',
        name: 'smartnote.api',
      );
      return response;
    } catch (error, stackTrace) {
      developer.log(
        '${request.method} ${request.url.path} failed '
        '${stopwatch.elapsedMilliseconds}ms',
        name: 'smartnote.api',
        error: error,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  @override
  void close() => _inner.close();
}
