import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:peepal/shared/location/model/location.dart';
import 'package:peepal/shared/toilet/model/toilet_collection.dart';
import 'package:peepal/shared/toilet/repository/toilet_repository.dart';

part 'nearby_toilet_state.dart';

class NearbyToiletCubit extends Cubit<NearbyToiletState> {
  final ToiletRepository toiletRepository;

  NearbyToiletCubit({required this.toiletRepository})
      : super(NearbyToiletStateInitial());

  void getNearbyToilets(
      {required PPLocation location, required double radius}) async {
    emit(NearbyToiletStateLoading());

    try {
      final PPToiletCollection toilets = await toiletRepository
          .getToiletsByLocation(location: location, radius: radius);

      emit(NearbyToiletStateLoaded(toilets: toilets));
    } catch (e) {
      emit(NearbyToiletStateError(error: e.toString()));
    }
  }
}
