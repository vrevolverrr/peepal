import 'dart:async';

import 'package:geolocator/geolocator.dart';
import 'package:peepal/api/toilets/model/latlng.dart';

abstract interface class LocationRepository {
  Future<bool> checkPermission();
  Future<bool> requestPermission();
  Future<PPLatLng> getCurrentLocation();
  Stream<PPLatLng> getLocationStream();

  factory LocationRepository() => LocationRepositoryImpl();
}

class LocationRepositoryImpl implements LocationRepository {
  bool _hasPermission = false;

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

    _positionStream ??= Geolocator.getPositionStream().map((event) =>
        PPLatLng(latitude: event.latitude, longitude: event.longitude));

    return _positionStream!;
  }
}
