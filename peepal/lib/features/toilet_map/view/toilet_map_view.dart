import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:peepal/shared/location/model/location.dart';
import 'package:peepal/shared/location/repository/location_repository.dart';

class ToiletMapPage extends StatefulWidget {
  final LocationRepository locationRepository;

  const ToiletMapPage({super.key, required this.locationRepository});

  @override
  State<ToiletMapPage> createState() => _ToiletMapPageState();
}

class _ToiletMapPageState extends State<ToiletMapPage> {
  late final LocationRepository locationRepository = widget.locationRepository;

  late Completer<GoogleMapController> _controller;

  Future<PPLocation> _getCurrentLocation() async {
    final bool hasPermission = await locationRepository.checkPermission();

    if (hasPermission) {
      return await locationRepository.getCurrentLocation();
    }

    final bool granted = await locationRepository.requestPermission();

    if (granted) {
      return await locationRepository.getCurrentLocation();
    }

    throw Exception("Location permission is not granted");
  }

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
    return FutureBuilder(
        future: _getCurrentLocation(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(snapshot.error.toString()),
            );
          }

          return _buildToiletMap(context);
        });
  }

  Widget _buildToiletMap(BuildContext context) {
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
