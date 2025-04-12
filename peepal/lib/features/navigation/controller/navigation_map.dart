import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class NavigationMap extends StatelessWidget {
  final Set<Marker> markers;
  final Set<Polyline> polylines;
  final Set<Circle> circles;
  final double initialLatitude;
  final double initialLongitude;
  final Function(GoogleMapController) onMapCreated;
  final Position? currentPosition;
  final VoidCallback? onCenterLocation; // New callback for centering
  
  const NavigationMap({
    Key? key,
    required this.markers,
    required this.polylines,
    required this.circles,
    required this.initialLatitude,
    required this.initialLongitude,
    required this.onMapCreated,
    this.currentPosition,
    this.onCenterLocation,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SizedBox(
          height: 300,
          width: double.infinity,
          child: GoogleMap(
            initialCameraPosition: CameraPosition(
              target: LatLng(initialLatitude, initialLongitude),
              zoom: 17,
            ),
            markers: markers,
            polylines: polylines,
            circles: circles,
            // Using our custom circle instead of built-in location
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            onMapCreated: onMapCreated,
          ),
        ),
        
        // Custom location button
        Positioned(
          right: 16,
          bottom: 16,
          child: FloatingActionButton(
            mini: true,
            backgroundColor: Colors.white,
            foregroundColor: Colors.grey[700],
            child: const Icon(Icons.my_location),
            onPressed: () {
              if (onCenterLocation != null) {
                onCenterLocation!();
              }
            },
          ),
        ),
      ],
    );
  }
}