import 'package:flutter/material.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: const Center(
        child: SizedBox(
          width: 300.0,
          height: 300.0,
          child: Image(
            image: AssetImage('assets/images/pp_logo.png'),
          ),
        ),
      ),
    );
  }
}
