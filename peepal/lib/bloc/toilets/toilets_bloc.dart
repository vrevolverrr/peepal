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
            const Duration(seconds: 1)));
  }

  void _onFetchNearby(
      ToiletEventFetchNearby event, Emitter<ToiletsState> emit) async {
    try {
      final List<PPToilet> toilets = await PPClient.toilets.getNearbyToilets(
        location: event.location,
        radius: event.radius,
        limit: event.limit,
      );

      emit(ToiletStateLoaded(toilets: {...state.toilets, ...toilets}.toList()));
    } catch (e) {
      emit(ToiletStateError(toilets: state.toilets, error: e.toString()));
    }
  }

  EventTransformer<T> _debounceSequential<T>(Duration duration) {
    return (events, mapper) =>
        sequential<T>().call(events.throttleTime(duration), mapper);
  }
}
