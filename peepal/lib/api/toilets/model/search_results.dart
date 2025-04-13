import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:peepal/api/images/model/image.dart';

@immutable
class PPSearchResult extends Equatable {
  final String id;
  final String name;
  final double rating;
  final int distance;
  final PPImage? image;

  const PPSearchResult({
    required this.id,
    required this.name,
    required this.rating,
    required this.distance,
    required this.image,
  });

  factory PPSearchResult.fromJson(Map<String, dynamic> json) {
    return PPSearchResult(
      id: json['id'],
      name: json['name'],
      rating: double.parse(json['rating']),
      distance: json['distance'],
      image: json['imageToken'] != null
          ? PPImage(token: json['imageToken'])
          : null,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        rating,
        distance,
        image,
      ];
}
