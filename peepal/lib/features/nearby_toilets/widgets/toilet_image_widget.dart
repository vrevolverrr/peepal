import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:peepal/api/client.dart';
import 'package:peepal/api/images/model/image.dart';

class PPImageWidget extends StatelessWidget {
  final PPImage? image;
  final double? height;
  final double? width;
  final BoxFit? fit;

  const PPImageWidget(
      {super.key, required this.image, this.height, this.width, this.fit});

  @override
  Widget build(BuildContext context) {
    if (image == null) {
      return Container(
        width: width,
        height: height,
        color: Colors.grey[200],
        child: Center(
          child: Icon(
            Icons.wc,
            size: 24.0,
            color: Colors.grey[600],
          ),
        ),
      );
    }

    final loadingWidget = Container(
      width: width,
      height: height,
      color: Colors.grey[200],
    ).animate(
        effects: [ShimmerEffect(duration: 1.seconds)],
        onPlay: (controller) => controller.repeat());

    return FutureBuilder(
      future: PPClient.images.getImageUrl(token: image!.token),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return CachedNetworkImage(
            imageUrl: snapshot.data!,
            placeholder: (context, url) => loadingWidget,
            errorWidget: (context, url, error) => loadingWidget,
            fadeInDuration: 300.ms,
            fadeOutDuration: 300.ms,
            height: height,
            width: width,
            fit: fit ?? BoxFit.cover,
          );
        } else {
          return loadingWidget;
        }
      },
    );
  }
}
