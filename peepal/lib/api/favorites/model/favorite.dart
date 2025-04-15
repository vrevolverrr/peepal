import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

@immutable
class PPFavorite extends Equatable {
  final String toiletId;
  final DateTime createdAt;

  const PPFavorite({
    required this.toiletId,
    required this.createdAt,
  });

  factory PPFavorite.fromJson(Map<String, dynamic> json) {
    return PPFavorite(
      toiletId: json['toiletId'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  @override
  List<Object?> get props => [toiletId, createdAt];
}
