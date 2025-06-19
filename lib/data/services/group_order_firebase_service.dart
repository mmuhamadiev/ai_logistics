import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ai_logistics_management_order_automation/config/constants.dart';
import 'package:ai_logistics_management_order_automation/domain/models/commnet_model.dart';
import 'package:ai_logistics_management_order_automation/domain/models/driver_info_model.dart';
import 'package:ai_logistics_management_order_automation/domain/models/order_group_model.dart';
import 'package:ai_logistics_management_order_automation/domain/models/order_model.dart';

class GroupOrderService {
  final FirebaseFirestore _firestore;

  GroupOrderService(this._firestore);

  // Add a new order group to Firestore
  Future<void> addOrderGroup(
      OrderGroupModel group, String userID, String userName) async {
    var updatedGroup = group.copyWith(
      creatorID: userID,
      creatorName: userName,
      status: OrderStatus.Confirmed
    );
    try {
      final groupRef =
          _firestore.collection('orderGroups').doc(updatedGroup.groupID);
      final batch = _firestore.batch();

      // Add the group to Firestore
      batch.set(groupRef, updatedGroup.toJson());

      // Update the status of each order in the group to Confirmed
      for (var order in updatedGroup.orders) {
        final orderRef = _firestore.collection('orders').doc(order.orderID);
        batch.update(orderRef, {
          'status': OrderStatus.Confirmed.name, // Update the status to Confirmed
          'lastModifiedAt': FieldValue
              .serverTimestamp(), // Update the lastModifiedAt timestamp
        });
      }

      // Commit the batch
      await batch.commit();

      // Log the action
      await logGroupAction(updatedGroup.groupID,
          "Created new group and updated order statuses", userID, userName);

      log("Order group created successfully and statuses updated: ${updatedGroup.groupID}");
    } catch (e) {
      throw Exception("Error adding order group: $e");
    }
  }

  Future<void> updateOrderAndGroupOrderStatus(OrderModel updatedOrder,
      String groupID, String userID, String userName) async {
    try {
      final orderRef =
          _firestore.collection('orders').doc(updatedOrder.orderID);
      final groupDocRef = _firestore.collection('orderGroups').doc(groupID);

      // Fetch existing group data
      final groupDoc = await groupDocRef.get();
      if (!groupDoc.exists) {
        throw Exception("Order group with ID $groupID does not exist.");
      }

      // Parse the existing order group
      final existingGroup =
          OrderGroupModel.fromJson(groupDoc.data() as Map<String, dynamic>);

      // Modify only the specific order inside the list
      final List<OrderModel> updatedOrders = existingGroup.orders.map((order) {
        if (order.orderID == updatedOrder.orderID) {
          return updatedOrder.copyWith(
              status: updatedOrder.status,
              isEditing: false,
              lastModifiedAt: DateTime.now(),
          ); // Update only status
        }
        return order; // Keep others unchanged
      }).toList();

      // Use a batch for atomic updates
      final batch = _firestore.batch();

      // Update the order status in the 'orders' collection
      batch.update(orderRef, {"status": updatedOrder.status.name, "isEditing": false, "lastModifiedAt": DateTime.now()});

      // Update the modified order list inside `orderGroups`
      batch.update(groupDocRef,
          {"orders": updatedOrders.map((order) => order.toJson()).toList()});

      // Commit the batch
      await batch.commit();

      // Log actions
      await logOrderAction(
          updatedOrder.orderID, "Updated order status", userID, userName);
      await logGroupAction(
          groupID, "Updated order status inside order group", userID, userName);

      log("Order status updated successfully: ${updatedOrder.orderID}");
    } catch (e) {
      log("Error updating order status: $e");
      throw Exception("Error updating order status: $e");
    }
  }

  // Add a comment to an order group
  Future<void> addGroupComment(
      String groupID, Comment comment, String userID, String userName) async {
    try {
      await _firestore.collection('orderGroups').doc(groupID).update({
        'comments': FieldValue.arrayUnion([comment.toJson()]),
      });
      await logGroupAction(groupID, "Added a comment", userID, userName);
      log("Added comment to group: $groupID");
    } catch (e) {
      throw Exception("Error adding comment to order group: $e");
    }
  }

  // Delete a comment from an order group
  Future<void> deleteGroupComment(
      String groupID, Comment comment, String userID, String userName) async {
    try {
      await _firestore.collection('orderGroups').doc(groupID).update({
        'comments': FieldValue.arrayRemove([comment.toJson()]),
      });
      await logGroupAction(groupID, "Deleted a comment", userID, userName);
      log("Deleted comment from group: $groupID");
    } catch (e) {
      throw Exception("Error deleting comment from order group: $e");
    }
  }

  // Log order group activity
  Future<void> logGroupAction(
      String groupID, String action, String userID, String userName) async {
    try {
      // Log entry structure
      final logEntry = {
        'action': action,
        'timestamp': DateTime.now().toIso8601String(),
        'userID': userID,
        'userName': userName,
      };

      // Update the order group document in Firestore
      await _firestore.collection('orderGroups').doc(groupID).update({
        'logs': FieldValue.arrayUnion([logEntry]),
      });

      // Optionally log the action in the user's log for tracking user-level actions
      await _firestore.collection('users').doc(userID).update({
        'actionsLog': FieldValue.arrayUnion([
          {
            'action': "Order Group: $action",
            'groupID': groupID,
            'timestamp': DateTime.now().toIso8601String(),
          }
        ]),
      });

      log("Logged action for order group: $groupID - $action");
    } catch (e) {
      log("Error logging order group action for $groupID: $e");
      throw Exception("Error logging order group action: $e");
    }
  }

  // Stream all groups
  Stream<List<OrderGroupModel>> streamAllGroups() {
    return _firestore.collection('orderGroups').snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) =>
              OrderGroupModel.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    });
  }

// Edit the status and driver for a group and its orders
  Future<void> updateGroupAndOrdersStatusAndDriver(
    String groupID,
    String newStatus,
    DriverInfo? newDriverInfo,
    String userID,
    String userName,
    bool? isNeedAddMore,
    Comment? carComment,
  ) async {
    try {
      // Reference to the group document
      final groupDocRef = _firestore.collection('orderGroups').doc(groupID);
      final groupDoc = await groupDocRef.get();

      if (!groupDoc.exists) {
        throw Exception("Group does not exist.");
      }

      // Deserialize the group data
      var groupData =
          OrderGroupModel.fromJson(groupDoc.data() as Map<String, dynamic>);

      // Update the group fields
      groupData.status =
          OrderStatus.values.firstWhere((status) => status.name == newStatus);
      if (newDriverInfo != null) {
        groupData = groupData.copyWith(driverInfo: newDriverInfo);
      }
      if (isNeedAddMore != null) {
        groupData = groupData.copyWith(isNeedAddMore: isNeedAddMore);
      }
      if (carComment != null) {
        groupData = groupData.copyWith(carComment: carComment);
      }

      // Update all orders within the group
      final batch = _firestore.batch();

      for (var order in groupData.orders) {
        final orderRef = _firestore.collection('orders').doc(order.orderID);

        // Update the status and driver info for each order
        final updatedOrder = order.copyWith(
          status: groupData.status,
          driverInfo: groupData.driverInfo,
          isEditing: false,
          lastModifiedAt: DateTime.now(),
        );

        batch.update(orderRef, updatedOrder.toJson());
      }

      // Update the group document with the updated orders and fields
      batch.update(groupDocRef, {
        'status': newStatus,
        'driverInfo': newDriverInfo?.toJson(),
        'orders': groupData.orders
            .map((order) => order
                .copyWith(
                  status: groupData.status,
                  driverInfo: groupData.driverInfo,
                )
                .toJson())
            .toList(),
        'isEditing': false,
        'isNeedAddMore': groupData.isNeedAddMore,
        'lastModifiedAt': DateTime.now(),
        'carComment': carComment?.toJson()
      });

      // Commit the batch
      await batch.commit();

      // Log the action
      await logGroupAction(
          groupID,
          "Updated group and orders with status: $newStatus and driver: ${newDriverInfo?.driverName ?? 'N/A'}",
          userID,
          userName);

      log("Group and orders updated successfully: $groupID");
    } catch (e) {
      throw Exception("Error updating group and orders: $e");
    }
  }

  Future<void> bulkUpdateGroupsAndOrdersStatus(
      List<String> groupIDs,
      OrderStatus newStatus,
      String userID,
      String userName,
      ) async {
    try {
      final batch = _firestore.batch();

      for (String groupID in groupIDs) {
        // Reference to the group document
        final groupDocRef = _firestore.collection('orderGroups').doc(groupID);
        final groupDoc = await groupDocRef.get();

        if (!groupDoc.exists) continue;

        // Deserialize the group data
        var groupData = OrderGroupModel.fromJson(groupDoc.data() as Map<String, dynamic>);

        groupData = groupData.copyWith(
          status: newStatus,
        );
        // Update each order in Firestore
        for (var order in groupData.orders) {
          final orderRef = _firestore.collection('orders').doc(order.orderID);

          final updatedOrder = order.copyWith(
            status: groupData.status,
            lastModifiedAt: DateTime.now(),
          );

          batch.update(orderRef, updatedOrder.toJson());
        }

        // Update the group document
        batch.update(groupDocRef, {
          'status': newStatus.name,
          'orders': groupData.orders
              .map((order) => order
              .copyWith(
            status: groupData.status,
              lastModifiedAt: DateTime.now()
          ).toJson()).toList(),
          'lastModifiedAt': DateTime.now(),
        });
      }

      // Commit the batch update
      await batch.commit();

      // Log the action for all updated groups
      for (String groupID in groupIDs) {
        await logGroupAction(
            groupID, "Bulk updated group and orders to status: ${newStatus.name}", userID, userName);
      }

      log("Bulk update successful for ${groupIDs.length} groups.");
    } catch (e) {
      throw Exception("Error in bulk updating groups and orders: $e");
    }
  }


  Future<void> updateOrderGroup(
      OrderGroupModel updatedGroup,
      String userID,
      String userName,
      OrderGroupModel oldGroup, // Required parameter for the old group
      ) async {
    try {
      print("Starting updateOrderGroup...");
      print("Old Group ID: ${oldGroup.groupID}");
      print("New Group ID: ${updatedGroup.groupID}");

      // Reference to the old and new group documents
      final oldGroupDocRef =
      _firestore.collection('orderGroups').doc(oldGroup.groupID);
      final newGroupDocRef =
      _firestore.collection('orderGroups').doc(updatedGroup.groupID);

      // Check if the old group exists
      final oldGroupDoc = await oldGroupDocRef.get();
      if (!oldGroupDoc.exists) {
        throw Exception("Group with ID ${oldGroup.groupID} does not exist.");
      }

      print("Old group exists, proceeding with update...");

      final List<OrderModel> oldOrders = oldGroup.orders;
      final Set<String> newOrderIDs =
      updatedGroup.orders.map((o) => o.orderID).toSet();

      print("Old Orders: ${oldOrders.map((o) => o.orderID).toList()}");
      print("New Orders: ${newOrderIDs.toList()}");

      // Find removed orders
      final Set<OrderModel> removedOrders = oldOrders
          .where((order) => !newOrderIDs.contains(order.orderID))
          .toSet();

      print("Removed Orders: ${removedOrders.map((o) => o.orderID).toList()}");

      // Use a batch to update the group and its orders atomically
      final batch = _firestore.batch();

      if (oldGroup.groupID != updatedGroup.groupID) {
        // If the groupID has changed, create a new document and delete the old one
        print("Group ID changed. Creating a new document and deleting the old one...");
        batch.set(newGroupDocRef, updatedGroup.toJson());
        batch.delete(oldGroupDocRef);
      } else {
        // If the groupID is the same, update the existing document
        print("Group ID is the same. Updating the existing document...");
        batch.update(oldGroupDocRef, updatedGroup.toJson());
      }


      print("Order group document updated. Handling removed orders...");

      // Handle removed orders
      for (var order in removedOrders) {
        print("Removing order ${order.orderID} from group...");
        final orderRef = _firestore.collection('orders').doc(order.orderID);
        batch.update(orderRef, {
          'connectedGroupID': null,
          'status': 'Pending',
          'isEditing': false,
          'lastStartEditTime': null,
          'lastModifiedAt': DateTime.now(),
        });
      }

      print("Updating orders to the new group...");
      // Update the connectedGroupID in all orders (both old and new) to the new groupID
      for (var order in updatedGroup.orders) {
        print("Updating order ${order.orderID}...");
        final orderRef = _firestore.collection('orders').doc(order.orderID);
        print("Updating order ${updatedGroup.status}...");
        final updatedOrder = order.copyWith(
          status: updatedGroup.status,
          lastModifiedAt: DateTime.now(),
          isEditing: false,
          lastStartEditTime: null,
          connectedGroupID: updatedGroup.groupID,
        );
        batch.set(orderRef, updatedOrder.toJson(), SetOptions(merge: true));
      }

      // Commit the batch
      print("Committing batch updates...");
      await batch.commit();
      print("Batch committed successfully.");

      // Log the update action
      await logGroupAction(
        updatedGroup.groupID,
        "Updated order group with new orders${oldGroup.groupID != updatedGroup.groupID ? ' and changed groupID from ${oldGroup.groupID} to ${updatedGroup.groupID}' : ''}",
        userID,
        userName,
      );

      print("Order group updated successfully with new orders: ${updatedGroup.groupID}");
    } catch (e) {
      print("Error updating order group: $e");
      throw Exception("Error updating order group: $e");
    }
  }

  Future<void> updateOrderInGroup(
      OrderGroupModel updatedGroup,
      String userID,
      String userName,
      OrderGroupModel oldGroup, // Required parameter for the old group
      ) async {
    try {
      print("Starting updateOrderGroup...");
      print("Old Group ID: ${oldGroup.groupID}");
      print("New Group ID: ${updatedGroup.groupID}");

      // Reference to the old and new group documents
      final oldGroupDocRef =
      _firestore.collection('orderGroups').doc(oldGroup.groupID);
      final newGroupDocRef =
      _firestore.collection('orderGroups').doc(updatedGroup.groupID);

      // Check if the old group exists
      final oldGroupDoc = await oldGroupDocRef.get();
      if (!oldGroupDoc.exists) {
        throw Exception("Group with ID ${oldGroup.groupID} does not exist.");
      }

      print("Old group exists, proceeding with update...");

      final List<OrderModel> oldOrders = oldGroup.orders;
      final Set<String> newOrderIDs =
      updatedGroup.orders.map((o) => o.orderID).toSet();

      print("Old Orders: ${oldOrders.map((o) => o.orderID).toList()}");
      print("New Orders: ${newOrderIDs.toList()}");

      // Find removed orders
      final Set<OrderModel> removedOrders = oldOrders
          .where((order) => !newOrderIDs.contains(order.orderID))
          .toSet();

      print("Removed Orders: ${removedOrders.map((o) => o.orderID).toList()}");

      // Use a batch to update the group and its orders atomically
      final batch = _firestore.batch();

      if (oldGroup.groupID != updatedGroup.groupID) {
        // If the groupID has changed, create a new document and delete the old one
        print("Group ID changed. Creating a new document and deleting the old one...");
        batch.set(newGroupDocRef, updatedGroup.toJson());
        batch.delete(oldGroupDocRef);
      } else {
        // If the groupID is the same, update the existing document
        print("Group ID is the same. Updating the existing document...");
        batch.update(oldGroupDocRef, updatedGroup.toJson());
      }


      print("Order group document updated. Handling removed orders...");

      // Handle removed orders
      for (var order in removedOrders) {
        print("Removing order ${order.orderID} from group...");
        final orderRef = _firestore.collection('orders').doc(order.orderID);
        batch.update(orderRef, {
          'connectedGroupID': null,
          'status': 'Pending',
          'isEditing': false,
          'lastStartEditTime': null,
          'lastModifiedAt': DateTime.now(),
        });
      }

      print("Updating orders to the new group...");
      // Update the connectedGroupID in all orders (both old and new) to the new groupID
      for (var order in updatedGroup.orders) {
        print("Updating order ${order.orderID}...");
        final orderRef = _firestore.collection('orders').doc(order.orderID);
        print("Updating order ${updatedGroup.status}...");
        final updatedOrder = order.copyWith(
          status: order.status,
          lastModifiedAt: DateTime.now(),
          isEditing: false,
          lastStartEditTime: null,
          connectedGroupID: updatedGroup.groupID,
        );
        batch.set(orderRef, updatedOrder.toJson(), SetOptions(merge: true));
      }

      // Commit the batch
      print("Committing batch updates...");
      await batch.commit();
      print("Batch committed successfully.");

      // Log the update action
      await logGroupAction(
        updatedGroup.groupID,
        "Updated order group with new orders${oldGroup.groupID != updatedGroup.groupID ? ' and changed groupID from ${oldGroup.groupID} to ${updatedGroup.groupID}' : ''}",
        userID,
        userName,
      );

      print("Order group updated successfully with new orders: ${updatedGroup.groupID}");
    } catch (e) {
      print("Error updating order group: $e");
      throw Exception("Error updating order group: $e");
    }
  }



  // Delete a group and update the status of its orders
  Future<void> deleteGroup(String groupID, OrderStatus newStatus, String userID,
      String userName) async {
    try {
      final groupDocRef = _firestore.collection('orderGroups').doc(groupID);
      final groupDoc = await groupDocRef.get();

      if (!groupDoc.exists) {
        throw Exception("Group does not exist.");
      }

      final groupData =
          OrderGroupModel.fromJson(groupDoc.data() as Map<String, dynamic>);

      final batch = _firestore.batch();

      // Update the status of each order in the group
      for (var order in groupData.orders) {
        final orderRef = _firestore.collection('orders').doc(order.orderID);
        batch.update(orderRef, {
          'status': newStatus.name,
          'driverInfo': null,
          'connectedGroupID': null,
        });
        logOrderAction(
            order.orderID,
            'Updated order ${order.orderID}, removed from group',
            userID,
            userName);

        log("Updated order ${order.orderID}, removed from group");
      }

      // Delete the group document
      batch.delete(groupDocRef);

      // Commit the batch operation
      await batch.commit();

      log("Group deleted successfully: $groupID");
    } catch (e) {
      throw Exception("Error deleting group: $e");
    }
  }
// Start editing a group order
  Future<void> startGroupEditing(String groupID, String userID, String userName) async {
    try {
      final groupDocRef = _firestore.collection('orderGroups').doc(groupID);
      final groupDoc = await groupDocRef.get();

      if (!groupDoc.exists) {
        throw Exception("Group order does not exist.");
      }

      final data = groupDoc.data() as Map<String, dynamic>?;

      if (data == null) {
        throw Exception("Group order data is missing.");
      }

      final isEditing = data['isEditing'] ?? false;
      final lastStartEditTime = (data['lastStartEditTime'] as Timestamp?)?.toDate();
      final now = DateTime.now();

      if (!isEditing) {
        // No one is editing, start editing
        await groupDocRef.update({
          'isEditing': true,
          'lastStartEditTime': now,
        });
        await logOrderAction(groupID, "Started editing", userID, userName);
        print("Editing started for group: $groupID");
      } else {
        // Someone is editing, check timeout
        if (lastStartEditTime != null) {
          final diff = now.difference(lastStartEditTime).inMinutes;
          if (diff > 3) {
            // Lock expired, allow taking over editing
            await groupDocRef.update({
              'isEditing': true,
              'lastStartEditTime': now,
            });
            await logOrderAction(groupID, "Took over editing after lock expired", userID, userName);
            print("Editing lock expired. Took over editing for group: $groupID");
          } else {
            throw Exception("Another user is currently editing this group order.");
          }
        } else {
          throw Exception("Group order is currently locked for editing.");
        }
      }
    } catch (e) {
      print("Error starting edit mode for group: $e");
      throw Exception("Error starting edit mode for group order: $e");
    }
  }

// Stop editing a group order
  Future<void> stopGroupEditing(String groupID, String userID, String userName) async {
    try {
      await _firestore.collection('orderGroups').doc(groupID).update({
        'isEditing': false,
        'lastStartEditTime': null, // Reset lastStartEditTime after editing ends
      });

      await logOrderAction(groupID, "Stopped editing", userID, userName);
      print("Editing stopped for group: $groupID");
    } catch (e) {
      print("Error stopping edit mode for group: $e");
      throw Exception("Error stopping edit mode for group order: $e");
    }
  }

// Check if user can edit the group order
  Future<bool> canGroupEditOrder(String groupID) async {
    final doc = await _firestore.collection('orderGroups').doc(groupID).get();
    if (!doc.exists) return true; // No document means it's editable

    final data = doc.data() as Map<String, dynamic>?;
    if (data == null) return true; // If order has no data, assume editable

    final isEditing = data['isEditing'] ?? false;
    final lastStartEditTime = (data['lastStartEditTime'] as Timestamp?)?.toDate();

    if (!isEditing) return true; // No one is editing

    final now = DateTime.now();

    if (lastStartEditTime == null) return true; // Treat as expired lock

    final diff = now.difference(lastStartEditTime).inMinutes;
    return diff > 3; // True if lock expired
  }

// Check if order was modified since last check
  Future<bool> isOrderLastStartGroupEditTimeChanged(String orderID, DateTime? oldLastModifiedAt) async {
    print('Checking lastModifiedAt for order: $orderID');
    print('Old lastModifiedAt: $oldLastModifiedAt');

    final doc = await _firestore.collection('orderGroups').doc(orderID).get();
    if (!doc.exists) {
      print('Order does not exist. Assuming changed.');
      return true;
    }

    final data = doc.data();
    if (data == null) {
      print('lastModifiedAt field is missing. Assuming changed.');
      return true;
    }

    final lastModifiedAt = data['lastModifiedAt'] != null
        ? _parseExactDateTime(data['lastModifiedAt'])
        : null;

    // Convert Firestore Timestamp to DateTime
    DateTime? currentDateTime;
    currentDateTime = lastModifiedAt;

    print('Fetched lastModifiedAt: $currentDateTime');

    // If lastModifiedAt is null, it was never modified before
    if (currentDateTime == null) {
      print('lastModifiedAt is null, meaning it was never modified before.');
      return false;
    }

    // If lastModifiedAt exists but old is null, then it's modified
    if (oldLastModifiedAt == null) {
      print('Old lastModifiedAt is null, but lastModifiedAt exists. Order is modified.');
      return true;
    }

    // If both timestamps are the same, it's not modified
    if (currentDateTime.isAtSameMomentAs(oldLastModifiedAt)) {
      print('Both timestamps match. Order is NOT modified.');
      return false;
    }

    // If timestamps are different, it's modified
    print('Timestamps do not match. Order is modified.');
    return true;
  }


  Future<void> logOrderAction(
      String orderID, String action, String userID, String userName) async {
    try {
      // Log entry structure
      final logEntry = {
        'action': action,
        'timestamp': DateTime.now().toIso8601String(),
        'userID': userID,
        'userName': userName,
      };

      // Update the order document in Firestore
      await _firestore.collection('orders').doc(orderID).update({
        'logs': FieldValue.arrayUnion([logEntry]),
      });

      // Optionally log the action in the user's log for tracking user-level actions
      await _firestore.collection('users').doc(userID).update({
        'actionsLog': FieldValue.arrayUnion([
          {
            'action': "Order: $action",
            'orderID': orderID,
            'timestamp': DateTime.now().toIso8601String(),
          }
        ]),
      });

      log("Logged action for order: $orderID - $action");
    } catch (e) {
      log("Error logging order action for $orderID: $e");
      throw Exception("Error logging order action: $e");
    }
  }

  static DateTime _parseExactDateTime(dynamic timestamp) {
    if (timestamp is Timestamp) {
      return timestamp.toDate();
    } else if (timestamp is String) {
      return DateTime.parse(timestamp);
    } else {
      throw Exception('Invalid timestamp format: $timestamp');
    }
  }
}
