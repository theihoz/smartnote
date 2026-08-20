import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:smartnote/features/inspiration/data/quote_api_repository.dart';

void main() {
  test('parses a random quote response', () async {
    Uri? requestedUri;
    final repository = QuoteApiRepository(
      MockClient((request) async {
        requestedUri = request.url;
        return http.Response(
          '{"data":{"text":"Stay curious.","author":"Ada"},"meta":{"requestId":"1"}}',
          200,
        );
      }),
      baseUrl: 'https://api.example.com',
    );

    final quote = await repository.fetchRandom();

    expect(quote.text, 'Stay curious.');
    expect(quote.author, 'Ada');
    expect(requestedUri?.path, '/v1/quotes/random');
  });

  test('throws QuoteRequestException for a non-success response', () async {
    final repository = QuoteApiRepository(
      MockClient((_) async => http.Response('unavailable', 503)),
      baseUrl: 'https://api.example.com',
    );

    expect(repository.fetchRandom, throwsA(isA<QuoteRequestException>()));
  });

  test('throws QuoteFormatException for malformed JSON', () async {
    final repository = QuoteApiRepository(
      MockClient((_) async => http.Response('{"quote":42}', 200)),
      baseUrl: 'https://api.example.com',
    );

    expect(repository.fetchRandom, throwsA(isA<QuoteFormatException>()));
  });
}
