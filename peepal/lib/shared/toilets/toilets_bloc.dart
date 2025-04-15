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

class ToiletsBloc extends Bloc<ToiletEvent, ToiletsState> {
  ToiletsBloc() : super(ToiletsStateInitial()) {
    on<ToiletEventFetchNearby>(_onFetchNearby,
        transformer: _debounceSequential<ToiletEventFetchNearby>(
            const Duration(milliseconds: 1500)));

    on<ToiletEventSearch>(_onSearch,
        transformer: _debounceSequential<ToiletEventSearch>(
            const Duration(milliseconds: 500)));

    on<ToiletEventClearSearch>(_onClearSearch);

    on<ToiletEventUpdateToilet>(_onUpdateToilet);

    on<ToiletEventFetchToiletById>(_onFetchToiletById);
  }

  void _onFetchNearby(
      ToiletEventFetchNearby event, Emitter<ToiletsState> emit) async {
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

  void _onFetchToiletById(
      ToiletEventFetchToiletById event, Emitter<ToiletsState> emit) async {
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

  void _onSearch(ToiletEventSearch event, Emitter<ToiletsState> emit) async {
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

  void _onClearSearch(
      ToiletEventClearSearch event, Emitter<ToiletsState> emit) {
    emit(ToiletStateLoaded(toilets: state.toilets, searchResults: const []));
  }

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

  EventTransformer<T> _debounceSequential<T>(Duration duration) {
    return (events, mapper) =>
        sequential<T>().call(events.throttleTime(duration), mapper);
  }
}
