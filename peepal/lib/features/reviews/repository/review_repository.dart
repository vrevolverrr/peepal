import 'package:peepal/features/reviews/model/review.dart';

abstract class ReviewRepository {
  Future<List<Review>> fetchReviewsByToiletId(String toiletId);
}