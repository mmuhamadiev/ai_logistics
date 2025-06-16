// clustering_isolate.dart
import 'dart:convert';
import 'dart:math';
import 'package:isolate_manager/isolate_manager.dart';

@pragma('vm:entry-point')
@isolateManagerWorker
String performClusteringIsolate(dynamic params) {
  print("Isolate received params of type: ${params.runtimeType}");
  print("Raw params length: ${(params as String).length}");

  if (params is! String) {
    throw Exception("Expected params to be a JSON string, got ${params.runtimeType}");
  }

  final input = jsonDecode(params) as Map<String, dynamic>;

  // Extract parameters
  List<Map<String, dynamic>> ordersData = (input['orders'] as List).cast<Map<String, dynamic>>();
  double eps = input['eps'] ?? 200.0;
  int minPts = input['minPts'] ?? 2;
  double minPricePerKm = input['minPricePerKm'] ?? 2.0;
  double maxRadius = input['maxRadius'] ?? 200.0;
  List<Map<String, dynamic>> carTypesData = (input['carTypes'] as List).cast<Map<String, dynamic>>();
  String currentTime = input['currentTime'];

  print("Isolate parameters extracted: orders=${ordersData.length}, eps=$eps km, minPts=$minPts, minPricePerKm=$minPricePerKm, maxRadius=$maxRadius km, currentTime=$currentTime");

  // Helper functions
  double _degreesToRadians(double degrees) => degrees * pi / 180;
  DateTime max(DateTime a, DateTime b) => a.isAfter(b) ? a : b;
  DateTime min(DateTime a, DateTime b) => a.isBefore(b) ? a : b;

  double calculateDistance(double lat1, double lon1, double lat2, double lon2, {double errorMargin = 0.15}) {
    const double earthRadius = 6371.0;
    double dLat = _degreesToRadians(lat2 - lat1);
    double dLon = _degreesToRadians(lon2 - lon1);
    double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_degreesToRadians(lat1)) * cos(_degreesToRadians(lat2)) * sin(dLon / 2) * sin(dLon / 2);
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    double straightLineDistance = earthRadius * c;
    return straightLineDistance * (1 + errorMargin);
  }

  double calculateOrderPricePerKm(Map<String, dynamic> order) {
    double distance = calculateDistance(
      order['pickupPlace']['latitude'],
      order['pickupPlace']['longitude'],
      order['deliveryPlace']['latitude'],
      order['deliveryPlace']['longitude'],
    );
    double pricePerKm = distance > 0 ? order['price'] / distance : 0.0;
    print("  OrderID: ${order['orderID']}, Distance: ${distance.toStringAsFixed(2)} km, Price/Km: ${pricePerKm.toStringAsFixed(2)} EUR/km");
    return pricePerKm;
  }

  bool isBestOrder(Map<String, dynamic> order, double minPricePerKm) {
    double pricePerKm = calculateOrderPricePerKm(order);
    var carType = carTypesData.firstWhere((type) => type['name'] == order['carTypeName'], orElse: () => {});
    if (carType.isEmpty) {
      print("  OrderID: ${order['orderID']} - Car type '${order['carTypeName']}' not found.");
      return false;
    }

    DateTime nowInGermanTime = DateTime.parse(currentTime);
    DateTime pickupEnd = DateTime.parse(order['pickupTimeWindow']['end']);

    bool weightOk = order['weight'] <= carType['maxWeight'];
    bool ldmOk = order['ldm'] <= carType['length'];
    bool priceOk = pricePerKm >= minPricePerKm;
    bool timeOk = pickupEnd.isAfter(nowInGermanTime);

    print("  OrderID: ${order['orderID']}, Weight OK: $weightOk (${order['weight']} <= ${carType['maxWeight']}), LDM OK: $ldmOk (${order['ldm']} <= ${carType['length']}), Price OK: $priceOk ($pricePerKm >= $minPricePerKm), Time OK: $timeOk (Pickup End: $pickupEnd > Now: $nowInGermanTime)");

    return weightOk && ldmOk && priceOk && timeOk;
  }

  bool canGroupOrders(List<Map<String, dynamic>> orders) {
    if (orders.isEmpty) return false;

    final hasAdrOrder = orders.any((o) => o['isAdrOrder'] as bool);
    if (hasAdrOrder) {
      final nonAdrValid = orders.every((o) => (o['isAdrOrder'] as bool) || (o['canGroupWithAdr'] as bool));
      if (!nonAdrValid) {
        print("  Group ADR validation failed: Non-ADR order cannot group with ADR.");
        return false;
      }

      final adrOrders = orders.where((o) => o['isAdrOrder'] as bool).toList();
      if (adrOrders.length > 1) {
        bool allCanGroup = adrOrders.every((o) => o['canGroupWithAdr'] as bool);
        print("  Multiple ADR orders: Can group with ADR: $allCanGroup");
        return allCanGroup;
      }
      print("  Single ADR order detected, grouping OK.");
      return true;
    }
    print("  No ADR orders, grouping OK.");
    return true;
  }

  List<int> optimizeRoute(List<Map<String, dynamic>> group) {
    if (group.isEmpty) return [];

    print("  Optimizing route for group: ${group.map((o) => o['orderID']).join(', ')}");

    List<Map<String, dynamic>> points = [];
    for (var order in group) {
      points.add({
        'type': 'pickup',
        'orderId': order['orderID'],
        'lat': order['pickupPlace']['latitude'],
        'lon': order['pickupPlace']['longitude'],
      });
      points.add({
        'type': 'delivery',
        'orderId': order['orderID'],
        'lat': order['deliveryPlace']['latitude'],
        'lon': order['deliveryPlace']['longitude'],
      });
    }

    int n = points.length;
    List<List<double>> distanceMatrix = List.generate(n, (i) => List.filled(n, 0.0));
    for (int i = 0; i < n; i++) {
      for (int j = 0; j < n; j++) {
        if (i != j) {
          distanceMatrix[i][j] = calculateDistance(points[i]['lat'], points[i]['lon'], points[j]['lat'], points[j]['lon']);
        }
      }
    }

    List<bool> visited = List.filled(n, false);
    List<int> route = [];
    int current = 0;
    visited[current] = true;
    route.add(current);

    while (route.length < n) {
      double minDistance = double.infinity;
      int next = -1;
      for (int i = 0; i < n; i++) {
        if (!visited[i] && distanceMatrix[current][i] < minDistance) {
          if (points[i]['type'] == 'delivery') {
            int pickupIndex = points.indexWhere((p) => p['type'] == 'pickup' && p['orderId'] == points[i]['orderId']);
            if (!visited[pickupIndex]) continue;
          }
          minDistance = distanceMatrix[current][i];
          next = i;
        }
      }
      if (next == -1) break;
      visited[next] = true;
      route.add(next);
      current = next;
    }

    print("  Optimized route: ${route.map((i) => "${points[i]['type']}-${points[i]['orderId']}").join(' -> ')}");
    return route;
  }

  bool validateTimeWindows(List<Map<String, dynamic>> group, List<int> optimizedGroup) {
    if (group.isEmpty || optimizedGroup.isEmpty) {
      print("  Time window validation failed: Group or route empty.");
      return false;
    }

    DateTime parseDateTime(String value) => DateTime.parse(value);
    DateTime now = DateTime.parse(currentTime);
    DateTime minStartDate = now;
    DateTime maxEndDate = now;

    print("  Validating time windows for group: ${group.map((o) => o['orderID']).join(', ')}");

    for (var order in group) {
      DateTime pickupStart = parseDateTime(order['pickupTimeWindow']['start']);
      DateTime deliveryEnd = parseDateTime(order['deliveryTimeWindow']['end']);
      minStartDate = min(minStartDate, pickupStart);
      maxEndDate = max(maxEndDate, deliveryEnd);
      print("    OrderID: ${order['orderID']}, Pickup: $pickupStart - $deliveryEnd");
    }

    for (var order in group) {
      DateTime pickupStart = parseDateTime(order['pickupTimeWindow']['start']);
      DateTime pickupEnd = parseDateTime(order['pickupTimeWindow']['end']);
      if (pickupStart.isAfter(pickupEnd)) {
        print("    OrderID: ${order['orderID']} - Pickup start after end: $pickupStart > $pickupEnd");
        return false;
      }
    }

    List<Map<String, dynamic>> timeWindows = [];
    for (int index in optimizedGroup) {
      if (index == 0) timeWindows.add({'start': group[0]['pickupTimeWindow']['start'], 'end': group[0]['pickupTimeWindow']['end']});
      else if (index == 1) timeWindows.add({'start': group[0]['deliveryTimeWindow']['start'], 'end': group[0]['deliveryTimeWindow']['end']});
      else if (index == 2) timeWindows.add({'start': group[1]['pickupTimeWindow']['start'], 'end': group[1]['pickupTimeWindow']['end']});
      else if (index == 3) timeWindows.add({'start': group[1]['deliveryTimeWindow']['start'], 'end': group[1]['deliveryTimeWindow']['end']});
      else if (index == 4) timeWindows.add({'start': group[2]['pickupTimeWindow']['start'], 'end': group[2]['pickupTimeWindow']['end']});
      else if (index == 5) timeWindows.add({'start': group[2]['deliveryTimeWindow']['start'], 'end': group[2]['deliveryTimeWindow']['end']});
    }

    bool isTimeWindowWithinRange(Map<String, dynamic> a, Map<String, dynamic> b) {
      DateTime aStart = parseDateTime(a['start']);
      DateTime bStart = parseDateTime(b['start']);
      DateTime aStartDay = DateTime(aStart.year, aStart.month, aStart.day);
      DateTime aEndDay = DateTime(parseDateTime(a['end']).year, parseDateTime(a['end']).month, parseDateTime(a['end']).day);
      DateTime bStartDay = DateTime(bStart.year, bStart.month, bStart.day);
      DateTime bEndDay = DateTime(parseDateTime(b['end']).year, parseDateTime(b['end']).month, parseDateTime(b['end']).day);
      bool result = (aStartDay.isBefore(bEndDay) || aStartDay.isAtSameMomentAs(bEndDay)) &&
          (aEndDay.isAfter(bStartDay) || aEndDay.isAtSameMomentAs(bStartDay));
      print("      Time Window Check: $aStartDay - $aEndDay vs $bStartDay - $bEndDay: $result");
      return result;
    }

    bool isTimeWindowWithinRangeForThree(Map<String, dynamic> a, Map<String, dynamic> b, Map<String, dynamic> c) {
      DateTime aStart = parseDateTime(a['start']);
      DateTime bStart = parseDateTime(b['start']);
      DateTime cStart = parseDateTime(c['start']);
      if (aStart.isAfter(parseDateTime(a['end']))) return false;
      if (bStart.isAfter(parseDateTime(b['end']))) return false;
      if (cStart.isAfter(parseDateTime(c['end']))) return false;

      DateTime aStartDay = DateTime(aStart.year, aStart.month, aStart.day);
      DateTime aEndDay = DateTime(parseDateTime(a['end']).year, parseDateTime(a['end']).month, parseDateTime(a['end']).day);
      DateTime bStartDay = DateTime(bStart.year, bStart.month, bStart.day);
      DateTime bEndDay = DateTime(parseDateTime(b['end']).year, parseDateTime(b['end']).month, parseDateTime(b['end']).day);
      DateTime cStartDay = DateTime(cStart.year, cStart.month, cStart.day);
      DateTime cEndDay = DateTime(parseDateTime(c['end']).year, parseDateTime(c['end']).month, parseDateTime(c['end']).day);
      bool result = (aStartDay.isBefore(bEndDay) || aStartDay.isAtSameMomentAs(bEndDay)) &&
          (bStartDay.isBefore(cEndDay) || bStartDay.isAtSameMomentAs(cEndDay)) &&
          (aEndDay.isAfter(cStartDay) || aEndDay.isAtSameMomentAs(cStartDay));
      print("      Three-Way Time Window Check: $aStartDay - $aEndDay vs $bStartDay - $bEndDay vs $cStartDay - $cEndDay: $result");
      return result;
    }

    int validCount = 0;
    if (group.length == 2) {
      if (isTimeWindowWithinRange(timeWindows[0], timeWindows[1])) validCount++;
      if (isTimeWindowWithinRange(timeWindows[2], timeWindows[3])) validCount++;
      print("    Two-order time validation: $validCount/2 valid overlaps");
      return validCount == 2;
    } else {
      if (isTimeWindowWithinRangeForThree(timeWindows[0], timeWindows[1], timeWindows[2])) validCount++;
      if (isTimeWindowWithinRangeForThree(timeWindows[3], timeWindows[4], timeWindows[5])) validCount++;
      print("    Three-order time validation: $validCount/2 valid overlaps");
      return validCount == 2;
    }
  }

  double calculateRouteDistance(List<Map<String, dynamic>> group, List<int> route) {
    if (group.isEmpty || route.isEmpty) {
      print("  Route distance calculation failed: Group or route empty.");
      return 0.0;
    }

    double totalDistance = 0.0;
    List<Map<String, dynamic>> points = [];
    for (var order in group) {
      points.add({'type': 'pickup', 'lat': order['pickupPlace']['latitude'], 'lon': order['pickupPlace']['longitude']});
      points.add({'type': 'delivery', 'lat': order['deliveryPlace']['latitude'], 'lon': order['deliveryPlace']['longitude']});
    }

    for (int i = 0; i < route.length - 1; i++) {
      int currentIndex = route[i];
      int nextIndex = route[i + 1];
      double segmentDistance = calculateDistance(
        points[currentIndex]['lat'],
        points[currentIndex]['lon'],
        points[nextIndex]['lat'],
        points[nextIndex]['lon'],
      );
      totalDistance += segmentDistance;
      totalDistance *= 1.1;
      print("    Segment ${points[currentIndex]['type']}-${points[currentIndex]['orderId']} to ${points[nextIndex]['type']}-${points[nextIndex]['orderId']}: ${segmentDistance.toStringAsFixed(2)} km, Cumulative: ${totalDistance.toStringAsFixed(2)} km");
    }

    print("  Total Route Distance: ${totalDistance.toStringAsFixed(2)} km");
    return totalDistance;
  }

  // Main clustering logic
  print("\n--- Starting Clustering Process ---");
  List<Map<String, dynamic>> bestOrders = [];
  List<Map<String, dynamic>> suggestions = [];
  List<Map<String, dynamic>> noise = [];

  print("Step 1: Identifying Best Orders");
  List<Map<String, dynamic>> bestOrderGroups = [];
  List<Map<String, dynamic>> remainingOrders = [];

  for (var order in ordersData) {
    print("\nChecking OrderID: ${order['orderID']}");
    if (isBestOrder(order, minPricePerKm)) {
      Map<String, dynamic> updatedOrder = Map.from(order);
      updatedOrder['connectedGroupID'] = updatedOrder['orderID'] as String;
      updatedOrder['isConnected'] = true;

      Map<String, dynamic> groupData = {
        'groupID': updatedOrder['orderID'] as String,
        'orders': [updatedOrder],
        'totalDistance': 0.0,
        'pricePerKm': calculateOrderPricePerKm(updatedOrder),
        'totalPrice': updatedOrder['price'] as double,
        'totalLDM': updatedOrder['ldm'] as double,
        'totalWeight': updatedOrder['weight'] as double,
        'status': 'Pending',
        'creatorID': updatedOrder['creatorID'] as String? ?? 'system',
        'creatorName': updatedOrder['creatorName'] as String? ?? 'System',
        'createdAt': updatedOrder['createdAt'] as String? ?? DateTime.now().toIso8601String(),
        'lastModifiedAt': updatedOrder['lastModifiedAt'] as String?,
        'isEditing': updatedOrder['isEditing'] as bool? ?? false,
        'comments': updatedOrder['comments'] as List? ?? [],
        'logs': updatedOrder['orderLogs'] as List? ?? [],
        'driverInfo': updatedOrder['driverInfo'],
      };
      bestOrderGroups.add(groupData);
      print("  Added to Best Orders: ${groupData['groupID']}");
    } else {
      remainingOrders.add(order);
      print("  Added to Remaining Orders: ${order['orderID']}");
    }
  }

  bestOrders.addAll(bestOrderGroups);
  print("Total Best Orders Identified: ${bestOrders.length}");

  print("\nStep 2: Running DBSCAN Clustering on Remaining Orders");
  Map<int, List<Map<String, dynamic>>> clusters = {};
  List<Map<String, dynamic>> noiseFromDBSCAN = [];
  if (remainingOrders.isNotEmpty) {
    print("  Remaining Orders to Cluster: ${remainingOrders.length}");
    List<int?> labels = List.filled(remainingOrders.length, null);
    int clusterId = 0;

    List<int> regionQuery(List<Map<String, dynamic>> orders, int index) {
      List<int> neighbors = [];
      for (int i = 0; i < orders.length; i++) {
        double pickupDist = calculateDistance(
          orders[index]['pickupPlace']['latitude'],
          orders[index]['pickupPlace']['longitude'],
          orders[i]['pickupPlace']['latitude'],
          orders[i]['pickupPlace']['longitude'],
        );
        double deliveryDist = calculateDistance(
          orders[index]['deliveryPlace']['latitude'],
          orders[index]['deliveryPlace']['longitude'],
          orders[i]['deliveryPlace']['latitude'],
          orders[i]['deliveryPlace']['longitude'],
        );
        if (pickupDist <= eps && deliveryDist <= eps) {
          neighbors.add(i);
        }
      }
      print("    Region Query for OrderID: ${orders[index]['orderID']}, Neighbors: ${neighbors.length}");
      return neighbors;
    }

    void expandCluster(List<Map<String, dynamic>> orders, List<int?> labels, int index, List<int> neighbors, int clusterId) {
      labels[index] = clusterId;
      clusters.putIfAbsent(clusterId, () => []).add(orders[index]);
      print("      Expanding Cluster $clusterId, Added OrderID: ${orders[index]['orderID']}");

      List<int> seeds = List.from(neighbors);
      while (seeds.isNotEmpty) {
        int current = seeds.removeLast();
        if (labels[current] == -1) {
          labels[current] = clusterId;
          clusters[clusterId]?.add(orders[current]);
          print("      Added Noise-to-Cluster OrderID: ${orders[current]['orderID']}");
        }
        if (labels[current] != null) continue;
        labels[current] = clusterId;
        clusters[clusterId]?.add(orders[current]);
        print("      Added Core OrderID: ${orders[current]['orderID']}");

        List<int> currentNeighbors = regionQuery(orders, current);
        if (currentNeighbors.length >= minPts) {
          seeds.addAll(currentNeighbors.where((n) => labels[n] == null));
          print("      Expanded with ${currentNeighbors.length} neighbors for OrderID: ${orders[current]['orderID']}");
        }
      }
    }

    for (int i = 0; i < remainingOrders.length; i++) {
      if (labels[i] != null) continue;
      List<int> neighbors = regionQuery(remainingOrders, i);
      if (neighbors.length < minPts) {
        labels[i] = -1;
        noiseFromDBSCAN.add(remainingOrders[i]);
        print("    OrderID: ${remainingOrders[i]['orderID']} marked as noise.");
      } else {
        clusterId++;
        print("    Starting new Cluster $clusterId with OrderID: ${remainingOrders[i]['orderID']}");
        expandCluster(remainingOrders, labels, i, neighbors, clusterId);
      }
    }

    print("\nDBSCAN Results: Clusters Formed: ${clusters.length}, Noise Orders: ${noiseFromDBSCAN.length}");
    clusters.forEach((id, cluster) {
      print("  Cluster $id: ${cluster.map((o) => o['orderID']).join(', ')}");
    });
    print("  Noise: ${noiseFromDBSCAN.map((o) => o['orderID']).join(', ')}");
  } else {
    print("  No remaining orders to cluster.");
  }

  if (clusters.isNotEmpty) {
    print("\nStep 3: Processing Clusters for Best Groups");
    Set<String> bestOrdersIDs = bestOrders.map((g) => g['groupID'] as String).toSet();

    Map<String, dynamic> validateGroup(List<Map<String, dynamic>> group, double maxRadius, double minPricePerKm) {
      if (group.isEmpty || group.length > 3) {
        print("  Group Validation Failed: Empty or too large (${group.length} orders).");
        return {'status': 'noise'};
      }

      print("\n  Validating Group: ${group.map((o) => o['orderID']).join(', ')}");
      double totalWeight = group.fold(0, (sum, order) => sum + (order['weight'] as double));
      double totalLDM = group.fold(0, (sum, order) => sum + (order['ldm'] as double));
      var carType = carTypesData.firstWhere((type) => type['name'] == group.first['carTypeName'], orElse: () => carTypesData.first);
      bool weightOk = totalWeight <= carType['maxWeight'];
      bool ldmOk = totalLDM <= carType['length'];
      print("    Total Weight: ${totalWeight.toStringAsFixed(2)} tons (Max: ${carType['maxWeight']}), OK: $weightOk");
      print("    Total LDM: ${totalLDM.toStringAsFixed(2)} (Max: ${carType['length']}), OK: $ldmOk");

      List<int> optimizedGroup = optimizeRoute(group);
      List<Map<String, dynamic>> postalCodeList = [];
      for (int index in optimizedGroup) {
        if (index == 0) postalCodeList.add(group[0]['pickupPlace']);
        else if (index == 1) postalCodeList.add(group[0]['deliveryPlace']);
        else if (index == 2) postalCodeList.add(group[1]['pickupPlace']);
        else if (index == 3) postalCodeList.add(group[1]['deliveryPlace']);
        else if (index == 4) postalCodeList.add(group[2]['pickupPlace']);
        else if (index == 5) postalCodeList.add(group[2]['deliveryPlace']);
      }

      bool isValidForAdr = canGroupOrders(group);
      print("    ADR Validation: $isValidForAdr");

      double totalDistance = calculateRouteDistance(group, optimizedGroup);
      double totalPrice = group.fold(0, (sum, order) => sum + (order['price'] as double));
      double pricePerKm = totalDistance > 0 ? totalPrice / totalDistance : 0.0;
      bool priceOk = pricePerKm >= minPricePerKm;
      print(" $pricePerKm $minPricePerKm    Total Price: ${totalPrice.toStringAsFixed(2)} EUR, Price/Km: ${pricePerKm.toStringAsFixed(2)} EUR/km, OK: $priceOk");

      bool proximityOk = true;
      if (group.length == 2) {
        double pickupDistance = calculateDistance(
          postalCodeList[0]['latitude'], postalCodeList[0]['longitude'],
          postalCodeList[1]['latitude'], postalCodeList[1]['longitude'],
        );
        proximityOk &= pickupDistance <= maxRadius;
        print("    Pickup Distance (0-1): ${pickupDistance.toStringAsFixed(2)} km, OK: ${pickupDistance <= maxRadius}");

        double deliveryDistance = calculateDistance(
          postalCodeList[2]['latitude'], postalCodeList[2]['longitude'],
          postalCodeList[3]['latitude'], postalCodeList[3]['longitude'],
        );
        proximityOk &= deliveryDistance <= maxRadius;
        print("    Delivery Distance (2-3): ${deliveryDistance.toStringAsFixed(2)} km, OK: ${deliveryDistance <= maxRadius}");
      } else if (group.length == 3) {
        double pickupDistance1 = calculateDistance(
          postalCodeList[0]['latitude'], postalCodeList[0]['longitude'],
          postalCodeList[1]['latitude'], postalCodeList[1]['longitude'],
        );
        proximityOk &= pickupDistance1 <= maxRadius;
        print("    Pickup Distance (0-1): ${pickupDistance1.toStringAsFixed(2)} km, OK: ${pickupDistance1 <= maxRadius}");

        double pickupDistance2 = calculateDistance(
          postalCodeList[1]['latitude'], postalCodeList[1]['longitude'],
          postalCodeList[2]['latitude'], postalCodeList[2]['longitude'],
        );
        proximityOk &= pickupDistance2 <= maxRadius;
        print("    Pickup Distance (1-2): ${pickupDistance2.toStringAsFixed(2)} km, OK: ${pickupDistance2 <= maxRadius}");

        double deliveryDistance1 = calculateDistance(
          postalCodeList[3]['latitude'], postalCodeList[3]['longitude'],
          postalCodeList[4]['latitude'], postalCodeList[4]['longitude'],
        );
        proximityOk &= deliveryDistance1 <= maxRadius;
        print("    Delivery Distance (3-4): ${deliveryDistance1.toStringAsFixed(2)} km, OK: ${deliveryDistance1 <= maxRadius}");

        double deliveryDistance2 = calculateDistance(
          postalCodeList[4]['latitude'], postalCodeList[4]['longitude'],
          postalCodeList[5]['latitude'], postalCodeList[5]['longitude'],
        );
        proximityOk &= deliveryDistance2 <= maxRadius;
        print("    Delivery Distance (4-5): ${deliveryDistance2.toStringAsFixed(2)} km, OK: ${deliveryDistance2 <= maxRadius}");
      }

      bool timeWindowResult = validateTimeWindows(group, optimizedGroup);
      print("    Time Window Validation: $timeWindowResult");

      int failedCriteria = 0;
      if (!proximityOk) failedCriteria++;
      if (!timeWindowResult) failedCriteria++;
      if (!priceOk) failedCriteria++;
      print("    Failed Criteria: $failedCriteria");

      if (!weightOk || !ldmOk || !isValidForAdr) {
        print("    Failed Weight/LDM/ADR: Marked as Noise");
        return {'status': 'noise'};
      }

      var orderIdsList = group.map((o) => o['orderID'] as String).toList();
      String groupID = orderIdsList.join('-').toUpperCase();

      List<Map<String, dynamic>> updatedOrders = group.map((order) {
        Map<String, dynamic> updatedOrder = Map.from(order);
        updatedOrder['connectedGroupID'] = groupID;
        updatedOrder['isConnected'] = true;
        updatedOrder['pickupPlace'] = {
          'countryCode': updatedOrder['pickupPlace']['countryCode'] as String? ?? '',
          'postalCode': updatedOrder['pickupPlace']['postalCode'] as String? ?? '',
          'name': updatedOrder['pickupPlace']['name'] as String? ?? '',
          'code': updatedOrder['pickupPlace']['code'] as String? ?? '',
          'latitude': updatedOrder['pickupPlace']['latitude'] as double,
          'longitude': updatedOrder['pickupPlace']['longitude'] as double,
        };
        updatedOrder['deliveryPlace'] = {
          'countryCode': updatedOrder['deliveryPlace']['countryCode'] as String? ?? '',
          'postalCode': updatedOrder['deliveryPlace']['postalCode'] as String? ?? '',
          'name': updatedOrder['deliveryPlace']['name'] as String? ?? '',
          'code': updatedOrder['deliveryPlace']['code'] as String? ?? '',
          'latitude': updatedOrder['deliveryPlace']['latitude'] as double,
          'longitude': updatedOrder['deliveryPlace']['longitude'] as double,
        };
        return updatedOrder;
      }).toList();

      Map<String, dynamic> groupData = {
        'groupID': groupID,
        'orders': updatedOrders,
        'totalDistance': totalDistance,
        'pricePerKm': pricePerKm,
        'totalPrice': totalPrice,
        'totalLDM': totalLDM,
        'totalWeight': totalWeight,
        'status': 'Pending',
        'creatorID': 'system',
        'creatorName': 'System',
        'createdAt': DateTime.now().toIso8601String(),
        'lastModifiedAt': null,
        'isEditing': false,
        'comments': updatedOrders.first['comments'] as List? ?? [],
        'logs': updatedOrders.first['orderLogs'] as List? ?? [],
        'driverInfo': updatedOrders.first['driverInfo'],
      };

      if (failedCriteria == 0) {
        print("    All criteria met: Marked as Best Group - $groupID");
        return {'status': 'best', 'group': groupData};
      }
      if (failedCriteria <= 2) {
        print("    Up to 2 criteria failed: Marked as Suggestion Group - $groupID");
        return {'status': 'suggestion', 'group': groupData};
      }
      print("    More than 2 criteria failed: Marked as Noise");
      return {'status': 'noise'};
    }

    clusters.forEach((clusterId, orders) {
      print("\n  Processing Cluster $clusterId with ${orders.length} orders");
      List<Map<String, dynamic>> clusterNoise = List.from(orders);
      Set<String> checkedCombinations = {};

      for (int i = 0; i < orders.length; i++) {
        for (int j = i + 1; j < orders.length; j++) {
          for (int k = j + 1; k <= orders.length; k++) {
            List<Map<String, dynamic>> group = [orders[i], orders[j]];
            if (k < orders.length) group.add(orders[k]);
            List<String> groupKey = group.map((o) => o['orderName'] as String).toList()..sort();
            String groupKeyString = groupKey.join("-");
            if (checkedCombinations.contains(groupKeyString)) {
              print("    Skipping already checked group: $groupKeyString");
              continue;
            }
            checkedCombinations.add(groupKeyString);

            var validation = validateGroup(group, maxRadius, minPricePerKm);
            if (validation['status'] == 'best') {
              bestOrders.add(validation['group']);
              group.forEach((order) => clusterNoise.removeWhere((o) => o['orderID'] == order['orderID']));
            }
          }
        }
      }
      noise.addAll(clusterNoise);
      print("  Remaining Noise Orders in Cluster $clusterId: ${clusterNoise.map((o) => o['orderID']).join(', ')}");
    });

    print("\nStep 4: Processing Clusters for Suggestion Groups");
    clusters.forEach((clusterId, orders) {
      print("\n  Processing Suggestions for Cluster $clusterId");
      List<Map<String, dynamic>> remainingOrders = orders.where((order) => !bestOrdersIDs.contains(order['orderID'])).toList();
      Set<String> checkedCombinations = {};

      for (int i = 0; i < remainingOrders.length; i++) {
        for (int j = i + 1; j < remainingOrders.length; j++) {
          for (int k = j + 1; k <= remainingOrders.length; k++) {
            List<Map<String, dynamic>> group = [remainingOrders[i], remainingOrders[j]];
            if (k < remainingOrders.length) group.add(remainingOrders[k]);
            List<String> groupKey = group.map((o) => o['orderID'] as String).toList()..sort();
            String groupKeyString = groupKey.join("-");
            if (checkedCombinations.contains(groupKeyString)) {
              print("    Skipping already checked group: $groupKeyString");
              continue;
            }
            checkedCombinations.add(groupKeyString);

            var validation = validateGroup(group, maxRadius, minPricePerKm);
            if (validation['status'] == 'suggestion') {
              suggestions.add(validation['group']);
            }
          }
        }
      }
    });
  } else {
    print("\nNo clusters to process.");
    noise.addAll(noiseFromDBSCAN);
  }

  print("\n--- Final Clustering Results ---");
  print("Best Orders: ${bestOrders.length}");
  bestOrders.forEach((group) {
    print("  Group: ${group['groupID']}");
    (group['orders'] as List).forEach((order) => print("    OrderID: ${order['orderID']}"));
  });
  print("Suggestion Groups: ${suggestions.length}");
  suggestions.forEach((group) {
    print("  Group: ${group['groupID']}");
    (group['orders'] as List).forEach((order) => print("    OrderID: ${order['orderID']}"));
  });
  print("Noise Orders: ${noise.length}");
  noise.forEach((order) => print("  OrderID: ${order['orderID']}"));

  return jsonEncode({
    'bestOrders': bestOrders,
    'suggestions': suggestions,
    'noise': noise,
  });
}