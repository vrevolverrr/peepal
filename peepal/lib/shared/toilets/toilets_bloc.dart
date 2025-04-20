import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maps_toolkit/maps_toolkit.dart';
import 'package:peepal/api/client.dart';
import 'package:peepal/api/toilets/model/latlng.dart';
import 'package:peepal/api/toilets/model/toilet.dart';
import 'package:rxdart/rxdart.dart';

part 'toilets_state.dart';
part 'toilet_event.dart';

/// ToiletsBloc manages the state of toilet-related actions and events.
///
/// This Bloc handles events related to fetching nearby toilets, searching
/// for toilets, clearing search results, updating toilet information,
/// and fetching toilets by their IDs. It uses a debounce mechanism to
/// throttle certain events for performance optimization.
class ToiletsBloc extends Bloc<ToiletEvent, ToiletsState> {
  ToiletsBloc() : super(ToiletsStateInitial()) {
    on<ToiletEventFetchNearby>(
      _onFetchNearby,
      transformer: _debounceSequential<ToiletEventFetchNearby>(
          const Duration(milliseconds: 1500)),
    );

    on<ToiletEventSearch>(
      _onSearch,
      transformer: _debounceSequential<ToiletEventSearch>(
          const Duration(milliseconds: 500)),
    );

    on<ToiletEventClearSearch>(_onClearSearch);

    on<ToiletEventUpdateToilet>(_onUpdateToilet);

    on<ToiletEventFetchToiletById>(_onFetchToiletById);
  }

  /// Handles the [ToiletEventFetchNearby] event.
  ///
  /// Fetches toilets near the specified location from the API and updates the
  /// state. Merges the newly fetched toilets with the existing ones to avoid
  /// duplicates.
  void _onFetchNearby(
      ToiletEventFetchNearby event, Emitter<ToiletsState> emit) async {
    emit(ToiletsStateLoading(
        toilets: state.toilets, searchResults: state.searchResults));
    try {
      final List<PPToilet> toilets = await PPClient.toilets.getNearbyToilets(
        location: event.location,
        radius: event.radius,
        limit: event.limit,
      );

      emit(ToiletStateLoaded(
          toilets: {...state.toilets, ...toilets}.toList(),
          searchResults: state.searchResults));
    } catch (e) {
      emit(ToiletStateError(toilets: state.toilets, error: e.toString()));
    }
  }

  /// Handles the [ToiletEventFetchToiletById] event.
  ///
  /// Fetches details for specific toilets by their IDs from the API.
  /// Filters out IDs for toilets already present in the state to avoid redundant calls.
  /// Updates the state by merging the newly fetched toilets.
  void _onFetchToiletById(
      ToiletEventFetchToiletById event, Emitter<ToiletsState> emit) async {
    emit(ToiletsStateLoading(
        toilets: state.toilets, searchResults: state.searchResults));
    try {
      final List<String> filteredIds = event.toiletIds
          .where((id) => !state.toilets.any((toilet) => toilet.id == id))
          .toList();

      if (filteredIds.isEmpty) {
        return;
      }

      final List<PPToilet> toilets =
          await PPClient.toilets.getToiletByIds(toiletIds: filteredIds);

      emit(ToiletStateLoaded(
          toilets: {...state.toilets, ...toilets}.toList(),
          searchResults: state.searchResults));
    } catch (e) {
      emit(ToiletStateError(toilets: state.toilets, error: e.toString()));
    }
  }

  /// Handles the [ToiletEventSearch] event.
  ///
  /// Performs a search for toilets based on the query and location using the API.
  /// Updates the state with both the merged list of all toilets (including search results)
  /// and the specific search results.
  void _onSearch(ToiletEventSearch event, Emitter<ToiletsState> emit) async {
    emit(ToiletsStateLoading(
        toilets: state.toilets, searchResults: state.searchResults));
    try {
      final List<PPToilet> toilets = await PPClient.toilets.searchToilets(
        query: event.query,
        location: event.location,
      );

      emit(ToiletStateLoaded(
          toilets: {...state.toilets, ...toilets}.toList(),
          searchResults: toilets));
    } catch (e) {
      emit(ToiletStateError(toilets: state.toilets, error: e.toString()));
    }
  }

  /// Handles the [ToiletEventClearSearch] event.
  ///
  /// Clears the search results in the state while keeping the main list of toilets.
  void _onClearSearch(
      ToiletEventClearSearch event, Emitter<ToiletsState> emit) {
    emit(ToiletStateLoaded(toilets: state.toilets, searchResults: const []));
  }

  /// Handles the [ToiletEventUpdateToilet] event.
  ///
  /// Updates a single toilet in the state list or removes it.
  /// If [event.shouldRemove] is true, the toilet is removed.
  /// Otherwise, the existing toilet with the same ID is replaced with [event.toilet],
  /// or [event.toilet] is added if it doesn't exist.
  void _onUpdateToilet(
      ToiletEventUpdateToilet event, Emitter<ToiletsState> emit) {
    final List<PPToilet> newList = List.from(state.toilets);

    final existingToilet = newList.firstWhere(
      (toilet) => toilet.id == event.toilet.id,
      orElse: () => event.toilet,
    );

    newList.removeWhere((toilet) => toilet.id == event.toilet.id);

    if (!event.shouldRemove) {
      final updatedToilet = event.toilet.copyWith(
        distance: existingToilet.distance,
      );

      newList.add(updatedToilet);
    }

    emit(ToiletStateLoaded(
        toilets: newList, searchResults: state.searchResults));
  }

  /// Creates an [EventTransformer] that debounces events using [duration]
  /// and processes them sequentially.
  ///
  /// This is useful for events like search or fetching nearby items where
  /// rapid firing should be throttled, and subsequent events should wait for
  /// the previous one to complete.
  EventTransformer<T> _debounceSequential<T>(Duration duration) {
    return (events, mapper) =>
        sequential<T>().call(events.throttleTime(duration), mapper);
  }
}
