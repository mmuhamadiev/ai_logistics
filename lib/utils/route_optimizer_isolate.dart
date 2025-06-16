import 'dart:math';

import 'package:isolate_manager/isolate_manager.dart';

// Top-level function for isolate with pragma annotation
@isolateManagerSharedWorker
List<int> optimizeRouteIsolate(Map<String, dynamic> params) {
  // Extract parameters
  List<Map<String, dynamic>> groupData = (params['group'] as List).cast<Map<String, dynamic>>();

  if (groupData.isEmpty) return [];

  double _degreesToRadians(double degrees) {
    return degrees * pi / 180.0;
  }

  // Helper function to calculate Haversine distance
  double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const double earthRadius = 6371.0; // Earth radius in km
    double dLat = _degreesToRadians(lat2 - lat1);
    double dLon = _degreesToRadians(lon2 - lon1);

    double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_degreesToRadians(lat1)) * cos(_degreesToRadians(lat2)) * sin(dLon / 2) * sin(dLon / 2);
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadius * c;
  }

  // Create a list of all pickup and delivery points from serialized data
  List<Map<String, dynamic>> points = [];
  for (var order in groupData) {
    points.add({
      'type': 'pickup',
      'orderId': order['orderId'], // Using a unique identifier instead of OrderModel object
      'lat': order['pickupPlace']['latitude'],
      'lon': order['pickupPlace']['longitude'],
    });
    points.add({
      'type': 'delivery',
      'orderId': order['orderId'],
      'lat': order['deliveryPlace']['latitude'],
      'lon': order['deliveryPlace']['longitude'],
    });
  }

  // Create a distance matrix
  int n = points.length;
  List<List<double>> distanceMatrix = List.generate(n, (i) => List.filled(n, 0.0));

  for (int i = 0; i < n; i++) {
    for (int j = 0; j < n; j++) {
      if (i != j) {
        distanceMatrix[i][j] = calculateDistance(
          points[i]['lat'],
          points[i]['lon'],
          points[j]['lat'],
          points[j]['lon'],
        );
      }
    }
  }

  // Solve TSP with constraints
  List<int> solveTSPWithConstraints(List<List<double>> distanceMatrix, List<Map<String, dynamic>> points) {
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
            int pickupIndex = points.indexWhere(
                    (p) => p['type'] == 'pickup' && p['orderId'] == points[i]['orderId']);
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

    return route;
  }

  // Perform TSP with Pickup-Delivery Constraints
  List<int> bestRoute = solveTSPWithConstraints(distanceMatrix, points);

  return bestRoute;
}