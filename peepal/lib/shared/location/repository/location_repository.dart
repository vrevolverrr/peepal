import 'dart:async';

import 'package:geolocator/geolocator.dart';
import 'package:peepal/api/toilets/model/latlng.dart';

abstract interface class LocationRepository {
  /// Checks if the user has granted location permission.
  ///
  /// Returns a `Future` that resolves to a `bool` indicating whether the
  /// user has granted location permission.
  Future<bool> checkPermission();

  /// Requests location permission from the user.
  ///
  /// Returns a `Future` that resolves to a `bool` indicating whether the
  /// user has granted location permission.
  Future<bool> requestPermission();

  /// Retrieves the current location of the user.
  ///
  /// Returns a `Future` that resolves to a `PPLatLng` object representing
  /// the current location of the user.
  Future<PPLatLng> getCurrentLocation();

  /// Retrieves a stream of the user's location updates.
  ///
  /// Returns a `Stream` that emits `PPLatLng` objects representing the
  /// user's location updates.
  Stream<PPLatLng> getLocationStream();

  factory LocationRepository() => LocationRepositoryImpl();
}

/// Concrete implementation of [LocationRepository] using the `geolocator` package.
class LocationRepositoryImpl implements LocationRepository {
  /// Internal flag to cache the location permission status.
  bool _hasPermission = false;

  /// Cached stream of location updates from `geolocator`.
  ///
  /// Lazily initialized when [getLocationStream] is first called.
  Stream<PPLatLng>? _positionStream;

  @override
  Future<bool> checkPermission() async {
    final permission = await Geolocator.checkPermission();

    _hasPermission = permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse;

    return _hasPermission;
  }

  @override
  Future<bool> requestPermission() async {
    final hasPermission = await checkPermission();

    if (hasPermission) {
      return true;
    }

    final permission = await Geolocator.requestPermission();

    return permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse;
  }

  @override
  Future<PPLatLng> getCurrentLocation() async {
    final hasPermission = await checkPermission();

    if (!hasPermission) {
      throw Exception("Location permission is not granted");
    }

    final position = await Geolocator.getCurrentPosition();

    return PPLatLng(latitude: position.latitude, longitude: position.longitude);
  }

  @override
  Stream<PPLatLng> getLocationStream() {
    if (!_hasPermission) {
      throw Exception("Location permission is not granted");
    }

    // Transform the `Geolocator` latlng into `PPLatLng`
    _positionStream ??= Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      ),
    ).map((event) =>
        PPLatLng(latitude: event.latitude, longitude: event.longitude));

    return _positionStream!;
  }
}
