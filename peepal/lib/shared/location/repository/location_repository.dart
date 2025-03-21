import 'package:geolocator/geolocator.dart';
import 'package:peepal/shared/location/model/location.dart';

abstract interface class LocationRepository {
  Future<bool> checkPermission();
  Future<bool> requestPermission();
  Future<PPLocation> getCurrentLocation();

  factory LocationRepository() => LocationRepositoryImpl();
}

class LocationRepositoryImpl implements LocationRepository {
  @override
  Future<bool> checkPermission() async {
    final permission = await Geolocator.checkPermission();

    return permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse;
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
}
