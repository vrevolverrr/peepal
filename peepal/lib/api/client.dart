import 'package:dio/dio.dart';
import 'package:peepal/api/auth/auth_api.dart';
import 'package:peepal/api/favorites/favorites_api.dart';
import 'package:peepal/api/images/images_api.dart';
import 'package:peepal/api/reviews/reviews_api.dart';
import 'package:peepal/api/toilets/toilet_api.dart';
import 'package:peepal/api/auth/exceptions.dart';
import 'package:peepal/api/constants.dart';
import 'package:peepal/api/user/user_api.dart';
import 'package:peepal/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

export 'auth/auth_api.dart';
export 'constants.dart';

/// Main client class for the PeePal application.
///
/// Provides centralized access to all API services and manages the HTTP client
/// configuration. This class follows the singleton pattern and must be initialized
/// before use with [init].
final class PPClient {
  /// Whether the client has been initialized.
  static bool _isInitialized = false;

  /// Global HTTP client instance used by all API services.
  static final Dio dio = Dio();

  /// Shared preferences instance with caching capabilities.
  static late final SharedPreferencesWithCache prefs;

  /// Authentication API service.
  static late final PPAuthApi auth;

  /// Toilets API service for managing toilet locations and details.
  static late final PPToiletApi toilets;

  /// User API service for managing user profiles and settings.
  static late final PPUserApi user;

  /// Images API service for handling image uploads and retrieval.
  static late final PPImagesApi images;

  /// Reviews API service for managing toilet reviews and ratings.
  static late final PPReviewsApi reviews;

  /// Favorites API service for managing user's favorite toilets.
  static late final PPFavoritesApi favorites;

  /// Initializes the PeePal client and all its API services.
  ///
  /// This method must be called before using any API services. It:
  /// * Sets up the shared preferences with caching
  /// * Configures the HTTP client with appropriate timeouts and base URL
  /// * Adds authentication interceptors
  /// * Initializes all API service instances
  ///
  /// Throws [PPUnexpectedServerError] if server returns 500 error.
  /// Throws [PPBadRequestError] if request is malformed (400).
  /// Throws [PPNotAuthenticatedError] if authentication token is invalid or missing.
  static Future<void> init() async {
    if (_isInitialized) return;

    prefs = await SharedPreferencesWithCache.create(
      cacheOptions: const SharedPreferencesWithCacheOptions(),
    );

    await prefs.reloadCache();

    if (kDebugMode) {
      /// Use local development server
      dio.options.baseUrl = 'http://localhost:3000';
    } else {
      dio.options.baseUrl =
          'https://peepal-backend-deployment-z0st0.kinsta.app/';
    }

    dio.options.connectTimeout = const Duration(seconds: 60);
    dio.options.receiveTimeout = const Duration(seconds: 60);

    dio.options.validateStatus = (status) {
      return true;
    };

    dio.interceptors.add(InterceptorsWrapper(
      /// Intercepts all requests and adds authentication headers.
      onRequest: (options, handler) {
        /// Add auth token to request headers
        final String authToken = prefs.getString(PP_AUTH_KEY) ?? '';
        options.headers['Authorization'] = 'Bearer $authToken';
        handler.next(options);
      },

      /// Intercepts all responses and handles errors globally.
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

    /// Initialize API services
    auth = PPAuthApi(dio: dio, prefs: prefs);
    toilets = PPToiletApi(dio: dio);
    user = PPUserApi(dio: dio);
    images = PPImagesApi(dio: dio);
    reviews = PPReviewsApi(dio: dio, imageApi: images);
    favorites = PPFavoritesApi(dio: dio);

    _isInitialized = true;
  }
}
