import 'package:flutter/material.dart';

class DirectionsList extends StatelessWidget {
  final List<Map<String, dynamic>> directions;
  final int currentDirectionIndex;
  final bool destinationReached;

  const DirectionsList({
    super.key,
    required this.directions,
    required this.currentDirectionIndex,
    required this.destinationReached,
  });

  @override
  Widget build(BuildContext context) {
    // Create a list of steps including a possible "destination reached" step
    final List<Map<String, dynamic>> allSteps =
        List<Map<String, dynamic>>.from(directions);

    // Add destination reached step if we've reached the destination
    if (destinationReached) {
      allSteps.add({
        'instructions': 'You have reached your destination',
        'distance': '',
        'is_destination': true,
      });
    }

    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Directions',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: allSteps.length,
              itemBuilder: (context, index) {
                final step = allSteps[index] as Map<String, dynamic>;
                final bool isCurrentStep = index == currentDirectionIndex;
                final bool isDestinationStep = step['is_destination'] == true;

                // Determine icon based on instructions
                IconData icon = Icons.arrow_forward;
                if (step['instructions'].toString().contains('Turn left')) {
                  icon = Icons.turn_left;
                } else if (step['instructions']
                    .toString()
                    .contains('Turn right')) {
                  icon = Icons.turn_right;
                } else if (isDestinationStep ||
                    index == directions.length - 1) {
                  icon = Icons.place;
                }

                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: isDestinationStep
                        ? Colors.green
                        : (isCurrentStep
                            ? Colors.blue
                            : (index == directions.length - 1
                                ? Colors.green
                                : Colors.blue[100])),
                    child: Icon(
                      icon,
                      color: (isCurrentStep || isDestinationStep)
                          ? Colors.white
                          : const Color.fromARGB(255, 52, 64, 74),
                      size: 20,
                    ),
                  ),
                  title: Text(
                    step['instructions'] as String,
                    style: TextStyle(
                      fontWeight: (isCurrentStep || isDestinationStep)
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                  subtitle: step['distance'] != null && step['distance'] != ''
                      ? Text(step['distance'] as String)
                      : null,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  tileColor: isDestinationStep
                      ? Colors.green.withOpacity(0.1)
                      : (isCurrentStep ? Colors.blue.withOpacity(0.1) : null),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
