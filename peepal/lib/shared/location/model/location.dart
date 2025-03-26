import 'dart:math';

import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

@immutable
class PPLocation extends Equatable {
  final double latitude;
  final double longitude;

  const PPLocation({
    required this.latitude,
    required this.longitude,
  });

  /// Default implementation of distance calculation using Haversine formula
  double distanceTo(PPLocation other) {
    // Earth's radius in meters
    const double earthRadius = 6371000;

    // Convert degrees to radians
    final lat1 = latitude * (pi / 180);
    final lat2 = other.latitude * (pi / 180);
    final dLat = (other.latitude - latitude) * (pi / 180);
    final dLon = (other.longitude - longitude) * (pi / 180);

    // Haversine formula
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(lat1) * cos(lat2) * sin(dLon / 2) * sin(dLon / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    final distance = earthRadius * c;

    return distance;
  }

  @override
  List<Object?> get props => [latitude, longitude];
}

/// Adapter class to convert [Position] of [Geolocator] to [PPLocation]
class PPLocationAdapter extends PPLocation {
  PPLocationAdapter(Position position)
      : super(
          latitude: position.latitude,
          longitude: position.longitude,
        );

  @override
  double distanceTo(PPLocation other) {
    return Geolocator.distanceBetween(
        latitude, longitude, other.latitude, other.longitude);
  }
}
