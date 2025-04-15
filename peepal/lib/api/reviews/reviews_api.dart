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

class PPReviewsApi extends PPApiClient {
  @override
  final Logger logger = Logger('PPReviewsApi');

  @override
  final String endpoint = "/api/reviews";

  final PPImagesApi imageApi;

  final Map<String, List<PPReview>> _reviewsCache = {};

  PPReviewsApi({required super.dio, required this.imageApi});

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
