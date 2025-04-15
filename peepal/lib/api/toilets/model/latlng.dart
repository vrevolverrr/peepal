import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:maps_toolkit/maps_toolkit.dart';
import 'package:apple_maps_flutter/apple_maps_flutter.dart' as am;

@immutable
final class PPLatLng extends Equatable {
  final double latitude;
  final double longitude;

  const PPLatLng({
    required this.latitude,
    required this.longitude,
  });

  factory PPLatLng.fromLocation(Map<String, dynamic> location) {
    /// PostGIS x is longitude, y is latitude
    return PPLatLng(
      latitude: location['y']! as double,
      longitude: location['x']! as double,
    );
  }

  factory PPLatLng.fromLatLng(Map<String, dynamic> json) {
    return PPLatLng(
      latitude: json['lat']! as double,
      longitude: json['lng']! as double,
    );
  }

  factory PPLatLng.fromAmLatLng(am.LatLng amLatLng) {
    return PPLatLng(
      latitude: amLatLng.latitude,
      longitude: amLatLng.longitude,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'x': longitude,
      'y': latitude,
    };
  }

  LatLng toLatLng() {
    return LatLng(latitude, longitude);
  }

  am.LatLng toAmLatLng() {
    return am.LatLng(latitude, longitude);
  }

  @override
  List<Object?> get props => [latitude, longitude];
}
