import 'package:flutter/material.dart';
import 'package:peepal/api/reviews/model/review.dart';

class AddReviewBottomSheet extends StatefulWidget {
  final String toiletId;
  final Function(PPReview review) onReviewAdded;

  const AddReviewBottomSheet({
    super.key,
    required this.toiletId,
    required this.onReviewAdded,
  });

  @override
  _AddReviewBottomSheetState createState() => _AddReviewBottomSheetState();
}

class _AddReviewBottomSheetState extends State<AddReviewBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _commentController = TextEditingController();
  double _rating = 0.0;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Add a Review",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _commentController,
                    decoration: const InputDecoration(
                      labelText: "Your Comment",
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Please enter a comment.";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  const Text("Rating",
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  Slider(
                    value: _rating,
                    onChanged: (value) {
                      setState(() {
                        _rating = value;
                      });
                    },
                    min: 0,
                    max: 5,
                    divisions: 5,
                    label: _rating.toStringAsFixed(1),
                  ),
                  const SizedBox(height: 24),
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton(
                      onPressed: () => {},
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(120, 48),
                      ),
                      child: const Text("Submit"),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
