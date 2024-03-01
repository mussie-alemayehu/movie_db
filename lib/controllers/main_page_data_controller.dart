import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';

import '../services/movie_service.dart';
import '../models/search_category.dart';
import '../models/main_page_data.dart';

class MainPageDataController extends StateNotifier<MainPageData> {
  MainPageDataController([MainPageData? state])
      : super(state ?? MainPageData.initial());

  final movieService = GetIt.instance.get<MovieService>();

  Future<void> updateSearchCategory(String searchCategory) async {
    state = state.copyWith(
      searchCategory: searchCategory,
      searchText: '',
    );
  }

  Future<void> updateSearchText(String searchText) async {
    state = state.copyWith(
      searchCategory: SearchCategory.none,
      searchText: searchText,
    );
  }
}
