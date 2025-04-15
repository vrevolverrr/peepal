import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:apple_maps_flutter/apple_maps_flutter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:peepal/api/toilets/model/latlng.dart';
import 'package:peepal/pages/add_toilet/bloc/add_toilet_bloc.dart';
import 'package:peepal/pages/add_toilet/widgets/location_selector_modal.dart';
import 'package:peepal/shared/location/bloc/location_bloc.dart';
import 'package:peepal/shared/widgets/pp_button.dart';

class AddToiletPage extends StatefulWidget {
  const AddToiletPage({super.key});

  @override
  State<AddToiletPage> createState() => _AddToiletPageState();
}

class _AddToiletPageState extends State<AddToiletPage> {
  late final AddToiletBloc bloc;

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();

  final Completer<AppleMapController> _controller =
      Completer<AppleMapController>();

  Future<void> _selectLocation() async {
    final PPLatLng? selectedLocation = bloc.state.details.selectedLocation;

    LatLng initialLocation = selectedLocation?.toAmLatLng() ??
        context.read<LocationCubit>().state.location.toAmLatLng();

    final location = await showModalBottomSheet<LatLng>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      enableDrag: false,
      builder: (context) {
        final height = MediaQuery.of(context).size.height * 0.8;

        return LocationSelectorModal(
            height: height, initialLocation: initialLocation);
      },
    );

    /// Ignore if for some reason no location was returned by the route
    if (location == null) {
      return;
    }

    bloc.add(AddToiletEventSelectLocation(
        location: PPLatLng.fromAmLatLng(location)));

    /// Update camera position
    _controller.future.then((controller) {
      controller.moveCamera(
        CameraUpdate.newLatLng(location),
      );
    });
  }

  void _onSubmit() async {
    final bool isValid = _formKey.currentState?.validate() ?? false;

    if (!isValid) {
      return;
    }

    final PPLatLng? selectedLocation = bloc.state.details.selectedLocation;

    if (selectedLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a location')),
      );
      return;
    }

    bloc.add(AddToiletEventCreate());
  }

  @override
  void initState() {
    bloc = context.read<AddToiletBloc>();
    super.initState();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Widget _buildLocationPreview() {
    return GestureDetector(
      onTap: _selectLocation,
      child: Container(
        color: const Color(0xFFF2F2F7),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(
                Icons.location_on,
                size: 32,
                color: Color(0xFF007AFF),
              ),
              SizedBox(height: 8),
              Text(
                'Tap to Select Location',
                style: TextStyle(
                  color: Color(0xFF007AFF),
                  fontSize: 17,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLocationSelector(LatLng selectedLocation) {
    return Stack(
      children: [
        AppleMap(
          initialCameraPosition: CameraPosition(
            target: selectedLocation,
            zoom: 17.0,
          ),
          scrollGesturesEnabled: false,
          rotateGesturesEnabled: false,
          zoomGesturesEnabled: false,
          onMapCreated: (controller) {
            if (!_controller.isCompleted) {
              _controller.complete(controller);
            }
          },
          annotations: {
            Annotation(
              annotationId: AnnotationId('selected'),
              position: selectedLocation,
            ),
          },
        ),
        GestureDetector(
          onTap: _selectLocation,
          child: Container(
            color: Colors.transparent,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Add New Toilet',
          style: TextStyle(fontSize: 20.0),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Stack(
                  children: [
                    Container(
                      height: 180.0,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(14.0),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(14.0),
                        child: BlocBuilder<AddToiletBloc, AddToiletState>(
                          builder: (context, state) {
                            if (bloc.state.details.selectedLocation != null) {
                              final LatLng selectedLocation = bloc
                                  .state.details.selectedLocation!
                                  .toAmLatLng();

                              return _buildLocationSelector(selectedLocation);
                            }

                            return _buildLocationPreview();
                          },
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20.0),
                const Text(
                  'Place Name',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8.0),
                BlocConsumer<AddToiletBloc, AddToiletState>(
                  listenWhen: (previous, current) =>
                      previous.details.placeName != current.details.placeName,
                  listener: (context, state) {
                    _nameController.text = state.details.placeName ?? '';
                  },
                  builder: (context, state) => _buildPlaceNameInputField(state),
                ),
                const SizedBox(height: 22.0),
                const Text(
                  'Rate cleanliness',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8.0),
                _buildRating(),
                const SizedBox(height: 24.0),
                const Text(
                  'Amenities',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                ..._buildAmenityToggles(),
                const SizedBox(height: 24),
                BlocConsumer<AddToiletBloc, AddToiletState>(
                  listener: (context, state) {
                    if (state is AddToiletStateCreated) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Toilet added successfully')),
                      );
                    }
                  },
                  builder: (context, state) {
                    return PPButton("Add Toilet",
                        isLoading: state is AddToiletStateCreating,
                        onPressed: _onSubmit);
                  },
                ),
                const SizedBox(height: 40.0),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRating() {
    return BlocSelector<AddToiletBloc, AddToiletState, int?>(
      selector: (state) => state.details.rating,
      builder: (context, rating) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(5, (index) {
            return IconButton(
              icon: Icon(
                index < (rating ?? 3)
                    ? Icons.star
                    : index + 0.5 == (rating ?? 3)
                        ? Icons.star_half
                        : Icons.star_border,
                color: Colors.amber,
                size: 32.0,
              ),
              onPressed: () {
                bloc.add(AddToiletEventRate(rating: index + 1));
              },
            );
          }),
        );
      },
    );
  }

  Widget _buildPlaceNameInputField(AddToiletState state) {
    return TextFormField(
      onEditingComplete: () {
        bloc.add(AddToiletEventNameUpdated(name: _nameController.text));
        FocusScope.of(context).unfocus();
      },
      readOnly: state is AddToiletStateLoadingPlaceDetails,
      textInputAction: TextInputAction.done,
      controller: _nameController,
      decoration: InputDecoration(
        hintText: 'Enter toilet name',
        border: OutlineInputBorder(
          borderSide: BorderSide(color: Color(0xFFBCBCBC)),
          borderRadius: BorderRadius.all(Radius.circular(12.0)),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
        filled: true,
        fillColor: Colors.white,
        suffixIcon: state is AddToiletStateLoadingPlaceDetails
            ? Container(
                padding: EdgeInsets.all(15.0),
                height: 18.0,
                width: 18.0,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF8E8E8E)),
                ),
              )
            : null,
      ),
      validator: (value) {
        if (value?.isEmpty ?? true) {
          return 'Please enter a name';
        }
        return null;
      },
    );
  }

  List<Widget> _buildAmenityToggles() {
    return [
      BlocBuilder<AddToiletBloc, AddToiletState>(
        buildWhen: (previous, current) =>
            previous.details.handicapAvail != current.details.handicapAvail ||
            previous.details.bidetAvail != current.details.bidetAvail ||
            previous.details.showerAvail != current.details.showerAvail ||
            previous.details.sanitiserAvail != current.details.sanitiserAvail,
        builder: (context, state) {
          return Column(
            children: [
              _buildAmenityTile(
                'Handicap Accessible',
                Icons.accessible,
                state.details.handicapAvail ?? false,
                (value) => bloc.add(AddToiletEventHandicapToggled(
                    handicapAvail: value ?? false)),
              ),
              _buildAmenityTile(
                'Bidet Available',
                Icons.water_drop,
                state.details.bidetAvail ?? false,
                (value) => bloc.add(
                    AddToiletEventBidetToggled(bidetAvail: value ?? false)),
              ),
              _buildAmenityTile(
                'Shower Available',
                Icons.shower,
                state.details.showerAvail ?? false,
                (value) => bloc.add(
                    AddToiletEventShowerToggled(showerAvail: value ?? false)),
              ),
              _buildAmenityTile(
                'Sanitiser Available',
                Icons.sanitizer,
                state.details.sanitiserAvail ?? false,
                (value) => bloc.add(AddToiletEventSanitiserToggled(
                    sanitiserAvail: value ?? false)),
              ),
            ],
          );
        },
      ),
    ];
  }

  Widget _buildAmenityTile(
    String title,
    IconData icon,
    bool value,
    void Function(bool?) onChanged,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF8E8E93)),
          const SizedBox(width: 12),
          Text(
            title,
            style: const TextStyle(fontSize: 17),
          ),
          const Spacer(),
          CupertinoSwitch(
            value: value,
            onChanged: onChanged,
            activeTrackColor: const Color(0xFF007AFF),
          ),
        ],
      ),
    );
  }
}
