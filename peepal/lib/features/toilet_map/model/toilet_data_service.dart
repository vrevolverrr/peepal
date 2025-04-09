import 'package:peepal/features/toilet_map/model/toilet_location.dart';

/// Provides toilet location data for the application
class ToiletDataService {
  // Singleton implementation
  static final ToiletDataService _instance = ToiletDataService._internal();
  factory ToiletDataService() => _instance;
  ToiletDataService._internal();

  /// Returns a list of all toilet locations
  List<ToiletLocation> getAllLocations() {
    return _toiletLocations;
  }

  /// Searches for toilet locations by name or address
  List<ToiletLocation> searchLocations(String query) {
    if (query.isEmpty) return [];
    
    final lowerQuery = query.toLowerCase();
    return _toiletLocations.where((location) {
      return location.name.toLowerCase().contains(lowerQuery) || 
             location.address.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  // Sample toilet location data
  final List<ToiletLocation> _toiletLocations = [
    ToiletLocation(
      id: 'central1',
      name: 'Central Mall Toilet',
      address: '1 Raffles Place, Singapore',
      latitude: 1.3644, 
      longitude: 103.8077,
      rating: 4.2,
      hasAccessibleFacilities: true,
      hasBidet: true,
    ),
    ToiletLocation(
      id: 'central_south1',
      name: 'Marina Bay Sands Toilet',
      address: '10 Bayfront Avenue, Singapore',
      latitude: 1.3050, 
      longitude: 103.8200,
      rating: 4.5,
      hasAccessibleFacilities: true,
      hasBidet: true,
    ),
    ToiletLocation(
      id: 'east1',
      name: 'Tampines Mall Toilet',
      address: '4 Tampines Central 5, Singapore',
      latitude: 1.3720, 
      longitude: 103.9530,
      rating: 4.0,
      hasAccessibleFacilities: true,
      hasBidet: false,
    ),
    ToiletLocation(
      id: 'east2',
      name: 'Changi Airport T3 Toilet',
      address: '65 Airport Boulevard, Singapore',
      latitude: 1.3600, 
      longitude: 103.9800,
      rating: 4.8,
      hasAccessibleFacilities: true,
      hasBidet: true,
    ),
    ToiletLocation(
      id: 'west1',
      name: 'Jurong Point Toilet',
      address: '1 Jurong West Central 2, Singapore',
      latitude: 1.3280, 
      longitude: 103.7650,
      rating: 3.9,
      hasAccessibleFacilities: true,
      hasBidet: false,
    ),
  ];
}