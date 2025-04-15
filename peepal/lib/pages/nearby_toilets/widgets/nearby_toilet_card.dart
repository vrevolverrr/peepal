import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:peepal/api/toilets/model/toilet.dart';
import 'package:peepal/pages/nearby_toilets/widgets/rating_widget.dart';
import 'package:peepal/pages/nearby_toilets/widgets/toilet_feature_widget.dart';
import 'package:peepal/pages/nearby_toilets/widgets/toilet_image_widget.dart';
import 'package:peepal/shared/toilets/toilets_bloc.dart';
import 'package:peepal/shared/widgets/pp_button.dart';

class NearbyToiletCard extends StatelessWidget {
  final PPToilet toilet;
  final void Function()? onNavigate;

  final double height = 480.0;

  const NearbyToiletCard({
    super.key,
    required this.toilet,
    this.onNavigate,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: Card(
        elevation: 4.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(16)),
              child: PPImageWidget(
                image: toilet.image,
                height: height * 0.5,
                width: double.infinity,
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 18.0, vertical: 13.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ConstrainedBox(
                          constraints: BoxConstraints(maxWidth: 240.0),
                          child: AutoSizeText(
                            toilet.name,
                            style: const TextStyle(
                                fontSize: 22.0, fontWeight: FontWeight.bold),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        RatingWidget(rating: toilet.rating),
                      ],
                    ),
                    SizedBox(height: 5.0),
                    Text(
                      toilet.address,
                      maxLines: 2,
                      style: TextStyle(
                          height: 1.6,
                          color: const Color(0xFF2D2D2D),
                          fontSize: 14.0),
                    ),
                    SizedBox(height: 12.0),
                    BlocBuilder<ToiletsBloc, ToiletsState>(
                      builder: (context, state) {
                        final PPToilet updatedToilet =
                            state.toilets.firstWhere((t) => t.id == toilet.id);

                        return ToiletFeatureWidget(
                          hasBidet: updatedToilet.bidetAvail,
                          hasOku: updatedToilet.handicapAvail,
                          hasShower: updatedToilet.showerAvail,
                          hasSanitizer: updatedToilet.sanitiserAvail,
                        );
                      },
                    ),
                    const Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        _ToiletDistanceWidget(distance: toilet.distance!),
                        SizedBox(
                          width: 140.0,
                          height: 45.0,
                          child: PPButton("Navigate", onPressed: onNavigate),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ToiletDistanceWidget extends StatelessWidget {
  final int distance;

  const _ToiletDistanceWidget({
    required this.distance,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Transform.translate(
            offset: const Offset(0.0, 2.0),
            child: Icon(Icons.directions_walk, size: 26.0)),
        SizedBox(width: 2.0),
        Text(
          "${distance}m",
          style: const TextStyle(
            fontSize: 25.0,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
