import 'package:flutter/material.dart';

import '../services/movie_service.dart';
import '../widgets/video_tile.dart';

class VideosScreen extends StatelessWidget {
  final String movieTitle;
  final int movieId;

  const VideosScreen({
    super.key,
    required this.movieTitle,
    required this.movieId,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: FutureBuilder(
            future: MovieService().getVideos(movieId),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(
                    backgroundColor: Colors.white,
                  ),
                );
              } else if (snapshot.hasError) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 15),
                  child: Text(
                    'An error occured.',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                );
              } else {
                final videos = snapshot.data;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: (videos == null || videos.isEmpty)
                      ? const Padding(
                          padding: EdgeInsets.symmetric(vertical: 15),
                          child: Text(
                            'No videos at the moment.',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(0),
                          itemCount: videos.length,
                          itemBuilder: (context, index) {
                            return VideoTile(
                              movieTitle: movieTitle,
                              video: videos[index],
                            );
                          },
                        ),
                );
              }
            },
          ),
        ),
      ],
    );
  }
}
