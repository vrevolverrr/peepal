import 'package:flutter/material.dart';
import 'package:peepal/shared/toilet/model/toilet.dart';
import 'package:peepal/shared/toilet/model/toilet_crowd_level.dart';

class ToiletCard extends StatelessWidget {
  final PPToilet toilet;

  const ToiletCard({required this.toilet, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Toilet Name and Like Count
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  toilet.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                Row(
                  children: [
                    const Icon(Icons.favorite, color: Colors.red),
                    const SizedBox(width: 4),
                    Text(
                      '123', // Replace with actual like count if available
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Address
            Text(
              toilet.address,
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),

            // Features: Bidet, Shower, Sanitizer, Accessibility
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildFeatureIcon(
                  icon: Icons.wash,
                  label: 'Bidet',
                  isAvailable: toilet.features.hasBidet,
                ),
                _buildFeatureIcon(
                  icon: Icons.shower,
                  label: 'Shower',
                  isAvailable: toilet.features.hasShower,
                ),
                _buildFeatureIcon(
                  icon: Icons.clean_hands,
                  label: 'Sanitizer',
                  isAvailable: toilet.features.hasSanitizer,
                ),
                _buildFeatureIcon(
                  icon: Icons.accessible,
                  label: 'Accessible',
                  isAvailable: toilet.features.hasAccessibility,
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Crowd Status
            Row(
              children: [
                const Icon(Icons.people, color: Colors.blue),
                const SizedBox(width: 8),
                Text(
                  _getCrowdStatusText(toilet.crowdStatus.crowdLevel),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to build feature icons
  Widget _buildFeatureIcon({
    required IconData icon,
    required String label,
    required bool isAvailable,
  }) {
    return Column(
      children: [
        Icon(
          icon,
          color: isAvailable ? Colors.green : Colors.grey,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isAvailable ? Colors.black : Colors.grey,
          ),
        ),
      ],
    );
  }

  // Helper method to get crowd status text
  String _getCrowdStatusText(PPToiletCrowdLevel crowdLevel) {
    switch (crowdLevel) {
      case PPToiletCrowdLevel.empty:
        return 'Empty';
      case PPToiletCrowdLevel.moderate:
        return 'Moderate';
      case PPToiletCrowdLevel.crowded:
        return 'Crowded';
      default:
        return 'Unknown';
    }
  }
}