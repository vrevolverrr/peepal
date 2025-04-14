import 'dart:async';
import 'package:apple_maps_flutter/apple_maps_flutter.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:maps_toolkit/maps_toolkit.dart' hide LatLng;
import 'package:maps_toolkit/maps_toolkit.dart' as mtk;
import 'package:peepal/api/toilets/model/toilet.dart';
import 'package:peepal/features/navigation/controller/mock_navigation_service.dart';
import 'package:peepal/features/navigation/controller/location_service.dart';
import 'package:peepal/features/navigation/controller/navigation_simulator.dart';
import 'package:peepal/features/navigation/controller/navigation_map.dart';
import 'package:peepal/features/navigation/widgets/navigation_header.dart';
import 'package:peepal/features/navigation/widgets/direction_list.dart';

class NavigationPage extends StatefulWidget {
  final PPToilet destination;

  const NavigationPage({
    super.key,
    required this.destination,
  });

  @override
  State<NavigationPage> createState() => _NavigationPageState();
}

class _NavigationPageState extends State<NavigationPage> {
  final Completer<AppleMapController> _controller = Completer();
  final MockNavigationService _navigationService = MockNavigationService();

  // Services
  LocationService? _locationService;
  NavigationSimulator? _simulator;

  // State
  Map<String, dynamic>? _navigationData;
  bool _isLoading = true;
  String? _errorMessage;
  bool _simulationActive = false;
  bool _debugMode = true; // For development

  // Navigation state
  Position? _currentPosition;
  bool _destinationReached = false;
  int _currentDirectionIndex = 0;

  // Map elements
  Set<Polyline> _polylines = {};
  Set<Annotation> _markers = {};
  Set<Circle> _circles = {};

  // Default current location
  final double _currentLatitude = 1.3349539;
  final double _currentLongitude = 103.7286225;

  @override
  void initState() {
    super.initState();

    // Set initial position to match mock navigation route starting point
    _currentPosition = Position(
      latitude: _currentLatitude,
      longitude: _currentLongitude,
      timestamp: DateTime.now(),
      accuracy: 0,
      altitude: 0,
      heading: 0,
      speed: 0,
      speedAccuracy: 0,
      altitudeAccuracy: 0,
      headingAccuracy: 0,
    );

    // Initialize circle for current location
    _circles = {
      Circle(
        circleId: CircleId('current_location'),
        center: LatLng(_currentLatitude, _currentLongitude),
        radius: 8,
        fillColor: Colors.blue.withAlpha(178),
        strokeColor: Colors.white,
        strokeWidth: 2,
        zIndex: 2,
      )
    };

    _fetchDirections();
  }

  @override
  void dispose() {
    _locationService?.dispose();
    _simulator?.dispose();
    super.dispose();
  }

  Future<void> _fetchDirections() async {
    try {
      final data = await _navigationService.getNavigationDirections(
        destination: widget.destination,
        currentLatitude: _currentLatitude,
        currentLongitude: _currentLongitude,
      );

      // Create polyline from overview_polyline
      final List<LatLng> polylinePoints =
          PolygonUtil.decode(data['overview_polyline'])
              .map((point) => LatLng(point.latitude, point.longitude))
              .toList();

      final polyline = Polyline(
        polylineId: PolylineId('overview_route'),
        color: Colors.blue,
        width: 5,
        points: polylinePoints,
      );

      // Create markers for start and end points
      final startMarker = Annotation(
        annotationId: AnnotationId('start'),
        position: LatLng(
            data['start_location']['lat'], data['start_location']['lng']),
        infoWindow: InfoWindow(title: 'Start', snippet: data['start_address']),
      );

      final endMarker = Annotation(
        annotationId: AnnotationId('destination'),
        position:
            LatLng(data['end_location']['lat'], data['end_location']['lng']),
        icon: await BitmapDescriptor.fromAssetImage(
            ImageConfiguration(size: Size(12, 12)), "assets/images/marker.png"),
        infoWindow: InfoWindow(
            title: widget.destination.name, snippet: data['end_address']),
      );

      // Initialize services
      _locationService = LocationService(
        onPositionUpdate: _handlePositionUpdate,
        onError: (message) {
          setState(() {
            _errorMessage = message;
          });
        },
      );

      _simulator = NavigationSimulator(
        navigationData: data,
        onPositionUpdate: _handlePositionUpdate,
        onSimulationComplete: () {
          setState(() {
            _simulationActive = false;
          });
        },
      );

      setState(() {
        _navigationData = data;
        _polylines = {polyline};
        _markers = {startMarker, endMarker};
        _isLoading = false;
      });

      // IMPORTANT: Add a slight delay to make sure map is ready
      await Future.delayed(const Duration(milliseconds: 300));

      // Move camera to show the full route
      final AppleMapController controller = await _controller.future;

      // Calculate bounds that include both start and destination
      final LatLngBounds bounds = LatLngBounds(
        southwest: LatLng(
          min(data['start_location']['lat'], data['end_location']['lat']),
          min(data['start_location']['lng'], data['end_location']['lng']),
        ),
        northeast: LatLng(
          max(data['start_location']['lat'], data['end_location']['lat']),
          max(data['start_location']['lng'], data['end_location']['lng']),
        ),
      );

      // Animate camera with padding
      controller.animateCamera(
        CameraUpdate.newLatLngBounds(
            bounds, 100), // Increased padding for better view
      );

      // Start location updates AFTER showing the full route
      _locationService?.startLocationUpdates();
    } catch (e) {
      setState(() {
        _errorMessage = 'Error getting directions: $e';
        _isLoading = false;
      });
    }
  }

  void _handlePositionUpdate(Position position) {
    setState(() {
      _currentPosition = position;

      // Update circle for current location
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

  void _updateCurrentDirectionStep(Position position) {
    if (_navigationData == null || _destinationReached) return;

    final directions = _navigationData!['directions'] as List<dynamic>;
    int closestStepIndex = 0;
    double closestDistance = double.infinity;

    for (int i = 0; i < directions.length; i++) {
      final step = directions[i];
      final stepPoints = PolygonUtil.decode(step['polyline']);

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

  void _checkIfDestinationReached(Position position) {
    if (_navigationData == null || _destinationReached) return;

    final endLocation = _navigationData!['end_location'];
    final distanceToEnd = SphericalUtil.computeDistanceBetween(
        mtk.LatLng(position.latitude, position.longitude),
        mtk.LatLng(endLocation['lat'], endLocation['lng']));

    if (distanceToEnd < 0.02) {
      // Within 20 meters
      setState(() {
        _destinationReached = true;
        _currentDirectionIndex =
            (_navigationData!['directions'] as List).length - 1;
      });

      _showDestinationReachedMessage();

      if (_simulationActive) {
        _simulator?.stopSimulation();
        setState(() {
          _simulationActive = false;
        });
      }
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

  void _toggleSimulation() {
    if (_simulator == null) return;

    if (_simulator!.isActive) {
      _simulator!.stopSimulation();
      setState(() {
        _simulationActive = false;
      });
    } else {
      setState(() {
        _simulationActive = true;
        _destinationReached = false;
      });
      _simulator!.startSimulation();
    }
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
        actions: _debugMode
            ? [
                IconButton(
                  icon: Icon(_simulationActive ? Icons.stop : Icons.play_arrow),
                  tooltip: _simulationActive
                      ? 'Stop Simulation'
                      : 'Start Simulation',
                  onPressed: _toggleSimulation,
                ),
              ]
            : null,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(child: Text('Error: $_errorMessage'))
              : _buildContent(),
    );
  }

  Widget _buildContent() {
    return Column(
      children: [
        // Map
        NavigationMap(
          markers: _markers,
          polylines: _polylines,
          circles: _circles,
          initialLatitude: _currentLatitude,
          initialLongitude: _currentLongitude,
          onMapCreated: (AppleMapController controller) {
            _controller.complete(controller);
          },
          currentPosition: _currentPosition,
          onCenterLocation: () {
            if (_currentPosition != null) {
              _controller.future.then((controller) {
                controller.animateCamera(
                  CameraUpdate.newCameraPosition(
                    CameraPosition(
                      target: LatLng(_currentPosition!.latitude,
                          _currentPosition!.longitude),
                      zoom:
                          17.0, // Higher zoom level when centering on location
                    ),
                  ),
                );
              });
            }
          },
        ),

        // Header with destination info
        NavigationHeader(
          destinationName: widget.destination.name,
          destinationAddress: _navigationData!['end_address'],
          duration: _navigationData!['duration'],
          distance: _navigationData!['distance'],
        ),

        // Directions list
        DirectionsList(
          directions: _navigationData!['directions'],
          currentDirectionIndex: _currentDirectionIndex,
          destinationReached: _destinationReached,
        ),
      ],
    );
  }
}

// Helper functions if not already defined
double min(double a, double b) => a < b ? a : b;
double max(double a, double b) => a > b ? a : b;
