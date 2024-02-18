import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';

import '../services/movie_service.dart';
import '../models/main_page_data.dart';

class MainPageDataController extends StateNotifier<MainPageData> {
  MainPageDataController([MainPageData? state])
      : super(state ?? MainPageData.initial()) {
    getMovies();
  }

  final movieService = GetIt.instance.get<MovieService>();

  Future<void> getMovies() async {
    try {
      final movies = await movieService.getMovies(
        page: state.page + 1,
        searchCategory: state.searchCategory,
      );
      state = state.copyWith(
        movies: [...state.movies, ...movies],
        page: state.page + 1,
      );
    } catch (e) {
      print('There is some error here man.');
    }
  }

  Future<void> updateSearchCategory(String searchCategory) async {
    final movies = await movieService.getMovies(
      page: 1,
      searchCategory: searchCategory,
    );

    state = state.copyWith(
      movies: movies,
      searchCategory: searchCategory,
      page: 1,
    );
  }
}
