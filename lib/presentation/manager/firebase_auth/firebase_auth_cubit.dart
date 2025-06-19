import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ai_logistics_management_order_automation/data/repositories/auth_repository.dart';
import 'package:ai_logistics_management_order_automation/domain/models/user_model.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

part 'firebase_auth_state.dart';

class FirebaseAuthCubit extends Cubit<FirebaseAuthState> {
  final AuthRepositoryImpl authRepositoryImpl;
  final FlutterSecureStorage secureStorage;
  String tempUsername = '';
  String tempPassword = '';

  FirebaseAuthCubit(this.authRepositoryImpl, this.secureStorage)
      : super(FirebaseAuthInitial());

  // Load Saved Credentials and User Profile
  Future<bool> loadSavedCredentialsAndProfile() async {
    print("Loading saved credentials and user profile...");
    final rememberMe = await secureStorage.read(key: 'rememberMe') == 'true';
    if (rememberMe) {
      print("Remember Me is enabled. Fetching username and password...");
      tempUsername = await secureStorage.read(key: 'username') ?? '';
      tempPassword = await secureStorage.read(key: 'password') ?? '';

      print("Loaded credentials: Username = $tempUsername, Password = $tempPassword");
      return true;
    }
    print("Remember Me is disabled. No credentials loaded.");
    return false;
  }

  // Save User Profile Locally
  void _saveUserProfileToSecureStorage(UserModel user) async {
    print("Saving user profile to secure storage...");
    final userJson = jsonEncode(user.toJson());
    await secureStorage.write(key: 'user_profile', value: userJson);
    print("User profile saved: $userJson");
  }

  // Save Credentials if "Remember Me" is Enabled
  Future<void> _saveCredentials(bool rememberMe, String username, String password) async {
    if (rememberMe) {
      print("Remember Me is enabled. Saving credentials...");
      await secureStorage.write(key: 'username', value: username);
      await secureStorage.write(key: 'password', value: password);
      print("Credentials saved: Username = $username, Password = $password");
    } else {
      print("Remember Me is disabled. Clearing credentials...");
      await secureStorage.delete(key: 'username');
      await secureStorage.delete(key: 'password');
      print("Credentials cleared.");
    }
    await secureStorage.write(key: 'rememberMe', value: rememberMe.toString());
    print("Remember Me status saved: $rememberMe");
  }

  // Login User
  Future<void> login(bool isRemember, String username, String password) async {
    print("Attempting to login with username: $username");
    emit(FirebaseAuthLoading());
    try {
      final user = await authRepositoryImpl.loginUser(username: username, password: password);

      if (user != null) {
        print("Login successful for user: ${user.username}");
        _saveCredentials(isRemember, username, password);
        _saveUserProfileToSecureStorage(user);
        emit(FirebaseAuthAuthenticated(user));
      } else {
        print("Login failed: Invalid username or password.");
        emit(FirebaseAuthError("Invalid username or password"));
      }
    } catch (e) {
      print("Login error: $e");
      emit(FirebaseAuthError(e.toString()));
    }
  }

  // Logout User and Clear Local Data
  Future<void> hardLogout(String userID) async {
    print("Performing hard logout for userID: $userID");
    secureStorage.delete(key: 'user_profile');
    print("User profile cleared from secure storage.");
    authRepositoryImpl.logoutUser(userID);
    print("Logout successful.");
  }

  // Logout User and Clear Local Data
  Future<bool> logout(String userID) async {
    print("Logging out userID: $userID");
    emit(FirebaseAuthLoading());
    try {
      await authRepositoryImpl.logoutUser(userID);
      print("AuthRepository logout successful.");
      await secureStorage.delete(key: 'user_profile'); // Clear stored user profile
      print("User profile cleared from secure storage.");
      emit(FirebaseAuthUnauthenticated());
      return true;
    } catch (e) {
      print("Logout error: $e");
      emit(FirebaseAuthError(e.toString()));
      return false;
    }
  }
}
