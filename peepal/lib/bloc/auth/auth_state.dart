part of 'auth_bloc.dart';

sealed class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

final class AuthStateInitial extends AuthState {
  const AuthStateInitial();

  @override
  List<Object?> get props => [];
}

final class AuthStateLoading extends AuthState {
  const AuthStateLoading();

  @override
  List<Object?> get props => [];
}

final class AuthStateInvalidCredentials extends AuthState {
  const AuthStateInvalidCredentials();

  @override
  List<Object?> get props => [];
}

final class AuthStateAuthenticated extends AuthState {
  final PPUser user;

  const AuthStateAuthenticated(this.user);

  @override
  List<Object?> get props => [user];
}

final class AuthStateLoggedOut extends AuthState {
  const AuthStateLoggedOut();

  @override
  List<Object?> get props => [];
}

final class AuthStateError extends AuthState {
  final String message;

  const AuthStateError(this.message);

  @override
  List<Object?> get props => [message];
}
