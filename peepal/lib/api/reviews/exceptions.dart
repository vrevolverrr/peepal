class PPReviewNotFoundError extends Error {
  PPReviewNotFoundError();

  @override
  String toString() => 'Review not found';
}

class PPReviewNothingToUpdateError extends Error {
  @override
  String toString() => 'Nothing to update';
}

class PPReviewForbiddenError extends Error {
  @override
  String toString() => 'You are not authorized to delete this review';
}
