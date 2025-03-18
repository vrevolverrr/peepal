import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class ToiletMapPage extends StatefulWidget {
  const ToiletMapPage({super.key});

  @override
  State<ToiletMapPage> createState() => _ToiletMapPageState();
}

class _ToiletMapPageState extends State<ToiletMapPage> {
  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();

  late final Position _currentPosition;

  @override
  void initState() {
    _getCurrentLocation();
    super.initState();
  }

  void _getCurrentLocation() async {
    if (await Geolocator.checkPermission() == LocationPermission.denied) {
      Geolocator.requestPermission();
    }

    _currentPosition = await Geolocator.getCurrentPosition();

    debugPrint("Current Position: $_currentPosition");

    final GoogleMapController controller = await _controller.future;

    await controller.animateCamera(CameraUpdate.newLatLng(LatLng(
      _currentPosition.latitude,
      _currentPosition.longitude,
    )));
  }

  @override
  void dispose() {
    _controller.future.then((controller) => controller.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GoogleMap(
          myLocationButtonEnabled: true,
          myLocationEnabled: true,
          mapType: MapType.normal,
          initialCameraPosition: CameraPosition(
            target: LatLng(37.42796133580664, -122.085749655962),
            zoom: 20,
          ),
          onMapCreated: (GoogleMapController controller) async {
            _controller.complete(controller);
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
  }
}
