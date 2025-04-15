import 'dart:async';

import 'package:flutter/material.dart';
import 'package:peepal/api/toilets/model/toilet.dart';
import 'package:peepal/shared/widgets/pp_button.dart';

class AddReviewModal extends StatefulWidget {
  final PPToilet toilet;
  final double height;
  final FutureOr<void> Function({required int rating, required String comment})
      onConfirm;

  const AddReviewModal({
    super.key,
    required this.toilet,
    required this.height,
    required this.onConfirm,
  });

  @override
  State<AddReviewModal> createState() => _AddReviewModalState();
}

class _AddReviewModalState extends State<AddReviewModal> {
  final _commentController = TextEditingController();

  int _selectedRating = 3;
  bool _isLoading = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
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
                  'Add Review',
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
          SizedBox(height: 4.0),
          _buildRating(),
          const SizedBox(height: 10.0),
          _buildComment(),
          const SizedBox(height: 8.0),
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
                        await widget.onConfirm(
                          rating: _selectedRating,
                          comment: _commentController.text,
                        );
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

  Widget _buildRating() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        return IconButton(
          icon: Icon(
            index < _selectedRating
                ? Icons.star
                : index + 0.5 == _selectedRating
                    ? Icons.star_half
                    : Icons.star_border,
            color: Colors.amber,
            size: 32.0,
          ),
          onPressed: () => setState(() => _selectedRating = index + 1),
        );
      }),
    );
  }

  Widget _buildComment() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Comment',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8.0),
        TextField(
          maxLines: 3,
          controller: _commentController,
          onTapOutside: (_) => FocusScope.of(context).unfocus(),
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
          ),
        ),
      ],
    );
  }
}
