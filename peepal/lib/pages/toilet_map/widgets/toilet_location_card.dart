import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:peepal/api/toilets/model/toilet.dart';
import 'package:peepal/pages/nearby_toilets/widgets/rating_widget.dart';
import 'package:peepal/pages/toilet_map/bloc/toilet_map_bloc.dart';
import 'package:peepal/shared/widgets/pp_button.dart';

class ToiletLocationCard extends StatelessWidget {
  final PPToilet toilet;
  final VoidCallback onClose;
  final VoidCallback? onDirections;

  const ToiletLocationCard({
    required this.toilet,
    required this.onClose,
    this.onDirections,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16.0),
      elevation: 8.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: 230.0),
                  child: AutoSizeText(
                    toilet.name,
                    maxLines: 2,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20.0,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const Spacer(),
                Transform.translate(
                    offset: const Offset(-2.0, -3.0),
                    child: RatingWidget(
                        rating: toilet.rating,
                        iconSize: 18.0,
                        fontSize: 16.0,
                        spacing: 3.0,
                        offset: const Offset(0.0, 1.5))),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: onClose,
                  padding: EdgeInsets.only(left: 8.0, bottom: 8.0),
                  iconSize: 26.0,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: 4.0),
            // Address
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.location_on,
                    size: 18, color: Color.fromARGB(255, 192, 73, 73)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    toilet.address,
                    style: const TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8.0),

            if (toilet.bidetAvail != null)
              Row(
                children: [
                  SizedBox(
                    width: 18.0,
                    height: 18.0,
                    child: Image.asset(
                      'assets/images/icons-bidet.png',
                      color: toilet.bidetAvail!
                          ? const Color(0xFF38843B)
                          : Colors.grey,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    toilet.bidetAvail!
                        ? 'Bidet available'
                        : 'Bidet unavailable',
                    style: TextStyle(
                      color: toilet.bidetAvail!
                          ? const Color(0xFF38843B)
                          : Colors.grey,
                    ),
                  ),
                ],
              ),
            if (toilet.handicapAvail != null) const SizedBox(height: 5.0),
            if (toilet.handicapAvail != null)
              Row(
                children: [
                  Icon(
                    Icons.accessible,
                    color: toilet.handicapAvail!
                        ? const Color.fromARGB(255, 56, 132, 59)
                        : Colors.grey,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    toilet.handicapAvail! ? 'OKU friendly' : 'Non OKU friendly',
                    style: TextStyle(
                      color: toilet.handicapAvail!
                          ? const Color.fromARGB(255, 56, 132, 59)
                          : Colors.grey,
                    ),
                  ),
                ],
              ),
            if (toilet.sanitiserAvail != null) const SizedBox(height: 5.0),
            if (toilet.sanitiserAvail != null)
              Row(
                children: [
                  Icon(
                    Icons.wash,
                    color: toilet.sanitiserAvail!
                        ? const Color.fromARGB(255, 56, 132, 59)
                        : Colors.grey,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    toilet.sanitiserAvail!
                        ? 'Sanitiser available'
                        : 'Sanitiser unavailable',
                    style: TextStyle(
                      color: toilet.sanitiserAvail!
                          ? const Color.fromARGB(255, 56, 132, 59)
                          : Colors.grey,
                    ),
                  ),
                ],
              ),
            if (toilet.showerAvail != null) const SizedBox(height: 5.0),
            if (toilet.showerAvail != null)
              Row(
                children: [
                  Icon(
                    Icons.shower,
                    color: toilet.showerAvail!
                        ? const Color.fromARGB(255, 56, 132, 59)
                        : Colors.grey,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    toilet.showerAvail!
                        ? 'Shower available'
                        : 'Shower unavailable',
                    style: TextStyle(
                      color: toilet.showerAvail!
                          ? const Color.fromARGB(255, 56, 132, 59)
                          : Colors.grey,
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 16.0),
            BlocBuilder<ToiletMapCubit, ToiletMapState>(
              builder: (context, state) {
                if (state.activeRoute == null || state.isCalculating) {
                  return PPButton(
                    'Navigate',
                    onPressed: onDirections,
                    isLoading: true,
                  );
                }
                return PPButton('Navigate (${state.activeRoute!.duration})',
                    onPressed: onDirections);
              },
            ),
          ],
        ),
      ),
    );
  }
}
