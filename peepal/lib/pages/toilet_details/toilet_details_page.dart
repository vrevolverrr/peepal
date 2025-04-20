import 'dart:io';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:peepal/api/client.dart';
import 'package:peepal/api/reviews/model/review.dart';
import 'package:peepal/api/toilets/model/toilet.dart';
import 'package:peepal/pages/favourites/bloc/favorites_bloc.dart';
import 'package:peepal/pages/nearby_toilets/widgets/rating_widget.dart';
import 'package:peepal/pages/nearby_toilets/widgets/toilet_image_widget.dart';
import 'package:peepal/pages/toilet_details/widgets/edit_toilet_modal.dart';
import 'package:peepal/pages/toilet_details/widgets/report_modal.dart';
import 'package:peepal/pages/toilet_details/widgets/review_card.dart';
import 'package:peepal/pages/toilet_details/widgets/add_review_modal.dart';
import 'package:peepal/shared/toilets/toilets_bloc.dart';
import 'package:peepal/shared/widgets/pp_button.dart';

class ToiletDetailsPage extends StatefulWidget {
  final PPToilet toilet;

  const ToiletDetailsPage({super.key, required this.toilet});

  @override
  State<ToiletDetailsPage> createState() => _ToiletDetailsPageState();
}

class _ToiletDetailsPageState extends State<ToiletDetailsPage> {
  late List<PPReview> _reviews;
  final _picker = ImagePicker();

  late final ToiletsBloc toiletsBloc;

  late PPToilet _toilet;

  @override
  void initState() {
    toiletsBloc = context.read<ToiletsBloc>();
    _toilet = widget.toilet;
    // Ensure favorites are loaded
    final favoritesBloc = context.read<FavoritesBloc>();
    if (favoritesBloc.state is! FavoritesStateLoaded) {
      favoritesBloc.add(const FavoritesEventLoad());
    }
    super.initState();
  }

  Future<List<PPReview>> _fetchReviews() async {
    _reviews = await PPClient.reviews.getReviewsByToilet(toilet: _toilet);
    _reviews.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return _reviews;
  }

  Future<void> _handleAddReview() async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20.0),
        ),
      ),
      builder: (context) => AddReviewModal(
        toilet: _toilet,
        height: 650.0,
        onConfirm: (
            {required int rating, required String comment, File? image}) async {
          final PPReview review = await PPClient.reviews.postReview(
            toilet: _toilet,
            rating: rating,
            reviewText: comment,
            image: image,
          );

          setState(() {
            _toilet =
                _toilet.copyWith(rating: (review.rating + _toilet.rating) / 2);
            _reviews.add(review);
          });

          toiletsBloc.add(ToiletEventUpdateToilet(
            toilet: _toilet,
            shouldRemove: false,
          ));
        },
      ),
    );
  }

  Future<void> _handleReportToilet() async {
    final ToiletsBloc toiletsBloc = context.read<ToiletsBloc>();

    final BuildContext current = context;

    await showModalBottomSheet(
        context: context,
        builder: (context) => ReportModal(
            height: 400.0,
            title: 'Report Toilet',
            text: 'Are you sure you want to report the absence of this toilet?',
            onConfirm: () async {
              final bool shouldRemove =
                  await PPClient.toilets.reportToilet(toilet: _toilet);

              toiletsBloc.add(ToiletEventUpdateToilet(
                  toilet: _toilet, shouldRemove: shouldRemove));

              if (!current.mounted) {
                return;
              }

              if (shouldRemove) {
                ScaffoldMessenger.of(current).showSnackBar(
                  const SnackBar(
                    content: Text('Non-existent toilet removed successfully'),
                    duration: Duration(seconds: 2),
                  ),
                );
                Navigator.pop(current);
              } else {
                ScaffoldMessenger.of(current).showSnackBar(
                  const SnackBar(
                    content: Text('Toilet reported successfully'),
                    duration: Duration(seconds: 2),
                  ),
                );
              }
            }));
  }

  Future<void> _handleReportReview(PPReview review) async {
    final BuildContext current = context;

    await showModalBottomSheet(
        context: context,
        builder: (context) => ReportModal(
            height: 400.0,
            title: 'Report Review',
            text:
                'Are you sure you want to report this review for abusive language?',
            onConfirm: () async {
              final bool shouldRemove =
                  await PPClient.reviews.reportReview(review: review);

              if (shouldRemove) {
                setState(() {
                  _reviews.remove(review);
                });
              }

              if (!current.mounted) {
                return;
              }

              ScaffoldMessenger.of(current).showSnackBar(
                SnackBar(
                  content: Text(shouldRemove
                      ? 'Review deleted successfully'
                      : 'Review reported successfully'),
                  duration: Duration(seconds: 2),
                ),
              );
            }));
  }

  Future<void> _handleSuggestChanges() async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20.0),
        ),
      ),
      builder: (context) => EditToiletModal(
        height: 420.0,
        initialEdits: ToiletFeatureEdits(
            handicapAvail: _toilet.handicapAvail ?? false,
            bidetAvail: _toilet.bidetAvail ?? false,
            showerAvail: _toilet.showerAvail ?? false,
            sanitiserAvail: _toilet.sanitiserAvail ?? false),
        onConfirm: (edits) async {
          final PPToilet updatedToilet = await PPClient.toilets.updateToilet(
              toilet: _toilet,
              name: _toilet.name,
              address: _toilet.address,
              location: _toilet.location,
              handicapAvail: edits.handicapAvail,
              bidetAvail: edits.bidetAvail,
              showerAvail: edits.showerAvail,
              sanitiserAvail: edits.sanitiserAvail);

          final updatedToiletWithDistance =
              updatedToilet.copyWith(distance: _toilet.distance);
          setState(() {
            _toilet = updatedToiletWithDistance;
          });

          toiletsBloc.add(ToiletEventUpdateToilet(
            toilet: updatedToiletWithDistance,
            shouldRemove: false,
          ));
        },
      ),
    );
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
            expandedHeight: 350.0,
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
                child: BlocBuilder<FavoritesBloc, FavoritesState>(
                  builder: (context, state) {
                    final bool isFavorite =
                        state.favoriteIds.contains(_toilet.id);

                    return IconButton(
                      style: ButtonStyle(
                        iconColor: WidgetStateProperty.all(Colors.black),
                        backgroundColor:
                            WidgetStateProperty.all(const Color(0xFFDADADA)),
                      ),
                      icon: isFavorite
                          ? const Icon(
                              CupertinoIcons.heart_solid,
                              size: 22.0,
                              color: CupertinoColors.systemRed,
                            )
                          : const Icon(CupertinoIcons.heart, size: 22.0),
                      onPressed: () async {
                        context
                            .read<FavoritesBloc>()
                            .add(FavoritesEventToggle(_toilet));
                      },
                    );
                  },
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
                    child: _toilet.image == null
                        ? GestureDetector(
                            onTap: () async {
                              try {
                                final XFile? image = await _picker.pickImage(
                                  source: ImageSource.gallery,
                                  maxWidth: 1200,
                                  maxHeight: 1200,
                                  imageQuality: 85,
                                );

                                if (image != null && mounted) {
                                  final updatedToilet = await PPClient.toilets
                                      .updateToiletImage(
                                          toilet: _toilet,
                                          image: File(image.path));

                                  setState(() {
                                    _toilet = updatedToilet;
                                  });

                                  toiletsBloc.add(ToiletEventUpdateToilet(
                                    toilet: updatedToilet,
                                    shouldRemove: false,
                                  ));
                                }
                              } catch (e) {
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Failed to update image'),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              }
                            },
                            child: Container(
                              width: double.infinity,
                              height: 280.0,
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                              ),
                              child: const Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.add_photo_alternate,
                                    size: 48,
                                    color: Colors.grey,
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'Add Photo',
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : PPImageWidget(
                            image: _toilet.image,
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
                      ConstrainedBox(
                        constraints: BoxConstraints(
                            maxWidth: MediaQuery.sizeOf(context).width - 110.0),
                        child: AutoSizeText(
                          _toilet.name,
                          style: const TextStyle(
                            fontSize: 23.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Transform.translate(
                          offset: Offset(-4.0, -3.0),
                          child: RatingWidget(rating: _toilet.rating))
                    ],
                  ),
                  SizedBox(height: 5.0),
                  Padding(
                    padding: EdgeInsets.only(left: 2.0),
                    child: Text(
                      _toilet.address,
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
                  _ToiletFeatures(toilet: _toilet),
                  const SizedBox(height: 16.0),
                  PPButton("Suggest Changes", onPressed: _handleSuggestChanges),
                  const SizedBox(height: 16.0),
                  Center(
                    child: GestureDetector(
                      onTap: () => _handleReportToilet(),
                      child: Text("Report Non-Existent Toilet",
                          style: TextStyle(
                              color: Colors.grey,
                              fontWeight: FontWeight.bold,
                              fontSize: 14.0)),
                    ),
                  ),
                  SizedBox(height: 22.0),
                  FutureBuilder(
                    future: _fetchReviews(),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Failed to load reviews'),
                            duration: Duration(seconds: 2),
                          ),
                        );

                        return Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.close,
                              size: 80.0,
                              color: Colors.grey.shade300,
                            ),
                            SizedBox(height: 8.0),
                            Text("Error fetching reviews",
                                style: TextStyle(
                                    fontSize: 14.0,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey.shade700)),
                          ],
                        );
                      }

                      if (!snapshot.hasData) {
                        return const CircularProgressIndicator();
                      }

                      return _ToiletReviews(
                        reviews: snapshot.data!,
                        onReport: _handleReportReview,
                      );
                    },
                  ),
                  SizedBox(height: 80.0)
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _handleAddReview(),
        tooltip: "Add Review",
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
        child: const Icon(Icons.reviews_rounded),
      ),
    );
  }
}

class _ToiletReviews extends StatelessWidget {
  final List<PPReview> reviews;
  final void Function(PPReview review) onReport;
  const _ToiletReviews({required this.reviews, required this.onReport});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 8.0, bottom: 5.0),
          child: Text("${reviews.length} reviews",
              style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold)),
        ),
        ...reviews.map((review) => Padding(
              padding: const EdgeInsets.only(bottom: 5.0),
              child:
                  ReviewCard(review: review, onReport: () => onReport(review)),
            ))
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
