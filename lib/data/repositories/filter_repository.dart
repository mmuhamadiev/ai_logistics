import 'package:hegelmann_order_automation/data/services/firebase_filter_helper.dart';
import 'package:hegelmann_order_automation/domain/models/filter_model.dart';

abstract class FilterRepository {
  /// Save a filter to Firestore
  Future<void> saveFilter(FilterModel filter);

  /// Fetch the filter from Firestore
  Future<FilterModel?> fetchFilter();

  /// Update specific fields in the filter
  Future<void> updateFilter(FilterModel updatedFilter);

  /// Delete the global filter (if needed)
  Future<void> deleteFilter();
}

class FilterRepositoryImpl implements FilterRepository {
  final FirebaseFilterHelper _filterHelper;

  FilterRepositoryImpl(this._filterHelper);

  @override
  Future<void> saveFilter(FilterModel filter) async {
    return await _filterHelper.saveFilter(filter);
  }

  @override
  Future<FilterModel?> fetchFilter() async {
    return await _filterHelper.fetchFilter();
  }

  @override
  Future<void> updateFilter(FilterModel updatedFilter) async {
    return await _filterHelper.updateFilter(updatedFilter);
  }

  @override
  Future<void> deleteFilter() async {
    return await _filterHelper.deleteFilter();
  }
}
