import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/repositories/movie_repository.dart';
import 'movie_detail_state.dart';

class MovieDetailCubit extends Cubit<MovieDetailState> {
  final MovieRepository _repository;

  MovieDetailCubit({required MovieRepository repository})
    : _repository = repository,
      super(MovieDetailInitial());

  Future<void> loadMovieDetail(int movieId) async {
    if (state is MovieDetailLoading) return;

    emit(MovieDetailLoading());

    try {
      final movieDetail = await _repository.getMovieDetail(movieId);
      emit(MovieDetailLoaded(movie: movieDetail));
    } catch (e) {
      emit(
        MovieDetailError(
          message: 'Failed to load movie details: ${e.toString()}',
        ),
      );
    }
  }
}
