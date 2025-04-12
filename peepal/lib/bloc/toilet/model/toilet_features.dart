import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';

@immutable
class PPToiletFeatures extends Equatable {
  final bool hasBidet;
  final bool hasShower;
  final bool hasSanitizer;
  final bool hasAccessibility;

  const PPToiletFeatures({
    required this.hasBidet,
    required this.hasShower,
    required this.hasSanitizer,
    required this.hasAccessibility,
  });

  bool contains(PPToiletFeatures other) {
    return hasBidet == other.hasBidet &&
        hasShower == other.hasShower &&
        hasSanitizer == other.hasSanitizer &&
        hasAccessibility == other.hasAccessibility;
  }

  @override
  List<Object?> get props => [
        hasBidet,
        hasShower,
        hasSanitizer,
        hasAccessibility,
      ];
}
