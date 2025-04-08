import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

/// Simplified model class for toilet search functionality
@immutable
class ToiletLocation extends Equatable {
  final String id;
  final String name;
  final String address;
  final double latitude;
  final double longitude;
  final double? rating;
  final bool? hasAccessibleFacilities;
  final bool? hasBidet; // Add bidet information

  const ToiletLocation({
    required this.id,
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
    this.rating,
    this.hasAccessibleFacilities,
    this.hasBidet, // Add to constructor
  });
  
  @override
  List<Object?> get props => [
    id,
    name,
    address,
    latitude,
    longitude,
    rating,
    hasAccessibleFacilities,
    hasBidet, // Add to equality check
  ];
}