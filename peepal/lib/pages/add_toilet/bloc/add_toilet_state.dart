part of 'add_toilet_bloc.dart';

final class AddToiletDetails extends Equatable {
  final PPLatLng? selectedLocation;
  final PPAddress? selectedAddress;
  final String? placeName;
  final int? rating;
  final bool? handicapAvail;
  final bool? bidetAvail;
  final bool? showerAvail;
  final bool? sanitiserAvail;

  const AddToiletDetails({
    this.selectedLocation,
    this.selectedAddress,
    this.placeName,
    this.rating = 3,
    this.handicapAvail = false,
    this.bidetAvail = false,
    this.showerAvail = false,
    this.sanitiserAvail = false,
  });

  AddToiletDetails copyWith({
    PPLatLng? selectedLocation,
    PPAddress? selectedAddress,
    String? placeName,
    int? rating,
    bool? handicapAvail,
    bool? bidetAvail,
    bool? showerAvail,
    bool? sanitiserAvail,
  }) {
    return AddToiletDetails(
      selectedLocation: selectedLocation ?? this.selectedLocation,
      selectedAddress: selectedAddress ?? this.selectedAddress,
      placeName: placeName ?? this.placeName,
      rating: rating ?? this.rating,
      handicapAvail: handicapAvail ?? this.handicapAvail,
      bidetAvail: bidetAvail ?? this.bidetAvail,
      showerAvail: showerAvail ?? this.showerAvail,
      sanitiserAvail: sanitiserAvail ?? this.sanitiserAvail,
    );
  }

  @override
  List<Object?> get props => [
        selectedLocation,
        selectedAddress,
        placeName,
        rating,
        handicapAvail,
        bidetAvail,
        showerAvail,
        sanitiserAvail,
      ];
}

sealed class AddToiletState extends Equatable {
  final AddToiletDetails details;
  const AddToiletState({required this.details});

  AddToiletState copyWith({
    AddToiletDetails? details,
  });

  @override
  List<Object?> get props => [details];
}

/// Initial state, default values
final class AddToiletStateInitial extends AddToiletState {
  const AddToiletStateInitial({
    super.details = const AddToiletDetails(
      selectedLocation: null,
      selectedAddress: null,
      placeName: null,
      rating: 3,
      handicapAvail: false,
      bidetAvail: false,
      showerAvail: false,
      sanitiserAvail: false,
    ),
  });

  @override
  AddToiletStateInitial copyWith({
    AddToiletDetails? details,
  }) {
    return AddToiletStateInitial(
      details: details ?? this.details,
    );
  }
}

final class AddToiletStateLoadingPlaceDetails extends AddToiletState {
  const AddToiletStateLoadingPlaceDetails({
    required super.details,
  });

  @override
  AddToiletStateLoadingPlaceDetails copyWith({
    AddToiletDetails? details,
  }) {
    return AddToiletStateLoadingPlaceDetails(
      details: details ?? this.details,
    );
  }
}

final class AddToiletStatePlaceSelected extends AddToiletState {
  const AddToiletStatePlaceSelected({
    required super.details,
  });

  @override
  AddToiletStatePlaceSelected copyWith({
    AddToiletDetails? details,
  }) {
    return AddToiletStatePlaceSelected(
      details: details ?? this.details,
    );
  }
}

final class AddToiletStateCreating extends AddToiletState {
  const AddToiletStateCreating({
    required super.details,
  });

  @override
  AddToiletStateCreating copyWith({
    AddToiletDetails? details,
  }) {
    return AddToiletStateCreating(
      details: details ?? this.details,
    );
  }
}

final class AddToiletStateCreated extends AddToiletState {
  const AddToiletStateCreated({
    required super.details,
  });

  @override
  AddToiletStateCreated copyWith({
    AddToiletDetails? details,
  }) {
    return AddToiletStateCreated(
      details: details ?? this.details,
    );
  }

  @override
  List<Object?> get props => [];
}

final class AddToiletStateError extends AddToiletState {
  final String error;

  const AddToiletStateError({
    required super.details,
    required this.error,
  });

  @override
  AddToiletStateError copyWith({
    AddToiletDetails? details,
    String? error,
  }) {
    return AddToiletStateError(
      details: details ?? this.details,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [details, error];
}
