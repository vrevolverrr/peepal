import 'package:dio/dio.dart';
import 'package:logging/logging.dart';
import 'package:peepal/api/auth/exceptions.dart';
import 'package:peepal/api/base.dart';
import 'package:peepal/api/toilets/exceptions.dart';
import 'package:peepal/api/toilets/model/latlng.dart';
import 'package:peepal/api/toilets/model/route.dart';
import 'package:peepal/api/toilets/model/toilet.dart';

final class PPToiletApi extends PPApiClient {
  @override
  final Logger logger = Logger('PPToiletApi');

  @override
  final String endpoint = "/api/toilets";

  final Map<String, PPRoute> _routeCache = {};

  PPToiletApi({required super.dio});

  Future<PPToilet> createToilet({
    required String name,
    required String address,
    required PPLatLng location,
    bool? handicapAvail,
    bool? bidetAvail,
    bool? showerAvail,
    bool? sanitiserAvail,
  }) async {
    try {
      final Response<Map<String, dynamic>> response =
          await dio.post('$endpoint/create', data: {
        'name': name,
        'address': address,
        'location': location.toJson(),
        if (handicapAvail != null) 'handicapAvail': handicapAvail,
        if (bidetAvail != null) 'bidetAvail': bidetAvail,
        if (showerAvail != null) 'showerAvail': showerAvail,
        if (sanitiserAvail != null) 'sanitiserAvail': sanitiserAvail,
      });

      if (response.statusCode != 201) {
        throw PPUnexpectedServerError(message: 'Failed to create toilet');
      }

      if (response.data?['toilet'] == null) {
        throw PPUnexpectedServerError(message: 'Failed to create toilet');
      }

      final PPToilet toilet = PPToilet.fromJson(response.data!['toilet']);

      logger.info('Toilet created ${toilet.id}');

      return toilet;
    } catch (e) {
      logger.severe('Failed to create toilet: $e');
      rethrow;
    }
  }

  Future<PPToilet> updateToilet({
    required PPToilet toilet,
    required String name,
    required String address,
    required PPLatLng location,
    bool? handicapAvail,
    bool? bidetAvail,
    bool? showerAvail,
    bool? sanitiserAvail,
  }) async {
    try {
      final Response<Map<String, dynamic>> response =
          await dio.patch('$endpoint/details/${toilet.id}', data: {
        'name': name,
        'address': address,
        'location': location.toJson(),
        if (handicapAvail != null) 'handicapAvail': handicapAvail,
        if (bidetAvail != null) 'bidetAvail': bidetAvail,
        if (showerAvail != null) 'showerAvail': showerAvail,
        if (sanitiserAvail != null) 'sanitiserAvail': sanitiserAvail,
      });

      if (response.statusCode != 200) {
        if (response.statusCode == 404) {
          throw PPToiletNotFoundError();
        }

        throw PPUnexpectedServerError(message: 'Failed to update toilet');
      }

      if (response.data?['toilet'] == null) {
        throw PPUnexpectedServerError(message: 'Failed to update toilet');
      }

      final PPToilet updatedToilet =
          PPToilet.fromJson(response.data!['toilet']);

      logger.info('Toilet updated ${updatedToilet.id}');

      return updatedToilet;
    } catch (e) {
      logger.severe('Failed to update toilet: $e');
      rethrow;
    }
  }

  Future<PPToilet> getToiletById({required String toiletId}) async {
    try {
      final Response<Map<String, dynamic>> response =
          await dio.get('$endpoint/details/$toiletId');

      if (response.statusCode != 200) {
        if (response.statusCode == 404) {
          throw PPToiletNotFoundError();
        }

        throw PPUnexpectedServerError(message: 'Failed to get toilet');
      }

      if (response.data?['toilet'] == null) {
        throw PPUnexpectedServerError(message: 'Failed to get toilet');
      }

      final PPToilet toilet = PPToilet.fromJson(response.data!['toilet']);

      logger.info('Toilet fetched ${toilet.id}');

      return toilet;
    } catch (e) {
      logger.severe('Failed to get toilet: $e');
      rethrow;
    }
  }

  Future<bool> reportToilet({required String toiletId}) async {
    try {
      final Response<Map<String, dynamic>> response =
          await dio.post('$endpoint/report/$toiletId');

      if (response.statusCode != 200) {
        if (response.statusCode == 404) {
          throw PPToiletNotFoundError();
        }

        throw PPUnexpectedServerError(message: 'Failed to report toilet');
      }

      if (response.data?['deleted'] == null) {
        throw PPUnexpectedServerError(message: 'Failed to report toilet');
      }

      logger.info('Toilet reported $toiletId');

      return response.data!['deleted'];
    } catch (e) {
      logger.severe('Failed to report toilet: $e');
      rethrow;
    }
  }

  Future<List<PPToilet>> getNearbyToilets({
    required PPLatLng location,
    double? radius,
    int? limit,
  }) async {
    try {
      final Response<Map<String, dynamic>> response =
          await dio.get('$endpoint/nearby', queryParameters: {
        'latitude': location.latitude,
        'longitude': location.longitude,
        if (radius != null) 'radius': radius,
        if (limit != null) 'limit': limit,
      });

      if (response.statusCode != 200) {
        throw PPUnexpectedServerError(message: 'Failed to get nearby toilets');
      }

      if (response.data?['toilets'] == null) {
        throw PPUnexpectedServerError(message: 'Failed to get nearby toilets');
      }

      final List<PPToilet> toilets = (response.data!['toilets'] as List)
          .map((e) => PPToilet.fromJson(e))
          .toList();

      logger.info('Nearby toilets fetched');

      return toilets;
    } catch (e) {
      logger.severe('Failed to get nearby toilets: $e');
      rethrow;
    }
  }

  Future<List<PPToilet>> searchToilets({
    required String query,
    required PPLatLng location,
    bool? handicapAvail,
    bool? bidetAvail,
    bool? showerAvail,
    bool? sanitiserAvail,
  }) async {
    try {
      final Response<Map<String, dynamic>> response =
          await dio.post('$endpoint/search', data: {
        'query': query,
        'latitude': location.latitude,
        'longitude': location.longitude,
        if (handicapAvail != null) 'handicapAvail': handicapAvail,
        if (bidetAvail != null) 'bidetAvail': bidetAvail,
        if (showerAvail != null) 'showerAvail': showerAvail,
        if (sanitiserAvail != null) 'sanitiserAvail': sanitiserAvail,
      });

      if (response.statusCode != 200) {
        throw PPUnexpectedServerError(message: 'Failed to search toilets');
      }

      if (response.data?['toilets'] == null) {
        throw PPUnexpectedServerError(message: 'Failed to search toilets');
      }

      final List<PPToilet> toilets = (response.data!['toilets'] as List)
          .map((e) => PPToilet.fromJson(e))
          .toList();

      logger.info('Toilets searched');

      return toilets;
    } catch (e) {
      logger.severe('Failed to search toilets: $e');
      rethrow;
    }
  }

  Future<PPRoute> navigateToToilet(
      {required PPToilet toilet, required PPLatLng location}) async {
    if (_routeCache.containsKey(toilet.id)) {
      return _routeCache[toilet.id]!;
    }

    try {
      final Response<Map<String, dynamic>> response =
          await dio.post('$endpoint/navigate/${toilet.id}', data: {
        'latitude': location.latitude,
        'longitude': location.longitude,
      });

      if (response.statusCode != 200) {
        if (response.statusCode == 404) {
          throw PPToiletNotFoundError();
        }

        if (response.statusCode == 400) {
          throw PPToiletRouteNotFoundError();
        }

        throw PPUnexpectedServerError(message: 'Failed to navigate to toilet');
      }

      if (response.data?['route'] == null) {
        throw PPUnexpectedServerError(message: 'Failed to navigate to toilet');
      }

      final PPRoute route = PPRoute.fromJson(response.data!['route']);
      _routeCache[toilet.id] = route;

      logger.info('Got route to ${toilet.id}');
      return route;
    } catch (e) {
      logger.severe('Failed to navigate to toilet: $e');
      rethrow;
    }
  }
}
