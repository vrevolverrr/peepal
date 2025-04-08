import 'package:flutter/material.dart';
import 'package:peepal/features/toilet_map/model/toilet_location.dart';

class ToiletLocationCard extends StatelessWidget {
  final ToiletLocation location;
  final VoidCallback onClose;
  final VoidCallback? onDirections;

  const ToiletLocationCard({
    required this.location,
    required this.onClose,
    this.onDirections,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with name and close button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    location.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: onClose,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                )
              ],
            ),
            const SizedBox(height: 8),
            
            // Address
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.location_on, size: 18, color: Colors.grey),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    location.address,
                    style: const TextStyle(color: Colors.grey),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            // Rating
            if (location.rating != null)
              Row(
                children: [
                  const Icon(Icons.star, color: Colors.amber, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    '${location.rating}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            const SizedBox(height: 12),
            
            // Features
            if (location.hasAccessibleFacilities != null)
              Row(
                children: [
                  Icon(
                    Icons.accessible,
                    color: location.hasAccessibleFacilities! 
                        ? const Color.fromARGB(255, 56, 132, 59) 
                        : Colors.grey,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    location.hasAccessibleFacilities! 
                        ? 'OKU friendly' 
                        : 'Non OKU friendly',
                    style: TextStyle(
                      color: location.hasAccessibleFacilities! 
                          ? const Color.fromARGB(255, 56, 132, 59)  
                          : Colors.grey,
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 12),

            // Add bidet information
            if (location.hasBidet != null)
              Row(
                children: [
                  Icon(
                    Icons.wash, // Using wash icon for bidet
                    color: location.hasBidet! 
                        ? const Color.fromARGB(255, 56, 132, 59) 
                        : Colors.grey,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    location.hasBidet! 
                        ? 'Bidet available' 
                        : 'Bidet unavailable',
                    style: TextStyle(
                      color: location.hasBidet! 
                          ? const Color.fromARGB(255, 56, 132, 59) 
                          : Colors.grey,
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 16),
            
            // Directions button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.directions),
                label: const Text('Directions'),
                onPressed: onDirections,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}