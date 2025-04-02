import 'package:flutter/material.dart';

class NearbyToiletCard extends StatelessWidget {
  final int cardNumber;

  const NearbyToiletCard({Key? key, required this.cardNumber}) : super(key: key);

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
              child: Image.asset('assets/images/toilet.jpeg'), 
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
                      Text('60 Yuan Ching Rd', style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
                      Row(
                        children: [
                          Icon(Icons.star, color: const Color.fromARGB(255, 244, 223, 34)),
                          Text('5', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Wrap(
                    spacing: 16.0,
                    runSpacing: 8.0,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.circle, color: Colors.green, size: 12),
                          SizedBox(width: 4),
                          Text('High Vacancy',
                            style: TextStyle(fontSize: 16)
                          ),
                        ],
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.check, color: Colors.black, size: 12),
                          SizedBox(width: 4),
                          Text('Bidet available',
                            style: TextStyle(fontSize: 16)
                            ),
                        ],
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.accessible, color: Colors.black, size: 12),
                          SizedBox(width: 4),
                          Text('OKU friendly',
                            style: TextStyle(fontSize: 16)
                            ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 18),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('500m', style: TextStyle(fontSize: 20,)),
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
                        )
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text('Card $cardNumber', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}