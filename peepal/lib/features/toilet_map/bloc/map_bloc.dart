import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:peepal/shared/location/model/location.dart';
import 'package:peepal/shared/location/repository/location_repository.dart';
import 'package:peepal/shared/toilet/model/toilet_collection.dart';

part 'map_event.dart';
part 'map_state.dart';

class ToiletMapBloc extends Bloc<ToiletMapEvent, ToiletMapState> {
  // final ToiletRepository toiletRepository;
  final LocationRepository locationRepository;

  ToiletMapBloc({required this.locationRepository})
      : super(ToiletMapStateLoading()) {
    on<ToiletMapEventInit>(_onToiletMapInit);
    on<ToiletMapEventLoaded>(_onToiletMapLoaded);
  }

  @override
  void onEvent(ToiletMapEvent event) {
    debugPrint(event.toString());
    super.onEvent(event);
  }

  @override
  void onChange(Change<ToiletMapState> change) {
    debugPrint(change.toString());
    super.onChange(change);
  }

  /// Initializes the bloc by requesting location permission
  void _onToiletMapInit(
      ToiletMapEventInit event, Emitter<ToiletMapState> emit) async {
    final bool hasPermission = await locationRepository.checkPermission();

    if (hasPermission) {
      emit(ToiletMapStateLoading());
      return;
    }

    final bool granted = await locationRepository.requestPermission();

    if (!granted) {
      emit(ToiletMapStateError(message: "Location permission is not granted"));
    }

    emit(ToiletMapStateLoading());
  }

  void _onToiletMapLoaded(
      ToiletMapEventLoaded event, Emitter<ToiletMapState> emit) async {
    /// Maps has been loaded, now we can start listening to location changes
    emit.forEach(await locationRepository.getLocationStream(),
        onData: (data) => (state.copyWith(currentLocation: data)));

    final PPLocation location = await locationRepository.getCurrentLocation();

    emit(ToiletMapStateReady(currentLocation: location));
  }
}
