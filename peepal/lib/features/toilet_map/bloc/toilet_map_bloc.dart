import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:maps_toolkit/maps_toolkit.dart' hide LatLng;
import 'package:peepal/api/client.dart';
import 'package:peepal/api/toilets/model/route.dart';
import 'package:peepal/api/toilets/model/toilet.dart';
import 'package:peepal/bloc/location/bloc/location_bloc.dart';

part 'toilet_map_state.dart';

class ToiletMapCubit extends Cubit<ToiletMapState> {
  final LocationCubit locationCubit;

  ToiletMapCubit({required this.locationCubit}) : super(ToiletMapState());

  void updateMarkers(List<PPToilet> toilets) {
    final Set<Marker> markers = toilets
        .map((toilet) => Marker(
              markerId: MarkerId(toilet.id),
              position: toilet.location.toGmLatLng(),
              icon: BitmapDescriptor.defaultMarkerWithHue(
                  BitmapDescriptor.hueRed),
              onTap: () => selectToilet(toilet),
            ))
        .toSet();

    emit(state.copyWith(
        selectedToilet: state.selectedToilet, toiletMarkers: markers));
  }

  void selectToilet(PPToilet toilet) async {
    emit(state.copyWith(selectedToilet: toilet));

    if (locationCubit.state is LocationStateWithLocation) {
      final location =
          (locationCubit.state as LocationStateWithLocation).location;
      final PPRoute route = await PPClient.toilets
          .navigateToToilet(toilet: toilet, location: location);

      emit(state.copyWith(
          selectedToilet: toilet,
          activeRoute: route,
          activePolylines: {
            Polyline(
                polylineId: const PolylineId('route'),
                color: Colors.blue,
                width: 5,
                points: PolygonUtil.decode(route.overviewPolyline)
                    .map((e) => LatLng(e.latitude, e.longitude))
                    .toList())
          }));
    }
  }

  void deselectToilet() {
    emit(state.copyWith(
        selectedToilet: null, activePolylines: {}, activeRoute: null));
  }
}
