import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logging/logging.dart';
import 'package:peepal/features/app/app.dart';

import 'package:peepal/shared/location/repository/location_repository.dart';

void main() {
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((record) {
    log('[${record.loggerName}] ${record.level.name}: ${record.time}: ${record.message}');
  });

  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) => MultiRepositoryProvider(providers: [
        /// Provide all the repositories here
        RepositoryProvider(
            create: (context) => LocationRepository()..checkPermission())
      ], child: PeePalApp());
}
