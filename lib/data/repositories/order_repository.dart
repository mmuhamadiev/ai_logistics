import 'package:ai_logistics_management_order_automation/data/services/order_firebase_service.dart';
import 'package:ai_logistics_management_order_automation/domain/models/commnet_model.dart';
import 'package:ai_logistics_management_order_automation/domain/models/order_model.dart';

abstract class OrderRepository {
  Future<void> deleteOrder(String orderID, String userID, String userName);
  Future<bool> deleteOrders(List<String> orderIDs, String userID, String userName);
  Future<void> addOrder(OrderModel order, String userID, String userName);
  Future<void> editOrder(OrderModel order, String userID, String userName);
  Future<void> updateOrderStatusBulk(
      List<String> orderIDs, String newStatus, String userID, String userName);
  Future<void> startEditing(String orderID, String userID, String userName);
  Future<void> stopEditing(String orderID, String userID, String userName);
  Future<bool> canEditOrder(String orderID);
  Future<bool> isOrderLastStartEditTimeChanged(String orderID, DateTime? oldLastStartEditTime);
  Future<void> addOrderComment(String orderID, Comment comment, String userID, String userName);
  Future<void> deleteOrderComment(String orderID, Comment comment, String userID, String userName);
  Future<void> logOrderAction(String orderID, String action, String userID, String userName);
  Stream<List<OrderModel>> streamOrders();
}

class OrderRepositoryImpl implements OrderRepository {
  final OrderService _orderService;

  OrderRepositoryImpl(this._orderService);

  @override
  Future<bool> deleteOrder(String orderID, String userID, String userName) async {
      return await _orderService.deleteOrder(orderID, userID, userName);
  }

  @override
  Future<bool> deleteOrders(List<String> orderIDs, String userID, String userName) async {
      return await _orderService.deleteOrders(orderIDs, userID, userName);
  }

  @override
  Future<void> addOrder(OrderModel order, String userID, String userName) {
    return _orderService.addOrder(order, userID, userName);
  }

  @override
  Future<void> editOrder(OrderModel order, String userID, String userName) {
    return _orderService.editOrder(order, userID, userName);
  }

  @override
  Future<void> startEditing(String orderID, String userID, String userName) {
    return _orderService.startEditing(orderID, userID, userName);
  }

  @override
  Future<void> stopEditing(String orderID, String userID, String userName) {
    return _orderService.stopEditing(orderID, userID, userName);
  }

  @override
  Future<void> updateOrderStatusBulk(List<String> orderIDs, String newStatus, String userID, String userName) {
    return _orderService.updateOrderStatusBulk(orderIDs, newStatus, userID, userName);
  }

  @override
  Future<bool> canEditOrder(String orderID) {
    return _orderService.canEditOrder(orderID);
  }

  @override
  Future<bool> isOrderLastStartEditTimeChanged(String orderID, DateTime? oldLastStartEditTime) {
    return _orderService.isOrderLastStartEditTimeChanged(orderID, oldLastStartEditTime);
  }

  @override
  Future<void> addOrderComment(String orderID, Comment comment, String userID, String userName) {
    return _orderService.addOrderComment(orderID, comment, userID, userName);
  }

  @override
  Future<void> deleteOrderComment(String orderID, Comment comment, String userID, String userName) {
    return _orderService.deleteOrderComment(orderID, comment, userID, userName);
  }

  @override
  Future<void> logOrderAction(String orderID, String action, String userID, String userName) {
    return _orderService.logOrderAction(orderID, action, userID, userName);
  }

  @override
  Stream<List<OrderModel>> streamOrders() {
    return _orderService.streamOrders();
  }
}
