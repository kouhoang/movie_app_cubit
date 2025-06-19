import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'data/repositories/movie_repository.dart';
import 'data/services/api_service.dart';
import 'data/services/database_service.dart';
import 'presentation/cubits/movie_list/movie_list_cubit.dart';
import 'presentation/screens/movies_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Movie App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: const Color(0xFF1C1C1E),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1C1C1E),
          elevation: 0,
        ),
      ),
      home: BlocProvider(
        create: (context) => MovieListCubit(
          repository: MovieRepository(
            apiService: ApiService(),
            databaseService: DatabaseService(),
          ),
        ),
        child: const MoviesScreen(),
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}
