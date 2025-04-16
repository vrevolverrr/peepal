import 'dart:async';
import 'package:apple_maps_flutter/apple_maps_flutter.dart';
import 'package:flutter/material.dart';
import 'package:maps_toolkit/maps_toolkit.dart' hide LatLng;
import 'package:maps_toolkit/maps_toolkit.dart' as mtk;
import 'package:peepal/api/toilets/model/latlng.dart';
import 'package:peepal/api/toilets/model/route.dart';
import 'package:peepal/api/toilets/model/toilet.dart';
import 'package:peepal/pages/navigation/widgets/navigation_map.dart';
import 'package:peepal/pages/navigation/widgets/navigation_header.dart';
import 'package:peepal/pages/navigation/widgets/direction_list.dart';
import 'package:peepal/pages/toilet_map/widgets/toilet_marker.dart';
import 'package:peepal/shared/location/bloc/location_bloc.dart';

class NavigationPage extends StatefulWidget {
  final PPToilet destination;
  final PPRoute route;
  final LocationCubit locationCubit;

  const NavigationPage({
    super.key,
    required this.destination,
    required this.route,
    required this.locationCubit,
  });

  @override
  State<NavigationPage> createState() => _NavigationPageState();
}

class _NavigationPageState extends State<NavigationPage> {
  final Completer<AppleMapController> _controller = Completer();

  bool _isLoading = true;

  bool _destinationReached = false;
  int _currentDirectionIndex = 0;

  Set<Polyline> _polylines = {};
  Set<Annotation> _markers = {};
  Set<Circle> _circles = {};

  late final LocationCubit locationCubit;
  StreamSubscription<PPLatLng>? _positionSubscription;

  late PPLatLng _currentLocation;

  @override
  void initState() {
    locationCubit = widget.locationCubit;
    _currentLocation = locationCubit.state.location;

    _circles = {
      Circle(
        circleId: CircleId('current_location'),
        center: _currentLocation.toAmLatLng(),
        radius: 12.0,
        fillColor: Colors.blue.withAlpha(178),
        strokeColor: Colors.white,
        strokeWidth: 2,
        zIndex: 2,
      )
    };

    _fetchDirections();

    super.initState();
  }

  @override
  void dispose() {
    _positionSubscription?.cancel();
    super.dispose();
  }

  Future<void> _fetchDirections() async {
    final PPRoute route = widget.route;

    final List<LatLng> polylinePoints = [];

    for (final direction in route.directions) {
      final List<mtk.LatLng> directionPoints =
          PolygonUtil.decode(direction.polyline);

      // Map MTK points to Apple Map points
      polylinePoints.addAll(directionPoints
          .map((point) => LatLng(point.latitude, point.longitude)));
    }

    final polyline = Polyline(
      polylineId: PolylineId('overview_route'),
      color: Colors.blue,
      width: 5,
      points: polylinePoints,
    );

    final endMarkerIcon = await Image.asset(
      "assets/images/marker.png",
      width: 60.0,
      height: 60.0,
    ).toBitmapDescriptor();

    final endMarker = Annotation(
      annotationId: AnnotationId('destination'),
      position: widget.destination.location.toAmLatLng(),
      icon: endMarkerIcon,
      infoWindow: InfoWindow(
          title: widget.destination.name, snippet: widget.destination.address),
    );

    setState(() {
      _polylines = {polyline};
      _markers = {endMarker};
      _isLoading = false;
    });

    // Slight delay to make sure map is ready
    await Future.delayed(const Duration(milliseconds: 300));

    // Move camera to show the full route
    final AppleMapController controller = await _controller.future;

    // Calculate bounds that include both start and destination
    final LatLngBounds bounds = LatLngBounds(
      southwest: LatLng(
        min(widget.destination.location.latitude, _currentLocation.latitude),
        min(widget.destination.location.longitude, _currentLocation.longitude),
      ),
      northeast: LatLng(
        max(widget.destination.location.latitude, _currentLocation.latitude),
        max(widget.destination.location.longitude, _currentLocation.longitude),
      ),
    );

    // Animate camera to bounds
    controller.animateCamera(
      CameraUpdate.newLatLngBounds(bounds, 50),
    );

    _positionSubscription =
        locationCubit.getLocationUpdates().listen(_handlePositionUpdate);
  }

  void _handlePositionUpdate(PPLatLng position) {
    setState(() {
      _currentLocation = position;
      _circles = {
        Circle(
          circleId: CircleId('current_location'),
          center: LatLng(position.latitude, position.longitude),
          radius: 8,
          fillColor: Colors.blue.withValues(alpha: 0.7),
          strokeColor: Colors.white,
          strokeWidth: 2,
          zIndex: 2,
        )
      };
    });

    _updateCurrentDirectionStep(position);
    _checkIfDestinationReached(position);

    // Update camera to follow user
    _controller.future.then((controller) {
      controller.animateCamera(
        CameraUpdate.newLatLng(
          LatLng(position.latitude, position.longitude),
        ),
      );
    });
  }

  void _updateCurrentDirectionStep(PPLatLng position) {
    if (_destinationReached) return;

    final directions = widget.route.directions;
    int closestStepIndex = 0;
    double closestDistance = double.infinity;

    for (int i = 0; i < directions.length; i++) {
      final step = directions[i];
      final stepPoints = PolygonUtil.decode(step.polyline);

      for (final point in stepPoints) {
        final distance = SphericalUtil.computeDistanceBetween(
            mtk.LatLng(position.latitude, position.longitude),
            mtk.LatLng(point.latitude, point.longitude));

        if (distance < closestDistance) {
          closestDistance = distance.toDouble();
          closestStepIndex = i;
        }
      }
    }

    if (closestStepIndex != _currentDirectionIndex) {
      setState(() {
        _currentDirectionIndex = closestStepIndex;
      });
    }
  }

  void _checkIfDestinationReached(PPLatLng position) {
    if (_destinationReached) return;

    final endLocation = widget.route.endLocation;
    final distanceToEnd = SphericalUtil.computeDistanceBetween(
        mtk.LatLng(position.latitude, position.longitude),
        mtk.LatLng(endLocation.latitude, endLocation.longitude));

    if (distanceToEnd < 0.02) {
      setState(() {
        _destinationReached = true;
        _currentDirectionIndex = widget.route.directions.length - 1;
      });

      _showDestinationReachedMessage();
    }
  }

  void _showDestinationReachedMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.green,
        content: Row(
          children: const [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 12),
            Text(
              'Destination Reached!',
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        duration: const Duration(seconds: 5),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 52, 64, 74),
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Navigation',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                NavigationMap(
                  markers: _markers,
                  polylines: _polylines,
                  circles: _circles,
                  onMapCreated: (AppleMapController controller) {
                    _controller.complete(controller);
                  },
                  currentPosition: _currentLocation,
                  onCenterLocation: () {
                    _controller.future.then((controller) {
                      controller.animateCamera(
                        CameraUpdate.newCameraPosition(
                          CameraPosition(
                            target: _currentLocation.toAmLatLng(),
                            zoom: 17.0,
                          ),
                        ),
                      );
                    });
                  },
                ),
                NavigationHeader(
                  destinationName: widget.destination.name,
                  destinationAddress: widget.destination.address,
                  duration: widget.route.duration,
                  distance: widget.route.distance,
                ),
                DirectionsList(
                  directions: widget.route.directions,
                  currentDirectionIndex: _currentDirectionIndex,
                  destinationReached: _destinationReached,
                ),
              ],
            ),
    );
  }
}

// Helper functions if not already defined
double min(double a, double b) => a < b ? a : b;
double max(double a, double b) => a > b ? a : b;
