import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hegelmann_order_automation/data/repositories/users_management_repository.dart';

part 'users_management_state.dart';

class UsersManagementCubit extends Cubit<UsersManagementState> {
  final UsersManagementRepositoryImpl userRepository;

  String? currentlyEditingUserID;

  UsersManagementCubit(this.userRepository) : super(UsersManagementInitial());

  // Add User
  Future<void> addUser({
    required String adminID,
    required String username,
    required String password,
    required String name,
    required String userRole,
  }) async {
    emit(UsersManagementLoading());
    try {
      await userRepository.addUser(
        username: username,
        password: password,
        name: name,
        userRole: userRole,
      );
      // Log the action
      await userRepository.logAdminAddAction(
        adminID: adminID,
        username: username,
        userRole: userRole,
      );
      emit(UsersManagementSuccess());
    } catch (e) {
      emit(UsersManagementError(e.toString()));
    }
  }

  // Edit User Details
  Future<void> editUser({
    required String adminID,
    required String userID,
    required String name,
    required String username,
    required String password,
  }) async {
    emit(UsersManagementLoading());
    try {
      await userRepository.editUser(userID, name, password);
      // Log the action
      await userRepository.logAdminEditAction(
        adminID: adminID,
        username: username,
      );
      emit(UsersManagementSuccess());
    } catch (e) {
      emit(UsersManagementError(e.toString()));
    }
  }

  // Edit User Role
  Future<void> editUserRole({
    required String adminID,
    required String userID,
    required String userRole,
    required String username,
  }) async {
    emit(UsersManagementLoading());
    try {
      await userRepository.editUserRole(userID, userRole);
      // Log the action
      await userRepository.logAdminChangeRoleAction(
        adminID: adminID,
        username: username,
        newRole: userRole,
      );
      emit(UsersManagementSuccess());
    } catch (e) {
      emit(UsersManagementError(e.toString()));
    }
  }

  // Edit User Role
  Future<void> editUserIP({
    required String adminID,
    required String userID,
    required String username,
  }) async {
    emit(UsersManagementLoading());
    try {
      await userRepository.editUserIP(userID);
      // Log the action
      await userRepository.logAdminEditAction(
        adminID: adminID,
        username: username,
      );
      emit(UsersManagementSuccess());
    } catch (e) {
      emit(UsersManagementError(e.toString()));
    }
  }

  // Delete User
  Future<void> deleteUser(String adminID, String userID) async {
    emit(UsersManagementLoading());
    try {
      final user = await userRepository.getUserDetails(userID); // For logging
      if (user == null) {
        emit(UsersManagementError("User not found"));
        return;
      }
      await userRepository.deleteUser(userID);
      // Log the action
      await userRepository.logAdminViewAction(
        adminID: adminID,
        username: user.username,
      );
      emit(UsersManagementSuccess());
    } catch (e) {
      emit(UsersManagementError(e.toString()));
    }
  }

  // Start Editing
  Future<void> startEditing(String userID) async {
    try {
      emit(UsersManagementLoading());
      await userRepository.startEditing(userID);
      currentlyEditingUserID = userID;
      emit(UsersManagementSuccess());
    } catch (e) {
      emit(UsersManagementError(e.toString()));
    }
  }

  // Stop Editing
  Future<void> stopEditing(String userID) async {
    try {
      emit(UsersManagementLoading());
      await userRepository.stopEditing(userID);
      if (currentlyEditingUserID == userID) {
        currentlyEditingUserID = null;
      }
      emit(UsersManagementSuccess());
    } catch (e) {
      emit(UsersManagementError(e.toString()));
    }
  }

  // Hard Stop Editing - best effort, no state change or logging
  void hardStopEditing() {
    if (currentlyEditingUserID != null && currentlyEditingUserID!.isNotEmpty) {
      userRepository.stopEditing(currentlyEditingUserID!);
      currentlyEditingUserID = null;
    }
  }

  // Check if user can edit
  Future<bool> canUserEdit(String userID) async {
    try {
      return await userRepository.canUserEdit(userID);
    } catch (e) {
      // Handle error if needed, or rethrow
      return false;
    }
  }

  // Check if lastStartEditTime changed
  // Now using DateTime instead of Timestamp
  Future<bool> isLastStartEditTimeChanged(
      String userID,
      DateTime oldLastStartEditTime
      ) async {
    try {
      return await userRepository.isLastStartEditTimeChanged(userID, oldLastStartEditTime);
    } catch (e) {
      // Handle error if needed, or assume changed
      return true;
    }
  }
}
