import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:peepal/shared/location/bloc/location_bloc.dart';
import 'package:peepal/features/toilet_map/view/widgets/search_bar.dart';

class ToiletMapPage extends StatefulWidget {
  const ToiletMapPage({super.key});

  @override
  State<ToiletMapPage> createState() => _ToiletMapPageState();
}

class _ToiletMapPageState extends State<ToiletMapPage> {
  final Completer<GoogleMapController> _controller = Completer();

  void _handleSearch(String query) {
    print('Searching for: $query');
  }

  @override
  void dispose() {
    _controller.future.then((controller) => controller.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    late final LatLng initialLocation;

    if (context.read<LocationCubit>().state is! LocationStateWithLocation) {
      initialLocation = const LatLng(1.350564, 103.681900);
    } else {
      final location =
          (context.read<LocationCubit>().state as LocationStateWithLocation)
              .location;
      initialLocation = LatLng(location.latitude, location.longitude);
    }

    return Stack(
      children: [
        GoogleMap(
            myLocationButtonEnabled: true,
            myLocationEnabled: true,
            mapType: MapType.normal,
            initialCameraPosition: CameraPosition(
              target: initialLocation,
              zoom: 12.0,
            ),
// markers: {
            //   // Central Region
            //   Marker(
            //     markerId: const MarkerId('central'),
            //     position: const LatLng(1.3644, 103.8077),
            //   ),
            //   Marker(
            //     markerId: const MarkerId('centralSouth'),
            //     position: const LatLng(1.3050, 103.8200),
            //   ),
            //   Marker(
            //     markerId: const MarkerId('centralEast'),
            //     position: const LatLng(1.3300, 103.8450),
            //   ),
            //   Marker(
            //     markerId: const MarkerId('centralWest'),
            //     position: const LatLng(1.3200, 103.7900),
            //   ),
            //   Marker(
            //     markerId: const MarkerId('centralNorth'),
            //     position: const LatLng(1.3800, 103.8300),
            //   ),

            //   // North Region
            //   Marker(
            //     markerId: const MarkerId('northCentral'),
            //     position: const LatLng(1.4195, 103.8208),
            //   ),
            //   Marker(
            //     markerId: const MarkerId('northWest'),
            //     position: const LatLng(1.4300, 103.7900),
            //   ),
            //   Marker(
            //     markerId: const MarkerId('northEast'),
            //     position: const LatLng(1.4400, 103.8500),
            //   ),
            //   Marker(
            //     markerId: const MarkerId('woodlands'),
            //     position: const LatLng(1.4180, 103.7650),
            //   ),
            //   Marker(
            //     markerId: const MarkerId('sembawang'),
            //     position: const LatLng(1.4443, 103.8172),
            //   ),

            //   // South Region
            //   Marker(
            //     markerId: const MarkerId('southCentral'),
            //     position: const LatLng(1.2967, 103.8485),
            //   ),
            //   Marker(
            //     markerId: const MarkerId('southWest'),
            //     position: const LatLng(1.2700, 103.8200),
            //   ),
            //   Marker(
            //     markerId: const MarkerId('southEast'),
            //     position: const LatLng(1.2800, 103.8600),
            //   ),

            //   // East Region

            //   Marker(
            //     markerId: const MarkerId('bedok'),
            //     position: const LatLng(1.3450, 103.9550),
            //   ),
            //   Marker(
            //     markerId: const MarkerId('tampines'),
            //     position: const LatLng(1.3720, 103.9530),
            //   ),
            //   Marker(
            //     markerId: const MarkerId('changi'),
            //     position: const LatLng(1.3600, 103.9800),
            //   ),

            //   // West Region
            //   Marker(
            //     markerId: const MarkerId('westCentral'),
            //     position: const LatLng(1.3350, 103.7400),
            //   ),
            //   Marker(
            //     markerId: const MarkerId('tuas'),
            //     position: const LatLng(1.3500, 103.7200),
            //   ),
            //   Marker(
            //     markerId: const MarkerId('jurongWest'),
            //     position: const LatLng(1.3280, 103.7650),
            //   ),

            //   // North-East Region
            //   Marker(
            //     markerId: const MarkerId('serangoon'),
            //     position: const LatLng(1.3510, 103.8891),
            //   ),
            //   Marker(
            //     markerId: const MarkerId('sengkang'),
            //     position: const LatLng(1.3850, 103.8930),
            //   ),
            //   Marker(
            //     markerId: const MarkerId('punggol'),
            //     position: const LatLng(1.4050, 103.9020),
            //   ),

            //   // Custom markers
            //   Marker(
            //     markerId: const MarkerId('bedok_mall'),
            //     position: const LatLng(1.3263, 103.9291),
            //   ),
            //   Marker(
            //     markerId: const MarkerId('geylang'),
            //     position: const LatLng(1.3205, 103.9070),
            //   ),
            //   Marker(
            //     markerId: const MarkerId('marine_parade'),
            //     position: const LatLng(1.3013, 103.8848),
            //   ),
            //   Marker(
            //     markerId: const MarkerId('pioneer'),
            //     position: const LatLng(1.3191, 103.7069),
            //   ),
            //   Marker(
            //     markerId: const MarkerId('cck'),
            //     position: const LatLng(1.3868, 103.7474),
            //   ),
            //   Marker(
            //     markerId: const MarkerId('bukit_badok'),
            //     position: const LatLng(1.3496, 103.7636),
            //   ),
            //   Marker(
            //     markerId: const MarkerId('sg_zoo'),
            //     position: const LatLng(1.4053, 103.7928),
            //   ),

            //   Marker(
            //     markerId: const MarkerId('cck_cemetary'),
            //     position: const LatLng(1.3814, 103.6889),
            //   ),

            //   Marker(
            //     markerId: const MarkerId('joo_koon'),
            //     position: const LatLng(1.3279, 103.6787),
            //   ),

            //   Marker(
            //     markerId: const MarkerId('net_co_marine'),
            //     position: const LatLng(1.3148, 103.6533),
            //   ),

            //   Marker(
            //     markerId: const MarkerId('hor_par'),
            //     position: const LatLng(1.2930, 103.7941),
            //   ),

            //   Marker(
            //     markerId: const MarkerId('amk'),
            //     position: const LatLng(1.3680, 103.8514),
            //   ),

            //   Marker(
            //     markerId: const MarkerId('tampines_ave'),
            //     position: const LatLng(1.3576, 103.9257),
            //   ),

            //   Marker(
            //     markerId: const MarkerId('changi2'),
            //     position: const LatLng(1.3320, 103.9725),
            //   ),
            // },
            onMapCreated: (GoogleMapController controller) {
              if (!_controller.isCompleted) {
                _controller.complete(controller);
              }
            }),
        ToiletSearchBar(
          onSearch: _handleSearch,
        ),
      ],
    );
  }
}
