import 'package:flutter/material.dart';

class YouTubeThumbnail extends StatelessWidget {
  final String videoId;
  final String thumbnailEndpoint = 'https://img.youtube.com/vi';

  const YouTubeThumbnail({super.key, required this.videoId});

  @override
  Widget build(BuildContext context) {
    String thumbnailUrl = '$thumbnailEndpoint/$videoId/default.jpg';

    return SizedBox(
      height: 40,
      width: 60,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            Center(
              child: SizedBox(
                height: 40,
                width: 60,
                child: Image.network(
                  thumbnailUrl,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Center(
              child: Icon(
                Icons.play_arrow_rounded,
                color: Colors.red.shade300,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
