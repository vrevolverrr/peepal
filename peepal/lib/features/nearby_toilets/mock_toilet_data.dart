import 'package:flutter/material.dart';
import 'package:peepal/features/nearby_toilets/widgets/nearby_toilet_card.dart'; // Import the new widget


  final List<Map<String, dynamic>> toilets = [
    {
    'address': '60 Yuan Ching Rd',
    'rating': 4.5,
    'distance': '500m',
    'highVacancy': true,
    'bidetAvailable': true,
    'okuFriendly': true,
  },
  {
    'address': '123 Jurong West St',
    'rating': 4.0,
    'distance': '1.2km',
    'highVacancy': false,
    'bidetAvailable': true,
    'okuFriendly': false,
  },
  {
    'address': '456 Clementi Ave',
    'rating': 3.8,
    'distance': '2.0km',
    'highVacancy': true,
    'bidetAvailable': false,
    'okuFriendly': true,
  },
  {
    'address': '789 Bukit Batok Rd',
    'rating': 4.2,
    'distance': '800m',
    'highVacancy': true,
    'bidetAvailable': true,
    'okuFriendly': false,
  },
  {
    'address': '321 Tampines Ave',
    'rating': 3.9,
    'distance': '1.5km',
    'highVacancy': false,
    'bidetAvailable': false,
    'okuFriendly': true,
  },
  {
    'address': '654 Punggol Walk',
    'rating': 4.7,
    'distance': '600m',
    'highVacancy': true,
    'bidetAvailable': true,
    'okuFriendly': true,
  },
  ];

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
          );
        },
      ),
    );
  }
