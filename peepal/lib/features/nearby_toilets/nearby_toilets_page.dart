import 'package:flutter/material.dart';

class NearbyToiletsPage extends StatefulWidget {
  const NearbyToiletsPage({super.key});

  @override
  State<NearbyToiletsPage> createState() => NearbyToiletsPageState();
}

class NearbyToiletsPageState extends State<NearbyToiletsPage> {
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
                      BoxDecoration(shape: BoxShape.circle, color: Colors.red),
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
            )
          ],
        ),
      ),
    );
  }
}
