part of 'firebase_auth_cubit.dart';

abstract class FirebaseAuthState {}

class FirebaseAuthInitial extends FirebaseAuthState {}

class FirebaseAuthLoading extends FirebaseAuthState {}

class FirebaseAuthAuthenticated extends FirebaseAuthState {
  UserModel userModel;

  FirebaseAuthAuthenticated(this.userModel);
}

class FirebaseAuthUnauthenticated extends FirebaseAuthState {}

class FirebaseAuthError extends FirebaseAuthState {
  final String message;

  FirebaseAuthError(this.message);
}
