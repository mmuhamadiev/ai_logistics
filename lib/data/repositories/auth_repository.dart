import 'package:hegelmann_order_automation/data/services/firebase_helper.dart';
import 'package:hegelmann_order_automation/domain/models/user_model.dart';

abstract class AuthRepository {
  Future<UserModel?> loginUser({
    required String username,
    required String password,
  });

  Future<void> logoutUser(String userID);
}

class AuthRepositoryImpl implements AuthRepository {
  final FirebaseHelper _firebaseHelper;

  AuthRepositoryImpl(this._firebaseHelper);

  @override
  Future<UserModel?> loginUser({
    required String username,
    required String password,
  }) async {
    return await _firebaseHelper.loginUser(
      username: username,
      password: password,
    );
  }

  @override
  Future<void> logoutUser(String userID) async {
    await _firebaseHelper.logoutUser(userID);
  }
}