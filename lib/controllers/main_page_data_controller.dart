import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';

import '../services/movie_service.dart';
import '../models/movie.dart';
import '../models/search_category.dart';
import '../models/main_page_data.dart';

class MainPageDataController extends StateNotifier<MainPageData> {
  MainPageDataController([MainPageData? state])
      : super(state ?? MainPageData.initial()) {
    getMovies();
  }

  final movieService = GetIt.instance.get<MovieService>();

  Future<void> getMovies() async {
    try {
      List<Movie> movies;
      if (state.searchText.isEmpty) {
        print('getting movies....');
        movies = await movieService.getMovies(
          page: state.page + 1,
          searchCategory: state.searchCategory,
        );
      } else {
        print('searching movies....');
        movies = await movieService.searchMovies(
          state.searchText,
          page: state.page + 1,
        );
      }
      if (movies.isNotEmpty) {
        print('number of received movies: ${movies.length}');
        state = state.copyWith(
          movies: [...state.movies, ...movies],
          page: state.page + 1,
          isLoading: false,
        );
        movies = [];
      } else {
        print('no movies received');
      }

      print('total movies: ${state.movies.length}');
    } catch (e) {
      print('There is some error here man.');
    }
    ;
  }

  Future<void> updateSearchCategory(String searchCategory) async {
    state = state.copyWith(
      movies: [],
      searchCategory: searchCategory,
      searchText: '',
      page: 0,
      isLoading: true,
    );
    getMovies();
  }

  Future<void> performMovieSearch(String searchText) async {
    state = state.copyWith(
      movies: [],
      searchCategory: SearchCategory.none,
      searchText: searchText,
      isLoading: true,
    );
    getMovies();
  }
}
