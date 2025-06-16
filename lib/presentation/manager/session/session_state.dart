part of 'session_cubit.dart';

abstract class SessionState {}

class SessionInitial extends SessionState {}

class SessionLoading extends SessionState {}

class SessionAuthenticated extends SessionState {
  final UserModel user;
  SessionAuthenticated(this.user);
}

class SessionUnauthenticated extends SessionState {}

class SessionError extends SessionState {
  final String message;
  SessionError(this.message);
}
