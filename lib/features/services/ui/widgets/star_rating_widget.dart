import 'package:flutter/material.dart';

/// A reusable widget for displaying star ratings, numerical value, and reviews.
/// - Shows stars (full/half/empty) based on double rating.
/// - Options to show/hide rating, reviews, stars, and parentheses styles.
class RatingStarsWidget extends StatelessWidget {
  final String rating;
  final String reviews;
  final bool showRating; // Show stars row based on rating value
  final bool showStar; // Show a single star icon
  final bool showReviews; // Show review count
  final bool showRatingInP; // Show rating in parenthesis (e.g. "(4.3)")
  final bool showRatingInNp; // Show rating without parenthesis (e.g. "4.3")

  const RatingStarsWidget({
    super.key,
    required this.rating,
    required this.reviews,
    this.showRating = false,
    this.showStar = true,
    this.showReviews = true,
    this.showRatingInP = false,
    this.showRatingInNp = true,
  });

  @override
  Widget build(BuildContext context) {
    final double ratingValue = double.tryParse(rating) ?? 0.0;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Star row based on double value if enabled
        if (showRating)
          ...List.generate(5, (index) {
            if (index < ratingValue.floor()) {
              return const Icon(Icons.star, color: Colors.orange, size: 20);
            } else if (index < ratingValue && ratingValue - index >= 0.5) {
              return const Icon(
                Icons.star_half,
                color: Colors.orange,
                size: 20,
              );
            } else {
              return const Icon(
                Icons.star_border,
                color: Colors.amber,
                size: 16,
              );
            }
          }),
        // Single star if enabled (default)
        if (showStar) const Icon(Icons.star, color: Colors.orange, size: 20),
        const SizedBox(width: 4),
        // Show rating (number) in different styles
        if (showRatingInNp)
          Text(
            rating,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade600,
            ),
          ),
        if (showRatingInP)
          Text(
            '($rating)',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade600,
            ),
          ),
        const SizedBox(width: 4),
        // Show review count if enabled (default)
        if (showReviews)
          Text(
            '($reviews Reviews)',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade600,
            ),
          ),
      ],
    );
  }
}
