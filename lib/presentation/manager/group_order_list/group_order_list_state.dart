part of 'group_order_list_cubit.dart';

abstract class GroupOrderListState {}

class GroupOrderListInitial extends GroupOrderListState {}

class GroupOrderListLoading extends GroupOrderListState {}

class GroupOrderListLoaded extends GroupOrderListState {
  final List<OrderGroupModel> groups;

  GroupOrderListLoaded(this.groups);
}

class GroupOrderListError extends GroupOrderListState {
  final String message;

  GroupOrderListError(this.message);
}

class GroupOrderListActionLoading extends GroupOrderListState {}

class GroupOrderListActionSuccess extends GroupOrderListState {
  final String message;

  GroupOrderListActionSuccess(this.message);
}

class GroupOrderListActionError extends GroupOrderListState {
  final String message;

  GroupOrderListActionError(this.message);
}
