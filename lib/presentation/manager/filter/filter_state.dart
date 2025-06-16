part of 'filter_cubit.dart';

abstract class FilterState {}

class FilterInitial extends FilterState {}

class FilterLoading extends FilterState {}

class FilterSuccess extends FilterState {
  final String message;
  FilterSuccess({required this.message});
}

class FilterError extends FilterState {
  final String message;
  FilterError({required this.message});
}

class FilterLoaded extends FilterState {
  final FilterModel filter;
  FilterLoaded(this.filter);
}