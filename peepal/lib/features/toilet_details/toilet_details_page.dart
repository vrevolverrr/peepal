import 'package:flutter/material.dart';
import 'package:peepal/api/client.dart';
import 'package:peepal/api/reviews/model/review.dart';
import 'package:peepal/api/toilets/model/toilet.dart';
import 'package:peepal/features/nearby_toilets/widgets/rating_widget.dart';
import 'package:peepal/features/nearby_toilets/widgets/toilet_image_widget.dart';
import 'package:peepal/features/toilet_details/widgets/review_card.dart';
import 'package:peepal/features/toilet_details/widgets/add_review_bottom_sheet.dart';

class ToiletDetailsPage extends StatefulWidget {
  final PPToilet toilet;

  const ToiletDetailsPage({super.key, required this.toilet});

  @override
  State<ToiletDetailsPage> createState() => _ToiletDetailsPageState();
}

class _ToiletDetailsPageState extends State<ToiletDetailsPage> {
  late Future<List<PPReview>> _reviewsFuture;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: <Widget>[
          SliverAppBar(
            stretch: true,
            expandedHeight: 280.0,
            leading: IconButton(
              style: ButtonStyle(
                iconColor: WidgetStateProperty.all(Colors.black),
                backgroundColor:
                    WidgetStateProperty.all(const Color(0xFFDADADA)),
              ),
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: IconButton(
                  style: ButtonStyle(
                    iconColor: WidgetStateProperty.all(Colors.black),
                    backgroundColor:
                        WidgetStateProperty.all(const Color(0xFFDADADA)),
                  ),
                  icon: const Icon(Icons.favorite_outline, size: 22.0),
                  onPressed: () {},
                ),
              ),
            ],
            flexibleSpace: Stack(
              children: [
                Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: PPImageWidget(
                      image: widget.toilet.image,
                      width: double.infinity,
                      height: 280.0,
                      fit: BoxFit.cover,
                    )),
                Positioned(
                  bottom: -1,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 20.0,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 10.0,
                          spreadRadius: 5.0,
                          offset: const Offset(0, -4.0),
                        ),
                      ],
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(60.0),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 18.0),
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        widget.toilet.name,
                        style: const TextStyle(
                          fontSize: 23.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Transform.translate(
                          offset: Offset(-4.0, -3.0),
                          child: RatingWidget(rating: widget.toilet.rating))
                    ],
                  ),
                  SizedBox(height: 5.0),
                  Padding(
                    padding: EdgeInsets.only(left: 2.0),
                    child: Text(
                      widget.toilet.address,
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 13.0,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  const Text("Toilet Features",
                      style: TextStyle(
                          fontSize: 18.0, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4.0),
                  _ToiletFeatures(toilet: widget.toilet),
                  SizedBox(height: 18.0),
                  _ToiletReviews(toilet: widget.toilet)
                ],
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
                final currentReviews =
                    await _reviewsFuture; // Resolve the Future
                setState(() {
                  _reviewsFuture = Future.value(
                      [...currentReviews, newReview]); // Append the new review
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
}

class _ToiletReviews extends StatelessWidget {
  final PPToilet toilet;
  const _ToiletReviews({required this.toilet});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        FutureBuilder(
          future: PPClient.reviews.getReviewsByToilet(toilet: toilet),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const CircularProgressIndicator();
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.only(left: 8.0, bottom: 5.0),
                  child: Text("${snapshot.data!.length} reviews",
                      style: TextStyle(
                          fontSize: 20.0, fontWeight: FontWeight.bold)),
                ),
                ...snapshot.data!.map((review) => Padding(
                      padding: const EdgeInsets.only(bottom: 5.0),
                      child: ReviewCard(review: review),
                    ))
              ],
            );
          },
        ),
      ],
    );
  }
}

class _ToiletFeatures extends StatelessWidget {
  final PPToilet toilet;
  const _ToiletFeatures({required this.toilet});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildFeatureRow(
          icon: Icons.accessible,
          text: "Handicap access",
          available: toilet.handicapAvail,
        ),
        _buildFeatureRow(
          icon: Icons.wash,
          text: "Bidet",
          available: toilet.bidetAvail,
        ),
        _buildFeatureRow(
          icon: Icons.shower,
          text: "Shower",
          available: toilet.showerAvail,
        ),
        _buildFeatureRow(
          icon: Icons.wash,
          text: "Sanitizer",
          available: toilet.sanitiserAvail,
        ),
      ],
    );
  }

  Widget _buildFeatureRow(
      {required IconData icon,
      required String text,
      required bool? available}) {
    Color color;
    String caption;

    if (available == null) {
      color = Colors.grey;
      caption = "$text availability unknown";
    } else if (available) {
      color = const Color.fromARGB(255, 56, 132, 59);
      caption = "$text is available";
    } else {
      color = Colors.grey;
      caption = "$text is unavailable";
    }

    return Padding(
      padding: EdgeInsets.only(bottom: 6.0),
      child: Row(
        children: [
          Icon(
            icon,
            color: color,
            size: 18.0,
          ),
          const SizedBox(width: 8.0),
          Text(
            caption,
            style: TextStyle(
              fontSize: 14.0,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
