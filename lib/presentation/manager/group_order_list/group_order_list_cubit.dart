import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ai_logistics_management_order_automation/config/constants.dart';
import 'package:ai_logistics_management_order_automation/data/repositories/group_order_repository.dart';
import 'package:ai_logistics_management_order_automation/domain/models/commnet_model.dart';
import 'package:ai_logistics_management_order_automation/domain/models/driver_info_model.dart';
import 'package:ai_logistics_management_order_automation/domain/models/order_group_model.dart';
import 'package:ai_logistics_management_order_automation/domain/models/order_model.dart';

part 'group_order_list_state.dart';

class GroupOrderListCubit extends Cubit<GroupOrderListState> {
  final GroupOrderRepositoryImpl _groupOrderRepository;

  StreamSubscription<List<OrderGroupModel>>? _groupSubscription;
  List<OrderGroupModel> allGroups = []; // Cache the full list of groups for search/filter functionality

  String? searchQuery;
  Map<String, dynamic> selectedFilters = {};
  String? deletingGroupID; // Track the currently deleting order ID

  GroupOrderListCubit(this._groupOrderRepository) : super(GroupOrderListInitial());

  // Stream all groups
  void streamAllGroups() {
    _groupSubscription?.cancel(); // Cancel any previous subscription
    emit(GroupOrderListLoading()); // Emit loading state

    _groupSubscription = _groupOrderRepository.streamAllGroups().listen(
          (groups) {

            // Sort orders by createdAt in descending order
            groups.sort((a, b) => b.createdAt.compareTo(a.createdAt));

            Future.delayed(Duration(seconds: 2), () {
              allGroups = groups; // Store the full list of groups
              emit(GroupOrderListLoaded(groups)); // Emit the updated group list
            });
      },
      onError: (error) {
        emit(GroupOrderListError("Error streaming groups: $error")); // Handle errors
      },
    );
  }

  // Search orders by name
  void searchOrders(String query) {
    if (query.isEmpty) {
      searchQuery = '';
      var filteredGroups = allGroups;

      // Apply filters
      if (selectedFilters.containsKey('From') && selectedFilters['From'] != null) {
        filteredGroups = filteredGroups.where((group) {
          return group.orders.any((order) =>
          order.pickupPlace.countryCode == selectedFilters['From']);
        }).toList();
      }

      if (selectedFilters.containsKey('To') && selectedFilters['To'] != null) {
        filteredGroups = filteredGroups.where((group) {
          return group.orders.any((order) =>
          order.deliveryPlace.countryCode == selectedFilters['To']);
        }).toList();
      }

      if (selectedFilters.containsKey('DateRange') && selectedFilters['DateRange'] != null) {
        final dateRange = selectedFilters['DateRange'] as DateTimeRange;
        filteredGroups = filteredGroups.where((group) {
          return group.orders.any((order) =>
          order.pickupTimeWindow.start == null? DateTime.now().isAfter(dateRange.start): order.pickupTimeWindow.start!.isAfter(dateRange.start) &&
              order.deliveryTimeWindow.end.isBefore(dateRange.end));
        }).toList();
      }

      // Sort orders by createdAt in descending order
      filteredGroups.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      emit(GroupOrderListLoaded(filteredGroups)); // Reset to full list if query is empty
    } else {
      searchQuery = query;

      var filteredGroups = allGroups;

      // Apply 'From' filter
      if (selectedFilters.containsKey('From') && selectedFilters['From'] != null) {
        filteredGroups = filteredGroups.where((group) {
          return group.orders.any((order) =>
          order.pickupPlace.countryCode == selectedFilters['From']);
        }).toList();
      }

      // Apply 'To' filter
      if (selectedFilters.containsKey('To') && selectedFilters['To'] != null) {
        filteredGroups = filteredGroups.where((group) {
          return group.orders.any((order) =>
          order.deliveryPlace.countryCode == selectedFilters['To']);
        }).toList();
      }

      // Apply date range filter
      if (selectedFilters.containsKey('DateRange') && selectedFilters['DateRange'] != null) {
        final dateRange = selectedFilters['DateRange'] as DateTimeRange;
        filteredGroups = filteredGroups.where((group) {
          return group.orders.any((order) =>
          order.pickupTimeWindow.start == null? DateTime.now().isAfter(dateRange.start): order.pickupTimeWindow.start!.isAfter(dateRange.start) &&
              order.deliveryTimeWindow.end.isBefore(dateRange.end));
        }).toList();
      }

      // Apply search query
      filteredGroups = filteredGroups.where((group) {
        return group.orders.any((order) =>
            order.orderName.toLowerCase().contains(query.toLowerCase()));
      }).toList();

      // Sort orders by createdAt in descending order
      filteredGroups.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      emit(GroupOrderListLoaded(filteredGroups)); // Emit the filtered list
    }
  }

  // Apply filters dynamically
  void applyFilters(Map<String, dynamic> filters) {
    var filteredGroups = allGroups;
    selectedFilters = filters;

    // Apply 'From' filter
    if (filters.containsKey('From') && filters['From'] != null) {
      filteredGroups = filteredGroups.where((group) {
        return group.orders.any((order) =>
        order.pickupPlace.countryCode == filters['From']);
      }).toList();
    }

    // Apply 'To' filter
    if (filters.containsKey('To') && filters['To'] != null) {
      filteredGroups = filteredGroups.where((group) {
        return group.orders.any((order) =>
        order.deliveryPlace.countryCode == filters['To']);
      }).toList();
    }

    // Apply date range filter
    if (filters.containsKey('DateRange') && filters['DateRange'] != null) {
      final dateRange = filters['DateRange'] as DateTimeRange;
      filteredGroups = filteredGroups.where((group) {
        return group.orders.any((order) =>
        (order.pickupTimeWindow.start == null
            ? DateTime.now().isAfter(dateRange.start)
            : order.pickupTimeWindow.start!.isAfter(dateRange.start)) &&
            order.deliveryTimeWindow.end.isBefore(dateRange.end));
      }).toList();
    }

    // Apply search query
    if (searchQuery != null && searchQuery!.isNotEmpty) {
      filteredGroups = filteredGroups.where((group) {
        return group.orders.any((order) =>
            order.orderName.toLowerCase().contains(searchQuery!.toLowerCase()));
      }).toList();
    }

    // Sort orders by createdAt in descending order
    filteredGroups.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    emit(GroupOrderListLoaded(filteredGroups)); // Emit the filtered list
  }



  // Add a new group
  Future<void> addOrderGroup(OrderGroupModel group, String userID, String userName) async {
    try {
      emit(GroupOrderListActionLoading());
      await _groupOrderRepository.addOrderGroup(group, userID, userName);
      emit(GroupOrderListActionSuccess("Group added successfully."));
    } catch (error) {
      emit(GroupOrderListActionError("Error adding group: $error"));
    }
  }
  // Add a new group
  Future<void> updateOrderAndGroupOrderStatus(
      OrderModel updatedOrder, String groupID, String userID, String userName) async {
    try {
      emit(GroupOrderListActionLoading());
      await _groupOrderRepository.updateOrderAndGroupOrderStatus(updatedOrder, groupID, userID, userName);
      emit(GroupOrderListActionSuccess("Group and Order status Updated successfully."));
    } catch (error) {
      emit(GroupOrderListActionError("Error adding group: $error"));
    }
  }

  // Add a comment to a group
  Future<void> addGroupComment(String groupID, Comment comment, String userID, String userName) async {
    try {
      emit(GroupOrderListActionLoading());
      await _groupOrderRepository.addGroupComment(groupID, comment, userID, userName);
      emit(GroupOrderListActionSuccess("Comment added successfully."));
    } catch (error) {
      emit(GroupOrderListActionError("Error adding comment: $error"));
    }
  }

  // Delete a comment from a group
  Future<void> deleteGroupComment(String groupID, Comment comment, String userID, String userName) async {
    try {
      emit(GroupOrderListActionLoading());
      await _groupOrderRepository.deleteGroupComment(groupID, comment, userID, userName);
      emit(GroupOrderListActionSuccess("Comment deleted successfully."));
    } catch (error) {
      emit(GroupOrderListActionError("Error deleting comment: $error"));
    }
  }

  // Edit an order within a group
  Future<void> editOrderInGroup(String groupID,
      String newStatus,
      DriverInfo? newDriverInfo,
      String userID,
      String userName,
      bool? isNeedAddMore,
      Comment? carComment,
      ) async {
    try {
      emit(GroupOrderListActionLoading());
      await _groupOrderRepository.editOrderInGroup(groupID, newStatus, newDriverInfo, userID, userName, isNeedAddMore, carComment);
      emit(GroupOrderListActionSuccess("Order updated successfully in group."));
    } catch (error) {
      emit(GroupOrderListActionError("Error editing order in group: $error"));
    }
  }
  
  // Edit an order within a group
  Future<void> bulkUpdateGroupsAndOrdersStatus(
      List<String> groupIDs,
      OrderStatus newStatus,
      String userID,
      String userName,
      ) async {
    try {
      emit(GroupOrderListActionLoading());
      await _groupOrderRepository.bulkUpdateGroupsAndOrdersStatus(groupIDs, newStatus, userID, userName);
      emit(GroupOrderListActionSuccess("Order updated successfully in group."));
    } catch (error) {
      emit(GroupOrderListActionError("Error editing order in group: $error"));
    }
  }

  // Update an order within a group
  Future<void> updateOrderGroup(
      OrderGroupModel updatedGroup,
      String userID,
      String userName,
      OrderGroupModel oldGroupID, // Required parameter for the old groupID
      ) async {
    try {
      emit(GroupOrderListActionLoading());
      await _groupOrderRepository.updateOrderGroup(updatedGroup, userID, userName, oldGroupID);
      emit(GroupOrderListActionSuccess("Order updated successfully in group."));
    } catch (error) {
      emit(GroupOrderListActionError("Error editing order in group: $error"));
    }
  }

  // Update an order within a group
  Future<void> updateOrderInGroup(
      OrderGroupModel updatedGroup,
      String userID,
      String userName,
      OrderGroupModel oldGroupID, // Required parameter for the old groupID
      ) async {
    try {
      emit(GroupOrderListActionLoading());
      await _groupOrderRepository.updateOrderInGroup(updatedGroup, userID, userName, oldGroupID);
      emit(GroupOrderListActionSuccess("Order updated successfully in group."));
    } catch (error) {
      emit(GroupOrderListActionError("Error editing order in group: $error"));
    }
  }

  // Delete an group and update order status
  Future<void> deleteGroup(String groupID, OrderStatus newStatus, String userID, String userName) async {
    try {
      emit(GroupOrderListActionLoading());
      await _groupOrderRepository.deleteGroup(groupID, newStatus, userID, userName);
      emit(GroupOrderListActionSuccess("Order updated successfully in group."));
    } catch (error) {
      emit(GroupOrderListActionError("Error editing order in group: $error"));
    }
  }

  Future<void> closeSubscription() async{
    _groupSubscription?.cancel(); // Ensure the stream is closed
    allGroups.clear(); // Keep the full list of orders for filtering
    if(searchQuery != null) {
      searchQuery = null;
    }
    selectedFilters.clear();
    if(deletingGroupID != null) {
      deletingGroupID = null;
    }
  }

  Future<void> startGroupEditing(String groupID, String userID, String userName) async {
    await _groupOrderRepository.startGroupEditing(groupID, userID, userName);
  }

  Future<void> stopGroupEditing(String groupID, String userID, String userName) async{
    await _groupOrderRepository.stopGroupEditing(groupID, userID, userName);
  }

  Future<bool> canEditGroupOrder(String groupID) async {
    return await _groupOrderRepository.canGroupEditOrder(groupID);
  }

  Future<bool> isOrderLastStartGroupEditTimeChanged(String groupID, DateTime? oldLastStartEditTime) async {
    return await _groupOrderRepository.isOrderLastStartGroupEditTimeChanged(groupID, oldLastStartEditTime);
  }
}
