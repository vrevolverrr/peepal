import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:peepal/client/auth/model/user.dart';
import 'package:peepal/client/images/model/image.dart';

@immutable
class PPReview extends Equatable {
  final PPUser user;
  final int rating;
  final String reviewText;
  final int reportCount;
  final PPImage image;
  final DateTime createdAt;

  const PPReview({
    required this.user,
    required this.rating,
    required this.reviewText,
    required this.reportCount,
    required this.image,
    required this.createdAt,
  });

  factory PPReview.fromJson(Map<String, dynamic> json) {
    return PPReview(
      user: PPUser.fromJson(json['user']),
      rating: json['rating'],
      reviewText: json['reviewText'],
      reportCount: json['reportCount'],
      image: PPImage(token: json['imageToken']),
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  @override
  List<Object?> get props => [
        user,
        rating,
        reviewText,
        reportCount,
        image,
        createdAt,
      ];
}
