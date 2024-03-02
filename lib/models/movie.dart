import 'package:get_it/get_it.dart';

import '../models/app_config.dart';

class Movie {
  final int id;
  final String name;
  final String language;
  final bool isAdult;
  final String description;
  final String posterPath;
  final String backdropPath;
  final double rating;
  final String releaseDate;

  Movie.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        name = json['title'],
        language = json['original_language'],
        isAdult = json['adult'],
        description = json['overview'],
        posterPath = json['poster_path'] ?? '',
        backdropPath = json['backdrop_path'] ?? '',
        rating = json['vote_average'],
        releaseDate = json['release_date'];

  String posterUrl() {
    final appConfig = GetIt.instance.get<AppConfig>();
    return '${appConfig.baseImageApiUrl}$posterPath';
  }

  String backdropUrl() {
    final appConfig = GetIt.instance.get<AppConfig>();
    return backdropPath == ''
        ? 'https://images.hdqwalls.com/download/sylvester-stallone-as-barney-ross-in-the-expendables-4-py-1080x1920.jpg'
        : '${appConfig.baseImageApiUrl}$backdropPath';
  }
}
