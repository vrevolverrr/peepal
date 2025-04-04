import 'package:flutter/material.dart';

class NearbyToiletCard extends StatelessWidget {
  final String address;
  final double rating;
  final String distance;
  final bool highVacancy;
  final bool bidetAvailable;
  final bool okuFriendly;

  const NearbyToiletCard({
    Key? key,
    required this.address,
    required this.rating,
    required this.distance,
    required this.highVacancy,
    required this.bidetAvailable,
    required this.okuFriendly,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5.0),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              child: Image.asset('assets/images/toilet.jpeg'), // Replace with your image
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(address, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      Row(
                        children: [
                          Icon(Icons.star, color: const Color.fromARGB(255, 244, 223, 34)),
                          Text(rating.toString(), style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Wrap(
                    spacing: 16.0,
                    runSpacing: 8.0,
                    children: [
                      if (highVacancy)
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.circle, color: Colors.green, size: 12),
                            SizedBox(width: 4),
                            Text('High Vacancy', style: TextStyle(fontSize: 16)),
                          ],
                        ),
                      if (bidetAvailable)
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.check, color: Colors.black, size: 12),
                            SizedBox(width: 4),
                            Text('Bidet available', style: TextStyle(fontSize: 16)),
                          ],
                        ),
                      if (okuFriendly)
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.accessible, color: Colors.black, size: 12),
                            SizedBox(width: 4),
                            Text('OKU friendly', style: TextStyle(fontSize: 16)),
                          ],
                        ),
                    ],
                  ),
                  SizedBox(height: 18),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(distance, style: TextStyle(fontSize: 20)),
                      ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color.fromARGB(255, 91, 100, 134), // Background color
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Text(
                          'Navigate',
                          style: TextStyle(
                            fontSize: 16,
                            fontFamily: "MazzardH",
                            fontWeight: FontWeight.bold,
                            color: Color.fromARGB(255, 225, 222, 222),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}