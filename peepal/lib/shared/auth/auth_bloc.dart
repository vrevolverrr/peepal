import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logging/logging.dart';
import 'package:peepal/api/auth/exceptions.dart';
import 'package:peepal/api/client.dart';
import 'package:peepal/api/user/model/user.dart';

part 'auth_state.dart';
part 'auth_event.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final Logger logger = Logger("AuthBloc");

  AuthBloc() : super(AuthStateInitial()) {
    on<AuthEventInit>(_onAuthEventInit);
    on<AuthEventSignIn>(_onAuthEventSignIn);
    on<AuthEventSignUp>(_onAuthEventSignUp);
    on<AuthEventSignOut>(_onAuthEventSignOut);
  }

  void _onAuthEventInit(AuthEventInit event, Emitter<AuthState> emit) async {
    logger.info('Initializing auth state');
    final isAuthenticated = PPClient.auth.isAuthenticated;
    logger.info('Auth check - isAuthenticated: $isAuthenticated');

    if (isAuthenticated) {
      try {
        final PPUser user = await PPClient.user.getCurrentUser();
        logger.info('Retrieved current user: ${user.username}');
        emit(AuthStateAuthenticated(user));
      } catch (e) {
        logger.warning('Failed to get current user: $e');
        emit(AuthStateLoggedOut());
      }
    } else {
      logger.info('No authenticated session found');
      emit(AuthStateLoggedOut());
    }
  }

  void _onAuthEventSignIn(
      AuthEventSignIn event, Emitter<AuthState> emit) async {
    logger.info('Attempting sign in for email: ${event.email}');
    emit(AuthStateLoading());

    try {
      final PPUser user = await PPClient.auth
          .login(email: event.email, password: event.password);

      logger.info('Sign in successful for user: ${user.username}');
      emit(AuthStateAuthenticated(user));
    } on PPInvalidCredentialsError {
      logger.warning('Invalid credentials for email: ${event.email}');
      emit(AuthStateInvalidCredentials());
    } catch (e) {
      logger.severe('Unexpected error during sign in: $e');
      emit(AuthStateError("An unexpected error occurred"));
    }
  }

  void _onAuthEventSignUp(
      AuthEventSignUp event, Emitter<AuthState> emit) async {
    logger.info('Attempting sign up for username: ${event.username}');
    emit(AuthStateLoading());

    try {
      final PPUser user = await PPClient.auth.signUp(
          username: event.username,
          password: event.password,
          email: event.email,
          gender: event.gender);

      logger.info('Sign up successful for user: ${user.username}');
      emit(AuthStateAuthenticated(user));
    } on PPInvalidCredentialsError {
      logger.warning(
          'Invalid credentials during signup for username: ${event.username}');
      emit(AuthStateInvalidCredentials());
    } catch (e) {
      logger.severe('Unexpected error during sign up: $e');
      emit(AuthStateError("An unexpected error occurred"));
    }
  }

  void _onAuthEventSignOut(
      AuthEventSignOut event, Emitter<AuthState> emit) async {
    logger.info('Signing out user');
    try {
      await PPClient.auth.logout();
      logger.info('Sign out successful');
      emit(AuthStateLoggedOut());
    } catch (e) {
      logger.severe('Error during sign out: $e');
      emit(AuthStateError("Failed to sign out"));
    }
  }
}
