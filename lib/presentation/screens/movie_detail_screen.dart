import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../cubits/movie_detail/movie_detail_cubit.dart';
import '../cubits/movie_detail/movie_detail_state.dart';
import '../../data/models/movie_detail.dart';
import '../../data/repositories/movie_repository.dart';
import '../../data/services/api_service.dart';
import '../../data/services/database_service.dart';
import 'package:google_fonts/google_fonts.dart';

class MovieDetailScreen extends StatelessWidget {
  final int movieId;

  const MovieDetailScreen({super.key, required this.movieId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => MovieDetailCubit(
        repository: MovieRepository(
          apiService: ApiService(),
          databaseService: DatabaseService(),
        ),
      )..loadMovieDetail(movieId),
      child: Scaffold(
        backgroundColor: const Color(0xFF1C1C1E),
        body: BlocBuilder<MovieDetailCubit, MovieDetailState>(
          builder: (context, state) {
            if (state is MovieDetailLoading) {
              return const Center(
                child: CircularProgressIndicator(color: Colors.blue),
              );
            }

            if (state is MovieDetailError) {
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
                    const Text(
                      'Failed to load movie details',
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      state.message,
                      style: const TextStyle(color: Colors.grey, fontSize: 14),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        context.read<MovieDetailCubit>().loadMovieDetail(
                          movieId,
                        );
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            if (state is MovieDetailLoaded) {
              return _buildMovieDetail(context, state.movie, state.isOffline);
            }

            return const SizedBox();
          },
        ),
      ),
    );
  }

  Widget _buildMovieDetail(
    BuildContext context,
    MovieDetail movie,
    bool isOffline,
  ) {
    return Scaffold(
      backgroundColor: const Color(0xFF1C1C1E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1C1C1E),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Detail',
          style: TextStyle(
            color: Colors.white,
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.bookmark, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            if (isOffline)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                color: Colors.orange.withOpacity(0.2),
                child: const Text(
                  'Viewing cached content (offline)',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.orange),
                ),
              ),
            // Backdrop with overlapping poster
            Stack(
              clipBehavior: Clip.none, // Allow overflow
              children: [
                // Backdrop image
                SizedBox(
                  height: 200,
                  width: double.infinity,
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(16),
                      bottomRight: Radius.circular(16),
                    ),
                    child: movie.backdropPath != null
                        ? CachedNetworkImage(
                            imageUrl: movie.fullBackdropUrl,
                            fit: BoxFit.cover,
                            placeholder: (context, url) =>
                                Container(color: Color(0xFF2C2C2E)),
                            errorWidget: (context, url, error) =>
                                Container(color: Color(0xFF2C2C2E)),
                          )
                        : Container(color: Color(0xFF2C2C2E)),
                  ),
                ),

                // Poster
                Positioned(
                  left: 16,
                  top: 110,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: SizedBox(
                      width: 110,
                      height: 165,
                      child: movie.posterPath != null
                          ? CachedNetworkImage(
                              imageUrl: movie.fullPosterUrl,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Container(
                                color: const Color(0xFF2C2C2E),
                                child: const Icon(
                                  Icons.movie,
                                  color: Colors.grey,
                                  size: 48,
                                ),
                              ),
                              errorWidget: (context, url, error) => Container(
                                color: const Color(0xFF2C2C2E),
                                child: const Icon(
                                  Icons.movie,
                                  color: Colors.grey,
                                  size: 48,
                                ),
                              ),
                            )
                          : Container(
                              color: const Color(0xFF2C2C2E),
                              child: const Icon(
                                Icons.movie,
                                color: Colors.grey,
                                size: 48,
                              ),
                            ),
                    ),
                  ),
                ),
                // Rating positioned at bottom right of backdrop
                Positioned(
                  right: 16,
                  bottom: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.star_border,
                          color: Colors.amber,
                          size: 18,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          movie.formattedRating,
                          style: const TextStyle(
                            color: Colors.amber,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            // Title
            Padding(
              padding: const EdgeInsets.fromLTRB(142, 16, 16, 0),
              child: Text(
                movie.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.5,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.left,
              ),
            ),

            const SizedBox(height: 40),

            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Movie metadata row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Year with calendar icon
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.calendar_today,
                            color: Colors.grey,
                            size: 14,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            movie.year,
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 12),
                      // Separator dot
                      Container(
                        width: 4,
                        height: 4,
                        decoration: const BoxDecoration(
                          color: Colors.grey,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Runtime with clock icon
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.access_time,
                            color: Colors.grey,
                            size: 14,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            movie.runtimeFormatted,
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 12),
                      // Separator dot
                      Container(
                        width: 4,
                        height: 4,
                        decoration: const BoxDecoration(
                          color: Colors.grey,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Genre with tag icon
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.local_offer,
                            color: Colors.grey,
                            size: 14,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            movie.genres.isNotEmpty
                                ? movie.genres.first.name
                                : 'Action',
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Description
                  Text(
                    movie.overview,
                    style: GoogleFonts.roboto(
                      color: Colors.white,
                      fontSize: 15,
                      height: 1.4,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
