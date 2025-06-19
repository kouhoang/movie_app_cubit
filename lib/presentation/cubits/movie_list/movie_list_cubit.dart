import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/repositories/movie_repository.dart';
import '../../../data/models/movie.dart';
import 'movie_list_state.dart';

class MovieListCubit extends Cubit<MovieListState> {
  final MovieRepository _repository;
  final Map<int, int> _runtimeCache = {}; // Cache runtime by movie ID

  MovieListCubit({required MovieRepository repository})
    : _repository = repository,
      super(MovieListInitial());

  Future<void> loadMovies() async {
    if (state is MovieListLoading) return;

    emit(MovieListLoading());

    try {
      // Load cached runtime data first
      final cachedRuntimes = await _repository.getCachedRuntimes();
      _runtimeCache.addAll(cachedRuntimes);

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
          runtimeCache: Map.from(_runtimeCache),
        ),
      );

      // Load runtime for visible movies (first 10)
      _loadRuntimeForMovies(movies.take(10).toList());
    } catch (e) {
      // Try to load cached data
      try {
        final cachedMovies = await _repository.getCachedMovies();
        final cachedGenres = await _repository.getGenres();
        final cachedRuntimes = await _repository.getCachedRuntimes();
        _runtimeCache.addAll(cachedRuntimes);

        if (cachedMovies.isNotEmpty) {
          emit(
            MovieListOffline(
              movies: cachedMovies,
              genres: cachedGenres,
              runtimeCache: Map.from(_runtimeCache),
            ),
          );
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
          runtimeCache: Map.from(_runtimeCache),
        ),
      );

      // Load runtime for new movies
      _loadRuntimeForMovies(newMovies);
    } catch (e) {
      emit(currentState.copyWith(isLoadingMore: false));
    }
  }

  Future<void> refreshMovies() async {
    try {
      // Clear runtime cache on refresh
      _runtimeCache.clear();

      // Load cached runtime data
      final cachedRuntimes = await _repository.getCachedRuntimes();
      _runtimeCache.addAll(cachedRuntimes);

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
          runtimeCache: Map.from(_runtimeCache),
        ),
      );

      // Load runtime for visible movies
      _loadRuntimeForMovies(movies.take(10).toList());
    } catch (e) {
      // Keep current state and show error message
    }
  }

  // Load runtime for visible movies
  Future<void> loadRuntimeForVisibleMovies(List<int> visibleMovieIds) async {
    final moviesToLoad = visibleMovieIds
        .where((id) => !_runtimeCache.containsKey(id))
        .toList();

    if (moviesToLoad.isEmpty) return;

    for (final movieId in moviesToLoad) {
      _loadMovieRuntime(movieId);
    }
  }

  Future<void> _loadRuntimeForMovies(List<Movie> movies) async {
    for (final movie in movies) {
      if (!_runtimeCache.containsKey(movie.id)) {
        _loadMovieRuntime(movie.id);
      }
    }
  }

  Future<void> _loadMovieRuntime(int movieId) async {
    try {
      final runtime = await _repository.getMovieRuntime(movieId);
      if (runtime != null) {
        _runtimeCache[movieId] = runtime;

        // Update state with new runtime
        final currentState = state;
        if (currentState is MovieListLoaded) {
          emit(currentState.copyWith(runtimeCache: Map.from(_runtimeCache)));
        } else if (currentState is MovieListOffline) {
          emit(
            MovieListOffline(
              movies: currentState.movies,
              genres: currentState.genres,
              runtimeCache: Map.from(_runtimeCache),
            ),
          );
        }
      }
    } catch (e) {
      // Runtime loading failed, but don't affect main flow
    }
  }

  @override
  Future<void> close() {
    _repository.dispose();
    return super.close();
  }
}
