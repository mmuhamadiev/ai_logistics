part of 'users_management_cubit.dart';

abstract class UsersManagementState {}

class UsersManagementInitial extends UsersManagementState {}

class UsersManagementLoading extends UsersManagementState {}

class UsersManagementSuccess extends UsersManagementState {}

class UsersManagementError extends UsersManagementState {
  final String message;

  UsersManagementError(this.message);
}