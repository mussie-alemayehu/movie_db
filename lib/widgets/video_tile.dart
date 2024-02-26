import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:movie_db/models/video.dart';
import 'package:movie_db/screens/video_player.dart';

import './youtube_thumbnail.dart';

class VideoTile extends StatelessWidget {
  final Video video;
  final String movieTitle;
  const VideoTile({
    super.key,
    required this.video,
    required this.movieTitle,
  });

  @override
  Widget build(BuildContext context) {
    final description = '$movieTitle | ${video.videoName}';
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ListTile(
          leading: YouTubeThumbnail(videoId: video.key),
          title: Text(
            description,
            maxLines: 3,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
            ),
          ),
          subtitle: Text(
            DateFormat.yMMMd().format(video.time),
            style: const TextStyle(
              color: Colors.white54,
              fontSize: 11,
            ),
          ),
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (ctx) => VideoPlayer(
                videoId: video.key,
                description: description,
              ),
            ),
          ),
        ),
        const Divider(
          color: Colors.white10,
        ),
      ],
    );
  }
}
