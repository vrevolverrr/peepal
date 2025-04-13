part of 'toilets_bloc.dart';

sealed class ToiletsState extends Equatable {
  final List<PPToilet> toilets;

  const ToiletsState({this.toilets = const []});

  List<PPToilet> getNearest({required PPLatLng location, int limit = 5}) {
    final List<PPToilet> sortedToilets = List.from(toilets);

    sortedToilets.sort((a, b) => SphericalUtil.computeDistanceBetween(
                a.location.toLatLng(), location.toLatLng())
            .compareTo(
          SphericalUtil.computeDistanceBetween(
              b.location.toLatLng(), location.toLatLng()),
        ));

    return sortedToilets.take(limit).toList();
  }

  @override
  List<Object> get props => [toilets];
}

final class ToiletsStateInitial extends ToiletsState {
  const ToiletsStateInitial();
}

final class ToiletStateLoaded extends ToiletsState {
  const ToiletStateLoaded({required super.toilets});

  @override
  List<Object> get props => [toilets];
}

final class ToiletStateError extends ToiletsState {
  final String error;

  const ToiletStateError({required this.error, super.toilets = const []});

  @override
  List<Object> get props => [error];
}
