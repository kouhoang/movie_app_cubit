import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/movie_detail.dart';
import '../models/genre.dart';
import '../models/movie_response.dart';

class ApiService {
  static const String _baseUrl = 'https://api.themoviedb.org/3';

  // Replace with your actual API key and access token
  static const String _apiKey = '0a92b29a7ad82c578fc6d806742432cd';
  static const String _accessToken = 'eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiIwYTkyYjI5YTdhZDgyYzU3OGZjNmQ4MDY3NDI0MzJjZCIsIm5iZiI6MTc0OTc4MTY5NC4zMDMsInN1YiI6IjY4NGI4Y2JlYjFkMzYyY2Y2OGIwZDc0MiIsInNjb3BlcyI6WyJhcGlfcmVhZCJdLCJ2ZXJzaW9uIjoxfQ.zjSi00_dIJPIvLAd0TQ8awbiFTf8FWi60oNoyla6O-g';

  final http.Client _client;

  ApiService({http.Client? client}) : _client = client ?? http.Client();

  Map<String, String> get _headers => {
    'Authorization': 'Bearer $_accessToken',
    'Content-Type': 'application/json',
  };

  Future<MoviesResponse> getPopularMovies(int page) async {
    final url = '$_baseUrl/movie/popular?page=$page';

    try {
      final response = await _client.get(
        Uri.parse(url),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return MoviesResponse.fromJson(json);
      } else {
        throw Exception('Failed to load movies: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load movies: $e');
    }
  }

  Future<MovieDetail> getMovieDetail(int movieId) async {
    final url = '$_baseUrl/movie/$movieId';

    try {
      final response = await _client.get(
        Uri.parse(url),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return MovieDetail.fromJson(json);
      } else {
        throw Exception('Failed to load movie detail: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load movie detail: $e');
    }
  }

  Future<GenresResponse> getGenres() async {
    final url = '$_baseUrl/genre/movie/list';

    try {
      final response = await _client.get(
        Uri.parse(url),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return GenresResponse.fromJson(json);
      } else {
        throw Exception('Failed to load genres: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load genres: $e');
    }
  }

  void dispose() {
    _client.close();
  }
}