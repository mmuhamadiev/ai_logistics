import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ai_logistics_management_order_automation/domain/models/filter_model.dart';

class FirebaseFilterHelper {
  static const String collectionName = 'global_settings';
  static const String documentName = 'global_filter';

  final FirebaseFirestore _firestore;

  FirebaseFilterHelper(this._firestore);

  /// Save a filter to Firestore
  Future<void> saveFilter(FilterModel filter) async {
    try {
      await _firestore
          .collection(collectionName)
          .doc(documentName)
          .set(filter.toJson());
      print("Filter saved successfully.");
    } catch (e) {
      print("Error saving filter: $e");
      throw Exception("Failed to save filter.");
    }
  }

  /// Fetch the filter from Firestore
  Future<FilterModel?> fetchFilter() async {
    try {
      DocumentSnapshot snapshot =
      await _firestore.collection(collectionName).doc(documentName).get();

      if (snapshot.exists) {
        Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
        return FilterModel.fromJson(data);
      } else {
        print("No filter found, returning default filter.");
        return FilterModel.defaultFilters();
      }
    } catch (e) {
      print("Error fetching filter: $e");
      throw Exception("Failed to fetch filter.");
    }
  }

  /// Update specific fields in the filter
  Future<void> updateFilter(FilterModel updatedFilter) async {
    try {
      await _firestore
          .collection(collectionName)
          .doc(documentName)
          .update(updatedFilter.toJson());
      print("Filter updated successfully.");
    } catch (e) {
      print("Error updating filter: $e");
      throw Exception("Failed to update filter.");
    }
  }

  /// Delete the global filter (if needed)
  Future<void> deleteFilter() async {
    try {
      await _firestore.collection(collectionName).doc(documentName).delete();
      print("Filter deleted successfully.");
    } catch (e) {
      print("Error deleting filter: $e");
      throw Exception("Failed to delete filter.");
    }
  }
}
