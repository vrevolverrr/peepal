import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:peepal/pages/add_toilet/add_toilet_page.dart';
import 'package:peepal/pages/add_toilet/bloc/add_toilet_bloc.dart';
import 'package:peepal/pages/favourites/bloc/favorites_bloc.dart';
import 'package:peepal/pages/favourites/favourites_page.dart';
import 'package:peepal/shared/auth/auth_bloc.dart';
import 'package:peepal/shared/toilets/toilets_bloc.dart';
import 'package:peepal/pages/app/bloc/app_bloc.dart';
import 'package:peepal/pages/login_page/login_page.dart';
import 'package:peepal/pages/nearby_toilets/nearby_toilets_page.dart';
import 'package:peepal/pages/toilet_map/bloc/toilet_map_bloc.dart';
import 'package:peepal/pages/toilet_map/toilet_map_page.dart';
import 'package:peepal/shared/location/bloc/location_bloc.dart';
import 'package:peepal/shared/location/repository/location_repository.dart';
import 'package:peepal/shared/widgets/splashscreen.dart';

class PeePalApp extends StatefulWidget {
  const PeePalApp({super.key});

  @override
  State<PeePalApp> createState() => _PeePalAppState();
}

class _PeePalAppState extends State<PeePalApp> {
  late final LocationRepository locationRepository;
  late final LocationCubit locationCubit;
  late final ToiletsBloc toiletsBloc;

  late final PageController _pageController = PageController();

  @override
  void initState() {
    locationRepository = context.read<LocationRepository>();
    locationCubit = LocationCubit(locationRepository);
    locationCubit.init();

    toiletsBloc = ToiletsBloc();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "PeePal",
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          scaffoldBackgroundColor: Color(0xffF4F6F8),
          fontFamily: "MazzardH",
          snackBarTheme: SnackBarThemeData(
              backgroundColor: const Color(0xFFF7F7F7),
              elevation: 2.0,
              shape: RoundedRectangleBorder(
                side: BorderSide(
                  color: Colors.black,
                  width: 2.0,
                ),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16.0),
                  topRight: Radius.circular(16.0),
                ),
              ),
              contentTextStyle: TextStyle(
                  color: Colors.black,
                  fontSize: 14.0,
                  fontFamily: "MazzardH",
                  fontWeight: FontWeight.bold))),
      home: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthStateError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("An error occurred while authenticating")),
            );
          }

          if (state is AuthStateAuthenticated) {
            ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Successfully logged in")));
          }

          if (state is AuthStateInvalidCredentials) {
            ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Invalid email or password")));
          }
        },
        builder: (context, state) {
          if (state is AuthStateInitial) {
            return const SplashScreen();
          }

          if (state is! AuthStateAuthenticated) {
            return const LoginPage();
          }

          return MultiBlocProvider(
              providers: [
                BlocProvider<AppPageCubit>(create: (context) => AppPageCubit()),
                BlocProvider<LocationCubit>.value(value: locationCubit),
                BlocProvider<ToiletsBloc>.value(value: toiletsBloc),
                BlocProvider<ToiletMapCubit>(
                    create: (context) =>
                        ToiletMapCubit(locationCubit: locationCubit)),
                BlocProvider<FavoritesBloc>(create: (context) {
                  final bloc = FavoritesBloc(toiletsBloc: toiletsBloc);
                  bloc.add(const FavoritesEventLoad());
                  return bloc;
                }),
              ],
              child: Builder(builder: (context) {
                return Scaffold(
                  body: BlocListener<AppPageCubit, AppPageState>(
                      listener: (context, state) => _pageController.jumpToPage(
                            state.index,
                          ),
                      child: PageView(
                        physics: const NeverScrollableScrollPhysics(),
                        controller: _pageController,
                        children: [
                          const NearbyToiletsPage(),
                          const ToiletMapPage(),
                          BlocProvider<AddToiletBloc>(
                            create: (context) => AddToiletBloc(
                                locationCubit: locationCubit,
                                toiletsBloc: toiletsBloc),
                            lazy: false,
                            child: const AddToiletPage(),
                          ),
                          const FavouritesPage(),
                        ],
                      )),
                  bottomNavigationBar: BlocBuilder<AppPageCubit, AppPageState>(
                    builder: _buildBottomNavBar,
                  ),
                );
              }));
        },
      ),
    );
  }

  CurvedNavigationBar _buildBottomNavBar(
          BuildContext context, AppPageState state) =>
      CurvedNavigationBar(
        animationDuration: const Duration(milliseconds: 300),
        animationCurve: Curves.decelerate,
        index: state.index,
        onTap: (index) {
          if (index == 0) {
            context.read<AppPageCubit>().changeToHome();
          } else if (index == 1) {
            context.read<AppPageCubit>().changeToSearch();
          } else if (index == 2) {
            context.read<AppPageCubit>().changeToAdd();
          } else if (index == 3) {
            context.read<AppPageCubit>().changeToFavorite();
          }
        },
        items: [
          Icon(
            Icons.home_outlined,
            size: 25.0,
            color: Colors.black,
          ),
          Icon(
            Icons.search_outlined,
            size: 25.0,
            color: Colors.black,
          ),
          Icon(
            Icons.add_outlined,
            size: 25.0,
            color: Colors.black,
          ),
          Icon(
            Icons.favorite_outline,
            size: 25.0,
            color: Colors.black,
          ),
        ],
      );
}
