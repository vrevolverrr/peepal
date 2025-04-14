import 'package:flutter/material.dart';
import 'package:peepal/pages/login_page/login_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => ProfilePageState();
}

class ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      body: Column(
        children: [
          // Top Section with Profile Picture and Name
          Container(
            width: double.infinity,
            padding: EdgeInsets.only(top: 80, bottom: 20),
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 253, 253, 253),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(40.0),
                bottomRight: Radius.circular(40.0),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Profile Picture
                CircleAvatar(
                  radius: 70.0,
                  backgroundImage: AssetImage(
                      'assets/images/profile_pic.jpeg'), // Replace with your image
                ),
                const SizedBox(height: 20.0),
                // Name
                const Text(
                  'Bryan Soong', // Replace with dynamic name if needed
                  style: TextStyle(
                    fontSize: 22.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                // Role or Description
                const Text(
                  'User', // Replace with dynamic role if needed
                  style: TextStyle(
                    fontSize: 16.0,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20.0),
          // Profile Details Section
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'PROFILE',
                    style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 20.0),
                  // Name Field
                  Row(
                    children: const [
                      Icon(Icons.person, color: Colors.black54),
                      SizedBox(width: 10.0),
                      Text(
                        'Name:',
                        style: TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(width: 10.0),
                      Text(
                        'Bryan Soong', // Replace with dynamic name if needed
                        style: TextStyle(
                          fontSize: 16.0,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20.0),
                  // Email Field
                  Row(
                    children: const [
                      Icon(Icons.email, color: Colors.black54),
                      SizedBox(width: 10.0),
                      Text(
                        'Email:',
                        style: TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(width: 10.0),
                      Text(
                        'bryan.soong@example.com', // Replace with dynamic email if needed
                        style: TextStyle(
                          fontSize: 16.0,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  // Log Out Button
                  Center(
                    child: ElevatedButton(
                      onPressed: () {
                        // Show confirmation dialog
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text('Confirm Logout'),
                              content: const Text(
                                  'Are you sure you want to log out?'),
                              actions: <Widget>[
                                TextButton(
                                  onPressed: () {
                                    // User canceled logout
                                    Navigator.of(context)
                                        .pop(); // Close the dialog
                                  },
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    // User confirmed logout
                                    Navigator.of(context)
                                        .pop(); // Close the dialog

                                    // Navigate to login page and clear navigation stack
                                    Navigator.of(context).pushAndRemoveUntil(
                                      MaterialPageRoute(
                                        builder: (context) => const LoginPage(),
                                      ),
                                      (route) =>
                                          false, // This clears the navigation stack
                                    );
                                  },
                                  style: TextButton.styleFrom(
                                    foregroundColor: Colors.red,
                                  ),
                                  child: const Text('Logout'),
                                ),
                              ],
                            );
                          },
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 52, 64, 74),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 40.0, vertical: 15.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                      ),
                      child: const Text(
                        'Log Out',
                        style: TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20.0),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
