import 'package:get_it/get_it.dart';

import '../models/review.dart';
import '../models/movie.dart';
import '../models/search_category.dart';
import '../models/video.dart';
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
    List<Movie> movies;
    try {
      final response = await http.get(
        '/movie/${sendableCategory(searchCategory)}',
        additionalQuery: {'page': page},
      );
      if (response == null) {
        movies = [];
      } else if (response.statusCode == 200) {
        movies = response.data['results'].map<Movie>((movie) {
          return Movie.fromJson(movie);
        }).toList();
      } else {
        throw Exception("Connection error.");
      }
    } catch (error) {
      rethrow;
    }
    return movies;
  }

  Future<List<Movie>> searchMovies({
    required String searchText,
    required int page,
  }) async {
    List<Movie> movies;
    try {
      final response = await http.get(
        '/search/movie',
        additionalQuery: {
          'query': searchText,
          'language': 'en-US',
          'page': page,
        },
      );
      if (response == null) {
        movies = [];
      } else if (response.statusCode == 200) {
        movies = (response.data['results'] as List).map<Movie>((movie) {
          return Movie.fromJson(movie);
        }).toList();
      } else {
        throw Exception("Connection error.");
      }
    } catch (error) {
      rethrow;
    }
    return movies;
  }

  Future<List<Video>> getVideos(int id) async {
    List<Video> videos;
    try {
      final response = await http.get('/movie/$id/videos');
      if (response!.statusCode == 200) {
        videos = (response.data['results'] as List).map<Video>(
          (video) {
            return Video(video, id);
          },
        ).toList();
      } else {
        throw Exception("Connection error.");
      }
    } catch (error) {
      rethrow;
    }

    return videos;
  }

  Future<List<Review>> getReviews(int id) async {
    List<Review> reviews;
    try {
      final response = await http.get('/movie/$id/reviews');
      if (response!.statusCode == 200) {
        reviews = (response.data['results'] as List).map<Review>(
          (review) {
            return Review(review);
          },
        ).toList();
      } else {
        throw Exception("Connection error.");
      }
    } catch (error) {
      rethrow;
    }

    return reviews;
  }
}
