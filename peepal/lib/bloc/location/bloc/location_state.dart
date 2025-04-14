part of 'location_bloc.dart';

sealed class LocationState extends Equatable {
  final PPLatLng location;

  const LocationState({
    // Default location center of Singapore
    this.location = const PPLatLng(latitude: 1.287953, longitude: 103.851957),
  });

  @override
  List<Object> get props => [location];
}

final class LocationStateUnknown extends LocationState {
  const LocationStateUnknown();
}

final class LocationStateNoPermission extends LocationState {
  const LocationStateNoPermission();
}

final class LocationStatePermissionGranted extends LocationState {
  const LocationStatePermissionGranted();
}

final class LocationStateError extends LocationState {
  final String error;

  const LocationStateError({
    required this.error,
  });

  @override
  List<Object> get props => [error];
}

final class LocationStateWithLocation extends LocationState {
  const LocationStateWithLocation({
    required super.location,
  });

  @override
  List<Object> get props => [location];
}
