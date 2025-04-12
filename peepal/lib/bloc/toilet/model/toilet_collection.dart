import 'dart:collection';

import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';
import 'package:peepal/bloc/location/model/location.dart';
import 'package:peepal/bloc/toilet/model/toilet.dart';
import 'package:peepal/bloc/toilet/model/toilet_crowd_level.dart';
import 'package:peepal/bloc/toilet/model/toilet_features.dart';

@immutable
class PPToiletCollection extends Equatable {
  final List<PPToilet> _toilets;
  List<PPToilet> get toilets => UnmodifiableListView(_toilets);

  int get length => _toilets.length;

  const PPToiletCollection(List<PPToilet> toilets) : _toilets = toilets;

  PPToiletCollection filterByRating(
      {double minRating = 0.0, double maxRating = 5.0}) {
    return PPToiletCollection(toilets
        .where((toilet) =>
            toilet.rating >= minRating && toilet.rating <= maxRating)
        .toList());
  }

  PPToiletCollection filterByFeatures({required PPToiletFeatures features}) {
    return PPToiletCollection(
        toilets.where((toilet) => toilet.features.contains(features)).toList());
  }

  PPToiletCollection filterByLocation(
      {required PPLocation location, required double radius}) {
    return PPToiletCollection(toilets
        .where((toilet) => toilet.location.distanceTo(location) <= radius)
        .toList());
  }

  PPToiletCollection filterByCrowdLevel(
      {required PPToiletCrowdLevel crowdLevel}) {
    return PPToiletCollection(toilets
        .where((toilet) => toilet.crowdStatus.crowdLevel == crowdLevel)
        .toList());
  }

  @override
  List<Object?> get props => [_toilets];
}
