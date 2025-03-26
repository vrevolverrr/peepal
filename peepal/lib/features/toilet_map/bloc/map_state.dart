part of 'map_bloc.dart';

@immutable
sealed class ToiletMapState extends Equatable {
  final PPLocation? currentLocation;

  const ToiletMapState({
    required this.currentLocation,
  });

  ToiletMapState copyWith({
    PPLocation? currentLocation,
  });

  @override
  List<Object> get props => [];
}

/// Initial state of the bloc
final class ToiletMapStateInitial extends ToiletMapState {
  const ToiletMapStateInitial() : super(currentLocation: null);

  @override
  ToiletMapStateInitial copyWith({PPLocation? currentLocation}) {
    return ToiletMapStateInitial();
  }
}

/// State when the bloc is waiting for Google Maps to load
final class ToiletMapStateLoading extends ToiletMapState {
  const ToiletMapStateLoading() : super(currentLocation: null);

  @override
  ToiletMapStateLoading copyWith({PPLocation? currentLocation}) {
    return ToiletMapStateLoading();
  }
}

final class ToiletMapStateError extends ToiletMapState {
  final String message;

  const ToiletMapStateError({
    required this.message,
  }) : super(currentLocation: null);

  @override
  List<Object> get props => [message];

  @override
  ToiletMapState copyWith({PPLocation? currentLocation}) {
    return ToiletMapStateError(
      message: message,
    );
  }
}

final class ToiletMapStateReady extends ToiletMapState {
  const ToiletMapStateReady({required super.currentLocation});

  @override
  ToiletMapState copyWith({PPLocation? currentLocation}) {
    return ToiletMapStateReady(
        currentLocation: currentLocation ?? this.currentLocation);
  }
}

final class ToiletMapStateMapLoaded extends ToiletMapState {
  const ToiletMapStateMapLoaded({required super.currentLocation});

  @override
  ToiletMapState copyWith({PPLocation? currentLocation}) {
    return ToiletMapStateMapLoaded(
        currentLocation: currentLocation ?? this.currentLocation);
  }
}

final class ToiletMapSearchResults extends ToiletMapState {
  final PPToiletCollection results;

  const ToiletMapSearchResults({
    required this.results,
    required super.currentLocation,
  });

  @override
  List<Object> get props => [results];

  @override
  ToiletMapState copyWith({PPLocation? currentLocation}) {
    return ToiletMapSearchResults(
      results: results,
      currentLocation: currentLocation ?? this.currentLocation,
    );
  }
}
