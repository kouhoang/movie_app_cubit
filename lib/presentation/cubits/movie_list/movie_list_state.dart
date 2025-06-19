import 'package:equatable/equatable.dart';
import '../../../data/models/movie.dart';
import '../../../data/models/genre.dart';

abstract class MovieListState extends Equatable {
  const MovieListState();

  @override
  List<Object?> get props => [];
}

class MovieListInitial extends MovieListState {}

class MovieListLoading extends MovieListState {}

class MovieListLoaded extends MovieListState {
  final List<Movie> movies;
  final List<Genre> genres;
  final int currentPage;
  final bool hasReachedMax;
  final bool isLoadingMore;
  final Map<int, int> runtimeCache; // movieId -> runtime in minutes

  const MovieListLoaded({
    required this.movies,
    required this.genres,
    required this.currentPage,
    required this.hasReachedMax,
    this.isLoadingMore = false,
    this.runtimeCache = const {},
  });

  MovieListLoaded copyWith({
    List<Movie>? movies,
    List<Genre>? genres,
    int? currentPage,
    bool? hasReachedMax,
    bool? isLoadingMore,
    Map<int, int>? runtimeCache,
  }) {
    return MovieListLoaded(
      movies: movies ?? this.movies,
      genres: genres ?? this.genres,
      currentPage: currentPage ?? this.currentPage,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      runtimeCache: runtimeCache ?? this.runtimeCache,
    );
  }

  String getGenreNames(List<int> genreIds) {
    final movieGenres = genres
        .where((genre) => genreIds.contains(genre.id))
        .map((genre) => genre.name)
        .toList();

    return movieGenres.isNotEmpty ? movieGenres.first : 'Action';
  }

  // Get runtime for a movie, return null if not loaded yet
  int? getMovieRuntime(int movieId) {
    return runtimeCache[movieId];
  }

  // Get formatted runtime string
  String getFormattedRuntime(int movieId) {
    final runtime = runtimeCache[movieId];
    if (runtime == null || runtime <= 0) return '';
    return '$runtime minutes';
  }

  @override
  List<Object?> get props => [
    movies,
    genres,
    currentPage,
    hasReachedMax,
    isLoadingMore,
    runtimeCache,
  ];
}

class MovieListError extends MovieListState {
  final String message;
  final bool isOffline;

  const MovieListError({required this.message, this.isOffline = false});

  @override
  List<Object?> get props => [message, isOffline];
}

class MovieListOffline extends MovieListState {
  final List<Movie> movies;
  final List<Genre> genres;
  final Map<int, int> runtimeCache;

  const MovieListOffline({
    required this.movies,
    required this.genres,
    this.runtimeCache = const {},
  });

  String getGenreNames(List<int> genreIds) {
    final movieGenres = genres
        .where((genre) => genreIds.contains(genre.id))
        .map((genre) => genre.name)
        .toList();

    return movieGenres.isNotEmpty ? movieGenres.first : 'Action';
  }

  // Get runtime for a movie, return null if not loaded yet
  int? getMovieRuntime(int movieId) {
    return runtimeCache[movieId];
  }

  // Get formatted runtime string
  String getFormattedRuntime(int movieId) {
    final runtime = runtimeCache[movieId];
    if (runtime == null || runtime <= 0) return '';
    return '$runtime minutes';
  }

  @override
  List<Object?> get props => [movies, genres, runtimeCache];
}
