import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

enum PPToiletCrowdLevel {
  empty,
  low,
  moderate,
  crowded,
}

@immutable
class PPToiletCrowdStatus extends Equatable {
  final PPToiletCrowdLevel crowdLevel;
  final int estimatedWaitTime;
  final int estimatedCrowdSize;

  const PPToiletCrowdStatus({
    required this.crowdLevel,
    required this.estimatedWaitTime,
    required this.estimatedCrowdSize,
  });

  @override
  List<Object?> get props =>
      [crowdLevel, estimatedWaitTime, estimatedCrowdSize];
}
