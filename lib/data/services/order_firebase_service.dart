import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hegelmann_order_automation/domain/models/commnet_model.dart';
import 'package:hegelmann_order_automation/domain/models/order_model.dart';

class OrderService {
  final FirebaseFirestore _firestore;

  OrderService(this._firestore);

  // Delete an order
  Future<bool> deleteOrder(
      String orderID, String userID, String userName) async {
    try {
      // Remove the order document from Firestore
      await _firestore.collection('orders').doc(orderID).delete();
      await _firestore.collection('users').doc(userID).update({
        'actionsLog': FieldValue.arrayUnion([
          {
            'action': "Deleted order: ${orderID}",
            'timestamp': DateTime.now().toIso8601String(),
          }
        ]),
      });

      log("Order deleted successfully: $orderID");
      return true;
    } catch (e) {
      throw Exception("Error deleting order: $e");
    }
  }

  // Delete multiple orders
  Future<bool> deleteOrders(List<String> orderIDs, String userID, String userName) async {
    try {
      // Use batch write for Firestore for efficiency
      WriteBatch batch = _firestore.batch();

      for (String orderID in orderIDs) {
        // Delete order document
        batch.delete(_firestore.collection('orders').doc(orderID));
      }

      // Commit batch delete
      await batch.commit();

      // Log the deletion action for the user
      await _firestore.collection('users').doc(userID).update({
        'actionsLog': FieldValue.arrayUnion([
          {
            'action': "Deleted orders: ${orderIDs.join(', ')}",
            'timestamp': DateTime.now().toIso8601String(),
          }
        ]),
      });

      log("Orders deleted successfully: ${orderIDs.join(', ')}");
      return true;
    } catch (e) {
      throw Exception("Error deleting orders: $e");
    }
  }

  // Add a new order to Firestore
  Future<void> addOrder(
      OrderModel order, String userID, String userName) async {
    try {
      final docRef = _firestore.collection('orders').doc(order.orderID);

      // Check if the orderID already exists
      final existingOrder = await docRef.get();
      if (existingOrder.exists) {
        throw Exception("An order with ID ${order.orderID} already exists.");
      }

      // Add the new order
      await docRef.set(order.toJson());

      // Log the order action
      await logOrderAction(order.orderID, "Created new order ${order.orderID}",
          userID, userName);

      log("Order created successfully: ${order.orderID}");
    } catch (e) {
      throw Exception("Error adding order: $e");
    }
  }

  // Edit an order
  Future<void> editOrder(
      OrderModel order, String userID, String userName) async {
    try {
      final orderRef = _firestore.collection('orders').doc(order.orderID);

      await orderRef.update(order.toJson());
      await logOrderAction(
          order.orderID, "Edited order details", userID, userName);
      log("Order updated successfully: ${order.orderID}");
    } catch (e) {
      throw Exception("Error editing order: $e");
    }
  }

  Future<void> updateOrderStatusBulk(
      List<String> orderIDs, String newStatus, String userID, String userName) async {
    try {
      final batch = _firestore.batch();

      for (String orderID in orderIDs) {
        final orderRef = _firestore.collection('orders').doc(orderID);
        batch.update(orderRef, {'status': newStatus});
      }

      await batch.commit();

      // Logging the action for each order
      for (String orderID in orderIDs) {
        await logOrderAction(orderID, "Updated order status to $newStatus", userID, userName);
      }

      log("Order statuses updated successfully");
    } catch (e) {
      throw Exception("Error updating order statuses: $e");
    }
  }


  Future<void> startEditing(String orderID, String userID, String userName) async {
    try {
      final orderDocRef = _firestore.collection('orders').doc(orderID);
      final orderDoc = await orderDocRef.get();

      if (!orderDoc.exists) {
        throw Exception("Order does not exist.");
      }

      final data = orderDoc.data() as Map<String, dynamic>?;

      if (data == null) {
        throw Exception("Order data is missing.");
      }

      final isEditing = data['isEditing'] ?? false;
      final lastStartEditTime = (data['lastStartEditTime'] as Timestamp?)?.toDate();
      final now = DateTime.now();

      if (!isEditing) {
        // No one is editing, start editing
        await orderDocRef.update({
          'isEditing': true,
          'lastStartEditTime': now,
        });
        await logOrderAction(orderID, "Started editing", userID, userName);
        print("Editing started: $orderID");
      } else {
        // Someone is editing, check timeout
        if (lastStartEditTime != null) {
          final diff = now.difference(lastStartEditTime).inMinutes;
          if (diff > 3) {
            // Lock expired, allow taking over editing
            await orderDocRef.update({
              'isEditing': true,
              'lastStartEditTime': now,
            });
            await logOrderAction(orderID, "Took over editing after lock expired", userID, userName);
            print("Editing lock expired. Took over editing: $orderID");
          } else {
            throw Exception("Another user is currently editing this order.");
          }
        } else {
          throw Exception("Order is currently locked for editing.");
        }
      }
    } catch (e) {
      print("Error starting edit mode: $e");
      throw Exception("Error starting edit mode for order: $e");
    }
  }

  Future<void> stopEditing(String orderID, String userID, String userName) async {
    try {
      await _firestore.collection('orders').doc(orderID).update({
        'isEditing': false,
        'lastStartEditTime': null, // Reset lastStartEditTime after editing ends
      });

      await logOrderAction(orderID, "Stopped editing", userID, userName);
      print("Editing stopped: $orderID");
    } catch (e) {
      print("Error stopping edit mode: $e");
      throw Exception("Error stopping edit mode for order: $e");
    }
  }

// Check if user can edit the order
  Future<bool> canEditOrder(String orderID) async {
    final doc = await _firestore.collection('orders').doc(orderID).get();
    if (!doc.exists) return true; // No order doc means no lock

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
  Future<bool> isOrderLastStartEditTimeChanged(String orderID, DateTime? oldLastModifiedAt) async {
    print('Checking lastModifiedAt for order: $orderID');
    print('Old lastModifiedAt: $oldLastModifiedAt');

    final doc = await _firestore.collection('orders').doc(orderID).get();
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

  // Placeholder for the log function (assumed to exist elsewhere)
  void log(String message) {
    print(message); // Replace with your actual logging implementation
  }

  // Add a comment to an order
  Future<void> addOrderComment(
      String orderID, Comment comment, String userID, String userName) async {
    try {
      await _firestore.collection('orders').doc(orderID).update({
        'comments': FieldValue.arrayUnion([comment.toJson()]),
      });
      await logOrderAction(orderID, "Added a comment", userID, userName);
      log("Added comment to order: $orderID");
    } catch (e) {
      throw Exception("Error adding comment to order: $e");
    }
  }

  // Delete a comment from an order
  Future<void> deleteOrderComment(
      String orderID, Comment comment, String userID, String userName) async {
    try {
      await _firestore.collection('orders').doc(orderID).update({
        'comments': FieldValue.arrayRemove([comment.toJson()]),
      });
      await logOrderAction(orderID, "Deleted a comment", userID, userName);
      log("Deleted comment from order: $orderID");
    } catch (e) {
      throw Exception("Error deleting comment from order: $e");
    }
  }

  // Log order activity
  Future<void> logOrderAction(
      String orderID, String action, String userID, String userName) async {
    try {
      final logEntry = {
        'action': action,
        'timestamp': DateTime.now().toIso8601String(),
        'userID': userID,
        'userName': userName,
      };
      await _firestore.collection('orders').doc(orderID).update({
        'orderLogs': FieldValue.arrayUnion([logEntry]),
      });
      await _firestore.collection('users').doc(userID).update({
        'actionsLog': FieldValue.arrayUnion([
          {
            'action': action,
            'timestamp': DateTime.now().toIso8601String(),
          }
        ]),
      });
      log("Logged action for order: $orderID - $action");
    } catch (e) {
      throw Exception("Error logging order action: $e");
    }
  }

  // Stream orders
  Stream<List<OrderModel>> streamOrders() {
    return _firestore
        .collection('orders')
        .where('status', whereIn: ['Pending'])
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) =>
                  OrderModel.fromJson(doc.data() as Map<String, dynamic>))
              .toList();
        });
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
