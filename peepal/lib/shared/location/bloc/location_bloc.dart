import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logging/logging.dart';
import 'package:peepal/api/toilets/model/latlng.dart';
import 'package:peepal/shared/location/repository/location_repository.dart';

part 'location_state.dart';

class LocationCubit extends Cubit<LocationState> {
  final Logger log = Logger('LocationCubit');

  final LocationRepository repository;

  LocationCubit(this.repository) : super(LocationStateUnknown());

  void init() async {
    log.info("Initializing location service");

    final hasPermission = await repository.checkPermission();

    if (!hasPermission) {
      if (await repository.requestPermission()) {
        log.info("Location permission is granted");
      } else {
        log.warning("Location permission is not granted");
        emit(LocationStateNoPermission());
        return;
      }
    }

    log.info("Location permission is granted");
    emit(LocationStatePermissionGranted());

    getCurrentLocation();
  }

  void getCurrentLocation() async {
    log.info("Getting current location");

    if (state is! LocationStatePermissionGranted) {
      log.warning("Permission is not granted, call init() first.");
      return;
    }

    try {
      final PPLatLng location = await repository.getCurrentLocation();

      log.info("Current location: $location");
      emit(LocationStateWithLocation(location: location));
    } catch (e) {
      log.severe("Error getting current location: $e");
      emit(LocationStateError(error: e.toString()));
    }
  }

  void requestPermission() async {
    log.info("Requesting location permission");

    final hasPermission = await repository.requestPermission();

    if (!hasPermission) {
      log.warning("Location permission is not granted");
      emit(LocationStateNoPermission());
    }

    log.info("Location permission is granted");
    emit(LocationStatePermissionGranted());
  }

  Stream<PPLatLng> getLocationUpdates() {
    if (state is! LocationStatePermissionGranted) {
      log.warning("Permission is not granted, call init() first.");
      return Stream<PPLatLng>.empty();
    }

    return repository.getLocationStream();
  }
}
