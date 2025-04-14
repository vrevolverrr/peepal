import 'package:flutter/material.dart';

class RatingWidget extends StatelessWidget {
  final double rating;
  final double? fontSize;
  final double? iconSize;
  final double? spacing;
  final Offset? offset;

  const RatingWidget(
      {super.key,
      required this.rating,
      this.fontSize,
      this.iconSize,
      this.spacing,
      this.offset});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(Icons.star, size: iconSize, color: Color(0xFFffc106)),
        SizedBox(
          width: spacing ?? 3.8,
        ),
        Transform.translate(
          offset: offset ?? const Offset(0.0, 3.0),
          child: Text(
            rating.toString(),
            style: TextStyle(
                fontSize: fontSize ?? 18.0, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}
