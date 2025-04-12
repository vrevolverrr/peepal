import 'dart:io';

import 'package:dio/dio.dart';
import 'package:logging/logging.dart';
import 'package:peepal/client/auth/exceptions.dart';
import 'package:peepal/client/base.dart';
import 'package:peepal/client/images/exceptions.dart';

final class PPImagesApi extends PPApiClient {
  @override
  final Logger logger = Logger('PPImagesApi');

  @override
  final String endpoint = "/api/images";

  PPImagesApi({required super.dio});

  Future<String> getImageUrl({required String token}) async {
    try {
      final Response<Map<String, dynamic>> response =
          await dio.get('$endpoint/$token');

      if (response.statusCode != 200) {
        if (response.statusCode == 400) {
          throw PPImageNotFoundError();
        }

        throw PPUnexpectedServerError(message: 'Failed to get image URL');
      }

      if (response.data?['url'] == null) {
        throw PPUnexpectedServerError(message: 'Failed to get image URL');
      }

      return response.data!['url'];
    } catch (e) {
      logger.severe('Failed to get image: $e');
      rethrow;
    }
  }

  Future<String> uploadImage({required File image}) async {
    try {
      String fileName = image.path.split('/').last;
      FormData formData = FormData.fromMap({
        "file": await MultipartFile.fromFile(image.path, filename: fileName),
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
