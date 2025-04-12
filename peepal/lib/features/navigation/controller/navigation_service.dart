import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:peepal/features/toilet_map/model/toilet_location.dart';

class NavigationService {
  final String baseUrl = 'http://localhost:3000/api';
  
  Future<Map<String, dynamic>> getNavigationDirections({
    required ToiletLocation destination,
    required double currentLatitude,
    required double currentLongitude,
  }) async {
    final url = Uri.parse('$baseUrl/toilets/navigate');
    
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'toiletId': destination.id,
          'latitude': currentLatitude,
          'longitude': currentLongitude,
        }),
      );
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to load directions: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getting directions: $e');
    }
  }
}