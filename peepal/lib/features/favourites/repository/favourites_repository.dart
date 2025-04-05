import 'dart:developer';
import 'package:peepal/shared/location/model/mock_location.dart';
import 'package:peepal/shared/toilet/model/toilet.dart';
import 'package:peepal/shared/toilet/model/toilet_collection.dart';
import 'package:peepal/shared/toilet/model/toilet_crowd_level.dart';
import 'package:peepal/shared/toilet/model/toilet_features.dart';

abstract interface class FavouritesRespository {
  Future<PPToiletCollection> getFavourites();
  Future<void> addFavourite(String toiletId);
  Future<void> removeFavourite(String toiletId);
  Future<bool> isFavourite(String toiletId);
}

class MockFavouritesRepository implements FavouritesRespository {
  final List<PPToilet> _mockToilets = [
    PPToilet(
      id: 1,
      name: 'Toilet 1',
      location: MockPPLocation(
        latitude: 1.2900,
        longitude: 103.8500,
      ), // Use PPLocationAdapter instead of PPLocation
      address: '123 Main Street',
      rating: 4.5,
      features: PPToiletFeatures(
        hasBidet: true,
        hasShower: false,
        hasSanitizer: true,
        hasAccessibility: true,
      ), // Use correct properties for PPToiletFeatures
      crowdStatus: PPToiletCrowdStatus(
          crowdLevel: PPToiletCrowdLevel.empty,
          estimatedWaitTime: 0,
          estimatedCrowdSize: 0),
    ),
    PPToilet(
      id: 2,
      name: 'Toilet 2',
      location: MockPPLocation(
        latitude: 1.3000,
        longitude: 103.8000,
      ),
      address: '456 Another Street',
      rating: 4.0,
      features: PPToiletFeatures(
        hasBidet: false,
        hasShower: true,
        hasSanitizer: true,
        hasAccessibility: false,
      ),
      crowdStatus: PPToiletCrowdStatus(
          crowdLevel: PPToiletCrowdLevel.empty,
          estimatedWaitTime: 0,
          estimatedCrowdSize: 0),
    ),
  ];

  final List<String> _favouriteIds = []; // Store favorite toilet IDs

  @override
  Future<PPToiletCollection> getFavourites() async {
    try {
      await Future.delayed(Duration(seconds: 1)); // Simulate network delay
      return PPToiletCollection(_mockToilets);
    } catch (e) {
      log('Error in getFavourites: $e');
      rethrow;
    }
  }

  @override
  Future<void> addFavourite(String toiletId) async {
    await Future.delayed(Duration(milliseconds: 500)); // Simulate delay
    if (!_favouriteIds.contains(toiletId)) {
      _favouriteIds.add(toiletId);
    }
  }

  @override
  Future<void> removeFavourite(String toiletId) async {
    await Future.delayed(Duration(milliseconds: 500)); // Simulate delay
    _favouriteIds.remove(toiletId);
  }

  @override
  Future<bool> isFavourite(String toiletId) async {
    await Future.delayed(Duration(milliseconds: 500)); // Simulate delay
    return _favouriteIds.contains(toiletId);
  }
}
