import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class FavoritesHeartButton extends StatefulWidget {
  final VoidCallback onFavouriteTap;
  final bool isFavorite;

  const FavoritesHeartButton(
      {super.key, required this.onFavouriteTap, required this.isFavorite});

  @override
  State<FavoritesHeartButton> createState() => _FavoritesHeartButtonState();
}

class _FavoritesHeartButtonState extends State<FavoritesHeartButton>
    with TickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    _controller = AnimationController(vsync: this);
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          _controller.forward();
          widget.onFavouriteTap();
        },
        child: Icon(
                widget.isFavorite
                    ? CupertinoIcons.heart_fill
                    : CupertinoIcons.heart,
                size: 28.0,
                color: widget.isFavorite
                    ? CupertinoColors.destructiveRed
                    : Colors.grey)
            .animate(
                controller: _controller,
                autoPlay: false,
                onComplete: (controller) => controller.reverse())
            .scale(
                duration: 120.ms,
                curve: Curves.linear,
                begin: Offset(1.0, 1.0),
                end: Offset(1.2, 1.2)));
  }
}
