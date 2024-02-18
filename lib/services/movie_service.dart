import 'package:get_it/get_it.dart';

import '../models/movie.dart';
import '../models/search_category.dart';
import './http_service.dart';

class MovieService {
  final getIt = GetIt.instance;
  late HTTPService http;

  MovieService() {
    http = getIt.get<HTTPService>();
  }

  String sendableCategory(String receivedCategory) {
    switch (receivedCategory) {
      case SearchCategory.popular:
        return 'popular';
      case SearchCategory.topRated:
        return 'top_rated';
      case SearchCategory.upcoming:
        return 'upcoming';
      default:
        return '';
    }
  }

  Future<List<Movie>> getMovies({
    required int page,
    required String searchCategory,
  }) async {
    print(page);
    print(sendableCategory(searchCategory));
    final response = await http.get(
      '/movie/${sendableCategory(searchCategory)}',
      additionalQuery: {'page': page},
    );
    List<Movie> movies;
    if (response == null) {
      movies = [];
    } else if (response.statusCode == 200) {
      movies = response.data['results'].map<Movie>((movie) {
        return Movie.fromJson(movie);
      }).toList();
    } else {
      print('Couldn\'t load popular movies');
      movies = [];
    }
    return movies;
  }
}
