import 'package:flutter/material.dart';
import 'package:peepal/shared/toilet/model/toilet.dart';
import 'package:peepal/shared/toilet/model/toilet_crowd_level.dart';
import 'package:peepal/features/reviews/model/review.dart';
import 'package:peepal/features/reviews/widget/review_card.dart';
import 'package:peepal/features/reviews/repository/review_repository_implementation.dart';
import 'package:peepal/features/reviews/widget/add_review_bottom_sheet.dart';

class ToiletPage extends StatefulWidget {
  final PPToilet toilet;

  const ToiletPage({Key? key, required this.toilet}) : super(key: key);

  @override
  _ToiletPageState createState() => _ToiletPageState();
}

class _ToiletPageState extends State<ToiletPage> {
  late Future<List<Review>> _reviewsFuture;

@override
  void initState() {
    super.initState();
    final reviewRepository = ReviewRepositoryImpl();
    _reviewsFuture = reviewRepository.fetchReviewsByToiletId(widget.toilet.id.toString());
  }

 @override
  Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: const Color(0xFFE5F0FF),
    appBar: AppBar(
      title: Text(widget.toilet.name),
      elevation: 0,
      backgroundColor: const Color(0xFFE5F0FF),
    ),
    body: Column(
      children: [
        // Top image
        Image.asset(
          'assets/images/toilet.jpeg',
          width: double.infinity,
          height: 240,
          fit: BoxFit.cover,
        ),

        // Bottom sheet-like content
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
            ),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name and Rating
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.toilet.name,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              widget.toilet.address,
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber),
                          const SizedBox(width: 4),
                          Text(
                            widget.toilet.rating.toStringAsFixed(1),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Toilet Crowd
                  Row(
                      children: [
                        const Text("Toilet Crowd", style: TextStyle(fontWeight: FontWeight.w600)),
                        const SizedBox(width: 16),
                        Text(
                          _getCrowdStatusText(widget.toilet.crowdStatus.crowdLevel),
                          style: TextStyle(
                            color: _getCrowdStatusColor(widget.toilet.crowdStatus.crowdLevel),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 6),
                        CircleAvatar(
                          radius: 4,
                          backgroundColor: _getCrowdStatusColor(widget.toilet.crowdStatus.crowdLevel),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                  // Toilet Features
                  const Text("Toilet Features", style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 16,
                    runSpacing: 8,
                    children: [
                      if (widget.toilet.features.hasBidet)
                        const Text("✓  Bidet available", style: TextStyle(fontWeight: FontWeight.w500)),
                      if (widget.toilet.features.hasAccessibility)
                        const Text("✓  OKU friendly", style: TextStyle(fontWeight: FontWeight.w500)),
                      if (widget.toilet.features.hasShower)
                        const Text("✓  Shower", style: TextStyle(fontWeight: FontWeight.w500)),
                      if (widget.toilet.features.hasSanitizer)
                        const Text("✓  Sanitizer", style: TextStyle(fontWeight: FontWeight.w500)),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Review Section
                  const Text("Reviews", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(
                    "2 Reviews", // Replace with actual review count if available
                    style: TextStyle(color: Colors.grey[600]),
                  ),

                  const SizedBox(height: 12),

                  FutureBuilder<List<Review>>(
                    future: _reviewsFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const CircularProgressIndicator();
                      } else if (snapshot.hasError) {
                        return Text("Error: ${snapshot.error}");
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Text("No reviews available.");
                      } else {
                        final reviews = snapshot.data!;
                        return Column(
                          children: reviews
                              .map((review) => Padding(
                                    padding: const EdgeInsets.only(bottom: 16.0),
                                    child: ReviewCard(review: review),
                                  ))
                              .toList(),
                        );
                      }
                    },
                  ),
                  
                ],
              ),
            ),
          ),
        ),
      ],
    ),
   floatingActionButton: FloatingActionButton(
      onPressed: () {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          builder: (context) => AddReviewBottomSheet(
            toiletId: widget.toilet.id.toString(),
            onReviewAdded: (newReview) async {
              final currentReviews = await _reviewsFuture; // Resolve the Future
              setState(() {
                _reviewsFuture = Future.value([...currentReviews, newReview]); // Append the new review
              });
            },
          ),
        );
      },
      tooltip: "Add Review",
      child: const Icon(Icons.add),
    ),
  );
}

  // Helper method to get crowd status text
  String _getCrowdStatusText(PPToiletCrowdLevel crowdLevel) {
    switch (crowdLevel) {
      case PPToiletCrowdLevel.empty:
        return 'Empty';
      case PPToiletCrowdLevel.moderate:
        return 'Moderate';
      case PPToiletCrowdLevel.crowded:
        return 'Crowded';
      default:
        return 'Unknown';
    }
  }

    // Helper method to get crowd status color
  Color _getCrowdStatusColor(PPToiletCrowdLevel crowdLevel) {
    switch (crowdLevel) {
      case PPToiletCrowdLevel.empty:
        return Colors.green;
      case PPToiletCrowdLevel.moderate:
        return Colors.orange;
      case PPToiletCrowdLevel.crowded:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}

