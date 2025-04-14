import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:apple_maps_flutter/apple_maps_flutter.dart';

class NavigationMap extends StatelessWidget {
  final Set<Annotation> markers;
  final Set<Polyline> polylines;
  final Set<Circle> circles;
  final double initialLatitude;
  final double initialLongitude;
  final Function(AppleMapController) onMapCreated;
  final Position? currentPosition;
  final VoidCallback? onCenterLocation; // New callback for centering

  const NavigationMap({
    super.key,
    required this.markers,
    required this.polylines,
    required this.circles,
    required this.initialLatitude,
    required this.initialLongitude,
    required this.onMapCreated,
    this.currentPosition,
    this.onCenterLocation,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SizedBox(
          height: 300,
          width: double.infinity,
          child: AppleMap(
            initialCameraPosition: CameraPosition(
              target: LatLng(initialLatitude, initialLongitude),
              zoom: 17,
            ),
            annotations: markers,
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
