part of 'nearby_toilet_bloc.dart';

sealed class NearbyToiletState extends Equatable {
  const NearbyToiletState();

  @override
  List<Object> get props => [];
}

final class NearbyToiletStateInitial extends NearbyToiletState {
  const NearbyToiletStateInitial();
}

final class NearbyToiletStateLoading extends NearbyToiletState {
  const NearbyToiletStateLoading();
}

final class NearbyToiletStateError extends NearbyToiletState {
  final String error;

  const NearbyToiletStateError({
    required this.error,
  });

  @override
  List<Object> get props => [error];
}

final class NearbyToiletStateLoaded extends NearbyToiletState {
  final PPToiletCollection toilets;

  const NearbyToiletStateLoaded({
    required this.toilets,
  });

  @override
  List<Object> get props => [toilets];
}
