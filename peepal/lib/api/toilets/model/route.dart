import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:maps_toolkit/maps_toolkit.dart';
import 'package:peepal/api/toilets/model/latlng.dart';

@immutable
class PPRoute extends Equatable {
  final String distance;
  final String duration;
  final PPLatLng startLocation;
  final PPLatLng endLocation;
  final String overviewPolyline;
  final List<PPRouteDirection> directions;

  const PPRoute({
    required this.distance,
    required this.duration,
    required this.startLocation,
    required this.endLocation,
    required this.overviewPolyline,
    required this.directions,
  });

  List<PPLatLng> decodeOverviewPolyline() {
    return PolygonUtil.decode(overviewPolyline)
        .map((e) => PPLatLng(latitude: e.latitude, longitude: e.longitude))
        .toList();
  }

  factory PPRoute.fromJson(Map<String, dynamic> json) {
    return PPRoute(
      distance: json['distance'],
      duration: json['duration'],
      startLocation: PPLatLng.fromLatLng(json['start_location']),
      endLocation: PPLatLng.fromLatLng(json['end_location']),
      overviewPolyline: json['overview_polyline'],
      directions: (json['directions'] as List<dynamic>)
          .map((e) => PPRouteDirection.fromJson(e))
          .toList(),
    );
  }

  @override
  List<Object?> get props => [
        overviewPolyline,
        startLocation,
        endLocation,
        distance,
        duration,
      ];
}

@immutable
class PPRouteDirection extends Equatable {
  final String distance;
  final String duration;
  final PPLatLng startLocation;
  final PPLatLng endLocation;
  final String polyline;
  final String instructions;

  const PPRouteDirection({
    required this.distance,
    required this.duration,
    required this.startLocation,
    required this.endLocation,
    required this.polyline,
    required this.instructions,
  });

  List<PPLatLng> decodePolyline() {
    return PolygonUtil.decode(polyline)
        .map((e) => PPLatLng(latitude: e.latitude, longitude: e.longitude))
        .toList();
  }

  factory PPRouteDirection.fromJson(Map<String, dynamic> json) {
    return PPRouteDirection(
      distance: json['distance'],
      duration: json['duration'],
      startLocation: PPLatLng.fromLatLng(json['start_location']),
      endLocation: PPLatLng.fromLatLng(json['end_location']),
      polyline: json['polyline'],
      instructions: json['instructions'],
    );
  }

  @override
  List<Object?> get props => [
        distance,
        duration,
        startLocation,
        endLocation,
        polyline,
        instructions,
      ];
}
