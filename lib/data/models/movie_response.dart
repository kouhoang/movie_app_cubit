import 'package:equatable/equatable.dart';
import 'movie.dart';

class MoviesResponse extends Equatable {
  final int page;
  final int totalPages;
  final int totalResults;
  final List<Movie> results;

  const MoviesResponse({
    required this.page,
    required this.totalPages,
    required this.totalResults,
    required this.results,
  });

  factory MoviesResponse.fromJson(Map<String, dynamic> json) {
    return MoviesResponse(
      page: json['page'] as int,
      totalPages: json['total_pages'] as int,
      totalResults: json['total_results'] as int,
      results: (json['results'] as List)
          .map((movie) => Movie.fromJson(movie))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'page': page,
      'total_pages': totalPages,
      'total_results': totalResults,
      'results': results.map((movie) => movie.toJson()).toList(),
    };
  }

  @override
  List<Object> get props => [page, totalPages, totalResults, results];
}