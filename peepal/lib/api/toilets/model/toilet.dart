import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:peepal/api/images/model/image.dart';
import 'package:peepal/api/toilets/model/latlng.dart';

@immutable
class PPToilet extends Equatable {
  final String id;
  final String name;
  final String address;
  final PPLatLng location;
  final int? distance;
  final double rating;
  final int reportCount;
  final int crowdLevel;
  final PPImage? image;
  final bool? handicapAvail;
  final bool? bidetAvail;
  final bool? showerAvail;
  final bool? sanitiserAvail;

  const PPToilet({
    required this.id,
    required this.name,
    required this.address,
    required this.location,
    required this.distance,
    required this.rating,
    required this.reportCount,
    required this.crowdLevel,
    this.image,
    this.handicapAvail,
    this.bidetAvail,
    this.showerAvail,
    this.sanitiserAvail,
  });

  PPToilet copyWith({
    String? id,
    String? name,
    String? address,
    PPLatLng? location,
    int? distance,
    double? rating,
    int? reportCount,
    int? crowdLevel,
    PPImage? image,
    bool? handicapAvail,
    bool? bidetAvail,
    bool? showerAvail,
    bool? sanitiserAvail,
  }) {
    return PPToilet(
      id: id ?? this.id,
      name: name ?? this.name,
      address: address ?? this.address,
      location: location ?? this.location,
      distance: distance ?? this.distance,
      rating: rating ?? this.rating,
      reportCount: reportCount ?? this.reportCount,
      crowdLevel: crowdLevel ?? this.crowdLevel,
      image: image ?? this.image,
      handicapAvail: handicapAvail ?? this.handicapAvail,
      bidetAvail: bidetAvail ?? this.bidetAvail,
      showerAvail: showerAvail ?? this.showerAvail,
      sanitiserAvail: sanitiserAvail ?? this.sanitiserAvail,
    );
  }

  factory PPToilet.fromJson(Map<String, dynamic> json) {
    return PPToilet(
      id: json['id'],
      name: json['name'],
      address: json['address'],
      location: PPLatLng.fromLocation(json['location']),
      distance: json['distance'],
      rating: double.parse(json['rating']),
      reportCount: json['reportCount'],
      crowdLevel: json['crowdLevel'],
      image: json['imageToken'] != null
          ? PPImage(token: json['imageToken'])
          : null,
      handicapAvail: json['handicapAvail'],
      bidetAvail: json['bidetAvail'],
      showerAvail: json['showerAvail'],
      sanitiserAvail: json['sanitiserAvail'],
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        address,
        location,
        rating,
        reportCount,
        crowdLevel,
        image,
        handicapAvail,
        bidetAvail,
        showerAvail,
        sanitiserAvail,
      ];
}
