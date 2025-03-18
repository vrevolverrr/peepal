import 'package:peepal/shared/location/model/location.dart';

abstract interface class LocationRepository {
  Future<PPLocation> getCurrentLocation();
}
