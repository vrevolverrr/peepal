import 'package:dio/dio.dart';
import 'package:logging/logging.dart';
import 'package:peepal/client/base.dart';
import 'package:peepal/client/auth/exceptions.dart';
import 'package:peepal/client/constants.dart';
import 'package:peepal/client/auth/model/user.dart';
import 'package:shared_preferences/shared_preferences.dart';

final class PPAuthApi extends PPApiClient {
  @override
  final Logger logger = Logger('PPAuthApi');

  @override
  final String endpoint = "/auth";

  final SharedPreferencesWithCache prefs;

  PPAuthApi({required super.dio, required this.prefs});

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

  Future<void> logout() async {
    await prefs.remove(PP_AUTH_KEY);
  }
}
