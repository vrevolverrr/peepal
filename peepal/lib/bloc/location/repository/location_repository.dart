import 'dart:async';

import 'package:geolocator/geolocator.dart';
import 'package:peepal/bloc/location/model/location.dart';

abstract interface class LocationRepository {
  Future<bool> checkPermission();
  Future<bool> requestPermission();
  Future<PPLocation> getCurrentLocation();
  Stream<PPLocation> getLocationStream();

  factory LocationRepository() => LocationRepositoryImpl();
}

class LocationRepositoryImpl implements LocationRepository {
  bool _hasPermission = false;

  Stream<PPLocation>? _positionStream;

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
  Future<PPLocation> getCurrentLocation() async {
    final hasPermission = await checkPermission();

    if (!hasPermission) {
      throw Exception("Location permission is not granted");
    }

    final position = await Geolocator.getCurrentPosition();

    return PPLocationAdapter(position);
  }

  @override
  Stream<PPLocation> getLocationStream() {
    if (!_hasPermission) {
      throw Exception("Location permission is not granted");
    }

    _positionStream ??=
        Geolocator.getPositionStream().map((event) => PPLocationAdapter(event));

    return _positionStream!;
  }
}
