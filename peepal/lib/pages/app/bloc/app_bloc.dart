import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

part 'app_state.dart';

class AppPageCubit extends Cubit<AppPageState> {
  AppPageCubit() : super(AppPageStateHome());

  void changeToHome() => emit(AppPageStateHome());
  void changeToSearch() => emit(AppPageStateSearch());
  void changeToAdd() => emit(AppPageStateAdd());
  void changeToFavorite() => emit(AppPageStateFavorite());
}
