import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/review.dart';

class ReviewTile extends StatelessWidget {
  final Review review;

  const ReviewTile({
    super.key,
    required this.review,
  });

  @override
  Widget build(BuildContext context) {
    final placeholderImage = Image.asset(
      'assets/images/people_placeholder.png',
      fit: BoxFit.cover,
    );

    final side = min(MediaQuery.of(context).size.width * 0.2, 60).toDouble();
    final lastUpdated = 'Last updated: '
        '${DateFormat(DateFormat.YEAR_ABBR_MONTH_DAY).format(review.lastUpdated)}';

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 8.0,
        vertical: 6,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              SizedBox(
                width: side,
                height: side,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(side / 2),
                  child: review.getAvatarUrl().isEmpty
                      ? placeholderImage
                      : CachedNetworkImage(
                          imageUrl: review.getAvatarUrl(),
                          placeholder: (ctx, _) => placeholderImage,
                          fit: BoxFit.cover,
                        ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        review.author,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        lastUpdated,
                        style: const TextStyle(
                          color: Colors.white60,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.all(12),
            child: Text(
              review.reviewContent,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
