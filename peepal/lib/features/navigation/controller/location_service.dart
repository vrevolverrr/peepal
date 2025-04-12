import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

class LocationService {
  StreamSubscription<Position>? _positionSubscription;
  final void Function(Position) onPositionUpdate;
  final void Function(String) onError;

  LocationService({
    required this.onPositionUpdate,
    required this.onError,
  });

  Future<void> startLocationUpdates() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        onError('Location permissions are denied');
        return;
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      onError('Location permissions are permanently denied');
      return;
    }
    
    try {
      Position position = await Geolocator.getCurrentPosition();
      onPositionUpdate(position);
      
      _positionSubscription = Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 10,
        ),
      ).listen(
        onPositionUpdate,
        onError: (e) {
          debugPrint('Error getting position updates: $e');
          onError('Error getting position updates');
        },
      );
    } catch (e) {
      debugPrint('Error getting current position: $e');
      onError('Error getting current position');
    }
  }

  void dispose() {
    _positionSubscription?.cancel();
  }
}