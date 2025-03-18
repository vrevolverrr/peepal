import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'navigation_state.dart';

class NavigationCubit extends Cubit<NavigationState> {
  NavigationCubit() : super(NavigationStateIdle());

  void startNavigation() {
    /// Fetch route
    emit(NavigationStateLoading());
    // Start navigation
    emit(NavigationStateNavigating());

    /// Listen for destination reached
  }

  void stopNavigation() {
    /// Stop navigation
    emit(NavigationStateLoading());
  }
}
