import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:peepal/features/app/bloc/app_bloc.dart';
import 'package:peepal/features/nearby_toilets/nearby_toilets_page.dart';
import 'package:peepal/features/toilet_map/toilet_map_page.dart';
import 'package:peepal/shared/location/bloc/location_bloc.dart';
import 'package:peepal/shared/location/repository/location_repository.dart';
import 'package:peepal/shared/toilet/repository/toilet_repository.dart';

class PeePalApp extends StatefulWidget {
  const PeePalApp({super.key});

  @override
  State<PeePalApp> createState() => _PeePalAppState();
}

class _PeePalAppState extends State<PeePalApp> {
  late final LocationRepository locationRepository =
      context.read<LocationRepository>();

  late final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "PeePal",
      theme: ThemeData(
          scaffoldBackgroundColor: Color(0xffF4F6F8), fontFamily: "MazzardH"),
      home: MultiBlocProvider(
          providers: [
            BlocProvider(create: (context) => AppPageCubit()),
            BlocProvider(
              lazy: false,
              create: (context) =>
                  LocationCubit(context.read<LocationRepository>())..init(),
            )
          ],
          child: Scaffold(
            body: BlocListener<AppPageCubit, AppPageState>(
                listener: (context, state) =>
                    _pageController.jumpToPage(state.index),
                child: PageView(
                  physics: const NeverScrollableScrollPhysics(),
                  controller: _pageController,
                  children: [
                    NearbyToiletsPage(),
                    ToiletMapPage(),
                    Center(child: Text("Favorite Page")),
                    Center(child: Text("Profile Page")),
                  ],
                )),
            bottomNavigationBar: BlocBuilder<AppPageCubit, AppPageState>(
              builder: _buildBottomNavBar,
            ),
          )),
    );
  }

  BottomNavigationBar _buildBottomNavBar(
          BuildContext context, AppPageState state) =>
      BottomNavigationBar(
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
          _buildNavItem(
              activeIcon: Icons.home, icon: Icons.home_outlined, label: "Home"),
          _buildNavItem(
              activeIcon: Icons.search,
              icon: Icons.search_outlined,
              label: "Search"),
          _buildNavItem(
              activeIcon: Icons.favorite,
              icon: Icons.favorite_border_outlined,
              label: "Favorite"),
          _buildNavItem(
              activeIcon: Icons.person,
              icon: Icons.person_outline,
              label: "Profile"),
        ],
      );

  BottomNavigationBarItem _buildNavItem(
          {required String label,
          required IconData icon,
          required IconData activeIcon}) =>
      BottomNavigationBarItem(
          activeIcon: Icon(activeIcon, size: 25.0, color: Colors.black),
          icon: Icon(
            icon,
            size: 25.0,
            color: Colors.black,
          ),
          label: label);
}
