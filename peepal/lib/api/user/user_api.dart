import 'package:dio/dio.dart';
import 'package:logging/logging.dart';
import 'package:peepal/api/auth/exceptions.dart';
import 'package:peepal/api/base.dart';
import 'package:peepal/api/user/exceptions.dart';
import 'package:peepal/api/user/model/user.dart';

class PPUserApi extends PPApiClient {
  @override
  final Logger logger = Logger('PPUserApi');

  @override
  final String endpoint = "/api/user";

  PPUserApi({required super.dio});

  Future<PPUser> getCurrentUser() async {
    try {
      final Response<Map<String, dynamic>> response =
          await dio.get('$endpoint/me');

      if (response.statusCode != 200) {
        if (response.statusCode == 404) {
          throw PPUserNotFoundError();
        }

        throw PPUnexpectedServerError(message: 'Failed to get current user');
      }

      if (response.data?['user'] == null) {
        throw PPUnexpectedServerError(message: 'Failed to get current user');
      }

      final PPUser user = PPUser.fromJson(response.data!['user']);

      logger.info('Current user fetched ${user.id}');

      return user;
    } catch (e) {
      logger.severe('Failed to get current user: $e');
      rethrow;
    }
  }

  Future<PPUser> updateUser({
    String? username,
    String? email,
    PPGender? gender,
  }) async {
    if (username == null && email == null && gender == null) {
      throw ArgumentError('At least one field must be provided');
    }

    try {
      final Response<Map<String, dynamic>> response =
          await dio.put('$endpoint/update', data: {
        if (username != null) 'username': username,
        if (email != null) 'email': email,
        if (gender != null) 'gender': gender.name,
      });

      if (response.statusCode != 200) {
        if (response.statusCode == 400) {
          throw PPUserCredentialsNotAvailableError();
        }

        if (response.statusCode == 404) {
          throw PPUserNotFoundError();
        }

        throw PPUnexpectedServerError(message: 'Failed to update user');
      }

      if (response.data?['user'] == null) {
        throw PPUnexpectedServerError(message: 'Failed to update user');
      }

      final PPUser user = PPUser.fromJson(response.data!['user']);

      logger.info('User updated ${user.id}');

      return user;
    } catch (e) {
      logger.severe('Failed to update user: $e');
      rethrow;
    }
  }
}
