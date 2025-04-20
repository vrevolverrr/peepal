part of 'toilets_bloc.dart';

/// The base class for all events related to the [ToiletsBloc].
sealed class ToiletEvent extends Equatable {
  const ToiletEvent();

  @override
  List<Object> get props => [];
}

/// Event triggered to fetch toilets nearby a specified location.
final class ToiletEventFetchNearby extends ToiletEvent {
  /// The geographical coordinates around which to search for toilets.
  final PPLatLng location;

  /// The radius (in kilometers) within which to search. Defaults to a server-defined value if null.
  final double? radius;

  /// The maximum number of toilets to return. Defaults to a server-defined value if null.
  final int? limit;

  const ToiletEventFetchNearby(
      {required this.location, this.radius, this.limit});
}

/// Event triggered to search for toilets based on a query string and location.
final class ToiletEventSearch extends ToiletEvent {
  /// The search query string.
  final String query;

  /// The user's current location, used for sorting or filtering search results.
  final PPLatLng location;

  const ToiletEventSearch({
    required this.query,
    required this.location,
  });
}

/// Event triggered to clear the current search results.
final class ToiletEventClearSearch extends ToiletEvent {
  const ToiletEventClearSearch();
}

/// Event triggered to update a single toilet's information in the state,
/// or remove it entirely.
final class ToiletEventUpdateToilet extends ToiletEvent {
  /// The toilet object with updated information.
  final PPToilet toilet;

  /// If true, the toilet should be removed from the state instead of updated.
  final bool shouldRemove;

  const ToiletEventUpdateToilet(
      {required this.toilet, this.shouldRemove = false});
}

/// Event triggered to fetch details for specific toilets by their IDs.
final class ToiletEventFetchToiletById extends ToiletEvent {
  /// A list of toilet IDs to fetch details for.
  final List<String> toiletIds;

  const ToiletEventFetchToiletById({required this.toiletIds});
}
