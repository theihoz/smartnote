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
  QuoteApiRepository(this._client, {required this.baseUrl});

  final http.Client _client;
  final String baseUrl;

  Future<Quote> fetchRandom() async {
    final response = await _client
        .get(Uri.parse('$baseUrl/v1/quotes/random'))
        .timeout(const Duration(seconds: 8));
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw QuoteRequestException(response.statusCode);
    }

    try {
      final json = jsonDecode(response.body);
      if (json is! Map<String, dynamic> || json['data'] is! Map) {
        throw const QuoteFormatException();
      }
      final data = Map<String, dynamic>.from(json['data'] as Map);
      if (data['text'] is! String || data['author'] is! String) {
        throw const QuoteFormatException();
      }
      return Quote(
        text: data['text'] as String,
        author: data['author'] as String,
      );
    } on FormatException {
      throw const QuoteFormatException();
    }
  }
}
