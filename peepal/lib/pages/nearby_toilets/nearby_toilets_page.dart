import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:peepal/api/toilets/model/toilet.dart';
import 'package:peepal/pages/favourites/bloc/favorites_bloc.dart';
import 'package:peepal/pages/profile_page/profile_page.dart';
import 'package:peepal/shared/location/bloc/location_bloc.dart';
import 'package:peepal/shared/toilets/toilets_bloc.dart';
import 'package:peepal/pages/nearby_toilets/widgets/nearby_toilet_card.dart';
import 'package:peepal/pages/app/bloc/app_bloc.dart';
import 'package:peepal/pages/toilet_details/toilet_details_page.dart';
import 'package:peepal/pages/toilet_map/bloc/toilet_map_bloc.dart';

class NearbyToiletsPage extends StatefulWidget {
  const NearbyToiletsPage({super.key});

  @override
  State<NearbyToiletsPage> createState() => NearbyToiletsPageState();
}

class NearbyToiletsPageState extends State<NearbyToiletsPage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  final PageController _pageController =
      PageController(viewportFraction: 1.0, initialPage: 5000);

  late final locationCubit = context.read<LocationCubit>();
  late final toiletBloc = context.read<ToiletsBloc>();
  late final favoritesBloc = context.read<FavoritesBloc>();

  @override
  void initState() {
    _fetchToilets(locationCubit.state);
    locationCubit.stream.listen(_fetchToilets);

    super.initState();
  }

  void _fetchToilets(LocationState state) {
    if (state is LocationStateWithLocation) {
      toiletBloc.add(ToiletEventFetchNearby(location: state.location));
    } else {}
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        bottom: false,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                  onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const ProfilePage())),
                  child: _ProfileButtonWidget()),
              _GreetingTextWidget(),
              SizedBox(height: 4.0),
              _CurrentLocationAddressWidget(),
              SizedBox(height: 10.0),
              Divider(
                color: Colors.grey,
                thickness: 1.0,
                indent: 1,
                endIndent: 1,
              ),
              SizedBox(height: 8.0),
              Text(
                "Nearby Toilets",
                style: TextStyle(fontSize: 26.0, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8.0),
              BlocConsumer<ToiletsBloc, ToiletsState>(
                listener: (context, state) {
                  if (state is ToiletStateError) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content:
                            Text("An error occurred while fetching toilets")));
                  }
                },
                builder: (context, state) {
                  if (locationCubit.state is! LocationStateWithLocation) {
                    return Expanded(
                        child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.location_off,
                            size: 80.0,
                            color: Colors.grey.shade300,
                          ),
                          SizedBox(height: 8.0),
                          Text("Location not found",
                              style: TextStyle(
                                  fontSize: 14.0,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey.shade700)),
                        ],
                      ),
                    ));
                  }

                  if (state.toilets.isEmpty) {
                    return Expanded(
                        child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.wc,
                            size: 80.0,
                            color: Colors.grey.shade300,
                          ),
                          SizedBox(height: 8.0),
                          Text("No toilets found",
                              style: TextStyle(
                                  fontSize: 14.0,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey.shade700)),
                        ],
                      ),
                    ));
                  }

                  List<PPToilet> toilets;

                  if (locationCubit.state is LocationStateWithLocation) {
                    toilets = state.getNearest(
                        location:
                            (locationCubit.state as LocationStateWithLocation)
                                .location,
                        limit: 5);
                  } else {
                    toilets = state.toilets;
                  }

                  return SizedBox(
                    height: 500.0,
                    child: PageView.builder(
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

                            return Align(
                              alignment: Alignment.topCenter,
                              child: Transform.scale(
                                scale: value,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 7.0),
                                  child: child,
                                ),
                              ),
                            );
                          },
                          child: GestureDetector(
                            onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => MultiBlocProvider(
                                    providers: [
                                      BlocProvider.value(value: toiletBloc),
                                      BlocProvider.value(value: favoritesBloc),
                                    ],
                                    child: ToiletDetailsPage(
                                      toilet: toilet,
                                    ),
                                  ),
                                )),
                            child: NearbyToiletCard(
                                toilet: toilet,
                                onNavigate: () {
                                  context
                                      .read<ToiletMapCubit>()
                                      .selectToilet(toilet);
                                  context.read<AppPageCubit>().changeToSearch();
                                }),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileButtonWidget extends StatelessWidget {
  const _ProfileButtonWidget();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        CircleAvatar(
          radius: 20.0,
          backgroundColor: Colors.grey.shade200,
          child: Icon(
            Icons.person,
            color: Colors.black,
            size: 24.0,
          ),
        ),
      ],
    );
  }
}

class _GreetingTextWidget extends StatelessWidget {
  final List<String> _greetings = [
    "Good morning",
    "Good afternoon",
    "Good evening",
    "Good night"
  ];

  String _getGreeting() {
    final now = DateTime.now();
    final hour = now.hour;
    if (hour < 6) {
      return _greetings[3];
    } else if (hour < 12) {
      return _greetings[0];
    } else if (hour < 18) {
      return _greetings[1];
    } else {
      return _greetings[2];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      _getGreeting(),
      style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
    );
  }
}

class _CurrentLocationAddressWidget extends StatelessWidget {
  const _CurrentLocationAddressWidget();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          Icons.location_on,
          size: 16.0,
        ),
        SizedBox(width: 2.0),
        Text("Nanyang Technological University"),
      ],
    );
  }
}
