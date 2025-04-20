part of 'location_bloc.dart';

/// The state of the location cubit.
///
/// This class extends [Equatable] and is used to represent the state of the
/// location cubit.
sealed class LocationState extends Equatable {
  final PPLatLng location;

  const LocationState({
    // Default location center of Singapore
    this.location = const PPLatLng(latitude: 1.287953, longitude: 103.851957),
  });

  @override
  List<Object> get props => [location];
}

/// The state of the location cubit when the location is unknown.
final class LocationStateUnknown extends LocationState {
  const LocationStateUnknown();
}

/// The state of the location cubit when the location permission is not granted.
final class LocationStateNoPermission extends LocationState {
  const LocationStateNoPermission();
}

/// The state of the location cubit when the location permission is granted.
final class LocationStatePermissionGranted extends LocationState {
  const LocationStatePermissionGranted();
}

/// The state of the location cubit when an error occurs.
final class LocationStateError extends LocationState {
  final String error;

  const LocationStateError({
    required this.error,
  });

  @override
  List<Object> get props => [error];
}

/// The state of the location cubit when the location is known.
final class LocationStateWithLocation extends LocationState {
  const LocationStateWithLocation({
    required super.location,
  });

  @override
  List<Object> get props => [location];
}
