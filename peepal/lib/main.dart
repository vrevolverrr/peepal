import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:peepal/shared/app/bloc/app_bloc.dart';
import 'package:peepal/features/home/home_page.dart';
import 'package:peepal/shared/location/repository/location_repository.dart';

void main() => runApp(const MyApp());
// test

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "PeePal",
      theme: ThemeData(
          scaffoldBackgroundColor: Color(0xffF4F6F8), fontFamily: "MazzardH"),
      home: MultiRepositoryProvider(
          providers: [
            RepositoryProvider(create: (context) => LocationRepository())
          ],
          child: BlocProvider(
              create: (context) => AppPageCubit(), child: HomePage())),
    );
  }
}
