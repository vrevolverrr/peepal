part of 'location_bloc.dart';

sealed class LocationState extends Equatable {
  const LocationState();

  @override
  List<Object> get props => [];
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
  final PPLocation location;

  const LocationStateWithLocation({
    required this.location,
  });

  @override
  List<Object> get props => [location];
}
