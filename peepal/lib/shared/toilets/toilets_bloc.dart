import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
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

  void _onSearch(ToiletEventSearch event, Emitter<ToiletsState> emit) async {
    try {
      final List<PPToilet> toilets = await PPClient.toilets.searchToilets(
        query: event.query,
        location: event.location,
      );

      emit(ToiletStateLoaded(
          toilets: {...state.toilets, ...toilets}.toList(),
          searchResults: toilets));

      debugPrint('Search results ${toilets.map((x) => x.name).join(', ')}');
    } catch (e) {
      emit(ToiletStateError(toilets: state.toilets, error: e.toString()));
    }
  }

  void _onClearSearch(
      ToiletEventClearSearch event, Emitter<ToiletsState> emit) {
    emit(ToiletStateLoaded(toilets: state.toilets, searchResults: const []));
  }

  EventTransformer<T> _debounceSequential<T>(Duration duration) {
    return (events, mapper) =>
        sequential<T>().call(events.throttleTime(duration), mapper);
  }
}
