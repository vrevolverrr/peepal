import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:peepal/client/auth/exceptions.dart';
import 'package:peepal/client/client.dart';
import 'package:peepal/client/auth/model/user.dart';

part 'auth_state.dart';
part 'auth_event.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc() : super(AuthStateInitial()) {
    on<AuthEventInit>(_onAuthEventInit);
    on<AuthEventSignIn>(_onAuthEventSignIn);
    on<AuthEventSignUp>(_onAuthEventSignUp);
    on<AuthEventSignOut>(_onAuthEventSignOut);
  }

  void _onAuthEventInit(AuthEventInit event, Emitter<AuthState> emit) async {}

  void _onAuthEventSignIn(
      AuthEventSignIn event, Emitter<AuthState> emit) async {
    emit(AuthStateLoading());
    try {
      final PPUser user = await PPClient.auth
          .login(email: event.email, password: event.password);

      emit(AuthStateAuthenticated(user));
    } on PPInvalidCredentialsError {
      emit(AuthStateInvalidCredentials());
    } catch (e) {
      emit(AuthStateError("An unexpected error occurred"));
    }
  }

  void _onAuthEventSignUp(
      AuthEventSignUp event, Emitter<AuthState> emit) async {
    emit(AuthStateLoading());
    try {
      final PPUser user = await PPClient.auth.signUp(
          username: event.username,
          password: event.password,
          email: event.email,
          gender: event.gender);

      emit(AuthStateAuthenticated(user));
    } on PPInvalidCredentialsError {
      emit(AuthStateInvalidCredentials());
    } catch (e) {
      emit(AuthStateError("An unexpected error occurred"));
    }
  }

  void _onAuthEventSignOut(AuthEventSignOut event, Emitter<AuthState> emit) {
    emit(AuthStateLoggedOut());
  }
}
