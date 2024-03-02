import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:movie_db/services/movie_service.dart';
import 'package:movie_db/widgets/video_tile.dart';

class VideosScreen extends StatelessWidget {
  final String backdropPath;
  final String movieTitle;
  final int movieId;

  const VideosScreen({
    super.key,
    required this.movieTitle,
    required this.backdropPath,
    required this.movieId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _backgroundImage(),
          _foregroundElements(context),
        ],
      ),
    );
  }

  Widget _backgroundImage() {
    return Stack(
      children: [
        SizedBox(
          width: double.infinity,
          height: double.infinity,
          child: CachedNetworkImage(
            imageUrl: backdropPath,
            placeholder: (context, url) => Image.asset(
              'assets/images/placeholder_movie_image.jpg',
              fit: BoxFit.cover,
            ),
            fit: BoxFit.cover,
          ),
        ),
        BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12.0, sigmaY: 12.0),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.2),
            ),
          ),
        ),
      ],
    );
  }

  Widget _foregroundElements(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          margin:
              EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.06),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              IconButton(
                icon: const Icon(
                  Icons.arrow_back,
                  color: Colors.white,
                ),
                onPressed: () => Navigator.of(context).pop(),
              ),
              Expanded(
                child: Text(
                  movieTitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
        const Divider(
          color: Colors.white24,
          height: 4,
        ),
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
