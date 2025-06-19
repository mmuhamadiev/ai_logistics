import 'dart:math';

import 'package:ai_logistics_management_order_automation/domain/models/order_model.dart';

class RouteOptimizer {
  /// Calculate Haversine Distance between two points
  static double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const double earthRadius = 6371.0; // Earth radius in km
    double dLat = _degreesToRadians(lat2 - lat1);
    double dLon = _degreesToRadians(lon2 - lon1);

    double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_degreesToRadians(lat1)) * cos(_degreesToRadians(lat2)) *
            sin(dLon / 2) * sin(dLon / 2);
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadius * c;
  }

  static double _degreesToRadians(double degrees) {
    return degrees * pi / 180.0;
  }

  /// Optimize route for a group of orders
  static List<int> optimizeRoute(List<OrderModel> group) {
    if (group.isEmpty) return [];

    // Create a list of all pickup and delivery points
    List<Map<String, dynamic>> points = [];
    for (var order in group) {
      points.add({'type': 'pickup', 'order': order, 'lat': order.pickupPlace.latitude, 'lon': order.pickupPlace.longitude});
      points.add({'type': 'delivery', 'order': order, 'lat': order.deliveryPlace.latitude, 'lon': order.deliveryPlace.longitude});
    }

    // Create a distance matrix
    int n = points.length;
    List<List<double>> distanceMatrix = List.generate(n, (i) => List.filled(n, 0.0));

    for (int i = 0; i < n; i++) {
      for (int j = 0; j < n; j++) {
        if (i != j) {
          distanceMatrix[i][j] = calculateDistance(
            points[i]['lat'], points[i]['lon'],
            points[j]['lat'], points[j]['lon'],
          );
        }
      }
    }

    // Perform TSP with Pickup-Delivery Constraints
    List<int> bestRoute = _solveTSPWithConstraints(distanceMatrix, points);

    return bestRoute;
    // // Build the optimized route
    // List<OrderModel> optimizedGroup = [];
    // for (int idx in bestRoute) {
    //   if (points[idx]['type'] == 'pickup') {
    //     optimizedGroup.add(points[idx]['order']);
    //   }
    // }
    //
    // return optimizedGroup;
  }

  /// Solve TSP with constraints using a heuristic (e.g., nearest neighbor)
  static List<int> _solveTSPWithConstraints(List<List<double>> distanceMatrix, List<Map<String, dynamic>> points) {
    int n = distanceMatrix.length;
    List<bool> visited = List.filled(n, false);
    List<int> route = [];

    // Start with the first pickup point
    int current = 0;
    visited[current] = true;
    route.add(current);

    while (route.length < n) {
      double minDistance = double.infinity;
      int next = -1;

      for (int i = 0; i < n; i++) {
        if (!visited[i] && distanceMatrix[current][i] < minDistance) {
          // Ensure pickup-delivery constraints are respected
          if (points[i]['type'] == 'delivery') {
            int pickupIndex = points.indexWhere((p) => p['type'] == 'pickup' && p['order'] == points[i]['order']);
            if (!visited[pickupIndex]) continue; // Skip if pickup is not yet visited
          }
          minDistance = distanceMatrix[current][i];
          next = i;
        }
      }

      if (next == -1) break; // No valid next point
      visited[next] = true;
      route.add(next);
      current = next;
    }

    print('route: ${route}');
    return route;
  }
}
