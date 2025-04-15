import 'dart:io';

import 'package:dio/dio.dart';
import 'package:logging/logging.dart';
import 'package:peepal/api/auth/exceptions.dart';
import 'package:peepal/api/base.dart';
import 'package:peepal/api/images/exceptions.dart';

final class PPImagesApi extends PPApiClient {
  @override
  final Logger logger = Logger('PPImagesApi');

  @override
  final String endpoint = "/api/images";

  final Map<String, String> _cache = {};

  PPImagesApi({required super.dio});

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
