part of 'toilets_bloc.dart';

/// The state of the toilets page, containing a list of all toilets and the search results.
///
/// [toilets] is the list of all toilets.
/// [searchResults] is the list of toilets that match the current search query.
///
/// [getNearest] returns a list of toilets that are nearest to [location] in descending order of distance.
sealed class ToiletsState extends Equatable {
  /// The master list of all fetched toilets.
  final List<PPToilet> toilets;

  /// The list of toilets matching the current search criteria.
  final List<PPToilet> searchResults;

  const ToiletsState({
    this.toilets = const [],
    this.searchResults = const [],
  });

  /// Returns a list of the nearest toilets to the given [location].
  ///
  /// Sorts the [toilets] list based on distance from the provided [location]
  /// using the Haversine formula (via `SphericalUtil.computeDistanceBetween`)
  /// and returns the top [limit] results.
  ///
  /// - [location]: The central point from which to measure distance.
  /// - [limit]: The maximum number of nearest toilets to return (defaults to 5).
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
  List<Object> get props => [toilets, searchResults];
}

/// The initial state of the toilets page.
final class ToiletsStateInitial extends ToiletsState {
  const ToiletsStateInitial();
}

/// The state of the toilets page when the toilets are loading.
final class ToiletsStateLoading extends ToiletsState {
  const ToiletsStateLoading({
    super.toilets = const [],
    super.searchResults = const [],
  });
}

/// The state of the toilets page when the toilets are loaded.
final class ToiletStateLoaded extends ToiletsState {
  const ToiletStateLoaded({
    required super.toilets,
    super.searchResults = const [],
  });

  @override
  List<Object> get props => [toilets, searchResults];
}

/// The state of the toilets page when an error occurs.
final class ToiletStateError extends ToiletsState {
  /// Description of the error that occurred.
  final String error;

  const ToiletStateError({required this.error, super.toilets = const []});

  @override
  List<Object> get props => [error];
}
