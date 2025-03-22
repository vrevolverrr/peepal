import 'package:flutter/material.dart';


class NearbyToiletsPage extends StatefulWidget {
  const NearbyToiletsPage({super.key});

  @override
  State<NearbyToiletsPage> createState() => NearbyToiletsPageState();
}

class NearbyToiletsPageState extends State<NearbyToiletsPage> {
  final PageController _pageController = PageController(viewportFraction: 0.7, initialPage: 5000);
  final int _totalCards = 5;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  width: 40.0,
                  height: 40.0,
                  decoration:
                      BoxDecoration(
                        shape: BoxShape.circle, 
                        color: Colors.red
                      ),
                )
              ],
            ),
            Text(
              "Good afternoon",
              style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
            ),
            SizedBox(
              height: 8.0,
            ),
            Row(
              children: [
                Icon(
                  Icons.location_on,
                  size: 18.0,
                ),
                SizedBox(width: 5.0),
                Text("Jurong West St. 42")
              ],
            ),
            SizedBox(height: 16.0),
            Text(
              "Nearest Toilet",
              style: TextStyle(fontSize: 25.0, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 5.0),
             Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemBuilder: (context, index) {
                   int cardNumber = (index % _totalCards) + 1;
                  return AnimatedBuilder(
                    animation: _pageController,
                    builder: (context, child) {
                      double value = 1;
                      if (_pageController.position.haveDimensions) {
                        value = _pageController.page! - index;
                        value = (1 - (value.abs() * 0.3)).clamp(0.8, 1.0);
                      }
                      return Center(
                        child: Transform.scale(
                          scale: value,
                          child: child,
                        ),
                      );
                    },
                    child: Padding(
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
                                      Text('60 Yuan Ching Rd', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                      Row(
                                        children: [
                                          Icon(Icons.star, color: Colors.yellow),
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
                                          Text('High Vacancy'),
                                        ],
                                      ),
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(Icons.check, color: Colors.black, size: 12),
                                          SizedBox(width: 4),
                                          Text('Bidet available'),
                                        ],
                                      ),
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(Icons.accessible, color: Colors.black, size: 12),
                                          SizedBox(width: 4),
                                          Text('OKU friendly'),
                                        ],
                                      ), 
                                    ],
                                  ), 
                                  SizedBox(height: 18),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text('500m', style: TextStyle(fontSize: 16)),
                                      ElevatedButton(
                                        onPressed: () {},
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.blueGrey, // Background color
                                          foregroundColor: Colors.white,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(16),
                                          ),
                                        ),
                                        child: Text('Navigate'),
                                      ), 
                                  ],
                                ),
                                Text('Card $cardNumber', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ),
                        ],
                      ),
                      ),
                    ),
                    );      
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}