part of 'navigation_bloc.dart';

@immutable
sealed class NavigationState extends Equatable {
  const NavigationState();

  @override
  List<Object> get props => [];
}

final class NavigationStateIdle extends NavigationState {
  const NavigationStateIdle();
}

final class NavigationStateLoading extends NavigationState {
  const NavigationStateLoading();
}

final class NavigationStateNavigating extends NavigationState {
  const NavigationStateNavigating();
}

final class NaviagationStateReachedDestination extends NavigationState {
  const NaviagationStateReachedDestination();
}

final class NavigationStateError extends NavigationState {
  final String message;

  const NavigationStateError(this.message);

  @override
  List<Object> get props => [message];
}
