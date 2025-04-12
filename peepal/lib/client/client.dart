import 'package:dio/dio.dart';
import 'package:peepal/client/auth/auth_api.dart';
import 'package:peepal/client/toilets/toilet_api.dart';
import 'package:peepal/client/auth/exceptions.dart';
import 'package:peepal/client/constants.dart';
import 'package:peepal/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

export 'auth/auth_api.dart';
export 'constants.dart';

final class PPClient {
  static bool _isInitialized = false;

  static final Dio dio = Dio();
  static late final SharedPreferencesWithCache prefs;

  static late final PPAuthApi auth;
  static late final PPToiletApi toilets;

  static Future<void> init() async {
    if (_isInitialized) return;

    prefs = await SharedPreferencesWithCache.create(
      cacheOptions: const SharedPreferencesWithCacheOptions(),
    );

    await prefs.reloadCache();

    if (debugMode) {
      dio.options.baseUrl = 'http://127.0.0.1:3000';
    } else {
      // TODO: Replace with production URL
      dio.options.baseUrl = 'https://api.peepal.com';
    }

    dio.options.connectTimeout = const Duration(seconds: 60);
    dio.options.receiveTimeout = const Duration(seconds: 60);

    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        /// Add auth token to request headers
        final String authToken = prefs.getString(PP_AUTH_KEY) ?? '';
        options.headers['Authorization'] = 'Bearer $authToken';
        handler.next(options);
      },
      onResponse: (response, handler) {
        if (response.statusCode == 401 &&
            response.data['error'] == 'No token provided') {
          if (prefs.getString(PP_AUTH_KEY) != null) {
            auth.logout();
          }

          throw PPNotAuthenticatedError();
        } else if (response.statusCode == 500) {
          throw PPUnexpectedServerError(
              message: response.data['error'] ?? 'Unknown error');
        } else if (response.statusCode == 400) {
          throw PPBadRequestError(
              message: response.data['error'] ?? 'Unknown error');
        }

        handler.next(response);
      },
    ));

    auth = PPAuthApi(dio: dio, prefs: prefs);
    toilets = PPToiletApi(dio: dio);

    _isInitialized = true;
  }
}
