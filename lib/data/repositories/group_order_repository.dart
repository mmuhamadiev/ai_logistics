import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hegelmann_order_automation/config/constants.dart';
import 'package:hegelmann_order_automation/data/services/group_order_firebase_service.dart';
import 'package:hegelmann_order_automation/domain/models/commnet_model.dart';
import 'package:hegelmann_order_automation/domain/models/driver_info_model.dart';
import 'package:hegelmann_order_automation/domain/models/order_group_model.dart';
import 'package:hegelmann_order_automation/domain/models/order_model.dart';

/// Repository Interface for Group Order Operations
abstract class GroupOrderRepository {
  Future<void> addOrderGroup(OrderGroupModel group, String userID, String userName);
  Future<void> addGroupComment(String groupID, Comment comment, String userID, String userName);
  Future<void> deleteGroupComment(String groupID, Comment comment, String userID, String userName);
  Future<void> editOrderInGroup(String groupID,
      String newStatus,
      DriverInfo? newDriverInfo,
      String userID,
      String userName,
      bool? isNeedAddMore,
      Comment? carComment,
      );

  Future<void> updateOrderGroup(
      OrderGroupModel updatedGroup,
      String userID,
      String userName,
      OrderGroupModel oldGroupID, // Required parameter for the old groupID
      );

  Future<void> updateOrderInGroup(
      OrderGroupModel updatedGroup,
      String userID,
      String userName,
      OrderGroupModel oldGroupID, // Required parameter for the old groupID
      );

  Future<void> updateOrderAndGroupOrderStatus(
      OrderModel updatedOrder, String groupID, String userID, String userName);

  Future<void> deleteGroup(String groupID, OrderStatus newStatus, String userID, String userName);

  Stream<List<OrderGroupModel>> streamAllGroups();

  // Start editing an order
  Future<void> startGroupEditing(String groupID, String userID, String userName);

  // Stop editing an order
  Future<void> stopGroupEditing(String groupID, String userID, String userName);

  // Can edit
  Future<bool> canGroupEditOrder(String groupID);

  Future<bool> isOrderLastStartGroupEditTimeChanged(String groupID, DateTime? oldLastStartEditTime);

  Future<void> bulkUpdateGroupsAndOrdersStatus(
      List<String> groupIDs,
      OrderStatus newStatus,
      String userID,
      String userName,
      );
}

/// Implementation of GroupOrderRepository
class GroupOrderRepositoryImpl implements GroupOrderRepository {
  final GroupOrderService _groupOrderService;

  GroupOrderRepositoryImpl(this._groupOrderService);

  @override
  Future<void> addOrderGroup(OrderGroupModel group, String userID, String userName) {
    return _groupOrderService.addOrderGroup(group, userID, userName);
  }

  @override
  Future<void> addGroupComment(String groupID, Comment comment, String userID, String userName) {
    return _groupOrderService.addGroupComment(groupID, comment, userID, userName);
  }

  @override
  Future<void> deleteGroupComment(String groupID, Comment comment, String userID, String userName) {
    return _groupOrderService.deleteGroupComment(groupID, comment, userID, userName);
  }

  @override
  Future<void> editOrderInGroup(String groupID,
      String newStatus,
      DriverInfo? newDriverInfo,
      String userID,
      String userName,
      bool? isNeedAddMore,
      Comment? carComment,
      ) {
    return _groupOrderService.updateGroupAndOrdersStatusAndDriver(groupID, newStatus, newDriverInfo, userID, userName, isNeedAddMore, carComment);
  }

  @override
  Future<void> bulkUpdateGroupsAndOrdersStatus(
      List<String> groupIDs,
      OrderStatus newStatus,
      String userID,
      String userName,
      ) {
    return _groupOrderService.bulkUpdateGroupsAndOrdersStatus(groupIDs, newStatus, userID, userName);
  }

  @override
  Future<void> updateOrderGroup(
      OrderGroupModel updatedGroup,
      String userID,
      String userName,
      OrderGroupModel oldGroupID, // Required parameter for the old groupID
      ) {
    return _groupOrderService.updateOrderGroup(updatedGroup, userID, userName, oldGroupID);
  }

  @override
  Future<void> updateOrderInGroup(
      OrderGroupModel updatedGroup,
      String userID,
      String userName,
      OrderGroupModel oldGroupID, // Required parameter for the old groupID
      ) {
    return _groupOrderService.updateOrderInGroup(updatedGroup, userID, userName, oldGroupID);
  }

  @override
  Future<void> updateOrderAndGroupOrderStatus(
      OrderModel updatedOrder, String groupID, String userID, String userName) {
    return _groupOrderService.updateOrderAndGroupOrderStatus(updatedOrder, groupID, userID, userName);
  }

  @override
  Future<void> deleteGroup(String groupID, OrderStatus newStatus, String userID, String userName) {
    return _groupOrderService.deleteGroup(groupID, newStatus, userID, userName);
  }

  @override
  Stream<List<OrderGroupModel>> streamAllGroups() {
    return _groupOrderService.streamAllGroups();
  }

  @override
  Future<void> startGroupEditing(String groupID, String userID, String userName) async {
    return _groupOrderService.startGroupEditing(groupID, userID, userName);
  }

  @override
  Future<void> stopGroupEditing(String groupID, String userID, String userName) async{
    return _groupOrderService.stopGroupEditing(groupID, userID, userName);
  }

  @override
  Future<bool> canGroupEditOrder(String groupID) async {
    return _groupOrderService.canGroupEditOrder(groupID);
  }

  @override
  Future<bool> isOrderLastStartGroupEditTimeChanged(String groupID, DateTime? oldLastStartEditTime) async {
    return _groupOrderService.isOrderLastStartGroupEditTimeChanged(groupID, oldLastStartEditTime);
  }
}


