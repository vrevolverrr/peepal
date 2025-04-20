import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logging/logging.dart';
import 'package:peepal/api/client.dart';
import 'package:peepal/shared/location/repository/location_repository.dart';
import 'package:peepal/pages/app/app.dart';
import 'package:peepal/shared/auth/auth_bloc.dart';

/// Global flag to enable/disable debug-specific behaviors.
/// Set this flag to true if using local development server for backend.
bool kDebugMode = false;

/// The main entry point of the PeePal application.
///
/// Initializes necessary bindings, configures logging, initializes the API client,
/// and runs the root [App] widget.
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

/// The root widget of the PeePal application.
///
/// Sets up the necessary top-level providers, including [RepositoryProvider] for
/// [LocationRepository] and [BlocProvider] for [AuthBloc], before rendering
/// the main [PeePalApp].
class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) => MultiRepositoryProvider(
        providers: [
          RepositoryProvider(
            create: (context) => LocationRepository()..checkPermission(),
          ),
          BlocProvider(create: (context) => AuthBloc()..add(AuthEventInit())),
        ],
        child: PeePalApp(),
      );
}
