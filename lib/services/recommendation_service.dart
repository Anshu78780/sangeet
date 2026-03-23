import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/song.dart';

class RecommendationService {
  static const String _baseUrl = 'https://vibra-server-v33i.onrender.com';

  static Future<List<Song>> getRecommendations(String trackId, {int limit = 50}) async {
    if (trackId.trim().isEmpty) {
      return [];
    }

    try {
      final url = '$_baseUrl/recommended/$trackId?limit=$limit';
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) {
        return [];
      }

      final responseBody = utf8.decode(response.bodyBytes);
      final jsonData = jsonDecode(responseBody);

      if (jsonData is! Map<String, dynamic>) {
        return [];
      }

      final rootRecommendations = jsonData['recommendations'];
      if (rootRecommendations is! Map<String, dynamic>) {
        return [];
      }

      final recommendationsData = rootRecommendations['recommendations'];
      if (recommendationsData is! List) {
        return [];
      }

      final parsed = recommendationsData
          .whereType<Map<String, dynamic>>()
          .map(Song.fromJson)
          .where((song) => song.id.isNotEmpty)
          .where((song) => song.id != trackId)
          .toList();

      final uniqueById = <String, Song>{};
      for (final song in parsed) {
        uniqueById[song.id] = song;
      }

      return uniqueById.values.toList();
    } catch (_) {
      return [];
    }
  }
}