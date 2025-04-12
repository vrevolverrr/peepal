import 'package:flutter/material.dart';
import 'package:peepal/features/toilet_map/model/toilet_location.dart';
import 'package:peepal/features/navigation/view/navigation_page.dart'; // Add this import

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
                const Icon(Icons.location_on, size: 18, color: Color.fromARGB(255, 192, 73, 73)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    location.address,
                    style: const TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
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
                label: const Text(
                  'Navigate',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 255, 255, 255),
                    ),
                  ),
                onPressed: () {
                  // Create a complete ToiletLocation with all properties
                  final navigationDestination = ToiletLocation(
                    id: location.id,
                    name: location.name,
                    address: location.address,
                    latitude: location.latitude,
                    longitude: location.longitude,
                    rating: location.rating,
                    hasAccessibleFacilities: location.hasAccessibleFacilities,
                    hasBidet: location.hasBidet,
                    hasShower: false, // Add default values
                    hasSanitizer: false, // Add default values
                  );
                  
                  // Navigate to navigation page
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => NavigationPage(
                        destination: navigationDestination,
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 52, 64, 74),
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