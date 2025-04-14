import 'dart:async';

import 'package:apple_maps_flutter/apple_maps_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:peepal/api/toilets/model/latlng.dart';
import 'package:peepal/api/toilets/model/toilet.dart';
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

  late final CompositeSubscription _subscriptions;

  @override
  void initState() {
    locationCubit = context.read<LocationCubit>();
    toiletsBloc = context.read<ToiletsBloc>();
    toiletMapCubit = context.read<ToiletMapCubit>();
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
          builder: (context, state) {
            if (state.activePolylines.isNotEmpty) {
              debugPrint(state.activePolylines.first.hashCode.toString());
            }

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

                  // Load markers after map is created
                  if (!_mapsInitialized) {
                    _mapsInitialized = true;

                    // Add a short delay to ensure map is fully loaded
                    await Future.delayed(const Duration(milliseconds: 300));

                    final locationState = locationCubit.state;

                    if (locationState is LocationStateWithLocation) {
                      controller.animateCamera(
                        CameraUpdate.newCameraPosition(CameraPosition(
                            zoom: 17.0,
                            target: locationState.location.toAmLatLng())),
                      );
                    }

                    // Update markers
                    toiletMapCubit.updateMarkers(toiletsBloc.state.toilets);

                    // Listen to subsequent updates
                    _subscriptions.add(toiletsBloc.stream.listen((state) {
                      toiletMapCubit.updateMarkers(toiletsBloc.state.toilets);
                    }));
                  }
                }
              },
            );
          },
        ),
        ToiletSearchBar(),
        BlocBuilder<ToiletMapCubit, ToiletMapState>(builder: (context, state) {
          if (state.selectedToilet == null) {
            return const SizedBox.shrink();
          }

          return Align(
            alignment: Alignment.bottomCenter,
            child: GestureDetector(
              onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        ToiletDetailsPage(toilet: state.selectedToilet!),
                  )),
              child: ToiletLocationCard(
                toilet: state.selectedToilet!,
                onClose: () => toiletMapCubit.deselectToilet(),
                onDirections: () {
                  // Navigate to the NavigationPage with the selected location
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => NavigationPage(
                        destination: state.selectedToilet!,
                      ),
                    ),
                  );
                },
              ),
            ),
          );
        })
      ],
    );
  }
}
