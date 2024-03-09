import 'package:get_it/get_it.dart';

import './app_config.dart';

class Review {
  String reviewId;
  String author;
  String authorImageUrl;
  String reviewContent;
  double rating;
  DateTime lastUpdated;

  Review(Map<String, dynamic> review)
      : reviewId = review['id'],
        author = review['author'],
        authorImageUrl = review['author_details']['avatar_path'] ?? '',
        reviewContent = review['content'],
        rating = review['author_details']['rating'],
        lastUpdated = DateTime.parse(review['updated_at']);

  String getAvatarUrl() {
    if (authorImageUrl == '') {
      return '';
    }
    final url =
        '${GetIt.instance.get<AppConfig>().baseImageApiUrl}$authorImageUrl';
    return url;
  }
}
