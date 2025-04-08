import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:peepal/features/nearby_toilets/view/widgets/nearby_toilet_card.dart';
import 'package:peepal/features/app/bloc/app_bloc.dart';
import 'package:peepal/features/nearby_toilets/view/mock_toilet_data.dart';


class NearbyToiletsPage extends StatefulWidget {
  const NearbyToiletsPage({super.key});

  @override
  State<NearbyToiletsPage> createState() => NearbyToiletsPageState();
}

class NearbyToiletsPageState extends State<NearbyToiletsPage> {
  final PageController _pageController =
      PageController(viewportFraction: 1.0, initialPage: 5000);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        bottom: false,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  GestureDetector(
                    onTap: () {
                      context.read<AppPageCubit>().changeToProfile();
                    },
                    child: CircleAvatar(
                      radius: 20.0,
                      backgroundColor: Colors.grey.shade200,
                      child: Icon(
                        Icons.person,
                        color: Colors.black,
                        size: 24.0,
                      ),
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
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return PageView.builder(
                      controller: _pageController,
                      itemCount: null,
                      itemBuilder: (context, index) {
                        final actualIndex = index % toilets.length;
                        final toilet = toilets[actualIndex];
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
                          child: NearbyToiletCard(
                            address: toilet['address'],
                            rating: toilet['rating'],
                            distance: toilet['distance'],
                            highVacancy: toilet['highVacancy'],
                            bidetAvailable: toilet['bidetAvailable'],
                            okuFriendly: toilet['okuFriendly'],
                            hasShower: toilet['hasShower'] ?? false,
                            hasSanitizer: toilet['hasSanitizer'] ?? false,
                            height: 500, // Dynamically set card height
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
