import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:smartnote/features/inspiration/data/quote_api_repository.dart';

void main() {
  test('parses a random quote response', () async {
    final repository = QuoteApiRepository(
      MockClient(
        (_) async => http.Response(
          '{"id":1,"quote":"Stay curious.","author":"Ada"}',
          200,
        ),
      ),
    );

    final quote = await repository.fetchRandom();

    expect(quote.text, 'Stay curious.');
    expect(quote.author, 'Ada');
  });

  test('throws QuoteRequestException for a non-success response', () async {
    final repository = QuoteApiRepository(
      MockClient((_) async => http.Response('unavailable', 503)),
    );

    expect(repository.fetchRandom, throwsA(isA<QuoteRequestException>()));
  });

  test('throws QuoteFormatException for malformed JSON', () async {
    final repository = QuoteApiRepository(
      MockClient((_) async => http.Response('{"quote":42}', 200)),
    );

    expect(repository.fetchRandom, throwsA(isA<QuoteFormatException>()));
  });
}
