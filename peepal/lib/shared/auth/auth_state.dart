part of 'auth_bloc.dart';

/// The base class for all states related to the [AuthBloc].
sealed class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

/// The initial state of the authentication process.
final class AuthStateInitial extends AuthState {
  const AuthStateInitial();

  @override
  List<Object?> get props => [];
}

/// The state of the authentication process when loading.
final class AuthStateLoading extends AuthState {
  const AuthStateLoading();

  @override
  List<Object?> get props => [];
}

/// The state of the authentication process when invalid credentials are provided.
final class AuthStateInvalidCredentials extends AuthState {
  const AuthStateInvalidCredentials();

  @override
  List<Object?> get props => [];
}

/// The state of the authentication process when a user is authenticated.
final class AuthStateAuthenticated extends AuthState {
  final PPUser user;

  const AuthStateAuthenticated(this.user);

  @override
  List<Object?> get props => [user];
}

/// The state of the authentication process when a user is logged out.
final class AuthStateLoggedOut extends AuthState {
  const AuthStateLoggedOut();

  @override
  List<Object?> get props => [];
}

/// The state of the authentication process when an error occurs.
final class AuthStateError extends AuthState {
  final String message;

  const AuthStateError(this.message);

  @override
  List<Object?> get props => [message];
}
