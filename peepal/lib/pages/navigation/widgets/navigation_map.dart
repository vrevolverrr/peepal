import 'package:flutter/material.dart';
import 'package:apple_maps_flutter/apple_maps_flutter.dart';
import 'package:peepal/api/toilets/model/latlng.dart';

class NavigationMap extends StatelessWidget {
  final Set<Annotation> markers;
  final Set<Polyline> polylines;
  final Set<Circle> circles;
  final Function(AppleMapController) onMapCreated;
  final PPLatLng currentPosition;
  final VoidCallback? onCenterLocation; // New callback for centering

  const NavigationMap({
    super.key,
    required this.markers,
    required this.polylines,
    required this.circles,
    required this.onMapCreated,
    required this.currentPosition,
    this.onCenterLocation,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SizedBox(
          height: 300.0,
          width: double.infinity,
          child: AppleMap(
            initialCameraPosition: CameraPosition(
              target: currentPosition.toAmLatLng(),
              zoom: 17.0,
            ),
            annotations: markers,
            polylines: polylines,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            onMapCreated: onMapCreated,
          ),
        ),
        Positioned(
          right: 16,
          bottom: 16,
          child: FloatingActionButton(
            mini: true,
            backgroundColor: Colors.white,
            foregroundColor: Colors.grey[700],
            onPressed: onCenterLocation,
            child: const Icon(Icons.my_location),
          ),
        ),
      ],
    );
  }
}
