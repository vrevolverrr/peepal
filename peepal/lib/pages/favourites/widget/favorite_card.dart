import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:peepal/api/toilets/model/toilet.dart';
import 'package:peepal/pages/favourites/widget/favorites_heart_button.dart';
import 'package:peepal/pages/nearby_toilets/widgets/rating_widget.dart';
import 'package:peepal/pages/nearby_toilets/widgets/toilet_feature_widget.dart';
import 'package:peepal/pages/nearby_toilets/widgets/toilet_image_widget.dart';

class FavoriteCard extends StatelessWidget {
  final PPToilet toilet;
  final bool isFavorite;
  final VoidCallback onFavouriteTap;
  final VoidCallback onTap;

  const FavoriteCard({
    required this.toilet,
    required this.onFavouriteTap,
    required this.isFavorite,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        decoration: BoxDecoration(
          color: CupertinoColors.systemBackground,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: CupertinoColors.systemGrey.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Toilet Image
            Stack(
              children: [
                SizedBox(
                  height: 150.0,
                  width: double.infinity,
                  child: ClipRRect(
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(12)),
                    child: PPImageWidget(
                      image: toilet.image,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Positioned(
                  right: 12.0,
                  top: 12.0,
                  child: FavoritesHeartButton(
                    onFavouriteTap: onFavouriteTap,
                    isFavorite: isFavorite,
                  ),
                ),
              ],
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: 270.0),
                        child: Text(
                          toilet.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20.0,
                          ),
                        ),
                      ),
                      RatingWidget(rating: toilet.rating),
                    ],
                  ),
                  const SizedBox(height: 4.0),
                  Text(
                    toilet.address,
                    style: const TextStyle(color: Colors.grey, height: 1.7),
                  ),
                  const SizedBox(height: 12.0),
                  Padding(
                    padding: const EdgeInsets.only(left: 2.0),
                    child: Text(
                      "Features",
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16.0),
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  ToiletFeatureWidget(
                    hasBidet: toilet.bidetAvail,
                    hasOku: toilet.handicapAvail,
                    hasShower: toilet.showerAvail,
                    hasSanitizer: toilet.sanitiserAvail,
                  ),
                  const SizedBox(height: 8.0),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
