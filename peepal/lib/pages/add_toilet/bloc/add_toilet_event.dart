part of 'add_toilet_bloc.dart';

sealed class AddToiletEvent extends Equatable {
  const AddToiletEvent();

  @override
  List<Object?> get props => [];
}

final class AddToiletEventSelectLocation extends AddToiletEvent {
  final PPLatLng location;

  const AddToiletEventSelectLocation({required this.location});

  @override
  List<Object?> get props => [location];
}

final class AddToiletEventNameUpdated extends AddToiletEvent {
  final String name;

  const AddToiletEventNameUpdated({required this.name});

  @override
  List<Object?> get props => [name];
}

final class AddToiletEventHandicapToggled extends AddToiletEvent {
  final bool handicapAvail;

  const AddToiletEventHandicapToggled({required this.handicapAvail});

  @override
  List<Object?> get props => [handicapAvail];
}

final class AddToiletEventBidetToggled extends AddToiletEvent {
  final bool bidetAvail;

  const AddToiletEventBidetToggled({required this.bidetAvail});

  @override
  List<Object?> get props => [bidetAvail];
}

final class AddToiletEventShowerToggled extends AddToiletEvent {
  final bool showerAvail;

  const AddToiletEventShowerToggled({required this.showerAvail});

  @override
  List<Object?> get props => [showerAvail];
}

final class AddToiletEventSanitiserToggled extends AddToiletEvent {
  final bool sanitiserAvail;

  const AddToiletEventSanitiserToggled({required this.sanitiserAvail});

  @override
  List<Object?> get props => [sanitiserAvail];
}

final class AddToiletEventRate extends AddToiletEvent {
  final int rating;

  const AddToiletEventRate({required this.rating});

  @override
  List<Object?> get props => [rating];
}

final class AddToiletEventCreate extends AddToiletEvent {
  const AddToiletEventCreate();

  @override
  List<Object?> get props => [];
}
