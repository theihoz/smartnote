import 'dart:convert';

import 'package:http/http.dart' as http;

class Quote {
  const Quote({required this.text, required this.author});

  final String text;
  final String author;
}

class QuoteRequestException implements Exception {
  const QuoteRequestException(this.statusCode);

  final int statusCode;
}

class QuoteFormatException implements Exception {
  const QuoteFormatException();
}

class QuoteApiRepository {
  QuoteApiRepository(this._client);

  final http.Client _client;

  Future<Quote> fetchRandom() async {
    final response = await _client
        .get(Uri.parse('https://dummyjson.com/quotes/random'))
        .timeout(const Duration(seconds: 8));
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw QuoteRequestException(response.statusCode);
    }

    try {
      final json = jsonDecode(response.body);
      if (json is! Map<String, dynamic> ||
          json['quote'] is! String ||
          json['author'] is! String) {
        throw const QuoteFormatException();
      }
      return Quote(
        text: json['quote'] as String,
        author: json['author'] as String,
      );
    } on FormatException {
      throw const QuoteFormatException();
    }
  }
}
