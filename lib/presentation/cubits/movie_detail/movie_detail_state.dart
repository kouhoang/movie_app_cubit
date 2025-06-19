import 'package:equatable/equatable.dart';
import '../../../data/models/movie_detail.dart';

abstract class MovieDetailState extends Equatable {
  const MovieDetailState();

  @override
  List<Object?> get props => [];
}

class MovieDetailInitial extends MovieDetailState {}

class MovieDetailLoading extends MovieDetailState {}

class MovieDetailLoaded extends MovieDetailState {
  final MovieDetail movie;
  final bool isOffline;

  const MovieDetailLoaded({
    required this.movie,
    this.isOffline = false,
  });

  @override
  List<Object?> get props => [movie, isOffline];
}

class MovieDetailError extends MovieDetailState {
  final String message;

  const MovieDetailError({required this.message});

  @override
  List<Object?> get props => [message];
}