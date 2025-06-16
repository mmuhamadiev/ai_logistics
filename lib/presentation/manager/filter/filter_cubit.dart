import 'package:bloc/bloc.dart';
import 'package:hegelmann_order_automation/data/repositories/filter_repository.dart';
import 'package:hegelmann_order_automation/domain/models/filter_model.dart';

part 'filter_state.dart';

class FilterCubit extends Cubit<FilterState> {
  final FilterRepositoryImpl _filterRepositoryImpl;

  FilterCubit(this._filterRepositoryImpl) : super(FilterInitial());

  /// Ensure a global filter exists on app start
  Future<void> initializeGlobalFilter() async {
    emit(FilterLoading());
    try {
      final existingFilter = await _filterRepositoryImpl.fetchFilter();
      if (existingFilter == null) {
        final defaultFilter = FilterModel.defaultFilters();
        await _filterRepositoryImpl.saveFilter(defaultFilter);
        emit(FilterLoaded(defaultFilter));
      } else {
        emit(FilterLoaded(existingFilter));
      }
    } catch (e) {
      emit(FilterError(message: "Failed to initialize global filter: ${e.toString()}"));
    }
  }

  /// Fetch the global filter from Firestore
  Future<void> fetchFilter() async {
    emit(FilterLoading());
    try {
      final filter = await _filterRepositoryImpl.fetchFilter();
      emit(FilterLoaded(filter ?? FilterModel.defaultFilters()));
    } catch (e) {
      emit(FilterError(message: "Failed to fetch filter: ${e.toString()}"));
    }
  }

  /// Save a new global filter to Firestore
  Future<void> saveFilter(FilterModel filter) async {
    emit(FilterLoading());
    try {
      await _filterRepositoryImpl.saveFilter(filter);
      emit(FilterSuccess(message: "Filter saved successfully."));
      emit(FilterLoaded(filter));
    } catch (e) {
      emit(FilterError(message: "Failed to save filter: ${e.toString()}"));
    }
  }

  /// Update an existing filter in Firestore
  Future<void> updateFilter(FilterModel updatedFilter) async {
    emit(FilterLoading());
    try {
      await _filterRepositoryImpl.updateFilter(updatedFilter);
      emit(FilterSuccess(message: "Filter updated successfully."));
      emit(FilterLoaded(updatedFilter));
    } catch (e) {
      emit(FilterError(message: "Failed to update filter: ${e.toString()}"));
    }
  }

  /// Delete the global filter from Firestore
  Future<void> deleteFilter() async {
    emit(FilterLoading());
    try {
      await _filterRepositoryImpl.deleteFilter();
      emit(FilterLoaded(FilterModel.defaultFilters()));
    } catch (e) {
      emit(FilterError(message: "Failed to delete filter: ${e.toString()}"));
    }
  }
}
