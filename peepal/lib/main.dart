import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logging/logging.dart';
import 'package:peepal/features/login_page/login_page.dart';
import 'package:peepal/bloc/location/repository/location_repository.dart';

bool debugMode = false;

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Setup logging
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((record) {
    log('[${record.loggerName}] ${record.level.name}: ${record.time}: ${record.message}');
  });

  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) => MultiRepositoryProvider(
        providers: [
          // Provide repositories
          RepositoryProvider(
            create: (context) => LocationRepository()..checkPermission(),
          ),
          // You can add AuthRepository here when ready to connect to backend
        ],
        child: const PeePalApp(),
      );
}

class PeePalApp extends StatelessWidget {
  const PeePalApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PeePal',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        useMaterial3: true,
      ),
      home: const LoginPage(),
    );
  }
}
