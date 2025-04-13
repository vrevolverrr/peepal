import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maps_toolkit/maps_toolkit.dart';
import 'package:peepal/api/client.dart';
import 'package:peepal/api/toilets/model/latlng.dart';
import 'package:peepal/api/toilets/model/toilet.dart';

part 'toilets_state.dart';
part 'toilet_event.dart';

class ToiletsBloc extends Bloc<ToiletsEvent, ToiletsState> {
  ToiletsBloc() : super(ToiletsStateInitial()) {
    on<ToiletEventFetchNearby>(_onFetchNearby);
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
}
