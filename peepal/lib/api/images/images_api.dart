import 'dart:io';

import 'package:dio/dio.dart';
import 'package:logging/logging.dart';
import 'package:peepal/api/auth/exceptions.dart';
import 'package:peepal/api/base.dart';
import 'package:peepal/api/images/exceptions.dart';

/// API client for managing image uploads and retrievals.
///
/// Provides functionality to upload images and retrieve their URLs.
/// Images are stored on the server and accessed via tokens.
/// Supports different image types (toilet, review, etc.).
final class PPImagesApi extends PPApiClient {
  @override
  final Logger logger = Logger('PPImagesApi');

  @override
  final String endpoint = "/api/images";

  /// Cache of image URLs by token to reduce API calls.
  ///
  /// Maps image tokens to their corresponding URLs.
  final Map<String, String> _cache = {};

  /// Creates a new images API client.
  ///
  /// [dio] HTTP client for making API requests.
  /// The client must be configured with appropriate authentication headers.
  PPImagesApi({required super.dio});

  /// Retrieves the URL for an image using its token.
  ///
  /// [token] The unique token identifying the image.
  ///
  /// Returns the URL where the image can be accessed.
  /// Uses a cache to avoid redundant API calls for the same token.
  ///
  /// Throws [PPImageNotFoundError] if the image token is invalid.
  /// Throws [PPUnexpectedServerError] if the server returns an unexpected error.
  /// Throws [PPNotAuthenticatedError] if the user is not authenticated.
  Future<String> getImageUrl({required String token}) async {
    if (_cache.containsKey(token)) {
      return _cache[token]!;
    }

    try {
      final Response<Map<String, dynamic>> response =
          await dio.get('$endpoint/get', queryParameters: {'token': token});

      if (response.statusCode != 200) {
        if (response.statusCode == 400) {
          throw PPImageNotFoundError();
        }

        throw PPUnexpectedServerError(message: 'Failed to get image URL');
      }

      if (response.data?['url'] == null) {
        throw PPUnexpectedServerError(message: 'Failed to get image URL');
      }

      final url = response.data!['url'];
      _cache[token] = url;

      return url;
    } catch (e) {
      logger.severe('Failed to get image: $e');
      rethrow;
    }
  }

  /// Uploads an image file to the server.
  ///
  /// [image] The image file to upload.
  /// [type] The type of image ('toilet' or 'review').
  ///
  /// Returns a token that can be used to retrieve the image URL
  /// using [getImageUrl].
  ///
  /// Throws [PPUnexpectedServerError] if the upload fails.
  /// Throws [PPNotAuthenticatedError] if the user is not authenticated.
  Future<String> uploadImage(
      {required File image, required String type}) async {
    try {
      String fileName = image.path.split('/').last;
      FormData formData = FormData.fromMap({
        "image": await MultipartFile.fromFile(image.path, filename: fileName),
        "type": type,
      });

      final Response<Map<String, dynamic>> response =
          await dio.post('$endpoint/upload', data: formData);

      if (response.statusCode != 201) {
        throw PPUnexpectedServerError(message: 'Failed to upload image');
      }

      if (response.data?['token'] == null) {
        throw PPUnexpectedServerError(message: 'Failed to upload image');
      }

      return response.data!['token'];
    } catch (e) {
      logger.severe('Failed to upload image: $e');
      rethrow;
    }
  }
}
