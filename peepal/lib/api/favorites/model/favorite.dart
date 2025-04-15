import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:peepal/api/toilets/model/toilet.dart';

@immutable
class PPFavorite extends Equatable {
  final PPToilet toilet;
  final DateTime createdAt;

  const PPFavorite({
    required this.toilet,
    required this.createdAt,
  });

  factory PPFavorite.fromJson(Map<String, dynamic> json) {
    return PPFavorite(
      toilet: PPToilet.fromJson(json['toilet']),
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  @override
  List<Object?> get props => [toilet, createdAt];
}
