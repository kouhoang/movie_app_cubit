import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/repositories/movie_repository.dart';
import '../../../data/models/movie.dart';
import 'movie_list_state.dart';

class MovieListCubit extends Cubit<MovieListState> {
  final MovieRepository _repository;

  MovieListCubit({required MovieRepository repository})
    : _repository = repository,
      super(MovieListInitial());

  Future<void> loadMovies() async {
    if (state is MovieListLoading) return;

    emit(MovieListLoading());

    try {
      // Load genres first
      final genres = await _repository.getGenres();

      // Load first page of movies
      final movies = await _repository.getMovies(1);

      emit(
        MovieListLoaded(
          movies: movies,
          genres: genres,
          currentPage: 1,
          hasReachedMax: movies.length < 20,
        ),
      );
    } catch (e) {
      // Try to load cached data
      try {
        final cachedMovies = await _repository.getCachedMovies();
        final cachedGenres = await _repository.getGenres();

        if (cachedMovies.isNotEmpty) {
          emit(MovieListOffline(movies: cachedMovies, genres: cachedGenres));
        } else {
          emit(
            MovieListError(
              message: 'Failed to load movies: ${e.toString()}',
              isOffline: true,
            ),
          );
        }
      } catch (cacheError) {
        emit(MovieListError(message: 'Failed to load movies: ${e.toString()}'));
      }
    }
  }

  Future<void> loadMoreMovies() async {
    final currentState = state;
    if (currentState is! MovieListLoaded ||
        currentState.hasReachedMax ||
        currentState.isLoadingMore) {
      return;
    }

    emit(currentState.copyWith(isLoadingMore: true));

    try {
      final nextPage = currentState.currentPage + 1;
      final newMovies = await _repository.getMovies(nextPage);

      final allMovies = List<Movie>.from(currentState.movies)
        ..addAll(newMovies);

      emit(
        currentState.copyWith(
          movies: allMovies,
          currentPage: nextPage,
          hasReachedMax: newMovies.length < 20,
          isLoadingMore: false,
        ),
      );
    } catch (e) {
      emit(currentState.copyWith(isLoadingMore: false));
      // You might want to show a snackbar or toast here
    }
  }

  Future<void> refreshMovies() async {
    try {
      // Load genres
      final genres = await _repository.getGenres();

      // Load first page of movies
      final movies = await _repository.getMovies(1, forceRefresh: true);

      emit(
        MovieListLoaded(
          movies: movies,
          genres: genres,
          currentPage: 1,
          hasReachedMax: movies.length < 20,
        ),
      );
    } catch (e) {
      // Keep current state and show error message
      // You might want to show a snackbar or toast here
    }
  }

  @override
  Future<void> close() {
    _repository.dispose();
    return super.close();
  }
}
