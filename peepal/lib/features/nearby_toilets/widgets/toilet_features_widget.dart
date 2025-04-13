import 'package:flutter/material.dart';

class ToiletFeatureIcon extends StatelessWidget {
  final bool? hasFeature;
  final IconData? icon;
  final String? image;
  final Color? color;

  const ToiletFeatureIcon(
      {super.key, required this.hasFeature, this.icon, this.image, this.color});

  @override
  Widget build(BuildContext context) {
    assert(icon == null || image == null);

    if (hasFeature == null) {
      return const SizedBox.shrink();
    }

    Color? iconColor;

    if (hasFeature == true) {
      iconColor = const Color(0xFF4C4C4C);
    } else {
      iconColor = const Color(0xFFB8B8B8);
    }

    Widget iconWidget;

    if (icon != null) {
      iconWidget = Icon(icon!, color: iconColor, size: 24.0);
    } else {
      iconWidget = SizedBox(
        width: 24.0,
        height: 24.0,
        child: Image.asset(image!),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 7.0),
      child: iconWidget,
    );
  }
}
