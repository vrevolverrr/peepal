import 'package:flutter/material.dart';
import 'package:peepal/features/nearby_toilets/widgets/nearby_toilet_card.dart'; // Import the new widget

class NearbyToiletsPage extends StatefulWidget {
  const NearbyToiletsPage({super.key});

  @override
  State<NearbyToiletsPage> createState() => NearbyToiletsPageState();
}

class NearbyToiletsPageState extends State<NearbyToiletsPage> {
  final PageController _pageController =
      PageController(viewportFraction: 1.0, initialPage: 5000);
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
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.red,
                  ),
                ),
              ],
            ),
            Text(
              "Good afternoon",
              style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8.0),
            Row(
              children: [
                Icon(
                  Icons.location_on,
                  size: 18.0,
                ),
                SizedBox(width: 5.0),
                Text("Jurong West St. 42"),
              ],
            ),
            SizedBox(height: 10.0),
            Divider(
              color: Colors.grey,
              thickness: 1.0,
              indent: 1,
              endIndent: 1,
            ),
            SizedBox(height: 10.0),
            Text(
              "Nearest Toilet",
              style: TextStyle(fontSize: 35.0, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 1.0),
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
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 7.0),
                            child: child,
                          ),
                        ),
                      );
                    },
                    child: SizedBox(
                      width: double.infinity, // 80% of the screen width,
                      //padding: const EdgeInsets.symmetric(horizontal: 5.0),
                      child: NearbyToiletCard(
                      cardNumber: cardNumber)
                     ),
                   ); // Use the new widget
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
