import 'package:hegelmann_order_automation/data/services/firebase_helper.dart';
import 'package:hegelmann_order_automation/domain/models/user_model.dart';

abstract class UsersRepository {
  Stream<List<UserModel>> streamAllUsers();
}


class UsersRepositoryImpl implements UsersRepository {
  final FirebaseHelper _firebaseHelper;

  UsersRepositoryImpl(this._firebaseHelper);

  @override
  Stream<List<UserModel>> streamAllUsers() {
    return _firebaseHelper.streamAllUsers();
  }
}
