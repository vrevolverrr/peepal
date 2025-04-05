import 'package:peepal/shared/auth/model/user.dart';

class Review {
  final PPUser user; // Reference to the user who wrote the review
  final String profilePicture; // Path to the user's profile picture
  final String timeAgo; // e.g., "1h ago", "2h ago"
  final String comment; // The review comment
  final double rating; // Rating out of 5

  const Review({
    required this.user,
    required this.profilePicture,
    required this.timeAgo,
    required this.comment,
    required this.rating,
  });
}