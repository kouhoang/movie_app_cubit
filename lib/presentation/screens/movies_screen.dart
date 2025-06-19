import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../data/models/movie.dart';
import '../cubits/movie_list/movie_list_cubit.dart';
import '../cubits/movie_list/movie_list_state.dart';
import 'movie_detail_screen.dart';

class MoviesScreen extends StatefulWidget {
  const MoviesScreen({super.key});

  @override
  State<MoviesScreen> createState() => _MoviesScreenState();
}

class _MoviesScreenState extends State<MoviesScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    context.read<MovieListCubit>().loadMovies();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_isBottom) {
      context.read<MovieListCubit>().loadMoreMovies();
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.9);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1C1C1E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1C1C1E),
        elevation: 0,
        title: const Text(
          'Movies',
          style: TextStyle(
            color: Colors.white,
            fontSize: 34,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
      ),
      body: BlocBuilder<MovieListCubit, MovieListState>(
        builder: (context, state) {
          if (state is MovieListLoading) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.blue),
            );
          }

          if (state is MovieListError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    color: Colors.red,
                    size: 64,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    state.isOffline ? 'No internet connection' : 'Something went wrong',
                    style: const TextStyle(color: Colors.white, fontSize: 18),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    state.message,
                    style: const TextStyle(color: Colors.grey, fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.read<MovieListCubit>().loadMovies(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (state is MovieListOffline) {
            return Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  color: Colors.orange.withOpacity(0.2),
                  child: const Text(
                    'Showing cached movies (offline)',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.orange),
                  ),
                ),
                Expanded(
                  child: _buildMoviesList(state.movies, state.getGenreNames, false),
                ),
              ],
            );
          }

          if (state is MovieListLoaded) {
            return RefreshIndicator(
              onRefresh: () => context.read<MovieListCubit>().refreshMovies(),
              color: Colors.blue,
              backgroundColor: const Color(0xFF2C2C2E),
              child: _buildMoviesList(
                state.movies,
                state.getGenreNames,
                state.isLoadingMore,
              ),
            );
          }

          return const SizedBox();
        },
      ),
    );
  }

  Widget _buildMoviesList(
      List<Movie> movies,
      String Function(List<int>) getGenreNames,
      bool isLoadingMore,
      ) {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: movies.length + (isLoadingMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index >= movies.length) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: CircularProgressIndicator(color: Colors.blue),
            ),
          );
        }

        final movie = movies[index];
        return _buildMovieItem(movie, getGenreNames);
      },
    );
  }

  Widget _buildMovieItem(Movie movie, String Function(List<int>) getGenreNames) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MovieDetailScreen(movieId: movie.id),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Movie Poster
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                width: 80,
                height: 120,
                child: movie.posterPath != null
                    ? CachedNetworkImage(
                  imageUrl: movie.fullPosterUrl,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    color: const Color(0xFF2C2C2E),
                    child: const Icon(
                      Icons.movie,
                      color: Colors.grey,
                      size: 32,
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: const Color(0xFF2C2C2E),
                    child: const Icon(
                      Icons.movie,
                      color: Colors.grey,
                      size: 32,
                    ),
                  ),
                )
                    : Container(
                  color: const Color(0xFF2C2C2E),
                  child: const Icon(
                    Icons.movie,
                    color: Colors.grey,
                    size: 32,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            // Movie Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    movie.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  // Rating
                  Row(
                    children: [
                      const Icon(
                        Icons.star,
                        color: Colors.amber,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        movie.formattedRating,
                        style: const TextStyle(
                          color: Colors.amber,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  // Genre
                  Row(
                    children: [
                      const Icon(
                        Icons.local_movies,
                        color: Colors.grey,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        getGenreNames(movie.genreIds),
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  // Year
                  Row(
                    children: [
                      const Icon(
                        Icons.calendar_month,
                        color: Colors.grey,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        movie.year,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                  if (movie.runtime > 0) ...[
                    const SizedBox(height: 4),
                    // Runtime
                    Row(
                      children: [
                        const Icon(
                          Icons.access_time,
                          color: Colors.grey,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          movie.runtimeFormatted,
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}