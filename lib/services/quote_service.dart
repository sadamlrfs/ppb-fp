import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class QuoteModel {
  final String text;
  final String author;

  const QuoteModel({required this.text, required this.author});
}

class QuoteService {
  static String get _baseUrl =>
      dotenv.env['ZENQUOTES_BASE_URL'] ?? 'https://zenquotes.io/api';

  Future<QuoteModel> fetchRandomQuote() async {
    try {
      final res = await http
          .get(Uri.parse('$_baseUrl/random'))
          .timeout(const Duration(seconds: 5));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as List;
        return QuoteModel(
          text: data[0]['q'] ?? '',
          author: data[0]['a'] ?? '',
        );
      }
    } catch (_) {}
    return const QuoteModel(
      text:
          'Kesehatan mental sama pentingnya dengan kesehatan fisik.',
      author: 'MindEase',
    );
  }
}
