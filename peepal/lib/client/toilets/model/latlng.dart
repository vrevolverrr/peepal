import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

@immutable
final class PPLatLng extends Equatable {
  final double latitude;
  final double longitude;

  const PPLatLng({
    required this.latitude,
    required this.longitude,
  });

  factory PPLatLng.fromLocation(Map<String, double> location) {
    /// PostGIS x is longitude, y is latitude
    return PPLatLng(
      latitude: location['y']!,
      longitude: location['x']!,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'x': longitude,
      'y': latitude,
    };
  }

  @override
  List<Object?> get props => [latitude, longitude];
}
