import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';

@immutable
class PPAddress extends Equatable {
  final String placeName;
  final String address;

  const PPAddress({required this.placeName, required this.address});

  factory PPAddress.fromJson(Map<String, dynamic> json) =>
      PPAddress(placeName: json['placeName'], address: json['address']);

  @override
  List<Object?> get props => [placeName, address];
}
