import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ai_logistics_management_order_automation/data/repositories/auth_repository.dart';
import 'package:ai_logistics_management_order_automation/data/repositories/users_management_repository.dart';
import 'package:ai_logistics_management_order_automation/data/services/multi_storage.dart';
import 'package:ai_logistics_management_order_automation/domain/models/user_model.dart';

part 'session_state.dart';

// SessionCubit handles login, logout, profile, and remember me.
class SessionCubit extends Cubit<SessionState> {
  final AuthRepositoryImpl authRepositoryImpl;
  final UsersManagementRepositoryImpl userRepository;
  final MultiStorageHandler multiStorageHandler;

  SessionCubit(
      this.authRepositoryImpl,
      this.userRepository,
      this.multiStorageHandler,
      ) : super(SessionInitial());

  Future<void> checkSession() async {
    emit(SessionLoading());

    if(await multiStorageHandler.checkUserIdAvailability()) {
      var userId = await multiStorageHandler.retrieveUserId();
      if(userId != null) {
        await _fetchAndSetUserDetails(userId);
      } else {
        emit(SessionUnauthenticated());
      }
    } else {
      emit(SessionUnauthenticated());
    }
  }

  // Internal method to handle login logic and fetch user details
  Future<void> login({
    required String username,
    required String password,
  }) async {
    emit(SessionLoading());
    try {
      final user = await authRepositoryImpl.loginUser(username: username, password: password);
      if (user == null) {
        emit(SessionError("Invalid username or password"));
        return;
      }

      _setSessionUserId(user.userID);
      emit(SessionAuthenticated(user));
    } catch (e) {
      emit(SessionError(e.toString()));
    }
  }

  // Fetch user details from backend and store them
  Future<void> _fetchAndSetUserDetails(String userID) async {
    try {
      final userDetails = await userRepository.getUserDetails(userID);
      if (userDetails == null) {
        emit(SessionError("User not found"));
        return;
      }

      // Save profile locally if needed
      _setSessionUserId(userDetails.userID);
      emit(SessionAuthenticated(userDetails));
    } catch (e) {
      emit(SessionError(e.toString()));
    }
  }

  // Logout
  Future<void> logout() async {
    final currentState = state;
    if (currentState is SessionAuthenticated) {
      final userId = currentState.user.userID;
      // Perform logout directly here
      await authRepositoryImpl.logoutUser(userId);
      _clearSession();
      emit(SessionUnauthenticated());
    } else {
      _clearSession();
      emit(SessionUnauthenticated());
    }
  }

  // Clear Session Data
  void _clearSession() {
    multiStorageHandler.clearUserId();
    // We do not necessarily clear username/password if rememberMe is enabled,
    // because user might want to login automatically next time.
  }

  // Set userID in sessionStorage
  void _setSessionUserId(String userId) {
    multiStorageHandler.saveUserId(userId);
  }
}
