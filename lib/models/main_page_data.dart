import './search_category.dart';
import './movie.dart';

class MainPageData {
  final List<Movie> movies;
  final int page;
  final String searchCategory;
  final String searchText;
  final bool isLoading;

  const MainPageData({
    required this.movies,
    required this.page,
    required this.searchCategory,
    required this.searchText,
    this.isLoading = false,
  });

  MainPageData.initial()
      : movies = [],
        page = 0,
        searchCategory = SearchCategory.popular,
        searchText = '',
        isLoading = false;

  MainPageData copyWith({
    List<Movie>? movies,
    int? page,
    String? searchCategory,
    String? searchText,
    bool? isLoading,
  }) {
    return MainPageData(
      movies: movies ?? this.movies,
      page: page ?? this.page,
      searchCategory: searchCategory ?? this.searchCategory,
      searchText: searchText ?? this.searchText,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}
