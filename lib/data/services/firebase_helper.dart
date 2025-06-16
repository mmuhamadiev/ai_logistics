import 'dart:developer';
import 'dart:convert';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hegelmann_order_automation/domain/models/commnet_model.dart';
import 'package:hegelmann_order_automation/domain/models/filter_model.dart';
import 'package:hegelmann_order_automation/domain/models/ip_info_model.dart';
import 'package:hegelmann_order_automation/domain/models/order_group_model.dart';
import 'package:hegelmann_order_automation/domain/models/order_model.dart';
import 'package:hegelmann_order_automation/domain/models/user_model.dart';
import 'package:public_ip_address/public_ip_address.dart';

class FirebaseHelper {
  final FirebaseFirestore _firestore;
  final IpAddress ipAddress;

  FirebaseHelper(this._firestore, this.ipAddress);

  Future<bool> isUserExists(String userId) async {
    try {
      QuerySnapshot userSnapshot = await _firestore
          .collection('users')
          .where('userID', isEqualTo: userId)
          .get();

      return userSnapshot.docs.isNotEmpty;
    } catch (e) {
      print("Error checking user existence: $e");
      return false; // Assume user doesn't exist on error
    }
  }

  // Add a new user to Firestore
  Future<void> addUser({
    required String username,
    required String password,
    required String name,
    required String userRole,
  }) async {
    try {
      // Check if the username already exists
      QuerySnapshot existingUserSnapshot = await _firestore
          .collection('users')
          .where('username', isEqualTo: username)
          .get();

      if (existingUserSnapshot.docs.isNotEmpty) {
        throw Exception("A user with this username already exists.");
      }

      // Generate a document with Firestore and get the reference
      DocumentReference userDoc = _firestore.collection('users').doc();

      // Add user details to Firestore with the generated document ID
      await userDoc.set({
        'userID': userDoc.id,
        'username': username,
        'name': name,
        'password': password,
        'lastLoginTime': null,
        'currentLoginStatus': false,
        'ordersCreatedCount': 0,
        'ordersAcceptedCount': 0,
        'ordersDeletedCount': 0,
        'actionsLog': [],
        'userRole': userRole,
        'myOrdersIdList': [],
        'createdDate': DateTime.now(),
        'isEditing': false,
        'lastStartEditTime': null, // newly added field
        'filter': FilterModel.defaultFilters().toJson()
      });
    } catch (e) {
      throw Exception("Error adding user: $e");
    }
  }

  // Login user using Firestore database
  Future<UserModel?> loginUser({
    required String username,
    required String password,
  }) async {
    try {
      QuerySnapshot userSnapshot = await _firestore
          .collection('users')
          .where('username', isEqualTo: username)
          .where('password', isEqualTo: password)
          .get();

      if (userSnapshot.docs.isEmpty) {
        throw Exception("Invalid username or password.");
      }

      DocumentSnapshot userDoc = userSnapshot.docs.first;
      Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;

      // Check user role
      String? role = userData['userRole'];
      bool isAdmin = role != null && role == 'ADMIN';

      if (isAdmin == false) {
        // If user is NOT admin, perform location check
        Map<String, dynamic> allData = await ipAddress.getAllData();
        print('Running on ${allData.toString()}');

        IpInfoModel newIpInfo = IpInfoModel.fromJson(allData);

        // Check if the user already has IP info stored
        IpInfoModel? existingIpInfo = userData['ipInfo'] != null
            ? IpInfoModel.fromJson(userData['ipInfo'])
            : null;

        if (existingIpInfo == null) {
          // First-time login, store IP info
          await _firestore.collection('users').doc(userDoc.id).update({
            'ipInfo': newIpInfo.toJson(),
          });
        } else {
          // Extract latitude and longitude
          String oldIP = existingIpInfo.ip;
          // double oldLat = existingIpInfo.latitude;
          // double oldLon = existingIpInfo.longitude;
          // double newLat = newIpInfo.latitude;
          // double newLon = newIpInfo.longitude;

          // Print the old and new coordinates for debugging
          // print('Old Latitude: $oldLat');
          // print('Old Longitude: $oldLon');
          // print('New Latitude: $newLat');
          // print('New Longitude: $newLon');

// Check if the new login is within 500 meters of the old location
//           double distance = haversineDistance(oldLat, oldLon, newLat, newLon);

// Print the calculated distance
//           print('Distance between locations: $distance km');

// Optional: Check if within 500 meters
//           bool isWithin500Meters = distance <= 0.5;
//           print('Within 500 meters: $isWithin500Meters');

          // if (!isWithin500Meters) {
          if (newIpInfo.ip != oldIP) {
            // print("User is logging in from a new location: $distance km away.");
            throw Exception("You are logging in from a different location. Please verify your identity.");
          } else {
            print("User is logging in from the same location.");
          }
        }
      } else {
        print("Admin login - skipping location checks.");
      }

      // Update user's login status and last login time
      await _firestore.collection('users').doc(userDoc.id).update({
        'lastLoginTime': DateTime.now().toIso8601String(),
        'currentLoginStatus': true,
      });

      return UserModel.fromJson(userData);
    } catch (e) {
      throw Exception("Error logging in: $e");
    }
  }

  // Logout user
  Future<void> logoutUser(String userID) async {
    try {
      await _firestore.collection('users').doc(userID).update({
        'currentLoginStatus': false,
      });
    } catch (e) {
      throw Exception("Error logging out: $e");
    }
  }

  // Edit user details
  Future<void> editUserDetails({
    required String userID,
    required String name,
    required String newPassword,
  }) async {
    try {
      await _firestore.collection('users').doc(userID).update({
        'name': name,
        'password': newPassword,
        'isEditing': false,
        'lastStartEditTime': null,
      });
    } catch (e) {
      throw Exception("Error editing user details: $e");
    }
  }

  // Edit user role
  Future<void> editUserRole({
    required String userID,
    required String userRole,
  }) async {
    try {
      await _firestore.collection('users').doc(userID).update({
        'userRole': userRole,
        'isEditing': false,
        'lastStartEditTime': null,
      });
    } catch (e) {
      throw Exception("Error editing user role: $e");
    }
  }

  // Edit user role
  Future<void> editUserIP({
    required String userID,
  }) async {
    try {
      await _firestore.collection('users').doc(userID).update({
        'ipInfo': null,
        'isEditing': false,
        'lastStartEditTime': null,
      });
    } catch (e) {
      throw Exception("Error editing user role: $e");
    }
  }

  // Logging functions remain unchanged...
  Future<void> logUserEditAction({
    required String userID,
    required String username,
  }) async {
    try {
      await _firestore.collection('users').doc(userID).update({
        'actionsLog': FieldValue.arrayUnion([
          {
            'action': 'Edited user data for "$username"',
            'timestamp': DateTime.now(),
          }
        ]),
      });
    } catch (e) {
      throw Exception("Error logging user edit action: $e");
    }
  }

  Future<void> logUserAddAction({
    required String userID,
    required String username,
    required String userRole,
  }) async {
    try {
      await _firestore.collection('users').doc(userID).update({
        'actionsLog': FieldValue.arrayUnion([
          {
            'action': 'Added a new user: "$username" for role: $userRole',
            'timestamp': DateTime.now(),
          }
        ]),
      });
    } catch (e) {
      throw Exception("Error logging user add action: $e");
    }
  }

  Future<void> logUserViewAction({
    required String userID,
    required String username,
  }) async {
    try {
      await _firestore.collection('users').doc(userID).update({
        'actionsLog': FieldValue.arrayUnion([
          {
            'action': 'Viewed data for user "$username"',
            'timestamp': DateTime.now(),
          }
        ]),
      });
    } catch (e) {
      throw Exception("Error logging user view action: $e");
    }
  }

  Future<void> logUserChangeRoleAction({
    required String userID,
    required String username,
    required String newRole,
  }) async {
    try {
      await _firestore.collection('users').doc(userID).update({
        'actionsLog': FieldValue.arrayUnion([
          {
            'action': 'Changed role for "$username" to "$newRole"',
            'timestamp': DateTime.now(),
          }
        ]),
      });
    } catch (e) {
      throw Exception("Error logging role change action: $e");
    }
  }

  // Admin logging methods
  Future<void> logAdminEditAction({
    required String adminID,
    required String username,
  }) async {
    try {
      await _firestore.collection('users').doc(adminID).update({
        'actionsLog': FieldValue.arrayUnion([
          {
            'action': 'Edited user data for "$username"',
            'timestamp': DateTime.now(),
          }
        ]),
      });
    } catch (e) {
      throw Exception("Error logging user edit action: $e");
    }
  }

  Future<void> logAdminAddAction({
    required String adminID,
    required String username,
    required String userRole,
  }) async {
    try {
      await _firestore.collection('users').doc(adminID).update({
        'actionsLog': FieldValue.arrayUnion([
          {
            'action': 'Added a new user: "$username" for role: $userRole',
            'timestamp': DateTime.now(),
          }
        ]),
      });
    } catch (e) {
      throw Exception("Error logging user add action: $e");
    }
  }

  Future<void> logAdminViewAction({
    required String adminID,
    required String username,
  }) async {
    try {
      await _firestore.collection('users').doc(adminID).update({
        'actionsLog': FieldValue.arrayUnion([
          {
            'action': 'Viewed data for user "$username"',
            'timestamp': DateTime.now(),
          }
        ]),
      });
    } catch (e) {
      throw Exception("Error logging user view action: $e");
    }
  }

  Future<void> logAdminChangeRoleAction({
    required String adminID,
    required String username,
    required String newRole,
  }) async {
    try {
      await _firestore.collection('users').doc(adminID).update({
        'actionsLog': FieldValue.arrayUnion([
          {
            'action': 'Changed role for "$username" to "$newRole"',
            'timestamp': DateTime.now(),
          }
        ]),
      });
    } catch (e) {
      throw Exception("Error logging role change action: $e");
    }
  }

  // Update order stats
  Future<void> updateOrderStats({
    required String userID,
    int? created,
    int? accepted,
    int? deleted,
    List<String>? myOrdersIdList,
  }) async {
    try {
      Map<String, dynamic> updates = {};
      if (created != null) {
        updates['ordersCreatedCount'] = FieldValue.increment(created);
      }
      if (accepted != null) {
        updates['ordersAcceptedCount'] = FieldValue.increment(accepted);
      }
      if (deleted != null) {
        updates['ordersDeletedCount'] = FieldValue.increment(deleted);
      }
      if (myOrdersIdList != null) {
        updates['myOrdersIdList'] = FieldValue.arrayUnion(myOrdersIdList);
      }

      await _firestore.collection('users').doc(userID).update(updates);
    } catch (e) {
      throw Exception("Error updating order stats: $e");
    }
  }

  // Get user details
  Future<UserModel?> getUserDetails(String userID) async {
    try {
      DocumentSnapshot userDoc =
      await _firestore.collection('users').doc(userID).get();

      if (userDoc.exists) {
        return UserModel.fromJson(userDoc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      throw Exception("Error fetching user details: $e");
    }
  }

  // Delete a user
  Future<void> deleteUser(String userID) async {
    try {
      await _firestore.collection('users').doc(userID).delete();
    } catch (e) {
      throw Exception("Error deleting user: $e");
    }
  }

  // Fetch all users
  Future<List<UserModel>> fetchAllUsers() async {
    try {
      QuerySnapshot querySnapshot = await _firestore.collection('users').get();
      List<UserModel> users = querySnapshot.docs.map((doc) {
        return UserModel.fromJson(doc.data() as Map<String, dynamic>);
      }).toList();
      return users;
    } catch (e) {
      throw Exception('Failed to fetch users: $e');
    }
  }

  // Stream all users
  Stream<List<UserModel>> streamAllUsers() {
    return _firestore.collection('users').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return UserModel.fromJson(doc.data() as Map<String, dynamic>);
      }).toList();
    });
  }

  Future<void> startEditing(String userID) async {
    try {
      final userDocRef = _firestore.collection('users').doc(userID);
      final userDoc = await userDocRef.get();

      final data = userDoc.data() as Map<String, dynamic>?;

      if (data == null) {
        throw Exception("User does not exist.");
      }

      final isEditing = data['isEditing'] ?? false;
      final lastStartEditTime = data['lastStartEditTime'] as Timestamp?;

      if (!isEditing) {
        // Not currently editing, proceed
        await userDocRef.update({
          'isEditing': true,
          'lastStartEditTime': FieldValue.serverTimestamp(),
        });
      } else {
        // isEditing = true, check the time difference
        if (lastStartEditTime == null) {
          // If null but isEditing=true, treat as expired
          await userDocRef.update({
            'isEditing': true,
            'lastStartEditTime': FieldValue.serverTimestamp(),
          });
        } else {
          // Calculate time difference
          final now = DateTime.now();
          final lastTime = lastStartEditTime.toDate();
          final diff = now.difference(lastTime).inMinutes;

          if (diff > 3) {
            // Lock expired, take over
            await userDocRef.update({
              'isEditing': true,
              'lastStartEditTime': FieldValue.serverTimestamp(),
            });
          } else {
            // Another user editing actively
            throw Exception("Another user is already editing this profile.");
          }
        }
      }
    } catch (e) {
      throw Exception("Error starting edit mode: $e");
    }
  }

  Future<void> stopEditing(String userID) async {
    try {
      await _firestore.collection('users').doc(userID).update({
        'isEditing': false,
        'lastStartEditTime': null,
      });
    } catch (e) {
      throw Exception("Error stopping edit mode: $e");
    }
  }

  Future<bool> canUserEdit(String userID) async {
    final doc = await _firestore.collection('users').doc(userID).get();
    if (!doc.exists) return true; // No user doc means no lock

    final data = doc.data() as Map<String, dynamic>;
    final isEditing = data['isEditing'] ?? false;
    final lastStartEditTime = data['lastStartEditTime'] as Timestamp?;

    if (!isEditing) return true;

    if (lastStartEditTime == null) return true; // Treat as expired lock

    final now = DateTime.now();
    final lastTime = lastStartEditTime.toDate();
    final diff = now.difference(lastTime).inMinutes;
    return diff > 3; // True if lock expired
  }

  Future<bool> isLastStartEditTimeChanged(String userID, DateTime? oldLastStartEditTime) async {
    final doc = await _firestore.collection('users').doc(userID).get();
    if (!doc.exists) return true; // If user doesn't exist, consider changed

    final data = doc.data() as Map<String, dynamic>;
    final currentLastStartEditTime = data['lastStartEditTime'] as Timestamp?;

    // Convert currentLastStartEditTime to DateTime if not null
    final currentDateTime = currentLastStartEditTime?.toDate();

    // If currentLastStartEditTime is null but old was not null, changed
    if (currentDateTime == null && oldLastStartEditTime != null) return true;

    // If both null, no change
    if (currentDateTime == null && oldLastStartEditTime == null) return false;

    // Compare DateTimes
    return currentDateTime!.compareTo(oldLastStartEditTime!) != 0;
  }

  /// Update only the filter for a specific user
  Future<void> updateUserFilter(String userID, FilterModel updatedFilter) async {
    try {
      await _firestore.collection('users').doc(userID).update({
        'filter': updatedFilter.toJson(),
      });
      logUserFilterEditAction(userID: userID, updatedFilter: updatedFilter);
    } catch (e) {
      throw Exception("Failed to update user filter.");
    }
  }

  // Logging functions remain unchanged...
  Future<void> logUserFilterEditAction({
    required String userID,
    required FilterModel updatedFilter,
  }) async {
    try {
      await _firestore.collection('users').doc(userID).update({
        'actionsLog': FieldValue.arrayUnion([
          {
            'action': 'Edited user filter: "${updatedFilter.maxRadius}" and "${updatedFilter.pricePerKmThreshold}"',
            'timestamp': DateTime.now(),
          }
        ]),
      });
    } catch (e) {
      throw Exception("Error logging user edit action: $e");
    }
  }

  Future<String?> getLatestVersion() async {
    try {
      DocumentSnapshot snapshot =
      await _firestore.collection('app_info').doc('ESlxZMRvcUPoPUhISaE4').get();
      if (snapshot.exists) {
        return snapshot.get('version');
      }
    } catch (e) {
      print("Error fetching version: $e");
    }
    return null;
  }

}

double haversineDistance(double lat1, double lon1, double lat2, double lon2) {
  const double R = 6371; // Earth's radius in kilometers

  // Validate coordinates
  if (lat1 < -90 || lat1 > 90 || lat2 < -90 || lat2 > 90 ||
      lon1 < -180 || lon1 > 180 || lon2 < -180 || lon2 > 180) {
    throw ArgumentError('Invalid latitude or longitude values');
  }

  double dLat = _degreesToRadians(lat2 - lat1);
  double dLon = _degreesToRadians(lon2 - lon1);

  double a = sin(dLat / 2) * sin(dLat / 2) +
      cos(_degreesToRadians(lat1)) * cos(_degreesToRadians(lat2)) *
          sin(dLon / 2) * sin(dLon / 2);
  double c = 2 * atan2(sqrt(a), sqrt(1 - a));

  return R * c; // Distance in kilometers
}

double _degreesToRadians(double degrees) {
  return degrees * pi / 180;
}

bool isWithin500Meters(double lat1, double lon1, double lat2, double lon2) {
  try {
    double distance = haversineDistance(lat1, lon1, lat2, lon2);
    return distance <= 0.5; // 0.5 km = 500 meters
  } catch (e) {
    print('Error calculating distance: $e');
    return false; // Default to false on error
  }
}
