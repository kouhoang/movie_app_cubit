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

  const MovieListLoaded({
    required this.movies,
    required this.genres,
    required this.currentPage,
    required this.hasReachedMax,
    this.isLoadingMore = false,
  });

  MovieListLoaded copyWith({
    List<Movie>? movies,
    List<Genre>? genres,
    int? currentPage,
    bool? hasReachedMax,
    bool? isLoadingMore,
  }) {
    return MovieListLoaded(
      movies: movies ?? this.movies,
      genres: genres ?? this.genres,
      currentPage: currentPage ?? this.currentPage,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }

  String getGenreNames(List<int> genreIds) {
    final movieGenres = genres
        .where((genre) => genreIds.contains(genre.id))
        .map((genre) => genre.name)
        .toList();

    return movieGenres.isNotEmpty ? movieGenres.first : 'Action';
  }

  @override
  List<Object?> get props => [movies, genres, currentPage, hasReachedMax, isLoadingMore];
}

class MovieListError extends MovieListState {
  final String message;
  final bool isOffline;

  const MovieListError({
    required this.message,
    this.isOffline = false,
  });

  @override
  List<Object?> get props => [message, isOffline];
}

class MovieListOffline extends MovieListState {
  final List<Movie> movies;
  final List<Genre> genres;

  const MovieListOffline({
    required this.movies,
    required this.genres,
  });

  String getGenreNames(List<int> genreIds) {
    final movieGenres = genres
        .where((genre) => genreIds.contains(genre.id))
        .map((genre) => genre.name)
        .toList();

    return movieGenres.isNotEmpty ? movieGenres.first : 'Action';
  }

  @override
  List<Object?> get props => [movies, genres];
}