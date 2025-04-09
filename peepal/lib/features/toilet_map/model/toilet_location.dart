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
  final bool? hasBidet;
  final bool? hasShower; // Add this
  final bool? hasSanitizer; // Add this

  const ToiletLocation({
    required this.id,
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
    this.rating,
    this.hasAccessibleFacilities,
    this.hasBidet,
    this.hasShower, // Add to constructor
    this.hasSanitizer, // Add to constructor
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
    hasBidet,
    hasShower, // Add to equality check
    hasSanitizer, // Add to equality check
  ];
}