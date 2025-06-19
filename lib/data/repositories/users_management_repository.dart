import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:date_format/date_format.dart';
import 'package:ai_logistics_management_order_automation/data/services/firebase_helper.dart';
import 'package:ai_logistics_management_order_automation/domain/models/filter_model.dart';
import 'package:ai_logistics_management_order_automation/domain/models/user_model.dart';

abstract class UsersManagementRepository {
  Stream<List<UserModel>> streamAllUsers();

  Future<void> addUser({
    required String username,
    required String password,
    required String name,
    required String userRole,
  });

  Future<void> editUser(
      String userID,
      String name,
      String password,
      );

  Future<void> editUserRole(
      String userID,
      String userRole,
      );

  Future<void> editUserIP(
      String userID,
      );

  Future<void> updateOrderStats({
    required String userID,
    int? created,
    int? accepted,
    int? deleted,
    List<String>? myOrdersIdList,
  });

  Future<UserModel?> getUserDetails(String userID);

  Future<void> deleteUser(String userID);

  Future<void> logUserEditAction({
    required String userID,
    required String username,
  });

  Future<void> logUserAddAction({
    required String userID,
    required String username,
    required String userRole,
  });

  Future<void> logUserViewAction({
    required String userID,
    required String username,
  });

  Future<void> logUserChangeRoleAction({
    required String userID,
    required String username,
    required String newRole,
  });

  Future<void> logAdminEditAction({
    required String adminID,
    required String username,
  });

  Future<void> logAdminAddAction({
    required String adminID,
    required String username,
    required String userRole,
  });

  Future<void> logAdminViewAction({
    required String adminID,
    required String username,
  });

  Future<void> logAdminChangeRoleAction({
    required String adminID,
    required String username,
    required String newRole,
  });

  Future<void> startEditing(String userID);

  Future<void> stopEditing(String userID);

  /// New methods:
  Future<bool> canUserEdit(String userID);

  Future<bool> isLastStartEditTimeChanged(
      String userID,
      DateTime oldLastStartEditTime, // Changed from Timestamp to DateTime
      );

  Future<void> updateUserFilter(String userID, FilterModel updatedFilter);
  Future<bool> isUserExists(String userId);
}

class UsersManagementRepositoryImpl implements UsersManagementRepository {
  final FirebaseHelper _firebaseHelper;

  UsersManagementRepositoryImpl(this._firebaseHelper);

  @override
  Future<bool> isUserExists(String userId) {
    return _firebaseHelper.isUserExists(userId);
  }

  @override
  Stream<List<UserModel>> streamAllUsers() {
    return _firebaseHelper.streamAllUsers();
  }

  @override
  Future<void> addUser({
    required String username,
    required String password,
    required String name,
    required String userRole,
  }) async {
    await _firebaseHelper.addUser(
      username: username,
      password: password,
      name: name,
      userRole: userRole,
    );
  }

  @override
  Future<void> editUser(
      String userID,
      String name,
      String password,
      ) async {
    await _firebaseHelper.editUserDetails(
      userID: userID,
      name: name,
      newPassword: password,
    );
  }

  @override
  Future<void> editUserRole(
      String userID,
      String userRole
      ) async {
    await _firebaseHelper.editUserRole(
      userID: userID,
      userRole: userRole,
    );
  }

  @override
  Future<void> editUserIP(
      String userID,
      ) async {
    await _firebaseHelper.editUserIP(
      userID: userID,
    );
  }

  @override
  Future<void> updateOrderStats({
    required String userID,
    int? created,
    int? accepted,
    int? deleted,
    List<String>? myOrdersIdList,
  }) async {
    await _firebaseHelper.updateOrderStats(
      userID: userID,
      created: created,
      accepted: accepted,
      deleted: deleted,
      myOrdersIdList: myOrdersIdList,
    );
  }

  @override
  Future<UserModel?> getUserDetails(String userID) async {
    return await _firebaseHelper.getUserDetails(userID);
  }

  @override
  Future<void> deleteUser(String userID) async {
    await _firebaseHelper.deleteUser(userID);
  }

  @override
  Future<void> logUserEditAction({
    required String userID,
    required String username,
  }) async {
    await _firebaseHelper.logUserEditAction(
      userID: userID,
      username: username,
    );
  }

  @override
  Future<void> logUserAddAction({
    required String userID,
    required String username,
    required String userRole,
  }) async {
    await _firebaseHelper.logUserAddAction(
      userID: userID,
      username: username,
      userRole: userRole,
    );
  }

  @override
  Future<void> logUserViewAction({
    required String userID,
    required String username,
  }) async {
    await _firebaseHelper.logUserViewAction(
      userID: userID,
      username: username,
    );
  }

  @override
  Future<void> logUserChangeRoleAction({
    required String userID,
    required String username,
    required String newRole,
  }) async {
    await _firebaseHelper.logUserChangeRoleAction(
      userID: userID,
      username: username,
      newRole: newRole,
    );
  }

  @override
  Future<void> logAdminEditAction({
    required String adminID,
    required String username,
  }) async {
    await _firebaseHelper.logAdminEditAction(
      adminID: adminID,
      username: username,
    );
  }

  @override
  Future<void> logAdminAddAction({
    required String adminID,
    required String username,
    required String userRole,
  }) async {
    await _firebaseHelper.logAdminAddAction(
      adminID: adminID,
      username: username,
      userRole: userRole,
    );
  }

  @override
  Future<void> logAdminViewAction({
    required String adminID,
    required String username,
  }) async {
    await _firebaseHelper.logAdminViewAction(
      adminID: adminID,
      username: username,
    );
  }

  @override
  Future<void> logAdminChangeRoleAction({
    required String adminID,
    required String username,
    required String newRole,
  }) async {
    await _firebaseHelper.logAdminChangeRoleAction(
      adminID: adminID,
      username: username,
      newRole: newRole,
    );
  }

  @override
  Future<void> startEditing(String userID) async {
    await _firebaseHelper.startEditing(userID);
  }

  @override
  Future<void> stopEditing(String userID) async {
    await _firebaseHelper.stopEditing(userID);
  }

  @override
  Future<bool> canUserEdit(String userID) async {
    return await _firebaseHelper.canUserEdit(userID);
  }

  @override
  Future<void> updateUserFilter(String userID, FilterModel updatedFilter) async {
    return await _firebaseHelper.updateUserFilter(userID, updatedFilter);
  }

  @override
  Future<bool> isLastStartEditTimeChanged(
      String userID,
      DateTime oldLastStartEditTime, // Changed here to DateTime
      ) async {
    return await _firebaseHelper.isLastStartEditTimeChanged(
      userID,
      oldLastStartEditTime,
    );
  }
}
