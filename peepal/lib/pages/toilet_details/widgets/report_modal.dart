import 'dart:async';

import 'package:flutter/material.dart';
import 'package:peepal/shared/widgets/pp_button.dart';

class ReportModal extends StatefulWidget {
  final double height;
  final String title;
  final String text;

  /// Callback for when thr `confirm` button is pressed. Do not include
  /// `Navigator.pop` here, it is called internally after `onConfirm` resolves.
  final FutureOr<void> Function() onConfirm;

  const ReportModal({
    super.key,
    required this.height,
    required this.onConfirm,
    required this.title,
    required this.text,
  });

  @override
  State<ReportModal> createState() => _ReportModalState();
}

class _ReportModalState extends State<ReportModal> {
  bool _isLoading = false;

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
                  widget.title,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
            ]),
          ),
          Text(
            "Thank you for your contribution!",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 12.0),
          SizedBox(
              width: 110.0,
              height: 110.0,
              child: Image.asset("assets/images/pp_logo.png")),
          SizedBox(height: 12.0),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(
              widget.text,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.normal),
            ),
          ),
          SizedBox(height: 4.0),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 18.0),
            child: LayoutBuilder(
              builder: (context, constraints) => Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    PPButton("Cancel",
                        width: constraints.maxWidth * 0.49,
                        outline: true,
                        onPressed: () => Navigator.pop(context)),
                    PPButton("Confirm",
                        width: constraints.maxWidth * 0.49,
                        isLoading: _isLoading, onPressed: () async {
                      setState(() => _isLoading = true);

                      final BuildContext current = context;
                      try {
                        await widget.onConfirm();
                        setState(() => _isLoading = false);
                      } catch (e) {
                        setState(() => _isLoading = false);
                      }

                      if (current.mounted) {
                        Navigator.pop(current);
                      }
                    }),
                  ]),
            ),
          ),
          const SizedBox(height: 20.0),
        ],
      ),
    );
  }
}
