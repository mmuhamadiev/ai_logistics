part of 'order_list_cubit.dart';

abstract class OrderListState {}

class OrderListInitial extends OrderListState {}

class OrderListLoading extends OrderListState {}

class OrderListLoaded extends OrderListState {
  final List<OrderModel> orders;

  OrderListLoaded(this.orders);
}

class OrderListError extends OrderListState {
  final String message;

  OrderListError(this.message);
}

class OrderListActionLoading extends OrderListState {}
class OrderListAddingActionLoading extends OrderListState {}

class OrderListActionSuccess extends OrderListState {
  final String message;

  OrderListActionSuccess(this.message);
}

class OrderListActionError extends OrderListState {
  final String message;

  OrderListActionError(this.message);
}
