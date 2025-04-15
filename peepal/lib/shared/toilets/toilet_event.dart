part of 'toilets_bloc.dart';

sealed class ToiletEvent extends Equatable {
  const ToiletEvent();

  @override
  List<Object> get props => [];
}

final class ToiletEventFetchNearby extends ToiletEvent {
  final PPLatLng location;
  final double? radius;
  final int? limit;

  const ToiletEventFetchNearby(
      {required this.location, this.radius, this.limit});
}

final class ToiletEventSearch extends ToiletEvent {
  final String query;
  final PPLatLng location;

  const ToiletEventSearch({
    required this.query,
    required this.location,
  });
}

final class ToiletEventClearSearch extends ToiletEvent {
  const ToiletEventClearSearch();
}

final class ToiletEventUpdateToilet extends ToiletEvent {
  final PPToilet toilet;

  const ToiletEventUpdateToilet({required this.toilet});
}
