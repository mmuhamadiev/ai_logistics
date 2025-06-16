import 'package:isolate_manager/isolate_manager.dart';

/// Pure Dart function that works with List<Map<String, dynamic>>
@isolateManagerSharedWorker
bool canGroupOrders(List<Map<String, dynamic>> ordersData) {
  if (ordersData.isEmpty) return false;

  final hasAdrOrder = ordersData.any((o) => o['isAdrOrder'] as bool);

  if (hasAdrOrder) {
    final nonAdrValid = ordersData.every((o) => (o['isAdrOrder'] as bool) || (o['canGroupWithAdr'] as bool));
    if (!nonAdrValid) return false;

    final adrOrders = ordersData.where((o) => o['isAdrOrder'] as bool).toList();
    if (adrOrders.length > 1) {
      return adrOrders.every((o) => o['canGroupWithAdr'] as bool);
    }
    return true;
  }

  return true;
}