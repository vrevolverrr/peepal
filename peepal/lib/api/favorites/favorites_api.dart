import 'package:dio/dio.dart';
import 'package:logging/logging.dart';
import 'package:peepal/api/auth/exceptions.dart';
import 'package:peepal/api/base.dart';
import 'package:peepal/api/favorites/model/favorite.dart';
import 'package:peepal/api/toilets/model/toilet.dart';

final class PPFavoritesApi extends PPApiClient {
  @override
  final Logger logger = Logger('PPFavoritesApi');

  @override
  final String endpoint = "/api/favorites";

  PPFavoritesApi({required super.dio});

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

  Future<void> addFavorite({required PPToilet toilet}) async {
    try {
      final Response<Map<String, dynamic>> response =
          await dio.post('$endpoint/add/${toilet.id}');

      if (response.statusCode == 200) {
        logger.info('Successfully removed favorite for toilet: ${toilet.id}');
        return;
      }

      logger.warning('Error removing favorite: Status ${response.statusCode}');

      if (response.statusCode == 404) {
        logger.info('Favorite not found, treating as already removed');
        return;
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
