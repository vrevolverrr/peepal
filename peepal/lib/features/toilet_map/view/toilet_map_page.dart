import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:peepal/bloc/location/bloc/location_bloc.dart';
import 'package:peepal/features/toilet_map/view/widgets/search_bar.dart';
import 'package:peepal/features/toilet_map/model/toilet_data_service.dart';
import 'package:peepal/features/toilet_map/model/toilet_location.dart';
import 'package:peepal/features/toilet_map/view/widgets/toilet_location_card.dart';
import 'package:peepal/features/navigation/view/navigation_page.dart';

class ToiletMapPage extends StatefulWidget {
  const ToiletMapPage({super.key});

  @override
  State<ToiletMapPage> createState() => _ToiletMapPageState();
}

class _ToiletMapPageState extends State<ToiletMapPage> {
  final Completer<GoogleMapController> _controller = Completer();
  final ToiletDataService _dataService = ToiletDataService();
  Set<Marker> _markers = {};
  bool _mapsInitialized = false;
  ToiletLocation? _selectedLocation;

  @override
  void initState() {
    super.initState();
    // We'll load markers after the map is created for better compatibility
  }

  void _loadMarkers() {
    final locations = _dataService.getAllLocations();
    print('Loading ${locations.length} toilet locations as markers');

    final newMarkers = locations
        .map((location) => Marker(
              markerId: MarkerId(location.id),
              position: LatLng(location.latitude, location.longitude),
              // Make markers more visible with a different color
              icon: BitmapDescriptor.defaultMarkerWithHue(
                  BitmapDescriptor.hueRed),
              infoWindow: InfoWindow(
                title: location.name,
                snippet: location.address +
                    (location.rating != null ? ' (${location.rating}★)' : ''),
              ),
              onTap: () {
                _selectLocation(location);
              },
            ))
        .toSet();

    print('Created ${newMarkers.length} markers');

    setState(() {
      _markers = newMarkers;
    });
  }

  void _selectLocation(ToiletLocation location) {
    setState(() {
      _selectedLocation = location;
    });

    // Animate camera to the selected location
    _controller.future.then((controller) {
      controller.animateCamera(
        CameraUpdate.newLatLngZoom(
          LatLng(location.latitude, location.longitude),
          15.0,
        ),
      );
    });
  }

  void _handleSearch(String query) {
    print('Searching for: $query');
  }

  @override
  void dispose() {
    _controller.future.then((controller) => controller.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Set initial location to Singapore center
    final LatLng initialLocation = const LatLng(1.3349539, 103.7286225);

    return Stack(
      children: [
        GoogleMap(
            myLocationButtonEnabled: true,
            myLocationEnabled: true,
            mapType: MapType.normal,
            initialCameraPosition: CameraPosition(
              target: initialLocation,
              zoom: 11.0, // Slightly zoomed out to see more markers
            ),
            markers: _markers,
            onMapCreated: (GoogleMapController controller) {
              if (!_controller.isCompleted) {
                _controller.complete(controller);

                // Load markers after map is created
                if (!_mapsInitialized) {
                  _mapsInitialized = true;
                  // Add a short delay to ensure map is fully loaded
                  Future.delayed(const Duration(milliseconds: 500), () {
                    _loadMarkers();
                  });
                }
              }
            }),
        ToiletSearchBar(
          onSearch: _handleSearch,
          onLocationSelected: _selectLocation,
        ),

        // Location details card at the bottom
        if (_selectedLocation != null)
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: ToiletLocationCard(
              location: _selectedLocation!,
              onClose: () {
                setState(() {
                  _selectedLocation = null;
                });
              },
              onDirections: () {
                // Navigate to the NavigationPage with the selected location
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => NavigationPage(
                      destination: _selectedLocation!,
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}
