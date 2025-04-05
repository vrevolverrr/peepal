import 'package:flutter/material.dart';
import 'package:peepal/features/reviews/model/review.dart';
import 'package:peepal/shared/auth/model/user.dart';

class AddReviewBottomSheet extends StatefulWidget {
  final String toiletId;
  final Function(Review) onReviewAdded;

  const AddReviewBottomSheet({
    Key? key,
    required this.toiletId,
    required this.onReviewAdded,
  }) : super(key: key);

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

  void _submitReview() {
    if (_formKey.currentState!.validate()) {
      final newReview = Review(
        user: const PPUser(
          id: "current_user_id", // Replace with the actual logged-in user ID
          name: "Current User", // Replace with the actual logged-in user name
          email: "currentuser@example.com", // Replace with the actual logged-in user email
        ),
        profilePicture: "assets/profile_placeholder.png", // Replace with actual profile picture
        timeAgo: "Just now",
        comment: _commentController.text,
        rating: _rating,
      );

      widget.onReviewAdded(newReview);
      Navigator.pop(context); // Close the bottom sheet
    }
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
                  const Text("Rating", style: TextStyle(fontWeight: FontWeight.bold)),
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
                      onPressed: _submitReview,
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