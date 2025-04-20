import 'package:dio/dio.dart';
import 'package:logging/logging.dart';
import 'package:peepal/api/auth/exceptions.dart';
import 'package:peepal/api/base.dart';
import 'package:peepal/api/favorites/model/favorite.dart';
import 'package:peepal/api/toilets/model/toilet.dart';

/// API client for managing user's favorite toilets.
///
/// Provides functionality to add, remove, and list favorite toilets.
/// All methods require authentication and will throw appropriate errors
/// if the user is not authenticated or the token is invalid.
final class PPFavoritesApi extends PPApiClient {
  @override
  final Logger logger = Logger('PPFavoritesApi');

  @override
  final String endpoint = "/api/favorites";

  /// Creates a new favorites API client.
  ///
  /// [dio] HTTP client for making API requests.
  /// The client must be configured with appropriate authentication headers.
  PPFavoritesApi({required super.dio});

  /// Retrieves the authenticated user's favorite toilets.
  ///
  /// Returns a list of [PPFavorite] objects, each containing
  /// information about a favorited toilet and when it was favorited.
  ///
  /// Throws [PPUnexpectedServerError] if the server returns an unexpected error.
  /// Throws [PPNotAuthenticatedError] if the user is not authenticated.
  Future<List<PPFavorite>> getFavourites() async {
    try {
      final Response<Map<String, dynamic>> response =
          await dio.get('$endpoint/me');

      if (response.statusCode != 200) {
        throw PPUnexpectedServerError(message: 'Failed to fetch favorites');
      }

      if (response.data?['favorites'] == null) {
        throw PPUnexpectedServerError(message: 'Failed to fetch favorites');
      }

      final List<dynamic> data = response.data!['favorites'];
      final List<PPFavorite> favorites =
          data.map((json) => PPFavorite.fromJson(json)).toList();

      return favorites;
    } catch (e) {
      logger.severe('Failed to fetch favorites: $e');
      throw PPUnexpectedServerError(message: 'Failed to fetch favorites');
    }
  }

  /// Adds a toilet to the user's favorites.
  ///
  /// [toilet] The toilet to add to favorites.
  ///
  /// Silently succeeds if the toilet is already in favorites.
  /// This behavior is intentional to prevent race conditions
  /// and provide a smoother user experience.
  ///
  /// Throws [PPUnexpectedServerError] if the server returns an unexpected error
  /// or if the toilet doesn't exist.
  /// Throws [PPNotAuthenticatedError] if the user is not authenticated.
  Future<void> addFavorite({required PPToilet toilet}) async {
    try {
      final Response<Map<String, dynamic>> response =
          await dio.post('$endpoint/add/${toilet.id}');

      if (response.statusCode == 200) {
        logger.info('Successfully added favorite for toilet: ${toilet.id}');
        return;
      }

      logger.warning('Error adding favorite: Status ${response.statusCode}');

      if (response.statusCode == 404) {
        logger.severe('Toilet not found: ${toilet.id}');
        throw PPUnexpectedServerError(message: 'Toilet not found');
      }

      throw PPUnexpectedServerError(message: 'Failed to add favorite');
    } catch (e) {
      if (e is PPUnexpectedServerError) {
        rethrow;
      }

      if (e is DioException) {
        return;
      }

      logger.severe('Failed to add favorite: $e');
      throw PPUnexpectedServerError(message: 'Failed to add favorite');
    }
  }

  /// Removes a toilet from the user's favorites.
  ///
  /// [toilet] The toilet to remove from favorites.
  ///
  /// Silently succeeds if the toilet is not in favorites.
  /// This behavior is intentional to prevent race conditions
  /// and provide a smoother user experience.
  ///
  /// Throws [PPUnexpectedServerError] if the server returns an unexpected error.
  /// Throws [PPNotAuthenticatedError] if the user is not authenticated.
  Future<void> removeFavorite({required PPToilet toilet}) async {
    try {
      // Log the request for debugging
      logger.info('Removing favorite for toilet: ${toilet.id}');

      final Response<Map<String, dynamic>> response =
          await dio.delete('$endpoint/remove/${toilet.id}');

      if (response.statusCode == 200) {
        logger.info('Successfully removed favorite for toilet: ${toilet.id}');
        return;
      }

      logger.warning('Error removing favorite: Status ${response.statusCode}');

      if (response.statusCode == 404) {
        logger.info('Favorite not found, treating as already removed');
        return;
      }

      throw PPUnexpectedServerError(message: 'Failed to remove favorite');
    } catch (e) {
      if (e is PPUnexpectedServerError) {
        rethrow;
      }

      if (e is DioException) {
        return;
      }

      logger.severe('Failed to remove favorite: $e');
      throw PPUnexpectedServerError(message: 'Failed to remove favorite');
    }
  }
}
