class Video {
  final String key;
  final int movieId;
  final String videoName;
  final DateTime time;

  Video(Map<String, dynamic> video, int id)
      : key = video['key'],
        movieId = id,
        videoName = video['name'],
        time = DateTime.parse(video['published_at']);
}
