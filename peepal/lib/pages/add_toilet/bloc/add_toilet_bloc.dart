import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:peepal/api/client.dart';
import 'package:peepal/api/toilets/model/address.dart';
import 'package:peepal/api/toilets/model/latlng.dart';
import 'package:peepal/api/toilets/model/toilet.dart';
import 'package:peepal/shared/location/bloc/location_bloc.dart';
import 'package:peepal/shared/toilets/toilets_bloc.dart';

part 'add_toilet_state.dart';
part 'add_toilet_event.dart';

class AddToiletBloc extends Bloc<AddToiletEvent, AddToiletState> {
  final ToiletsBloc toiletsBloc;
  final LocationCubit locationCubit;

  AddToiletBloc({required this.toiletsBloc, required this.locationCubit})
      : super(AddToiletStateInitial()) {
    on<AddToiletEventSelectLocation>(_onSelectLocation);
    on<AddToiletEventNameUpdated>(_onNameUpdated);
    on<AddToiletEventRate>(_onRatingUpdated);
    on<AddToiletEventHandicapToggled>(_onHandicapAvailUpdated);
    on<AddToiletEventBidetToggled>(_onBidetAvailUpdated);
    on<AddToiletEventShowerToggled>(_onShowerAvailUpdated);
    on<AddToiletEventSanitiserToggled>(_onSanitiserAvailUpdated);
    on<AddToiletEventCreate>(_onToiletCreate);
  }

  void _onNameUpdated(
      AddToiletEventNameUpdated event, Emitter<AddToiletState> emit) {
    emit(
        state.copyWith(details: state.details.copyWith(placeName: event.name)));
  }

  void _onRatingUpdated(
      AddToiletEventRate event, Emitter<AddToiletState> emit) {
    emit(state.copyWith(details: state.details.copyWith(rating: event.rating)));
  }

  void _onHandicapAvailUpdated(
      AddToiletEventHandicapToggled event, Emitter<AddToiletState> emit) {
    emit(state.copyWith(
        details: state.details.copyWith(handicapAvail: event.handicapAvail)));
  }

  void _onBidetAvailUpdated(
      AddToiletEventBidetToggled event, Emitter<AddToiletState> emit) {
    emit(state.copyWith(
        details: state.details.copyWith(bidetAvail: event.bidetAvail)));
  }

  void _onShowerAvailUpdated(
      AddToiletEventShowerToggled event, Emitter<AddToiletState> emit) {
    emit(state.copyWith(
        details: state.details.copyWith(showerAvail: event.showerAvail)));
  }

  void _onSanitiserAvailUpdated(
      AddToiletEventSanitiserToggled event, Emitter<AddToiletState> emit) {
    emit(state.copyWith(
        details: state.details.copyWith(sanitiserAvail: event.sanitiserAvail)));
  }

  void _onSelectLocation(
      AddToiletEventSelectLocation event, Emitter<AddToiletState> emit) async {
    emit(AddToiletStateLoadingPlaceDetails(
      details: state.details.copyWith(selectedLocation: event.location),
    ));

    final PPAddress address = await PPClient.toilets.getAddressFromLocation(
      event.location,
    );

    emit(AddToiletStatePlaceSelected(
        details: state.details.copyWith(
      selectedAddress: address,
      placeName: address.placeName,
    )));
  }

  void _onToiletCreate(
      AddToiletEventCreate event, Emitter<AddToiletState> emit) async {
    emit(AddToiletStateCreating(details: state.details));

    try {
      final PPToilet createdToilet = await PPClient.toilets.createToilet(
        name: state.details.placeName!,
        address: state.details.selectedAddress!.placeName,
        location: state.details.selectedLocation!,
        currentLocation: locationCubit.state.location,
        rating: state.details.rating!,
        handicapAvail: state.details.handicapAvail,
        bidetAvail: state.details.bidetAvail,
        showerAvail: state.details.showerAvail,
        sanitiserAvail: state.details.sanitiserAvail,
      );

      toiletsBloc.add(ToiletEventUpdateToilet(toilet: createdToilet));

      await Future.delayed(const Duration(milliseconds: 300));

      emit(AddToiletStateCreated(details: AddToiletDetails()));
    } catch (e) {
      emit(AddToiletStateError(
        details: state.details,
        error: e.toString(),
      ));
    }
  }
}
