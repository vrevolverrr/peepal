import 'package:flutter/material.dart';

class NearbyToiletCard extends StatelessWidget {
  final String address;
  final double rating;
  final String distance;
  final bool highVacancy;
  final bool bidetAvailable;
  final bool okuFriendly;
  final bool hasShower; // Add shower property
  final bool hasSanitizer; // Add sanitizer property
  final double height;

  const NearbyToiletCard({
    Key? key,
    required this.address,
    required this.rating,
    required this.distance,
    required this.highVacancy,
    required this.bidetAvailable,
    required this.okuFriendly,
    this.hasShower = false, // Initialize with default value
    this.hasSanitizer = false, // Initialize with default value
    this.height = 400,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: Image.asset(
                'assets/images/toilet.jpeg',
                height: height * 0.55,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            address,
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Row(
                          children: [
                            const Icon(Icons.star, color: Color.fromARGB(255, 244, 223, 34)),
                            Text(
                              rating.toString(),
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 16.0,
                      runSpacing: 8.0,
                      children: [
                        if (highVacancy)
                          _buildFeatureRow(Icons.circle, 'High Vacancy', Colors.green),
                        if (bidetAvailable)
                          _buildFeatureRow(Icons.wash, 'Bidet', Colors.black),
                        if (okuFriendly)
                          _buildFeatureRow(Icons.accessible, 'OKU friendly', Colors.black),
                        if (hasShower)
                          _buildFeatureRow(Icons.shower, 'Shower', Colors.black),
                        if (hasSanitizer)
                          _buildFeatureRow(Icons.clean_hands, 'Sanitizer', Colors.black),
                      ],
                    ),
                    const Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(distance, style: const TextStyle(fontSize: 20)),
                        ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color.fromARGB(255, 91, 100, 134),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: const Text(
                            'Navigate',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color.fromARGB(255, 225, 222, 222),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  // Helper method to create feature rows
  Widget _buildFeatureRow(IconData icon, String text, Color iconColor) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: iconColor, size: 12),
        const SizedBox(width: 4),
        Text(text, style: const TextStyle(fontSize: 16)),
      ],
    );
  }
}