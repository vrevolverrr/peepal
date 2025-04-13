import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logging/logging.dart';
import 'package:peepal/api/client.dart';
import 'package:peepal/bloc/location/repository/location_repository.dart';
import 'package:peepal/features/app/app.dart';
import 'package:peepal/bloc/auth/auth_bloc.dart';

bool debugMode = true;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Setup logging
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((record) {
    log('[${record.loggerName}] ${record.level.name}: ${record.time}: ${record.message}');
  });

  await PPClient.init();

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
          BlocProvider(create: (context) => AuthBloc()..add(AuthEventInit())),
        ],
        child: PeePalApp(),
      );
}
