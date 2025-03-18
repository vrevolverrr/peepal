import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

@immutable
class PPUser extends Equatable {
  final String id;
  final String name;
  final String email;

  const PPUser({
    required this.id,
    required this.name,
    required this.email,
  });

  @override
  List<Object?> get props => [id, name, email];
}
