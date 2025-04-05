import 'package:peepal/features/reviews/model/review.dart';
import 'package:peepal/shared/auth/model/user.dart';
import 'package:peepal/features/reviews/repository/review_repository.dart';

class ReviewRepositoryImpl implements ReviewRepository {
  final List<Review> _mockReviews = [
    Review(
      user: const PPUser(
        id: "1",
        name: "John Doe",
        email: "johndoe@example.com",
      ),
      profilePicture: "assets/images/loopy1.png",
      timeAgo: "1h ago",
      comment: "Very clean and well-maintained!",
      rating: 5.0,
    ),
    Review(
      user: const PPUser(
        id: "2",
        name: "Jane Smith",
        email: "janesmith@example.com",
      ),
      profilePicture: "assets/images/loopy1.png",
      timeAgo: "2h ago",
      comment: "Could use more sanitizer.",
      rating: 4.0,
    ),
  ];

  @override
  Future<List<Review>> fetchReviewsByToiletId(String toiletId) async {
    // Simulate a delay to mimic network request
    await Future.delayed(const Duration(seconds: 1));
    return _mockReviews;
  }

  void addReview(Review review) {
    _mockReviews.add(review);
  }
}