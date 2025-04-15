import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:peepal/shared/widgets/pp_button.dart';

@immutable
class ToiletFeatureEdits extends Equatable {
  final bool handicapAvail;
  final bool bidetAvail;
  final bool showerAvail;
  final bool sanitiserAvail;

  const ToiletFeatureEdits({
    required this.handicapAvail,
    required this.bidetAvail,
    required this.showerAvail,
    required this.sanitiserAvail,
  });

  ToiletFeatureEdits copyWith({
    bool? handicapAvail,
    bool? bidetAvail,
    bool? showerAvail,
    bool? sanitiserAvail,
  }) {
    return ToiletFeatureEdits(
      handicapAvail: handicapAvail ?? this.handicapAvail,
      bidetAvail: bidetAvail ?? this.bidetAvail,
      showerAvail: showerAvail ?? this.showerAvail,
      sanitiserAvail: sanitiserAvail ?? this.sanitiserAvail,
    );
  }

  @override
  List<Object?> get props => [
        handicapAvail,
        bidetAvail,
        showerAvail,
        sanitiserAvail,
      ];
}

class EditToiletModal extends StatefulWidget {
  final double height;
  final ToiletFeatureEdits initialEdits;

  /// Callback for when thr `confirm` button is pressed. Do not include
  /// `Navigator.pop` here, it is called internally after `onConfirm` resolves.
  final FutureOr<void> Function(ToiletFeatureEdits) onConfirm;

  const EditToiletModal({
    super.key,
    required this.height,
    required this.initialEdits,
    required this.onConfirm,
  });

  @override
  State<EditToiletModal> createState() => _EditToiletModalState();
}

class _EditToiletModalState extends State<EditToiletModal> {
  late ToiletFeatureEdits _edits;
  bool _isLoading = false;

  @override
  void initState() {
    _edits = widget.initialEdits;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 18.0),
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
                  'Edit Amenities',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
            ]),
          ),
          Column(
            children: [
              _buildAmenityTile(
                'Handicap Accessible',
                Icons.accessible,
                _edits.handicapAvail,
                (value) => setState(() {
                  _edits = _edits.copyWith(
                    handicapAvail: value ?? false,
                  );
                }),
              ),
              _buildAmenityTile(
                'Bidet Available',
                Icons.water_drop,
                _edits.bidetAvail,
                (value) => setState(() {
                  _edits = _edits.copyWith(
                    bidetAvail: value ?? false,
                  );
                }),
              ),
              _buildAmenityTile(
                'Shower Available',
                Icons.shower,
                _edits.showerAvail,
                (value) => setState(() {
                  _edits = _edits.copyWith(
                    showerAvail: value ?? false,
                  );
                }),
              ),
              _buildAmenityTile(
                'Sanitiser Available',
                Icons.sanitizer,
                _edits.sanitiserAvail,
                (value) => setState(() {
                  _edits = _edits.copyWith(
                    sanitiserAvail: value ?? false,
                  );
                }),
              ),
            ],
          ),
          // Bottom button
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 18.0),
            child: PPButton("Confirm Edits", isLoading: _isLoading,
                onPressed: () async {
              setState(() => _isLoading = true);

              final BuildContext current = context;
              try {
                await widget.onConfirm(_edits);
                setState(() => _isLoading = false);
              } catch (e) {
                setState(() => _isLoading = false);
              }

              if (current.mounted) {
                Navigator.pop(current);
              }
            }),
          ),
          const SizedBox(height: 20.0),
        ],
      ),
    );
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
