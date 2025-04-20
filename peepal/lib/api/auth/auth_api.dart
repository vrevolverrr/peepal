import 'package:dio/dio.dart';
import 'package:logging/logging.dart';
import 'package:peepal/api/base.dart';
import 'package:peepal/api/auth/exceptions.dart';
import 'package:peepal/api/constants.dart';
import 'package:peepal/api/user/model/user.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// API client for user authentication and authorization.
///
/// Handles user registration, login, and logout operations.
/// Manages authentication tokens using shared preferences for persistence.
final class PPAuthApi extends PPApiClient {
  @override
  final Logger logger = Logger('PPAuthApi');

  @override
  final String endpoint = "/auth";

  /// Shared preferences instance for storing authentication tokens.
  final SharedPreferencesWithCache prefs;

  /// Whether the user is currently authenticated.
  ///
  /// Returns true if an authentication token exists in shared preferences.
  bool get isAuthenticated => prefs.containsKey(PP_AUTH_KEY);

  /// Creates a new authentication API client.
  ///
  /// [dio] HTTP client for making API requests.
  /// [prefs] Shared preferences instance for token persistence.
  PPAuthApi({required super.dio, required this.prefs});

  /// Registers a new user account.
  ///
  /// [username] Desired username for the new account.
  /// [password] User's password (will be hashed server-side).
  /// [email] User's email address for account verification.
  /// [gender] User's gender for profile customization.
  ///
  /// Returns a [PPUser] object representing the newly created account.
  /// Also stores the authentication token in shared preferences.
  ///
  /// Throws a [PPUserAlreadyExistsError] if the email is already registered.
  /// Throws a [PPUnexpectedServerError] if the server returns an unexpected error.
  Future<PPUser> signUp(
      {required String username,
      required String password,
      required String email,
      required PPGender gender}) async {
    try {
      final response = await dio.post('$endpoint/signup', data: {
        'username': username,
        'password': password,
        'email': email,
        'gender': gender.name,
      });

      if (response.statusCode != 200) {
        if (response.statusCode == 400) {
          throw PPUserAlreadyExistsError();
        }

        throw PPUnexpectedServerError(message: 'Failed to signup');
      }

      final authToken = response.data['token'];

      if (authToken == null) {
        logger.warning('Failed to get auth token');
        throw PPUnexpectedServerError(message: 'Failed to get auth token');
      }

      logger.info('Signup successful, auth token: $authToken');

      /// Save auth token to shared preferences
      await prefs.setString(PP_AUTH_KEY, authToken!);

      return PPUser.fromJson(response.data['user']);
    } catch (e) {
      logger.severe('Failed to signup: $e');
      rethrow;
    }
  }

  /// Authenticates a user with their credentials.
  ///
  /// [email] User's registered email address.
  /// [password] User's password.
  ///
  /// Returns a [PPUser] object representing the authenticated user.
  /// Also stores the authentication token in shared preferences.
  ///
  /// Throws a [PPInvalidCredentialsError] if credentials are incorrect.
  /// Throws a [PPUnexpectedServerError] if the server returns an unexpected error.
  Future<PPUser> login(
      {required String email, required String password}) async {
    try {
      final Response<Map<String, dynamic>> response =
          await dio.post('$endpoint/login', data: {
        'email': email,
        'password': password,
      });

      if (response.statusCode != 200) {
        if (response.statusCode == 401) {
          throw PPInvalidCredentialsError();
        }

        throw PPUnexpectedServerError(message: 'Failed to login');
      }

      final authToken = response.data!["token"];

      if (authToken == null) {
        logger.warning('Failed to get auth token');
        throw PPUnexpectedServerError(message: 'Failed to get auth token');
      }

      /// Save auth token to shared preferences
      await prefs.setString(PP_AUTH_KEY, authToken!);

      logger.info('Login successful, auth token: $authToken');

      return PPUser.fromJson(response.data!['user']);
    } catch (e) {
      logger.severe('Failed to login: $e');
      rethrow;
    }
  }

  /// Logs out the current user.
  ///
  /// Removes the authentication token from shared preferences.
  /// This will cause [isAuthenticated] to return false.
  Future<void> logout() async {
    await prefs.remove(PP_AUTH_KEY);
  }
}
