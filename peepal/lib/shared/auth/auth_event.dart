part of 'auth_bloc.dart';

/// The base class for all events related to the [AuthBloc].
sealed class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

/// Initializes the authentication state of the application.
///
/// Checks if a user session exists. If authenticated, fetches the current user's
/// details and emits [AuthStateAuthenticated]. Otherwise, emits [AuthStateLoggedOut].
/// If fetching the user fails (e.g., expired token), it also emits [AuthStateLoggedOut].
final class AuthEventInit extends AuthEvent {
  const AuthEventInit();

  @override
  List<Object?> get props => [];
}

/// Handles the sign-in event [AuthEventSignIn].
///
/// Emits [AuthStateLoading], attempts to log in using the provided credentials.
/// On success, emits [AuthStateAuthenticated] with the user data.
/// On invalid credentials, emits [AuthStateInvalidCredentials].
/// On other errors, emits [AuthStateError].
final class AuthEventSignIn extends AuthEvent {
  final String email;
  final String password;

  const AuthEventSignIn({required this.email, required this.password});

  @override
  List<Object?> get props => [email, password];
}

/// Handles the sign-up event [AuthEventSignUp].
///
/// Emits [AuthStateLoading], attempts to register a new user with the provided details.
/// On success, emits [AuthStateAuthenticated] with the new user data.
/// On invalid credentials (e.g., email already exists), emits [AuthStateInvalidCredentials].
/// On other errors, emits [AuthStateError].
final class AuthEventSignUp extends AuthEvent {
  final String username;
  final String password;
  final String email;
  final PPGender gender;

  const AuthEventSignUp({
    required this.username,
    required this.password,
    required this.email,
    required this.gender,
  });

  @override
  List<Object?> get props => [username, password, email, gender];
}

/// Handles the sign-out event [AuthEventSignOut].
///
/// Emits [AuthStateLoading], attempts to log out the current user.
/// On success, emits [AuthStateLoggedOut].
/// On other errors, emits [AuthStateError].
final class AuthEventSignOut extends AuthEvent {
  const AuthEventSignOut();

  @override
  List<Object?> get props => [];
}
