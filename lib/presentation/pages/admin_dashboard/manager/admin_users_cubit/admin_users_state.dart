part of 'admin_users_cubit.dart';

class AdminUsersState {
  final bool isLoading;
  final List<UserModel>? users;
  final String? error;

  AdminUsersState({
    this.isLoading = false,
    this.users,
    this.error,
  });

  // Initial state
  factory AdminUsersState.initial() {
    return AdminUsersState(isLoading: true);
  }
}