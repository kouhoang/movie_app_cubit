import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import '../models/genre.dart';
import '../models/movie.dart';
import '../models/movie_detail.dart';

class DatabaseService {
  static Database? _database;
  static const String _dbName = 'movies.db';
  static const int _dbVersion = 2; // Increment version for schema update

  // Table names
  static const String _moviesTable = 'movies';
  static const String _movieDetailsTable = 'movie_details';
  static const String _genresTable = 'genres';
  static const String _runtimeCacheTable = 'runtime_cache'; // New table

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _dbName);

    return await openDatabase(
      path,
      version: _dbVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Movies table
    await db.execute('''
      CREATE TABLE $_moviesTable (
        id INTEGER PRIMARY KEY,
        title TEXT NOT NULL,
        overview TEXT NOT NULL,
        poster_path TEXT,
        backdrop_path TEXT,
        release_date TEXT NOT NULL,
        vote_average REAL NOT NULL,
        genre_ids TEXT NOT NULL,
        runtime INTEGER DEFAULT 0,
        page_number INTEGER NOT NULL
      )
    ''');

    // Movie details table
    await db.execute('''
      CREATE TABLE $_movieDetailsTable (
        id INTEGER PRIMARY KEY,
        title TEXT NOT NULL,
        overview TEXT NOT NULL,
        poster_path TEXT,
        backdrop_path TEXT,
        release_date TEXT NOT NULL,
        vote_average REAL NOT NULL,
        genres TEXT NOT NULL,
        runtime INTEGER NOT NULL
      )
    ''');

    // Genres table
    await db.execute('''
      CREATE TABLE $_genresTable (
        id INTEGER PRIMARY KEY,
        name TEXT NOT NULL
      )
    ''');

    // Runtime cache table
    await db.execute('''
      CREATE TABLE $_runtimeCacheTable (
        movie_id INTEGER PRIMARY KEY,
        runtime INTEGER NOT NULL,
        cached_at INTEGER NOT NULL
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Add runtime cache table
      await db.execute('''
        CREATE TABLE $_runtimeCacheTable (
          movie_id INTEGER PRIMARY KEY,
          runtime INTEGER NOT NULL,
          cached_at INTEGER NOT NULL
        )
      ''');
    }
  }

  Future<void> saveMovies(List<Movie> movies, int page) async {
    final db = await database;

    for (final movie in movies) {
      await db.insert(_moviesTable, {
        'id': movie.id,
        'title': movie.title,
        'overview': movie.overview,
        'poster_path': movie.posterPath,
        'backdrop_path': movie.backdropPath,
        'release_date': movie.releaseDate,
        'vote_average': movie.voteAverage,
        'genre_ids': jsonEncode(movie.genreIds),
        'runtime': movie.runtime,
        'page_number': page,
      }, conflictAlgorithm: ConflictAlgorithm.replace);
    }
  }

  Future<List<Movie>> getMoviesByPage(int page) async {
    final db = await database;
    final maps = await db.query(
      _moviesTable,
      where: 'page_number = ?',
      whereArgs: [page],
      orderBy: 'id',
    );

    return maps
        .map(
          (map) => Movie(
            id: map['id'] as int,
            title: map['title'] as String,
            overview: map['overview'] as String,
            posterPath: map['poster_path'] as String?,
            backdropPath: map['backdrop_path'] as String?,
            releaseDate: map['release_date'] as String,
            voteAverage: map['vote_average'] as double,
            genreIds: List<int>.from(jsonDecode(map['genre_ids'] as String)),
            runtime: map['runtime'] as int,
          ),
        )
        .toList();
  }

  Future<List<Movie>> getAllCachedMovies() async {
    final db = await database;
    final maps = await db.query(_moviesTable, orderBy: 'page_number, id');

    return maps
        .map(
          (map) => Movie(
            id: map['id'] as int,
            title: map['title'] as String,
            overview: map['overview'] as String,
            posterPath: map['poster_path'] as String?,
            backdropPath: map['backdrop_path'] as String?,
            releaseDate: map['release_date'] as String,
            voteAverage: map['vote_average'] as double,
            genreIds: List<int>.from(jsonDecode(map['genre_ids'] as String)),
            runtime: map['runtime'] as int,
          ),
        )
        .toList();
  }

  Future<void> saveMovieDetail(MovieDetail movieDetail) async {
    final db = await database;

    await db.insert(_movieDetailsTable, {
      'id': movieDetail.id,
      'title': movieDetail.title,
      'overview': movieDetail.overview,
      'poster_path': movieDetail.posterPath,
      'backdrop_path': movieDetail.backdropPath,
      'release_date': movieDetail.releaseDate,
      'vote_average': movieDetail.voteAverage,
      'genres': jsonEncode(movieDetail.genres.map((g) => g.toJson()).toList()),
      'runtime': movieDetail.runtime,
    }, conflictAlgorithm: ConflictAlgorithm.replace);

    // Also cache the runtime separately for quick access
    await cacheMovieRuntime(movieDetail.id, movieDetail.runtime);
  }

  Future<MovieDetail?> getMovieDetail(int movieId) async {
    final db = await database;
    final maps = await db.query(
      _movieDetailsTable,
      where: 'id = ?',
      whereArgs: [movieId],
    );

    if (maps.isEmpty) return null;

    final map = maps.first;
    final genresJson = jsonDecode(map['genres'] as String) as List;
    final genres = genresJson.map((g) => Genre.fromJson(g)).toList();

    return MovieDetail(
      id: map['id'] as int,
      title: map['title'] as String,
      overview: map['overview'] as String,
      posterPath: map['poster_path'] as String?,
      backdropPath: map['backdrop_path'] as String?,
      releaseDate: map['release_date'] as String,
      voteAverage: map['vote_average'] as double,
      genres: genres,
      runtime: map['runtime'] as int,
    );
  }

  // Runtime cache methods
  Future<void> cacheMovieRuntime(int movieId, int runtime) async {
    final db = await database;
    await db.insert(_runtimeCacheTable, {
      'movie_id': movieId,
      'runtime': runtime,
      'cached_at': DateTime.now().millisecondsSinceEpoch,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<int?> getCachedMovieRuntime(int movieId) async {
    final db = await database;
    final maps = await db.query(
      _runtimeCacheTable,
      where: 'movie_id = ?',
      whereArgs: [movieId],
    );

    if (maps.isEmpty) return null;
    return maps.first['runtime'] as int?;
  }

  Future<Map<int, int>> getAllCachedRuntimes() async {
    final db = await database;
    final maps = await db.query(_runtimeCacheTable);

    final runtimeMap = <int, int>{};
    for (final map in maps) {
      runtimeMap[map['movie_id'] as int] = map['runtime'] as int;
    }

    return runtimeMap;
  }

  Future<void> saveGenres(List<Genre> genres) async {
    final db = await database;

    for (final genre in genres) {
      await db.insert(
        _genresTable,
        genre.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }

  Future<List<Genre>> getGenres() async {
    final db = await database;
    final maps = await db.query(_genresTable, orderBy: 'name');

    return maps.map((map) => Genre.fromJson(map)).toList();
  }

  Future<int> getLastCachedPage() async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT MAX(page_number) as max_page FROM $_moviesTable',
    );

    final maxPage = result.first['max_page'];
    return maxPage != null ? maxPage as int : 0;
  }

  Future<void> clearCache() async {
    final db = await database;
    await db.delete(_moviesTable);
    await db.delete(_movieDetailsTable);
    await db.delete(_genresTable);
    await db.delete(_runtimeCacheTable);
  }
}
