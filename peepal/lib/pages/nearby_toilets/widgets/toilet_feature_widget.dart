import 'package:flutter/material.dart';
import 'package:peepal/pages/nearby_toilets/widgets/toilet_features_widget.dart';

class ToiletFeatureWidget extends StatelessWidget {
  final bool? hasBidet;
  final bool? hasOku;
  final bool? hasShower;
  final bool? hasSanitizer;

  const ToiletFeatureWidget({
    super.key,
    this.hasBidet,
    this.hasOku,
    this.hasShower,
    this.hasSanitizer,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      runAlignment: WrapAlignment.start,
      children: [
        ToiletFeatureIcon(
          hasFeature: hasBidet,
          image: "assets/images/icons-bidet.png",
          color: Colors.black,
        ),
        ToiletFeatureIcon(
          hasFeature: hasOku,
          icon: Icons.accessible,
          color: Colors.black,
        ),
        ToiletFeatureIcon(
          hasFeature: hasSanitizer,
          icon: Icons.sanitizer,
          color: Colors.black,
        ),
        ToiletFeatureIcon(
          hasFeature: hasShower,
          icon: Icons.shower,
          color: Colors.black,
        ),
      ],
    );
  }
}
