import 'package:flutter/material.dart';
import 'package:peepal/features/toilet_map/model/toilet_location.dart';

class NavigationPage extends StatefulWidget {
  final ToiletLocation destination;
  
  const NavigationPage({
    Key? key,
    required this.destination,
  }) : super(key: key);

  @override
  State<NavigationPage> createState() => _NavigationPageState();
}

class _NavigationPageState extends State<NavigationPage> {
  // Mock navigation data
  final List<Map<String, dynamic>> _directions = [
    {
      'instruction': 'Head south on Jurong West St 42',
      'distance': '120m',
      'icon': Icons.arrow_upward,
    },
    {
      'instruction': 'Turn left onto Jurong West Ave 1',
      'distance': '350m',
      'icon': Icons.turn_left,
    },
    {
      'instruction': 'Continue straight',
      'distance': '200m',
      'icon': Icons.arrow_forward,
    },
    {
      'instruction': 'Turn right at the mall entrance',
      'distance': '50m',
      'icon': Icons.turn_right,
    },
    {
      'instruction': 'Toilet is on your right',
      'distance': '10m',
      'icon': Icons.wc,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 52, 64, 74),
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Navigation',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // Map View (Mock)
          Container(
            height: 300,
            width: double.infinity,
            color: const Color(0xFFEBEBEB),
            child: Stack(
              children: [
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.map, size: 64, color: Colors.blue[300]),
                      const SizedBox(height: 8),
                      const Text(
                        'Map View',
                        style: TextStyle(color: Colors.black54),
                      ),
                    ],
                  ),
                ),
                // ETA and distance overlay
                Positioned(
                  top: 16,
                  left: 0,
                  right: 0,
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.destination.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              widget.destination.address,
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.access_time, size: 16, color: Colors.blue),
                                const SizedBox(width: 4),
                                const Text(
                                  '8 min',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              '650m away',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 14,
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
          
          // Directions list
          Expanded(
            child: Container(
              color: Colors.white,
              width: double.infinity,
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
                      itemCount: _directions.length,
                      itemBuilder: (context, index) {
                        final direction = _directions[index];
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: index == _directions.length - 1 
                                ? Colors.green 
                                : Colors.blue[100],
                            child: Icon(
                              direction['icon'] as IconData,
                              color: index == _directions.length - 1 
                                  ? Colors.white 
                                  : const Color.fromARGB(255, 52, 64, 74),
                              size: 20,
                            ),
                          ),
                          title: Text(direction['instruction'] as String),
                          subtitle: Text(direction['distance'] as String),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}