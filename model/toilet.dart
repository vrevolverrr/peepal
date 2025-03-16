import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:peepal/shared/location/model/pp_location.dart';
import 'package:peepal/shared/toilet/model/toilet_crowd_level.dart';
import 'package:peepal/shared/toilet/model/toilet_features.dart';

@immutable
class PPToilet extends Equatable {
  final int id;
  final String name;
  final PPLocation location;
  final String address;
  final double rating;
  final PPToiletFeatures features;
  final PPToiletCrowdStatus crowdStatus;

  const PPToilet({
    required this.id,
    required this.name,
    required this.location,
    required this.address,
    required this.rating,
    required this.features,
    required this.crowdStatus,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        location,
        address,
        rating,
        features,
        crowdStatus,
      ];
}
