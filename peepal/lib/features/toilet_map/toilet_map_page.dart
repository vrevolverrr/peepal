import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:peepal/shared/location/bloc/location_bloc.dart';

class ToiletMapPage extends StatefulWidget {
  const ToiletMapPage({super.key});

  @override
  State<ToiletMapPage> createState() => _ToiletMapPageState();
}

class _ToiletMapPageState extends State<ToiletMapPage> {
  final Completer<GoogleMapController> _controller = Completer();

  @override
  void dispose() {
    _controller.future.then((controller) => controller.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    late final LatLng initialLocation;

    if (context.read<LocationCubit>().state is! LocationStateWithLocation) {
      initialLocation = const LatLng(1.350564, 103.681900);
    } else {
      final location =
          (context.read<LocationCubit>().state as LocationStateWithLocation)
              .location;
      initialLocation = LatLng(location.latitude, location.longitude);
    }

    return Stack(
      children: [
        GoogleMap(
            myLocationButtonEnabled: true,
            myLocationEnabled: true,
            mapType: MapType.normal,
            initialCameraPosition: CameraPosition(
              target: initialLocation,
              zoom: 20.0,
            ),
            onMapCreated: (GoogleMapController controller) {
              if (!_controller.isCompleted) {
                _controller.complete(controller);
              }
            }),
        SafeArea(
          child: Align(
            alignment: Alignment.topCenter,
            child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.0),
                child: SearchBar(
                  backgroundColor: WidgetStatePropertyAll(Colors.white),
                  padding: WidgetStatePropertyAll(
                      EdgeInsets.symmetric(horizontal: 20.0)),
                  leading: SizedBox(width: 12.0, child: Icon(Icons.search)),
                  hintText: "Search for toilets",
                  hintStyle: WidgetStatePropertyAll(TextStyle(
                      fontSize: 16.0, color: const Color(0xFF5C5C5C))),
                )),
          ),
        ),
      ],
    );
  }
}
