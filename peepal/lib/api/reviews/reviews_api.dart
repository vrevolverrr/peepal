import 'dart:io';

import 'package:dio/dio.dart';
import 'package:logging/logging.dart';
import 'package:peepal/api/auth/exceptions.dart';
import 'package:peepal/api/base.dart';
import 'package:peepal/api/enums.dart';
import 'package:peepal/api/images/images_api.dart';
import 'package:peepal/api/reviews/exceptions.dart';
import 'package:peepal/api/reviews/model/review.dart';
import 'package:peepal/api/toilets/exceptions.dart';
import 'package:peepal/api/toilets/model/toilet.dart';

/// API client for managing toilet reviews.
///
/// Provides functionality to create, read, update, and delete reviews,
/// as well as report inappropriate content. Reviews can include text and images.
class PPReviewsApi extends PPApiClient {
  @override
  final Logger logger = Logger('PPReviewsApi');

  @override
  final String endpoint = "/api/reviews";

  /// API client for handling image uploads.
  final PPImagesApi imageApi;

  /// Cache of reviews by toilet ID to reduce API calls.
  final Map<String, List<PPReview>> _reviewsCache = {};

  /// Creates a new reviews API client.
  ///
  /// [dio] HTTP client for making API requests.
  /// [imageApi] API client for handling image uploads.
  PPReviewsApi({required super.dio, required this.imageApi});

  /// Retrieves reviews for a specific toilet.
  ///
  /// [toilet] The toilet to get reviews for.
  /// [offset] Number of reviews to skip for pagination.
  /// [sort] Field to sort reviews by (date, rating).
  /// [order] Sort order (ascending or descending).
  ///
  /// Returns a list of [PPReview] objects. Uses a cache to avoid redundant API calls.
  ///
  /// Throws a [PPToiletNotFoundError] if the toilet doesn't exist.
  /// Throws a [PPUnexpectedServerError] if the server returns an unexpected error.
  Future<List<PPReview>> getReviewsByToilet(
      {required PPToilet toilet,
      int offset = 0,
      PPSortField sort = PPSortField.date,
      PPSortOrder order = PPSortOrder.desc}) async {
    if (_reviewsCache.containsKey(toilet.id)) {
      return _reviewsCache[toilet.id]!;
    }
    try {
      final Response<Map<String, dynamic>> response =
          await dio.get("$endpoint/toilet/${toilet.id}", queryParameters: {
        'offset': offset,
        'sort': sort.value,
        'order': order.value,
      });

      if (response.statusCode != 200) {
        if (response.statusCode == 404) {
          throw PPToiletNotFoundError();
        }

        throw PPUnexpectedServerError(message: 'Failed to get reviews');
      }

      if (response.data?['reviews'] == null) {
        throw PPUnexpectedServerError(message: 'Failed to get reviews');
      }

      final List<dynamic> reviewsData = response.data!['reviews'];

      final List<PPReview> reviews =
          reviewsData.map((e) => PPReview.fromJson(e)).toList();

      logger.info('Reviews fetched for toilet ${toilet.id}');

      _reviewsCache[toilet.id] = reviews;
      return reviews;
    } catch (e) {
      logger.severe('Failed to get reviews: $e');
      rethrow;
    }
  }

  /// Posts a new review for a toilet.
  ///
  /// [toilet] The toilet being reviewed.
  /// [rating] Rating score for the toilet (typically 1-5).
  /// [reviewText] Optional text content of the review.
  /// [image] Optional image file to attach to the review.
  ///
  /// Returns the created [PPReview] object.
  /// If an image is provided, it will be uploaded using [imageApi].
  ///
  /// Throws a [PPUnexpectedServerError] if the server returns an unexpected error.
  Future<PPReview> postReview({
    required PPToilet toilet,
    required int rating,
    String? reviewText,
    File? image,
  }) async {
    try {
      final imageToken = image != null
          ? await imageApi.uploadImage(image: image, type: 'review')
          : null;

      final Response<Map<String, dynamic>> response =
          await dio.post('$endpoint/create', data: {
        'toiletId': toilet.id,
        'rating': rating,
        if (reviewText != null) 'reviewText': reviewText,
        if (imageToken != null) 'imageToken': imageToken,
      });

      if (response.statusCode != 201) {
        throw PPUnexpectedServerError(message: 'Failed to post review');
      }

      if (response.data?['review'] == null) {
        throw PPUnexpectedServerError(message: 'Failed to post review');
      }

      final Map<String, dynamic> reviewData = response.data!['review'];
      final PPReview review = PPReview.fromJson(reviewData);

      return review;
    } catch (e) {
      logger.severe('Failed to post review: $e');
      rethrow;
    }
  }

  /// Edits an existing review.
  ///
  /// [oldReview] The review to edit.
  /// [rating] Optional new rating score.
  /// [reviewText] Optional new review text.
  ///
  /// Returns the updated [PPReview] object.
  ///
  /// Throws a [PPReviewNotFoundError] if the review doesn't exist.
  /// Throws a [PPReviewForbiddenError] if user isn't allowed to edit the review.
  /// Throws a [PPReviewNothingToUpdateError] if no changes were provided.
  /// Throws a [PPUnexpectedServerError] if the server returns an unexpected error.
  Future<PPReview> editReview({
    required PPReview oldReview,
    int? rating,
    String? reviewText,
  }) async {
    try {
      final Response<Map<String, dynamic>> response =
          await dio.patch('$endpoint/edit/${oldReview.id}', data: {
        'rating': rating,
        if (reviewText != null) 'reviewText': reviewText,
      });

      if (response.statusCode != 200) {
        if (response.statusCode == 400) {
          throw PPReviewNothingToUpdateError();
        }

        if (response.statusCode == 404) {
          throw PPReviewNotFoundError();
        }

        if (response.statusCode == 403) {
          throw PPReviewForbiddenError();
        }

        throw PPUnexpectedServerError(message: 'Failed to edit review');
      }

      if (response.data?['review'] == null) {
        throw PPUnexpectedServerError(message: 'Failed to edit review');
      }

      final Map<String, dynamic> reviewData = response.data!['review'];
      final PPReview review = PPReview.fromJson(reviewData);
      return review;
    } catch (e) {
      logger.severe('Failed to edit review: $e');
      rethrow;
    }
  }

  /// Reports a review for inappropriate content.
  ///
  /// [review] The review to report.
  ///
  /// Returns true if the review was deleted due to too many reports,
  /// false if it was only flagged.
  ///
  /// Throws a [PPReviewNotFoundError] if the review doesn't exist.
  /// Throws a [PPUnexpectedServerError] if the server returns an unexpected error.
  Future<bool> reportReview({required PPReview review}) async {
    try {
      final Response<Map<String, dynamic>> response =
          await dio.post('$endpoint/report/${review.id}');

      if (response.statusCode != 200) {
        if (response.statusCode == 404) {
          throw PPReviewNotFoundError();
        }

        throw PPUnexpectedServerError(message: 'Failed to report review');
      }

      if (response.data?['deleted'] == null) {
        throw PPUnexpectedServerError(message: 'Failed to report review');
      }

      return response.data!['deleted'];
    } catch (e) {
      logger.severe('Failed to report review: $e');
      rethrow;
    }
  }

  /// Deletes a review.
  ///
  /// [review] The review to delete.
  ///
  /// Throws a [PPReviewNotFoundError] if the review doesn't exist.
  /// Throws a [PPReviewForbiddenError] if user isn't allowed to delete the review.
  /// Throws a [PPUnexpectedServerError] if the server returns an unexpected error.
  Future<void> deleteReview({required PPReview review}) async {
    try {
      final Response<Map<String, dynamic>> response =
          await dio.delete('$endpoint/delete/${review.id}');

      if (response.statusCode != 200) {
        if (response.statusCode == 404) {
          throw PPReviewNotFoundError();
        }

        if (response.statusCode == 403) {
          throw PPReviewForbiddenError();
        }

        throw PPUnexpectedServerError(message: 'Failed to delete review');
      }
    } catch (e) {
      logger.severe('Failed to delete review: $e');
      rethrow;
    }
  }
}
