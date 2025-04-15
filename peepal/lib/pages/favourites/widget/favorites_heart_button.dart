import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:peepal/api/toilets/model/toilet.dart';
import 'package:peepal/pages/favourites/bloc/favorites_bloc.dart';

class FavoritesHeartButton extends StatefulWidget {
  final PPToilet toilet;

  const FavoritesHeartButton({super.key, required this.toilet});

  @override
  State<FavoritesHeartButton> createState() => _FavoritesHeartButtonState();
}

class _FavoritesHeartButtonState extends State<FavoritesHeartButton>
    with TickerProviderStateMixin {
  late final AnimationController _controller;
  late final FavoritesCubit cubit;

  @override
  void initState() {
    cubit = context.read<FavoritesCubit>();
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
    final bool isFavorite = cubit.getIsFavorite(widget.toilet);

    return GestureDetector(
        onTap: () {
          _controller.forward();

          if (isFavorite) {
            cubit.removeFavorite(widget.toilet);
          } else {
            cubit.addFavorite(widget.toilet);
          }
        },
        child: Icon(
                isFavorite ? CupertinoIcons.heart_fill : CupertinoIcons.heart,
                size: 28.0,
                color:
                    isFavorite ? CupertinoColors.destructiveRed : Colors.grey)
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
