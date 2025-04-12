import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:peepal/features/navigation/controller/map_utils.dart';
import 'package:flutter/material.dart';

class NavigationSimulator {
  final Map<String, dynamic> navigationData;
  final void Function(Position) onPositionUpdate;
  final VoidCallback onSimulationComplete;
  
  Timer? _simulationTimer;
  int _simulationStep = 0;
  List<LatLng> _allPoints = [];
  bool _isActive = false;
  
  NavigationSimulator({
    required this.navigationData,
    required this.onPositionUpdate,
    required this.onSimulationComplete,
  }) {
    _prepareRoutePoints();
  }
  
  bool get isActive => _isActive;
  
  void _prepareRoutePoints() {
    final List<dynamic> directions = navigationData['directions'];
    _allPoints = [];
    
    for (final step in directions) {
      final stepPolyline = step['polyline'] as String;
      _allPoints.addAll(MapUtils.decodePolyline(stepPolyline));
    }
  }
  
  void startSimulation() {
    if (_allPoints.isEmpty) return;
    
    _isActive = true;
    _simulationStep = 0;
    
    _simulationTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_simulationStep >= _allPoints.length - 1) {
        // Reached the end
        stopSimulation();
        
        final finalPoint = _allPoints.last;
        onPositionUpdate(_createPosition(
          finalPoint.latitude, 
          finalPoint.longitude
        ));
        
        onSimulationComplete();
        return;
      }
      
      final currentPoint = _allPoints[_simulationStep];
      onPositionUpdate(_createPosition(
        currentPoint.latitude, 
        currentPoint.longitude
      ));
      
      _simulationStep++;
    });
  }
  
  void stopSimulation() {
    _simulationTimer?.cancel();
    _isActive = false;
  }
  
  Position _createPosition(double latitude, double longitude) {
    return Position(
      latitude: latitude,
      longitude: longitude,
      timestamp: DateTime.now(),
      accuracy: 0,
      altitude: 0,
      heading: 0,
      speed: 10,
      speedAccuracy: 0,
      altitudeAccuracy: 0,
      headingAccuracy: 0,
    );
  }
  
  void dispose() {
    stopSimulation();
  }
}