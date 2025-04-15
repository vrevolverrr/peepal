import 'package:flutter/material.dart';
import 'package:peepal/api/toilets/model/route.dart';

class DirectionsList extends StatelessWidget {
  final List<PPRouteDirection> directions;
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
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
              width: double.infinity,
              padding: EdgeInsets.only(left: 12.0, right: 12.0, bottom: 12.0),
              decoration: BoxDecoration(color: Colors.white, boxShadow: [
                BoxShadow(
                    color: Colors.black12,
                    offset: Offset(0.0, 3.0),
                    blurRadius: 2.0)
              ]),
              child: Text(
                'Directions',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              )),
          Expanded(
            child: ListView.builder(
              itemCount: directions.length + (destinationReached ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == directions.length) {
                  return const _DestinationReachedEntry();
                }

                final step = directions[index];
                final bool isCurrentStep = index == currentDirectionIndex;

                return _DirectionListEntry(
                  direction: step,
                  isCurrentStep: isCurrentStep,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _DestinationReachedEntry extends StatelessWidget {
  const _DestinationReachedEntry();

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Colors.green,
        child: Icon(
          Icons.place,
          color: Colors.white,
          size: 20,
        ),
      ),
      title: Text(
        'You have reached your destination',
        style: TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 8,
      ),
      tileColor: Colors.green.withAlpha(25),
    );
  }
}

class _DirectionListEntry extends StatelessWidget {
  final PPRouteDirection direction;
  final bool isCurrentStep;

  const _DirectionListEntry({
    required this.direction,
    required this.isCurrentStep,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: isCurrentStep ? Colors.blue : Colors.blue[100],
        child: Icon(
          _mapInstructionToIcon(direction.instructions),
          color: isCurrentStep
              ? Colors.white
              : const Color.fromARGB(255, 52, 64, 74),
          size: 20,
        ),
      ),
      title: Text(
        direction.instructions,
        style: TextStyle(
          fontWeight: isCurrentStep ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      subtitle: Text(direction.distance),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 8,
      ),
      tileColor: isCurrentStep ? Colors.blue.withAlpha(255) : null,
    );
  }

  IconData _mapInstructionToIcon(String instruction) {
    if (instruction.contains('Take a left') ||
        instruction.contains('Turn left') ||
        instruction.contains('Take a slight left')) {
      return Icons.turn_left;
    } else if (instruction.contains('Take a right') ||
        instruction.contains('Turn right') ||
        instruction.contains('Take a slight right')) {
      return Icons.turn_right;
    } else if (instruction.contains('Destination')) {
      return Icons.place;
    } else {
      return Icons.arrow_forward;
    }
  }
}
