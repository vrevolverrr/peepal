import 'package:flutter/material.dart';
import 'package:peepal/features/nearby_toilets/view/widgets/nearby_toilet_card.dart';
import 'package:peepal/features/toilet_map/model/toilet_location.dart';
import 'package:peepal/features/navigation/navigation_page.dart';

final List<Map<String, dynamic>> toilets = [
  {
    'address': '60 Yuan Ching Rd',
    'rating': 4.5,
    'distance': '500m',
    'highVacancy': true,
    'bidetAvailable': true,
    'okuFriendly': true,
    'hasShower': true,
    'hasSanitizer': true,
    'latitude': 1.3414, 
    'longitude': 103.7208,
  },
  {
    'address': '123 Jurong West St',
    'rating': 4.0,
    'distance': '1.2km',
    'highVacancy': false,
    'bidetAvailable': true,
    'okuFriendly': false,
    'hasShower': false,
    'hasSanitizer': true,
    'latitude': 1.3484,
    'longitude': 103.7097,
  },
  {
    'address': '456 Clementi Ave',
    'rating': 3.8,
    'distance': '2.0km',
    'highVacancy': true,
    'bidetAvailable': false,
    'okuFriendly': true,
    'hasShower': true,
    'hasSanitizer': false,
    'latitude': 1.3162,
    'longitude': 103.7649,
  },
  {
    'address': '789 Bukit Batok Rd',
    'rating': 4.2,
    'distance': '800m',
    'highVacancy': true,
    'bidetAvailable': true,
    'okuFriendly': false,
    'hasShower': false,
    'hasSanitizer': true,
    'latitude': 1.3590,
    'longitude': 103.7637,
  },
  {
    'address': '321 Tampines Ave',
    'rating': 3.9,
    'distance': '1.5km',
    'highVacancy': false,
    'bidetAvailable': false,
    'okuFriendly': true,
    'hasShower': false,
    'hasSanitizer': false,
    'latitude': 1.3546,
    'longitude': 103.9436,
  },
  {
    'address': '654 Punggol Walk',
    'rating': 4.7,
    'distance': '600m',
    'highVacancy': true,
    'bidetAvailable': true,
    'okuFriendly': true,
    'hasShower': true,
    'hasSanitizer': true,
    'latitude': 1.4035,
    'longitude': 103.9082,
  },
];

// Helper method to convert mock data to ToiletLocation
ToiletLocation createToiletLocation(Map<String, dynamic> toilet) {
  return ToiletLocation(
    id: toilet['address'].hashCode.toString(),
    name: toilet['address'],
    address: toilet['address'],
    latitude: toilet['latitude'],
    longitude: toilet['longitude'],
    rating: toilet['rating'],
    hasAccessibleFacilities: toilet['okuFriendly'],
    hasBidet: toilet['bidetAvailable'],
  );
}

@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(title: Text('Nearby Toilets')),
    body: ListView.builder(
      itemCount: toilets.length,
      itemBuilder: (context, index) {
        final toilet = toilets[index];
        return NearbyToiletCard(
          address: toilet['address'],
          rating: toilet['rating'],
          distance: toilet['distance'],
          highVacancy: toilet['highVacancy'],
          bidetAvailable: toilet['bidetAvailable'],
          okuFriendly: toilet['okuFriendly'],
          latitude: toilet['latitude'],
          longitude: toilet['longitude'],
          hasShower: toilet['hasShower'] ?? false,
          hasSanitizer: toilet['hasSanitizer'] ?? false,
        );
      },
    ),
  );
}
