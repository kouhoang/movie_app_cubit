import 'package:equatable/equatable.dart';
import 'genre.dart';

class MovieDetail extends Equatable {
  final int id;
  final String title;
  final String overview;
  final String? posterPath;
  final String? backdropPath;
  final String releaseDate;
  final double voteAverage;
  final List<Genre> genres;
  final int runtime;

  const MovieDetail({
    required this.id,
    required this.title,
    required this.overview,
    this.posterPath,
    this.backdropPath,
    required this.releaseDate,
    required this.voteAverage,
    required this.genres,
    required this.runtime,
  });

  factory MovieDetail.fromJson(Map<String, dynamic> json) {
    return MovieDetail(
      id: json['id'] as int,
      title: json['title'] as String,
      overview: json['overview'] as String,
      posterPath: json['poster_path'] as String?,
      backdropPath: json['backdrop_path'] as String?,
      releaseDate: json['release_date'] as String,
      voteAverage: (json['vote_average'] as num).toDouble(),
      genres: (json['genres'] as List)
          .map((genre) => Genre.fromJson(genre))
          .toList(),
      runtime: json['runtime'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'overview': overview,
      'poster_path': posterPath,
      'backdrop_path': backdropPath,
      'release_date': releaseDate,
      'vote_average': voteAverage,
      'genres': genres.map((genre) => genre.toJson()).toList(),
      'runtime': runtime,
    };
  }

  String get fullPosterUrl => posterPath != null
      ? 'https://image.tmdb.org/t/p/w500$posterPath'
      : '';

  String get fullBackdropUrl => backdropPath != null
      ? 'https://image.tmdb.org/t/p/w780$backdropPath'
      : '';

  String get year => releaseDate.isNotEmpty ? releaseDate.split('-')[0] : '';

  String get formattedRating => voteAverage.toStringAsFixed(1);

  String get runtimeFormatted {
    if (runtime <= 0) return '';
    final hours = runtime ~/ 60;
    final minutes = runtime % 60;
    return hours > 0 ? '${hours}h ${minutes}m' : '${minutes}m';
  }

  String get genreNames => genres.map((g) => g.name).join(', ');

  @override
  List<Object?> get props => [
    id, title, overview, posterPath, backdropPath,
    releaseDate, voteAverage, genres, runtime
  ];
}