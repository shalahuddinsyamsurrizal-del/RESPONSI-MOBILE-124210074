import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/article.dart';

class NewsService {
  static const String baseUrl =
      'https://api.spaceflightnewsapi.net/v4/articles/';

  Future<List<Article>> fetchNews() async {
    try {
      final uri = Uri.parse(
        baseUrl,
      ).replace(queryParameters: {'limit': '10', 'ordering': '-published_at'});

      final response = await http.get(uri).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);

        final List<dynamic> results = data['results'];

        return results.map((item) => Article.fromJson(item)).toList();
      } else {
        throw Exception(
          'Gagal mengambil berita. Status: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Terjadi kesalahan: $e');
    }
  }
}
