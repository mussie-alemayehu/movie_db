import './search_category.dart';

class MainPageData {
  final String searchCategory;
  final String searchText;

  const MainPageData({
    required this.searchCategory,
    required this.searchText,
  });

  MainPageData.initial()
      : searchCategory = SearchCategory.popular,
        searchText = '';

  MainPageData copyWith({
    String? searchCategory,
    String? searchText,
  }) {
    return MainPageData(
      searchCategory: searchCategory ?? this.searchCategory,
      searchText: searchText ?? this.searchText,
    );
  }
}
