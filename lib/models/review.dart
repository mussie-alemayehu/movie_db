class Review {
  String reviewId;
  String author;
  String authorImageUrl;
  String reviewContent;
  int rating;
  DateTime lastUpdated;

  Review(Map<String, dynamic> review)
      : reviewId = review['id'],
        author = review['author'],
        authorImageUrl = review['author_details']['avatar_path'] ?? '',
        reviewContent = review['content'],
        rating = review['rating'],
        lastUpdated = DateTime.parse(review['updated_at']);
}
