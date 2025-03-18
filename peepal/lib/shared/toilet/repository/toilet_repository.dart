import 'package:peepal/shared/location/model/location.dart';
import 'package:peepal/shared/toilet/model/toilet.dart';
import 'package:peepal/shared/toilet/model/toilet_collection.dart';
import 'package:peepal/shared/toilet/model/toilet_crowd_level.dart';
import 'package:peepal/shared/toilet/model/toilet_features.dart';

abstract interface class ToiletRepository {
  Future<PPToilet> getToiletById(String id);

  Future<PPToiletCollection> getToiletsByLocation(
      {required PPLocation location, required double radius});

  Future<PPToiletCollection> getToiletsByFeatures(
      {PPLocation? location,
      double radius = 2.0,
      required PPToiletFeatures features});

  Future<PPToiletCollection> getToiletsByRating(
      {double minRating = 0.0, double maxRating = 5.0});

  Future<PPToiletCollection> getToiletsByAvailability(
      {PPLocation? location,
      double radius = 2.0,
      PPToiletCrowdLevel crowdLevel = PPToiletCrowdLevel.low});
}
