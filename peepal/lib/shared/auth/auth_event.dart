part of 'auth_bloc.dart';

sealed class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

final class AuthEventInit extends AuthEvent {
  const AuthEventInit();

  @override
  List<Object?> get props => [];
}

final class AuthEventSignIn extends AuthEvent {
  final String email;
  final String password;

  const AuthEventSignIn({required this.email, required this.password});

  @override
  List<Object?> get props => [email, password];
}

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

final class AuthEventSignOut extends AuthEvent {
  const AuthEventSignOut();

  @override
  List<Object?> get props => [];
}
