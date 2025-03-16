import 'dart:collection';

import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';
import 'package:peepal/shared/location/model/pp_location.dart';
import 'package:peepal/shared/toilet/model/toilet.dart';
import 'package:peepal/shared/toilet/model/toilet_crowd_level.dart';
import 'package:peepal/shared/toilet/model/toilet_features.dart';

abstract interface class PPToiletCollection {
  int get length;
  List<PPToilet> get toilets;

  PPToiletCollection filterByCrowdLevel(
      {required PPToiletCrowdLevel crowdLevel});

  PPToiletCollection filterByRating(
      {double minRating = 0.0, double maxRating = 5.0});

  PPToiletCollection filterByFeatures({required PPToiletFeatures features});

  PPToiletCollection filterByLocation(
      {required PPLocation location, required double radius});

  PPToiletCollection filterByAvailability(
      {required PPToiletCrowdLevel crowdLevel});

  factory PPToiletCollection({required List<PPToilet> toilets}) {
    return PPToiletCollectionImpl(toilets: toilets);
  }
}

@immutable
class PPToiletCollectionImpl extends Equatable implements PPToiletCollection {
  final List<PPToilet> _toilets;
  @override
  List<PPToilet> get toilets => UnmodifiableListView(_toilets);

  @override
  int get length => _toilets.length;

  const PPToiletCollectionImpl({required List<PPToilet> toilets})
      : _toilets = toilets;

  @override
  List<Object?> get props => [_toilets];

  @override
  PPToiletCollection filterByAvailability(
      {required PPToiletCrowdLevel crowdLevel}) {
    // TODO: implement filterByAvailability
    throw UnimplementedError();
  }

  @override
  PPToiletCollection filterByCrowdLevel(
      {required PPToiletCrowdLevel crowdLevel}) {
    // TODO: implement filterByCrowdLevel
    throw UnimplementedError();
  }

  @override
  PPToiletCollection filterByFeatures({required PPToiletFeatures features}) {
    // TODO: implement filterByFeatures
    throw UnimplementedError();
  }

  @override
  PPToiletCollection filterByLocation(
      {required PPLocation location, required double radius}) {
    // TODO: implement filterByLocation
    throw UnimplementedError();
  }

  @override
  PPToiletCollection filterByRating(
      {double minRating = 0.0, double maxRating = 5.0}) {
    // TODO: implement filterByRating
    throw UnimplementedError();
  }
}
