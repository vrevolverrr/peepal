import 'package:peepal/shared/location/model/location.dart';

class MockPPLocation extends PPLocation {
  const MockPPLocation({
    required double latitude,
    required double longitude,
  }) : super(latitude: latitude, longitude: longitude);

  @override
  double distanceTo(PPLocation other) {
    // Mock implementation of distance calculation
    return super.distanceTo(other);
  }
}