import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:peepal/api/reviews/model/review.dart';
import 'package:peepal/pages/nearby_toilets/widgets/toilet_image_widget.dart';

class ReviewCard extends StatelessWidget {
  final PPReview review;

  const ReviewCard({super.key, required this.review});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFFFFFFFF),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    review.username,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15.0,
                    ),
                  ),
                  Text(
                    DateFormat('yyyy-MM-dd HH:mm').format(review.createdAt),
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6.0),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  review.reviewText,
                  style: const TextStyle(fontSize: 14),
                ),
              ),
              const SizedBox(height: 6.0),
              _buildRating(review.rating),
              const SizedBox(height: 12.0),
              if (review.image != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(12.0),
                  child: PPImageWidget(
                    image: review.image!,
                    width: double.infinity,
                    height: 300.0,
                    fit: BoxFit.cover,
                  ),
                ),
              const SizedBox(height: 8.0),
            ],
          )),
    );
  }

  Widget _buildRating(int rating) {
    return Row(
      children: List.generate(
        5,
        (index) => Icon(
          index < review.rating ? Icons.star : Icons.star_border,
          color: Colors.amber,
          size: 16.0,
        ),
      ),
    );
  }
}
