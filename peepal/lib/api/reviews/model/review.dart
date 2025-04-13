import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:peepal/api/images/model/image.dart';

@immutable
class PPReview extends Equatable {
  final int id;
  final String username;
  final int rating;
  final String reviewText;
  final int reportCount;
  final DateTime createdAt;
  final PPImage? image;

  const PPReview({
    required this.id,
    required this.username,
    required this.rating,
    required this.reviewText,
    required this.reportCount,
    required this.image,
    required this.createdAt,
  });

  factory PPReview.fromJson(Map<String, dynamic> json) {
    return PPReview(
      id: json['id'],
      username: json['username'],
      rating: json['rating'],
      reviewText: json['reviewText'],
      reportCount: json['reportCount'],
      image: json['imageToken'] != null
          ? PPImage(token: json['imageToken'])
          : null,
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  @override
  List<Object?> get props => [
        username,
        rating,
        reviewText,
        reportCount,
        image,
        createdAt,
      ];
}
