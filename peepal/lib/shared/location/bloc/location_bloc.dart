import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logging/logging.dart';
import 'package:peepal/api/toilets/model/latlng.dart';
import 'package:peepal/shared/location/repository/location_repository.dart';

part 'location_state.dart';

/// A bloc that provides access to the user's location.
///
/// This bloc must be initialized by calling [init] before using it. This
/// method will request the location permission and check if the user has it.
/// If the user does not have the permission, it will be requested. If the
/// user denies the permission, the bloc will emit [LocationStateNoPermission].
class LocationCubit extends Cubit<LocationState> {
  /// Logger for this cubit.
  final Logger log = Logger('LocationCubit');

  /// The repository used to interact with the device's location services.
  final LocationRepository repository;

  /// Creates a [LocationCubit] instance.
  ///
  /// Requires a [LocationRepository] to interact with location services.
  /// Starts in the [LocationStateUnknown] state.
  LocationCubit(this.repository) : super(LocationStateUnknown());

  /// Initializes the location cubit.
  ///
  /// Checks for existing location permissions. If not granted, it requests them.
  /// If permission is granted (either initially or after request), it emits
  /// [LocationStatePermissionGranted] and attempts to get the current location.
  /// If permission is denied, it emits [LocationStateNoPermission].
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

  /// Attempts to retrieve the user's current location.
  ///
  /// This should only be called after [init] has successfully granted permission
  /// (i.e., the state is [LocationStatePermissionGranted] or [LocationStateWithLocation]).
  /// Emits [LocationStateWithLocation] on success or [LocationStateError] on failure.
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

  /// Explicitly requests location permission from the user.
  ///
  /// Emits [LocationStatePermissionGranted] if permission is granted,
  /// otherwise emits [LocationStateNoPermission].
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

  /// Returns a stream of location updates.
  ///
  /// This should only be called after [init] has successfully granted permission.
  /// If permission is not granted, it returns an empty stream and logs a warning.
  /// Otherwise, it returns the stream provided by the [repository].
  Stream<PPLatLng> getLocationUpdates() {
    if (state is! LocationStatePermissionGranted) {
      log.warning("Permission is not granted, call init() first.");
      return Stream<PPLatLng>.empty();
    }

    return repository.getLocationStream();
  }
}
