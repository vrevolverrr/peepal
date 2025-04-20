import 'dart:async';

import 'package:apple_maps_flutter/apple_maps_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:peepal/api/toilets/model/latlng.dart';
import 'package:peepal/api/toilets/model/toilet.dart';
import 'package:peepal/pages/favourites/bloc/favorites_bloc.dart';
import 'package:peepal/shared/location/bloc/location_bloc.dart';
import 'package:peepal/shared/toilets/toilets_bloc.dart';
import 'package:peepal/pages/toilet_map/bloc/toilet_map_bloc.dart';
import 'package:peepal/pages/toilet_map/widgets/search_bar.dart';
import 'package:peepal/pages/toilet_map/widgets/toilet_location_card.dart';
import 'package:peepal/pages/navigation/navigation_page.dart';
import 'package:peepal/pages/toilet_details/toilet_details_page.dart';
import 'package:rxdart/rxdart.dart';

class ToiletMapPage extends StatefulWidget {
  const ToiletMapPage({super.key});

  @override
  State<ToiletMapPage> createState() => _ToiletMapPageState();
}

class _ToiletMapPageState extends State<ToiletMapPage>
    with AutomaticKeepAliveClientMixin {
  final Completer<AppleMapController> _controller = Completer();
  @override
  bool get wantKeepAlive => true;

  bool _mapsInitialized = false;

  late final LocationCubit locationCubit;
  late final ToiletsBloc toiletsBloc;
  late final ToiletMapCubit toiletMapCubit;
  late final FavoritesBloc favoritesBloc;

  late final CompositeSubscription _subscriptions;

  @override
  void initState() {
    locationCubit = context.read<LocationCubit>();
    toiletsBloc = context.read<ToiletsBloc>();
    toiletMapCubit = context.read<ToiletMapCubit>();
    favoritesBloc = context.read<FavoritesBloc>();
    _subscriptions = CompositeSubscription();
    super.initState();
  }

  @override
  void dispose() {
    _subscriptions.cancel();
    super.dispose();
  }

  void _handleAnimateCameraToToilet(PPToilet toilet) async {
    final AppleMapController controller = await _controller.future;
    controller.animateCamera(
      CameraUpdate.newLatLngZoom(
        toilet.location.toAmLatLng(),
        17.0,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final LatLng initialLocation = const LatLng(1.3349539, 103.7286225);

    return Stack(
      children: [
        BlocConsumer<ToiletMapCubit, ToiletMapState>(
          listener: (context, state) async {
            if (state.selectedToilet != null) {
              _handleAnimateCameraToToilet(state.selectedToilet!);
            }
          },
          listenWhen: (previous, current) =>
              previous.selectedToilet != current.selectedToilet,
          builder: (context, state) {
            return AppleMap(
              myLocationEnabled: true,
              mapType: MapType.standard,
              initialCameraPosition: CameraPosition(
                target: initialLocation,
                zoom: 11.0,
              ),
              annotations: state.toiletMarkers,
              polylines: state.activePolylines,
              onCameraIdle: () async {
                final AppleMapController controller = await _controller.future;
                final LatLngBounds bounds = await controller.getVisibleRegion();
                final LatLng center = LatLng(
                    (bounds.northeast.latitude + bounds.southwest.latitude) / 2,
                    (bounds.northeast.longitude + bounds.southwest.longitude) /
                        2);

                toiletsBloc.add(ToiletEventFetchNearby(
                  location: PPLatLng(
                      latitude: center.latitude, longitude: center.longitude),
                  radius: 800,
                  limit: 10,
                ));
              },
              onMapCreated: (AppleMapController controller) async {
                if (!_controller.isCompleted) {
                  _controller.complete(controller);

                  // Load markers after map is created - only set up listeners once
                  if (!_mapsInitialized) {
                    _mapsInitialized = true;

                    // Longer delay to ensure map is fully loaded
                    await Future.delayed(const Duration(milliseconds: 500));

                    final locationState = locationCubit.state;

                    if (locationState is LocationStateWithLocation) {
                      controller.animateCamera(
                        CameraUpdate.newCameraPosition(CameraPosition(
                            zoom: 15.0, // Slightly wider view
                            target: locationState.location.toAmLatLng())),
                      );

                      // Also trigger a nearby toilets fetch
                      toiletsBloc.add(ToiletEventFetchNearby(
                        location: PPLatLng(
                          latitude: locationState.location.latitude,
                          longitude: locationState.location.longitude,
                        ),
                        radius: 1000, // Larger initial radius
                        limit: 20, // More initial toilets
                      ));
                    }

                    // Listen to subsequent updates
                    _subscriptions.add(toiletsBloc.stream.listen((state) {
                      // Only update markers when there are toilets available
                      if (state.toilets.isNotEmpty) {
                        toiletMapCubit.updateMarkers(state.toilets);
                      }
                    }));
                  }

                  // Always update markers when map is created (in case the map is recreated)
                  if (toiletsBloc.state.toilets.isNotEmpty) {
                    toiletMapCubit.updateMarkers(toiletsBloc.state.toilets);
                  }
                }
              },
            );
          },
        ),
        BlocBuilder<ToiletsBloc, ToiletsState>(builder: (context, state) {
          if (state is ToiletsStateLoading) {
            return Positioned(
              right: 20.0,
              top: 85.0,
              child: SafeArea(
                child: Container(
                  width: 40.0,
                  height: 40.0,
                  padding: const EdgeInsets.all(10.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 4.0,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                    ),
                  ),
                ),
              ),
            );
          }

          return const SizedBox.shrink();
        }),
        ToiletSearchBar(),
        BlocBuilder<ToiletMapCubit, ToiletMapState>(builder: (context, state) {
          if (state.selectedToilet == null) {
            return const SizedBox.shrink();
          }

          return Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Align(
              alignment: Alignment.bottomCenter,
              child: GestureDetector(
                onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MultiBlocProvider(
                        providers: [
                          BlocProvider.value(value: toiletsBloc),
                          BlocProvider.value(value: favoritesBloc),
                        ],
                        child: ToiletDetailsPage(
                          toilet: state.selectedToilet!,
                        ),
                      ),
                    )),
                child: ToiletLocationCard(
                  toilet: state.selectedToilet!,
                  onClose: () => toiletMapCubit.deselectToilet(),
                  onDirections: () {
                    // Get the [locationCubit] from current context and pass into new route
                    final locationCubit = context.read<LocationCubit>();

                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => NavigationPage(
                          locationCubit: locationCubit,
                          destination: state.selectedToilet!,
                          route: state.activeRoute!,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          );
        })
      ],
    );
  }
}
