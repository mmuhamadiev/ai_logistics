part of 'user_profile_cubit.dart';

abstract class UserProfileState {}

class UserProfileInitial extends UserProfileState {}

class UserProfileLoading extends UserProfileState {}

class UserProfileLoaded extends UserProfileState {
  final UserModel user;

  UserProfileLoaded(this.user);
}

class UserProfileFilterSuccess extends UserProfileState {
  final String message;
  UserProfileFilterSuccess({required this.message});
}

class UserProfileError extends UserProfileState {
  final String message;

  UserProfileError(this.message);
}
