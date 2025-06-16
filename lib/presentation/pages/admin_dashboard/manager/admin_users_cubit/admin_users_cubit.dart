import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:hegelmann_order_automation/data/repositories/users_repository.dart';
import 'package:hegelmann_order_automation/domain/models/user_model.dart';

part 'admin_users_state.dart';

class AdminUsersCubit extends Cubit<AdminUsersState> {

  final UsersRepositoryImpl userRepository;
  StreamSubscription<List<UserModel>>? _usersSubscription;
  List<UserModel> allUsers = []; // To store the complete user list

  AdminUsersCubit(this.userRepository) : super(AdminUsersState.initial());

  void streamUsers() {
    _usersSubscription?.cancel(); // Cancel any previous subscription
    emit(AdminUsersState(isLoading: true)); // Emit loading state

    _usersSubscription = userRepository.streamAllUsers().listen(
          (users) {
            allUsers = users; // Keep the full user list
        emit(AdminUsersState(users: users)); // Emit the updated user list
      },
      onError: (error) {
        emit(AdminUsersState(error: error.toString())); // Handle errors
      },
    );
  }

  // Search users by name
  void searchUsers(String query) {
    if (query.isEmpty) {
      emit(AdminUsersState(users: allUsers)); // Reset to full list if query is empty
    } else {
      final filteredUsers = allUsers
          .where((user) => user.name.toLowerCase().contains(query.toLowerCase()))
          .toList();

      emit(AdminUsersState(users: filteredUsers)); // Emit filtered list
    }
  }

  @override
  Future<void> close() {
    _usersSubscription?.cancel(); // Ensure the stream is closed
    return super.close();
  }
}