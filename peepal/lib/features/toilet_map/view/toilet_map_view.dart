import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:peepal/features/toilet_map/bloc/map_bloc.dart';
import 'package:peepal/shared/location/repository/location_repository.dart';

class ToiletMapPage extends StatefulWidget {
  final LocationRepository locationRepository;

  const ToiletMapPage({super.key, required this.locationRepository});

  @override
  State<ToiletMapPage> createState() => _ToiletMapPageState();
}

class _ToiletMapPageState extends State<ToiletMapPage> {
  late Completer<GoogleMapController> _controller;

  @override
  void initState() {
    _controller = Completer();
    super.initState();
  }

  @override
  void dispose() {
    _controller.future.then((controller) => controller.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ToiletMapBloc, ToiletMapState>(
        builder: (context, state) {
      /// Waiting for location permission
      if (state is ToiletMapStateInitial) {
        return Center(
          child: CircularProgressIndicator(),
        );
      }

      /// If error
      if (state is ToiletMapStateError) {
        return Center(
          child: Text(state.message),
        );
      }

      return Stack(
        children: [
          GoogleMap(
            myLocationButtonEnabled: true,
            myLocationEnabled: true,
            mapType: MapType.normal,
            initialCameraPosition: CameraPosition(
              target: LatLng(state.currentLocation!.latitude,
                  state.currentLocation!.longitude),
              zoom: 20,
            ),
            onMapCreated: (GoogleMapController controller) async {
              if (!_controller.isCompleted) {
                _controller.complete(controller);
              }
            },
          ),
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
    });
  }
}
