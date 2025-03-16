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

  @override
  List<Object?> get props => [
        hasBidet,
        hasShower,
        hasSanitizer,
        hasAccessibility,
      ];
}
