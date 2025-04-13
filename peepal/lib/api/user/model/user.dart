import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

enum PPGender { male, female, other }

@immutable
final class PPUser extends Equatable {
  final String id;
  final String username;
  final String email;
  final PPGender gender;

  const PPUser({
    required this.id,
    required this.email,
    required this.username,
    required this.gender,
  });

  factory PPUser.fromJson(Map<String, dynamic> json) {
    return PPUser(
      id: json['id'],
      email: json['email'],
      username: json['username'],
      gender: PPGender.values.firstWhere(
        (g) => g.name == json['gender'],
        orElse: () => PPGender.other,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'username': username,
      'gender': gender.name,
    };
  }

  @override
  List<Object?> get props => [id, email, username, gender];
}
