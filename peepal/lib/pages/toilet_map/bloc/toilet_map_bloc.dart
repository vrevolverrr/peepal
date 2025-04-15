import 'dart:async';

import 'package:apple_maps_flutter/apple_maps_flutter.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maps_toolkit/maps_toolkit.dart' hide LatLng;
import 'package:peepal/api/client.dart';
import 'package:peepal/api/toilets/model/route.dart';
import 'package:peepal/api/toilets/model/toilet.dart';
import 'package:peepal/shared/location/bloc/location_bloc.dart';
import 'package:peepal/pages/toilet_map/widgets/toilet_marker.dart';

part 'toilet_map_state.dart';

class ToiletMapCubit extends Cubit<ToiletMapState> {
  final LocationCubit locationCubit;
  final Completer<BitmapDescriptor> markerIcon = Completer<BitmapDescriptor>();

  ToiletMapCubit({required this.locationCubit}) : super(ToiletMapState()) {
    markerIcon.complete(Image.asset(
      "assets/images/marker.png",
      width: 60.0,
      height: 60.0,
    ).toBitmapDescriptor());
  }

  void updateMarkers(List<PPToilet> toilets) async {
    final BitmapDescriptor icon = await markerIcon.future;

    final Set<Annotation> markers = toilets
        .map((toilet) => Annotation(
            annotationId: AnnotationId(toilet.id),
            position: toilet.location.toAmLatLng(),
            onTap: () => selectToilet(toilet),
            icon: icon))
        .toSet();

    emit(state.copyWith(
        selectedToilet: state.selectedToilet, toiletMarkers: markers));
  }

  void selectToilet(PPToilet toilet) {
    emit(state.copyWith(selectedToilet: toilet, isCalculating: true));

    if (locationCubit.state is LocationStateWithLocation) {
      final location =
          (locationCubit.state as LocationStateWithLocation).location;

      PPClient.toilets
          .navigateToToilet(toilet: toilet, location: location)
          .then((route) {
        if (state.selectedToilet?.id == toilet.id) {
          emit(state.copyWith(
              selectedToilet: toilet,
              activeRoute: route,
              isCalculating: false,
              activePolylines: {
                Polyline(
                    polylineId: PolylineId('route'),
                    color: Colors.blue,
                    width: 5,
                    points: PolygonUtil.decode(route.overviewPolyline)
                        .map((e) => LatLng(e.latitude, e.longitude))
                        .toList())
              }));
        }
      });
    }
  }

  void deselectToilet() {
    emit(state.copyWith(
        selectedToilet: null, activePolylines: {}, activeRoute: null));
  }
}
