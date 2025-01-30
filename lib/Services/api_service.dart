import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:newzify/Models/news.dart';

class ApiService {
  final String techCrunchUrl =
      'https://newsapi.org/v2/top-headlines?sources=techcrunch&apiKey=1ea28493a8634e19bfe4a36aa7ea1031';
  final String businessUrl =
      'https://newsapi.org/v2/top-headlines?country=us&category=business&apiKey=1ea28493a8634e19bfe4a36aa7ea1031';
  final String sports =
      'https://newsapi.org/v2/top-headlines?country=us&category=business&apiKey=1ea28493a8634e19bfe4a36aa7ea1031';
  final String technology =
      'https://newsapi.org/v2/everything?q=apple&from=2025-01-28&to=2025-01-28&sortBy=popularity&apiKey=1ea28493a8634e19bfe4a36aa7ea1031';
  final String bollywood =
      'https://newsapi.org/v2/everything?domains=wsj.com&apiKey=1ea28493a8634e19bfe4a36aa7ea1031';

  Future<List<News>> fetchSportsNews() async {
    return await _fetchData(sports);
  }

  Future<List<News>> fetchTechnologyNews() async {
    return await _fetchData(technology);
  }

  Future<List<News>> fetchBollywoodNews() async {
    return await _fetchData(bollywood);
  }

  Future<List<News>> fetchTechCrunchNews() async {
    return await _fetchData(techCrunchUrl);
  }

  Future<List<News>> fetchBusinessNews() async {
    return await _fetchData(businessUrl);
  }

  Future<List<News>> _fetchData(String url) async {
    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        print("Response Data: $data");

        if (data.containsKey('articles')) {
          List<dynamic> articles = data['articles'];

          if (articles.isNotEmpty) {
            return articles.map((article) => News.fromJson(article)).toList();
          } else {
            throw Exception('No articles found');
          }
        } else {
          throw Exception('No "articles" key found in the response');
        }
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      print("Error: $e");
      throw Exception('Failed to fetch data: $e');
    }
  }
}
