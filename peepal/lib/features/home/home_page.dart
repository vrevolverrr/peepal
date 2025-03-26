import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:peepal/features/nearby_toilets/view/nearby_toilets_page.dart';
import 'package:peepal/shared/app/bloc/app_bloc.dart';
import 'package:peepal/features/toilet_map/view/toilet_map_view.dart';
import 'package:peepal/shared/location/repository/location_repository.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final PageController _pageController = PageController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<AppPageCubit, AppPageState>(
          listener: (context, state) => _pageController.jumpToPage(state.index),
          child: PageView(
            physics: const NeverScrollableScrollPhysics(),
            controller: _pageController,
            children: [
              NearbyToiletsPage(),
              ToiletMapPage(
                  locationRepository: context.read<LocationRepository>()),
              Center(child: Text("Favorite Page")),
              Center(child: Text("Profile Page")),
            ],
          )),
      bottomNavigationBar: BlocBuilder<AppPageCubit, AppPageState>(
        builder: (context, state) {
          return BottomNavigationBar(
            showSelectedLabels: false,
            showUnselectedLabels: false,
            backgroundColor: Color(0xffffffff),
            currentIndex: state.index,
            onTap: (index) {
              if (index == 0) {
                context.read<AppPageCubit>().changeToHome();
              } else if (index == 1) {
                context.read<AppPageCubit>().changeToSearch();
              } else if (index == 2) {
                context.read<AppPageCubit>().changeToFavorite();
              } else if (index == 3) {
                context.read<AppPageCubit>().changeToProfile();
              }
            },
            items: [
              BottomNavigationBarItem(
                  activeIcon: Icon(Icons.home, size: 25.0, color: Colors.black),
                  icon: Icon(
                    Icons.home_outlined,
                    size: 25.0,
                    color: Colors.black,
                  ),
                  label: "Home"),
              BottomNavigationBarItem(
                  activeIcon:
                      Icon(Icons.search, size: 25.0, color: Colors.black),
                  icon: Icon(
                    Icons.search_outlined,
                    size: 25.0,
                    color: Colors.black,
                  ),
                  label: "Search"),
              BottomNavigationBarItem(
                  activeIcon:
                      Icon(Icons.favorite, size: 25.0, color: Colors.black),
                  icon: Icon(
                    Icons.favorite_border_outlined,
                    size: 25.0,
                    color: Colors.black,
                  ),
                  label: "Favorite"),
              BottomNavigationBarItem(
                  activeIcon:
                      Icon(Icons.person, size: 25.0, color: Colors.black),
                  icon: Icon(
                    Icons.person_outline,
                    size: 25.0,
                    color: Colors.black,
                  ),
                  label: "Profile"),
            ],
          );
        },
      ),
    );
  }
}
