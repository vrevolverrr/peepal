import 'package:flutter/material.dart';
import 'package:apple_maps_flutter/apple_maps_flutter.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:peepal/shared/widgets/pp_button.dart';

class LocationSelectorModal extends StatefulWidget {
  final double height;
  final LatLng initialLocation;

  const LocationSelectorModal({
    super.key,
    required this.height,
    required this.initialLocation,
  });

  @override
  State<LocationSelectorModal> createState() => _LocationSelectorModalState();
}

class _LocationSelectorModalState extends State<LocationSelectorModal>
    with SingleTickerProviderStateMixin {
  late LatLng _selectedLocation = widget.initialLocation;
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.height,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            color: Colors.transparent,
            child: Column(children: [
              Container(
                margin: const EdgeInsets.symmetric(vertical: 8),
                height: 4.0,
                width: 40.0,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                    left: 16.0, right: 16.0, bottom: 16.0, top: 10.0),
                child: Text(
                  'Select Location',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
            ]),
          ),

          // Map area that can be interacted with
          Expanded(
            child: Stack(
              children: [
                AppleMap(
                  myLocationEnabled: true,
                  initialCameraPosition: CameraPosition(
                    target: _selectedLocation,
                    zoom: 17,
                  ),
                  onCameraMoveStarted: () {
                    _controller.forward();
                  },
                  onCameraMove: (position) {
                    setState(() {
                      _selectedLocation = position.target;
                    });
                  },
                  onCameraIdle: () {
                    _controller.reverse();
                  },
                ),
                IgnorePointer(
                  child: Center(
                    child: Transform.translate(
                      offset: const Offset(0.0, -60.0),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            width: 35.0,
                            height: 15.0,
                            transform: Matrix4.identity()
                              ..translate(0.0, 30.0, 0.0),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.all(
                                  Radius.elliptical(100.0, 40.0)),
                              color: Colors.black26,
                            ),
                          ),
                          Image.asset("assets/images/marker.png",
                                  width: 60.0, height: 60.0)
                              .animate(controller: _controller)
                              .moveY(begin: 0.0, end: -12.0, duration: 300.ms),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Bottom button
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 20.0, vertical: 18.0),
            child: PPButton("Confirm Location", onPressed: () {
              Navigator.pop(context, _selectedLocation);
            }),
          ),
          const SizedBox(height: 20.0),
        ],
      ),
    );
  }
}
