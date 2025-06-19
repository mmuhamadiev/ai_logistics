import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ai_logistics_management_order_automation/config/constants.dart';
import 'package:ai_logistics_management_order_automation/data/repositories/order_repository.dart';
import 'package:ai_logistics_management_order_automation/domain/models/commnet_model.dart';
import 'package:ai_logistics_management_order_automation/domain/models/order_model.dart';

part 'order_list_state.dart';

class OrderListCubit extends Cubit<OrderListState> {
  final OrderRepositoryImpl _orderRepositoryImpl;

  StreamSubscription<List<OrderModel>>? _ordersSubscription;
  List<OrderModel> allOrders = []; // Keep the full list of orders for filtering
  String? searchQuery;
  OrderStatus? filterStatus;
  Map<String, dynamic> selectedFilters = {};
  String? deletingOrderID; // Track the currently deleting order ID
  late TabController tabController;

  OrderListCubit(this._orderRepositoryImpl) : super(OrderListInitial());

  // Stream orders
  void streamOrders() {
    // Cancel any previous subscription
    if (_ordersSubscription != null) {
      print("Cancelling existing order subscription...");
      _ordersSubscription?.cancel();
    }

    print("Starting to stream orders...");
    emit(OrderListLoading()); // Emit loading state

    _ordersSubscription = _orderRepositoryImpl.streamOrders().listen(
          (orders) {
        print("Received ${orders.length} orders from the stream."); // Debugging the number of orders
        Future.delayed(Duration(seconds: 2), () {
          allOrders = orders; // Store the full order list
          emit(OrderListLoaded(orders)); // Emit the updated order list
          // try {
          //   final selectedStatus = OrderStatus.values.toList()[tabController.index];
          //   filterByStatus(selectedStatus);
          // } catch(e) {
          //   final selectedStatus = OrderStatus.values.toList()[0];
          //   filterByStatus(selectedStatus);
          // }
        });
      },
      onError: (error) {
        print("Error while streaming orders: $error"); // Print the error
        emit(OrderListError("Error streaming orders: $error")); // Handle errors
      },
      onDone: () {
        print("Order streaming completed."); // Notify when the stream is done
      },
    );

    print("Order stream subscription initialized.");
  }


  // Filter orders by status
  // void filterByStatus(OrderStatus status) {
  //   filterStatus = status;
  //   var filteredOrders = allOrders.where((order) => order.status == status).toList();
  //   if (selectedFilters.containsKey('From') && selectedFilters['From'] != null) {
  //     filteredOrders = filteredOrders.where((order) {
  //       return order.pickupPlace.countryCode == selectedFilters['From'];
  //     }).toList();
  //   }
  //
  //   if (selectedFilters.containsKey('To') && selectedFilters['To'] != null) {
  //     filteredOrders = filteredOrders.where((order) {
  //       return order.deliveryPlace.countryCode == selectedFilters['To'];
  //     }).toList();
  //   }
  //
  //   if (selectedFilters.containsKey('DateRange') && selectedFilters['DateRange'] != null) {
  //     final dateRange = selectedFilters['DateRange'] as DateTimeRange;
  //     filteredOrders = filteredOrders.where((order) {
  //       return order.pickupTimeWindow.start == null? DateTime.now().isAfter(dateRange.start): order.pickupTimeWindow.start!.isAfter(dateRange.start) &&
  //           order.deliveryTimeWindow.end.isBefore(dateRange.end);
  //     }).toList();
  //   }
  //
  //   print(searchQuery);
  //   if (searchQuery != null && searchQuery!.isNotEmpty) {
  //     filteredOrders = filteredOrders.where((order) {
  //       return order.orderName.toLowerCase().contains(searchQuery!);
  //     }).toList();
  //   }
  //
  //   emit(OrderListLoaded(filteredOrders)); // Emit the filtered list
  // }


  // Search orders by name
  // void searchOrders(String query) {
  //   if (query.isEmpty) {
  //     searchQuery = '';
  //     var filteredOrders = allOrders;
  //
  //     // Apply search query if it exists
  //     if (filterStatus != null) {
  //       filteredOrders = filteredOrders.where((order) => order.status == filterStatus).toList();
  //     }
  //
  //     if (selectedFilters.containsKey('From') && selectedFilters['From'] != null) {
  //       filteredOrders = filteredOrders.where((order) {
  //         return order.pickupPlace.countryCode == selectedFilters['From'];
  //       }).toList();
  //     }
  //
  //     if (selectedFilters.containsKey('To') && selectedFilters['To'] != null) {
  //       filteredOrders = filteredOrders.where((order) {
  //         return order.deliveryPlace.countryCode == selectedFilters['To'];
  //       }).toList();
  //     }
  //
  //     if (selectedFilters.containsKey('DateRange') && selectedFilters['DateRange'] != null) {
  //       final dateRange = selectedFilters['DateRange'] as DateTimeRange;
  //       filteredOrders = filteredOrders.where((order) {
  //         return order.pickupTimeWindow.start == null? DateTime.now().isAfter(dateRange.start): order.pickupTimeWindow.start!.isAfter(dateRange.start) &&
  //             order.deliveryTimeWindow.end.isBefore(dateRange.end);
  //       }).toList();
  //     }
  //     emit(OrderListLoaded(filteredOrders)); // Reset to full list if query is empty
  //   } else {
  //     searchQuery = query;
  //
  //     var filteredOrders = allOrders;
  //
  //     if (filterStatus != null) {
  //       filteredOrders = filteredOrders.where((order) => order.status == filterStatus).toList();
  //     }
  //     if (selectedFilters.containsKey('From') && selectedFilters['From'] != null) {
  //       filteredOrders = filteredOrders.where((order) {
  //         return order.pickupPlace.countryCode == selectedFilters['From'];
  //       }).toList();
  //     }
  //
  //     if (selectedFilters.containsKey('To') && selectedFilters['To'] != null) {
  //       filteredOrders = filteredOrders.where((order) {
  //         return order.deliveryPlace.countryCode == selectedFilters['To'];
  //       }).toList();
  //     }
  //
  //     if (selectedFilters.containsKey('DateRange') && selectedFilters['DateRange'] != null) {
  //       final dateRange = selectedFilters['DateRange'] as DateTimeRange;
  //       filteredOrders = filteredOrders.where((order) {
  //         return order.pickupTimeWindow.start == null? DateTime.now().isAfter(dateRange.start): order.pickupTimeWindow.start!.isAfter(dateRange.start) &&
  //             order.deliveryTimeWindow.end.isBefore(dateRange.end);
  //       }).toList();
  //     }
  //
  //     filteredOrders = filteredOrders
  //         .where((order) =>
  //         order.orderName.toLowerCase().contains(query.toLowerCase()))
  //         .toList();
  //
  //     emit(OrderListLoaded(filteredOrders)); // Emit the filtered list
  //   }
  // }

  // Apply filters dynamically
  // void applyFilters(Map<String, dynamic> filters) {
  //   var filteredOrders = allOrders;
  //   selectedFilters = filters;
  //
  //   if (filterStatus != null) {
  //     filteredOrders = filteredOrders.where((order) => order.status == filterStatus).toList();
  //   }
  //
  //   if (filters.containsKey('From') && filters['From'] != null) {
  //     filteredOrders = filteredOrders.where((order) {
  //       return order.pickupPlace.countryCode == filters['From'];
  //     }).toList();
  //   }
  //
  //   if (filters.containsKey('To') && filters['To'] != null) {
  //     filteredOrders = filteredOrders.where((order) {
  //       return order.deliveryPlace.countryCode == filters['To'];
  //     }).toList();
  //   }
  //
  //   if (filters.containsKey('DateRange') && filters['DateRange'] != null) {
  //     final dateRange = filters['DateRange'] as DateTimeRange;
  //     print("🔍 Filtering orders within Date Range: ${dateRange.start} - ${dateRange.end}");
  //
  //     filteredOrders = filteredOrders.where((order) {
  //       print("➡ Checking Order ID: ${order.orderID}");  // Assuming order has an ID
  //       print("   📦 Pickup Time: ${order.pickupTimeWindow.start}");
  //       print("   🚚 Delivery Time: ${order.deliveryTimeWindow.end}");
  //
  //       bool isPickupValid = order.pickupTimeWindow.start == null
  //           ? DateTime.now().isAfter(dateRange.start) || DateTime.now().isAtSameMomentAs(dateRange.start)
  //           : order.pickupTimeWindow.start!.isAfter(dateRange.start) || order.pickupTimeWindow.start!.isAtSameMomentAs(dateRange.start);
  //
  //       bool isDeliveryValid = order.deliveryTimeWindow.end.isBefore(dateRange.end) || order.deliveryTimeWindow.end.isAtSameMomentAs(dateRange.end);
  //
  //       print("   ✅ Pickup Valid: $isPickupValid");
  //       print("   ✅ Delivery Valid: $isDeliveryValid");
  //
  //       return isPickupValid && isDeliveryValid;
  //     }).toList();
  //
  //     print("📊 Total Orders After Filtering: ${filteredOrders.length}");
  //   }
  //
  //
  //   // Apply search query
  //   if (searchQuery != null && searchQuery!.isNotEmpty) {
  //     filteredOrders = filteredOrders.where((order) {
  //       return order.orderName.toLowerCase().contains(searchQuery!);
  //     }).toList();
  //   }
  //
  //   emit(OrderListLoaded(filteredOrders)); // Emit the filtered list
  // }

  Future<void> deleteOrder(String orderID, String userID, String userName) async {
    try {
      deletingOrderID = orderID;
      emit(OrderListActionLoading());
      await _orderRepositoryImpl.deleteOrder(orderID, userID, userName);
      deletingOrderID = null; // Reset after deletion
      emit(OrderListActionSuccess("Order deleted successfully."));
    } catch (error) {
      deletingOrderID = null; // Reset on error
      emit(OrderListActionError("Error deleting order: $error"));
    }
  }

  Future<void> deleteOrders(List<String> orderIDs, String userID, String userName) async {
    try {
      emit(OrderListActionLoading());
      await _orderRepositoryImpl.deleteOrders(orderIDs, userID, userName);
      emit(OrderListActionSuccess("Order deleted successfully."));
    } catch (error) {
      deletingOrderID = null; // Reset on error
      emit(OrderListActionError("Error deleting order: $error"));
    }
  }

  // Add a new order
  Future<void> addOrder(OrderModel order, String userID, String userName) async {
    try {
      emit(OrderListActionLoading());
      await _orderRepositoryImpl.addOrder(order, userID, userName);
      emit(OrderListActionSuccess("Order added successfully."));
    } on FirebaseException catch (e) {
      // Catch Firestore-related errors
      emit(OrderListActionError("Firebase Error: ${e.message}"));
    } on Exception catch (e) {
      // Catch general exceptions
      emit(OrderListActionError(e.toString().replaceAll("Exception: ", "")));
    } catch (e) {
      // Catch any other unexpected errors
      emit(OrderListActionError("Unexpected error: $e"));
    }
  }

  // Edit an existing order
  Future<void> editOrder(OrderModel order, String userID, String userName) async {
    try {
      emit(OrderListActionLoading());
      await _orderRepositoryImpl.editOrder(order, userID, userName);
      emit(OrderListActionSuccess("Order updated successfully."));
    } catch (error) {
      emit(OrderListActionError("Error updating order: $error"));
    }
  }

  // Edit an existing order
  Future<void>updateOrderStatusBulk(
      List<String> orderIDs, String newStatus, String userID, String userName) async {
    try {
      emit(OrderListActionLoading());
      await _orderRepositoryImpl.updateOrderStatusBulk(orderIDs, newStatus, userID, userName);
      emit(OrderListActionSuccess("Order updated successfully."));
    } catch (error) {
      emit(OrderListActionError("Error updating order: $error"));
    }
  }

  // Start Edit an existing order
  Future<void> startEditing(String orderID, String userID, String userName) async {
      await _orderRepositoryImpl.startEditing(orderID, userID, userName);
  }
  // Stop Edit an existing order
  Future<void> stopEditing(String orderID, String userID, String userName) async {
      await _orderRepositoryImpl.stopEditing(orderID, userID, userName);
  }

  // Can Edit an existing order
  Future<bool> canEditing(String orderID) async {
    return await _orderRepositoryImpl.canEditOrder(orderID);
  }

  // IsOrderLastStartEditTimeChanged an existing order
  Future<bool> isOrderLastStartEditTimeChanged(String orderID, DateTime? oldLastStartEditTime) async {
    return await _orderRepositoryImpl.isOrderLastStartEditTimeChanged(orderID, oldLastStartEditTime);
  }

  // Add a comment to an order
  Future<void> addOrderComment(String orderID, Comment comment, String userID, String userName) async {
    try {
      emit(OrderListAddingActionLoading());
      await _orderRepositoryImpl.addOrderComment(orderID, comment, userID, userName);
      emit(OrderListActionSuccess("Comment added successfully."));
    } catch (error) {
      emit(OrderListActionError("Error adding comment: $error"));
    }
  }

  // Delete a comment from an order
  Future<void> deleteOrderComment(String orderID, Comment comment, String userID, String userName) async {
    try {
      emit(OrderListActionLoading());
      await _orderRepositoryImpl.deleteOrderComment(orderID, comment, userID, userName);
      emit(OrderListActionSuccess("Comment deleted successfully."));
    } catch (error) {
      emit(OrderListActionError("Error deleting comment: $error"));
    }
  }

  // Log an action for an order
  Future<void> logOrderAction(String orderID, String action, String userID, String userName) async {
    try {
      await _orderRepositoryImpl.logOrderAction(orderID, action, userID, userName);
    } catch (error) {
      emit(OrderListActionError("Error logging order action: $error"));
    }
  }

  Future<void> closeSubscription() async{
    _ordersSubscription?.cancel(); // Ensure the stream is closed
    allOrders.clear(); // Keep the full list of orders for filtering
    if(searchQuery != null) {
      searchQuery = null;
    }
    if(filterStatus != null) {
      filterStatus = null;
    }
    selectedFilters.clear();
    if(deletingOrderID != null) {
      deletingOrderID = null;
    }
  }
}
