import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/rendering.dart';
import 'package:logging/logging.dart';
import 'package:peepal/api/auth/exceptions.dart';
import 'package:peepal/api/base.dart';
import 'package:peepal/api/toilets/exceptions.dart';
import 'package:peepal/api/toilets/model/address.dart';
import 'package:peepal/api/toilets/model/latlng.dart';
import 'package:peepal/api/toilets/model/route.dart';
import 'package:peepal/api/toilets/model/toilet.dart';

/// This class provides an interface to interact with the `api/toilets` endpoint.
///
/// All methods in this class are asynchronous and return a [Future].
final class PPToiletApi extends PPApiClient {
  @override
  final Logger logger = Logger('PPToiletApi');

  @override
  final String endpoint = "/api/toilets";

  /// Cache of navigation routes keyed by toilet ID.
  ///
  /// Used to avoid redundant API calls for frequently accessed routes.
  final Map<String, PPRoute> _routeCache = {};

  PPToiletApi({required super.dio});

  /// Creates a new toilet.
  ///
  /// Returns a [PPToilet] object representing the newly created toilet.
  ///
  /// Throws a [PPUnexpectedServerError] if the server returns an unexpected error.
  Future<PPToilet> createToilet({
    required String name,
    required String address,
    required PPLatLng location,
    required PPLatLng currentLocation,
    required int rating,
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
        'latitude': currentLocation.latitude,
        'longitude': currentLocation.longitude,
        'rating': rating.toDouble(),
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

  /// Updates an existing toilet.
  ///
  /// Returns a [PPToilet] object representing the updated toilet.
  ///
  /// Throws a [PPUnexpectedServerError] if the server returns an unexpected error.
  ///
  /// Throws a [PPToiletNotFoundError] if the toilet is not found.
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

  /// Retrieves the address from a given location.
  ///
  /// Returns a [PPAddress] object representing the address.
  ///
  /// Throws a [PPUnexpectedServerError] if the server returns an unexpected error.
  Future<PPAddress> getAddressFromLocation(PPLatLng location) async {
    try {
      final Response<Map<String, dynamic>> response =
          await dio.post('$endpoint/getAddress', data: {
        'latitude': location.latitude,
        'longitude': location.longitude,
      });

      if (response.statusCode != 200) {
        throw PPUnexpectedServerError(message: 'Failed to get address');
      }

      if (response.data?['address'] == null) {
        throw PPUnexpectedServerError(message: 'Failed to get address');
      }

      final PPAddress address = PPAddress.fromJson(response.data!['address']);

      logger.info('Address fetched ${address.placeName}');

      return address;
    } catch (e) {
      logger.severe('Failed to get address: $e');
      rethrow;
    }
  }

  /// Retrieves a list of toilets by their IDs.
  ///
  /// Returns a list of [PPToilet] objects representing the toilets.
  ///
  /// Throws a [PPUnexpectedServerError] if the server returns an unexpected error.
  ///
  /// Throws a [PPToiletNotFoundError] if the toilets are not found.
  Future<List<PPToilet>> getToiletByIds(
      {required List<String> toiletIds}) async {
    try {
      final Response<Map<String, dynamic>> response =
          await dio.post('$endpoint/details', data: {
        'toiletIds': toiletIds,
      });

      if (response.statusCode != 200) {
        if (response.statusCode == 404) {
          throw PPToiletNotFoundError();
        }

        throw PPUnexpectedServerError(message: 'Failed to get toilet');
      }

      if (response.data?['toilets'] == null) {
        throw PPUnexpectedServerError(message: 'Failed to get toilet');
      }

      final List<PPToilet> toilets = (response.data!['toilets'] as List)
          .map((e) => PPToilet.fromJson(e))
          .toList();

      logger.info('Toilets fetched ${toilets.map((x) => x.id).join(', ')}');

      return toilets;
    } catch (e) {
      logger.severe('Failed to get toilets: $e');
      rethrow;
    }
  }

  /// Reports a toilet.
  ///
  /// Returns a boolean indicating whether the report was deleted due to too many reports.
  ///
  /// Throws a [PPUnexpectedServerError] if the server returns an unexpected error.
  ///
  /// Throws a [PPToiletNotFoundError] if the toilet is not found.
  Future<bool> reportToilet({required PPToilet toilet}) async {
    try {
      final Response<Map<String, dynamic>> response =
          await dio.post('$endpoint/report/${toilet.id}');

      if (response.statusCode != 200) {
        if (response.statusCode == 404) {
          throw PPToiletNotFoundError();
        }

        throw PPUnexpectedServerError(message: 'Failed to report toilet');
      }

      if (response.data?['deleted'] == null) {
        throw PPUnexpectedServerError(message: 'Failed to report toilet');
      }

      logger.info('Toilet reported ${toilet.id}');

      return response.data!['deleted'];
    } catch (e) {
      logger.severe('Failed to report toilet: $e');
      rethrow;
    }
  }

  /// Retrieves a list of toilets near a given location.
  ///
  /// [location] The center point to search from.
  /// [radius] Optional radius in kilometers to search within. Defaults to server-side value.
  /// [limit] Optional maximum number of results to return. Defaults to server-side value.
  ///
  /// Returns a list of [PPToilet] objects sorted by distance from [location].
  ///
  /// Throws a [PPUnexpectedServerError] if the server returns an unexpected error.
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

  /// Searches for toilets based on query text and filters.
  ///
  /// [query] Text to search for in toilet names and addresses.
  /// [location] User's current location for distance calculation.
  /// [handicapAvail] Filter for handicap accessibility.
  /// [bidetAvail] Filter for bidet availability.
  /// [showerAvail] Filter for shower availability.
  /// [sanitiserAvail] Filter for sanitiser availability.
  ///
  /// Returns a list of [PPToilet] objects matching the search criteria.
  ///
  /// Throws a [PPUnexpectedServerError] if the server returns an unexpected error.
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

  /// Updates the image associated with a toilet.
  ///
  /// [toilet] The toilet to update the image for.
  /// [image] The new image file to upload.
  ///
  /// Returns the updated [PPToilet] object with the new image URL.
  ///
  /// Throws a [PPToiletNotFoundError] if the toilet is not found.
  /// Throws a [PPUnexpectedServerError] if the server returns an unexpected error.
  Future<PPToilet> updateToiletImage({
    required PPToilet toilet,
    required File image,
  }) async {
    debugPrint("Updating toilet image ${toilet.id}");
    try {
      final formData = FormData.fromMap({
        'image': await MultipartFile.fromFile(image.path),
        'type': 'toilet',
      });

      final Response<Map<String, dynamic>> response = await dio.patch(
        '$endpoint/image/${toilet.id}',
        data: formData,
      );

      if (response.statusCode != 200) {
        if (response.statusCode == 404) {
          throw PPToiletNotFoundError();
        }
        throw PPUnexpectedServerError(message: 'Failed to update toilet image');
      }

      if (response.data?['toilet'] == null) {
        throw PPUnexpectedServerError(message: 'Failed to update toilet image');
      }

      final PPToilet updatedToilet =
          PPToilet.fromJson(response.data!['toilet']);
      logger.info('Toilet image updated ${updatedToilet.id}');
      return updatedToilet;
    } catch (e) {
      logger.severe('Failed to update toilet image: $e');
      rethrow;
    }
  }

  /// Gets navigation route to a toilet from the user's current location.
  ///
  /// [toilet] The destination toilet.
  /// [location] User's current location.
  ///
  /// Returns a [PPRoute] object containing navigation instructions.
  /// Uses a cache to avoid redundant API calls for the same toilet.
  ///
  /// Throws a [PPToiletNotFoundError] if the toilet is not found.
  /// Throws a [PPToiletRouteNotFoundError] if no route can be calculated.
  /// Throws a [PPUnexpectedServerError] if the server returns an unexpected error.
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
