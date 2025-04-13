part of 'toilets_bloc.dart';

sealed class ToiletsEvent extends Equatable {
  const ToiletsEvent();

  @override
  List<Object> get props => [];
}

final class ToiletEventFetchNearby extends ToiletsEvent {
  final PPLatLng location;
  final double? radius;
  final int? limit;

  const ToiletEventFetchNearby(
      {required this.location, this.radius, this.limit});
}
