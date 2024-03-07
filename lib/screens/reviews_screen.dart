import 'package:flutter/material.dart';

import '../widgets/review_tile.dart';
import '../services/movie_service.dart';

class ReviewsScreen extends StatelessWidget {
  final int id;

  const ReviewsScreen(this.id, {super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: FutureBuilder(
            future: MovieService().getReviews(id),
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
                final reviews = snapshot.data;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: (reviews == null || reviews.isEmpty)
                      ? const Padding(
                          padding: EdgeInsets.symmetric(vertical: 15),
                          child: Text(
                            'No reviews at the moment.',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(0),
                          itemCount: reviews.length,
                          itemBuilder: (context, index) {
                            return ReviewTile(
                              review: reviews[index],
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
