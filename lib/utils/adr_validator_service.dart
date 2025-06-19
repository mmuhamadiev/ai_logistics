
import 'package:ai_logistics_management_order_automation/domain/models/order_model.dart';

class AdrValidatorService {
  /// Validates if the given list of orders can be grouped together.

  bool canGroupOrders(List<OrderModel> orders) {
    if (orders.isEmpty) return false;

    final hasAdrOrder = orders.any((o) => o.isAdrOrder);

    if (hasAdrOrder) {
      // Check if all non-ADR orders can group with ADR
      final nonAdrValid = orders.every((o) => o.isAdrOrder || o.canGroupWithAdr);
      if (!nonAdrValid) return false;

      // Check if there are multiple ADR orders and their grouping permissions
      final adrOrders = orders.where((o) => o.isAdrOrder).toList();
      if (adrOrders.length > 1) {
        return adrOrders.every((o) => o.canGroupWithAdr);
      }
      return true;
    }

    // No ADR orders - always allowed to group
    return true;
  }

}
