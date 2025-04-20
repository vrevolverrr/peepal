import 'package:dio/dio.dart';
import 'package:logging/logging.dart';
import 'package:peepal/api/auth/exceptions.dart';
import 'package:peepal/api/base.dart';
import 'package:peepal/api/user/exceptions.dart';
import 'package:peepal/api/user/model/user.dart';

/// API client for managing user profiles.
///
/// Provides functionality to retrieve and update user information.
/// All methods require authentication and will throw appropriate errors
/// if the user is not authenticated or the token is invalid.
class PPUserApi extends PPApiClient {
  @override
  final Logger logger = Logger('PPUserApi');

  @override
  final String endpoint = "/api/user";

  /// Creates a new user API client.
  ///
  /// [dio] HTTP client for making API requests.
  /// The client must be configured with appropriate authentication headers.
  PPUserApi({required super.dio});

  /// Retrieves the currently authenticated user's profile.
  ///
  /// Returns a [PPUser] object containing the user's profile information.
  ///
  /// Throws a [PPUserNotFoundError] if the user doesn't exist.
  /// Throws a [PPUnexpectedServerError] if the server returns an unexpected error.
  /// Throws a [PPNotAuthenticatedError] if the user is not authenticated.
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

  /// Updates the currently authenticated user's profile.
  ///
  /// At least one of the following parameters must be provided:
  /// * [username] New username
  /// * [email] New email address
  /// * [gender] New gender
  ///
  /// Returns a [PPUser] object containing the updated profile information.
  ///
  /// Throws [ArgumentError] if no update parameters are provided.
  /// Throws [PPUserCredentialsNotAvailableError] if the new credentials are taken.
  /// Throws [PPUserNotFoundError] if the user doesn't exist.
  /// Throws [PPUnexpectedServerError] if the server returns an unexpected error.
  /// Throws [PPNotAuthenticatedError] if the user is not authenticated.
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
