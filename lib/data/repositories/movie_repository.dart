import '../models/genre.dart';
import '../models/movie.dart';
import '../models/movie_detail.dart';
import '../services/api_service.dart';
import '../services/database_service.dart';

class MovieRepository {
  final ApiService _apiService;
  final DatabaseService _databaseService;

  MovieRepository({
    required ApiService apiService,
    required DatabaseService databaseService,
  }) : _apiService = apiService,
        _databaseService = databaseService;

  Future<List<Movie>> getMovies(int page, {bool forceRefresh = false}) async {
    try {
      // Try to get from API first
      final response = await _apiService.getPopularMovies(page);

      // Save to cache
      await _databaseService.saveMovies(response.results, page);

      return response.results;
    } catch (e) {
      // If API fails, try to get from cache
      final cachedMovies = await _databaseService.getMoviesByPage(page);

      if (cachedMovies.isNotEmpty) {
        return cachedMovies;
      }

      // If no cache, rethrow the error
      rethrow;
    }
  }

  Future<List<Movie>> getCachedMovies() async {
    return await _databaseService.getAllCachedMovies();
  }

  Future<MovieDetail> getMovieDetail(int movieId) async {
    try {
      // Try to get from API first
      final movieDetail = await _apiService.getMovieDetail(movieId);

      // Save to cache
      await _databaseService.saveMovieDetail(movieDetail);

      return movieDetail;
    } catch (e) {
      // If API fails, try to get from cache
      final cachedDetail = await _databaseService.getMovieDetail(movieId);

      if (cachedDetail != null) {
        return cachedDetail;
      }

      // If no cache, rethrow the error
      rethrow;
    }
  }

  Future<List<Genre>> getGenres() async {
    try {
      // Try to get from API first
      final response = await _apiService.getGenres();

      // Save to cache
      await _databaseService.saveGenres(response.genres);

      return response.genres;
    } catch (e) {
      // If API fails, try to get from cache
      final cachedGenres = await _databaseService.getGenres();

      if (cachedGenres.isNotEmpty) {
        return cachedGenres;
      }

      // If no cache, rethrow the error
      rethrow;
    }
  }

  Future<int> getLastCachedPage() async {
    return await _databaseService.getLastCachedPage();
  }

  Future<void> clearCache() async {
    await _databaseService.clearCache();
  }

  void dispose() {
    _apiService.dispose();
  }
}