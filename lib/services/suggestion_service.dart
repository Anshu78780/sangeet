import 'dart:convert';

import 'package:http/http.dart' as http;

class SuggestionService {
  static const String _baseUrl = 'https://suggestqueries.google.com/complete/search';

  static Future<List<String>> getSuggestions(String query) async {
    if (query.trim().isEmpty) {
      return [];
    }

    try {
      final encodedQuery = Uri.encodeQueryComponent(query.trim());
      final url = '$_baseUrl?client=firefox&ds=yt&q=$encodedQuery';

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:91.0) Gecko/20100101 Firefox/91.0',
          'Accept': 'application/json, text/plain, */*',
          'Accept-Language': 'en-US,en;q=0.5',
          'DNT': '1',
          'Connection': 'keep-alive',
        },
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final responseBody = utf8.decode(response.bodyBytes);
        final jsonData = jsonDecode(responseBody);

        if (jsonData is List && jsonData.length >= 2 && jsonData[1] is List) {
          return (jsonData[1] as List)
              .map((item) => item.toString())
              .where((suggestion) => suggestion.isNotEmpty)
              .take(8)
              .toList();
        }
      }
    } catch (_) {}

    return [];
  }
}