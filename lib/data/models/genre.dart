import 'package:equatable/equatable.dart';

class Genre extends Equatable {
  final int id;
  final String name;

  const Genre({
    required this.id,
    required this.name,
  });

  factory Genre.fromJson(Map<String, dynamic> json) {
    return Genre(
      id: json['id'] as int,
      name: json['name'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }

  @override
  List<Object> get props => [id, name];
}

class GenresResponse extends Equatable {
  final List<Genre> genres;

  const GenresResponse({required this.genres});

  factory GenresResponse.fromJson(Map<String, dynamic> json) {
    return GenresResponse(
      genres: (json['genres'] as List)
          .map((genre) => Genre.fromJson(genre))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'genres': genres.map((genre) => genre.toJson()).toList(),
    };
  }

  @override
  List<Object> get props => [genres];
}