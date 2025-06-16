// Top-level function for isolate with pragma annotation
import 'package:isolate_manager/isolate_manager.dart';

@isolateManagerSharedWorker
bool validateTimeWindowsIsolate(Map<String, dynamic> params) {
  // Extract parameters
  List<Map<String, dynamic>> groupData = (params['group'] as List).cast<Map<String, dynamic>>();
  List<int> optimizedGroup = (params['optimizedGroup'] as List).cast<int>();

  if (groupData.isEmpty || optimizedGroup.isEmpty) {
    return false;
  }

  // Helper function to parse DateTime from string or use now
  DateTime parseDateTime(dynamic value) {
    if (value is String) return DateTime.parse(value);
    return DateTime.now(); // Fallback to current time if null or invalid
  }

  // Helper function to mimic TimeWindow
  Map<String, DateTime> timeWindowFromMap(Map<String, dynamic> data) {
    return {
      'start': parseDateTime(data['start']),
      'end': parseDateTime(data['end']),
    };
  }

  // Convert groupData into a usable format
  List<Map<String, dynamic>> group = groupData.map((data) => {
    'pickupTimeWindow': timeWindowFromMap(data['pickupTimeWindow']),
    'deliveryTimeWindow': timeWindowFromMap(data['deliveryTimeWindow']),
  }).toList();

  // Determine the overall time window
  DateTime now = DateTime.now();
  DateTime minStartDate = now;
  DateTime maxEndDate = now;

  for (var order in group) {
    DateTime pickupStart = order['pickupTimeWindow']['start'];
    DateTime deliveryEnd = order['deliveryTimeWindow']['end'];
    minStartDate = min(minStartDate, pickupStart);
    maxEndDate = max(maxEndDate, deliveryEnd);
  }

  for (var order in group) {
    DateTime pickupStart = order['pickupTimeWindow']['start'];
    if (pickupStart.isAfter(order['pickupTimeWindow']['end'])) {
      return false;
    }
  }

  // Prepare time windows in the order of the optimized route
  List<Map<String, DateTime>> timeWindows = [];
  for (int index in optimizedGroup) {
    if (index == 0) {
      timeWindows.add(group[0]['pickupTimeWindow']);
    } else if (index == 1) {
      timeWindows.add(group[0]['deliveryTimeWindow']);
    } else if (index == 2) {
      timeWindows.add(group[1]['pickupTimeWindow']);
    } else if (index == 3) {
      timeWindows.add(group[1]['deliveryTimeWindow']);
    } else if (index == 4) {
      timeWindows.add(group[2]['pickupTimeWindow']);
    } else if (index == 5) {
      timeWindows.add(group[2]['deliveryTimeWindow']);
    } else if (index == 6) {
      timeWindows.add(group[3]['pickupTimeWindow']);
    } else if (index == 7) {
      timeWindows.add(group[3]['deliveryTimeWindow']);
    } else if (index == 8) {
      timeWindows.add(group[4]['pickupTimeWindow']);
    } else if (index == 9) {
      timeWindows.add(group[4]['deliveryTimeWindow']);
    } else if (index == 10) {
      timeWindows.add(group[5]['pickupTimeWindow']);
    } else if (index == 11) {
      timeWindows.add(group[5]['deliveryTimeWindow']);
    }
  }

  // Helper functions for time window overlap
  bool isTimeWindowWithinRange(Map<String, DateTime> a, Map<String, DateTime> b) {
    DateTime aStart = a['start']!;
    DateTime bStart = b['start']!;
    DateTime aStartDay = DateTime(aStart.year, aStart.month, aStart.day);
    DateTime aEndDay = DateTime(a['end']!.year, a['end']!.month, a['end']!.day);
    DateTime bStartDay = DateTime(bStart.year, bStart.month, bStart.day);
    DateTime bEndDay = DateTime(b['end']!.year, b['end']!.month, b['end']!.day);

    return (aStartDay.isBefore(bEndDay) || aStartDay.isAtSameMomentAs(bEndDay)) &&
        (aEndDay.isAfter(bStartDay) || aEndDay.isAtSameMomentAs(bStartDay));
  }

  bool isTimeWindowWithinRangeForThree(Map<String, DateTime> a, Map<String, DateTime> b, Map<String, DateTime> c) {
    DateTime aStart = a['start']!;
    DateTime bStart = b['start']!;
    DateTime cStart = c['start']!;

    if (aStart.isAfter(a['end']!)) return false;
    if (bStart.isAfter(b['end']!)) return false;
    if (cStart.isAfter(c['end']!)) return false;

    DateTime aStartDay = DateTime(aStart.year, aStart.month, aStart.day);
    DateTime aEndDay = DateTime(a['end']!.year, a['end']!.month, a['end']!.day);
    DateTime bStartDay = DateTime(bStart.year, bStart.month, bStart.day);
    DateTime bEndDay = DateTime(b['end']!.year, b['end']!.month, b['end']!.day);
    DateTime cStartDay = DateTime(cStart.year, cStart.month, cStart.day);
    DateTime cEndDay = DateTime(c['end']!.year, c['end']!.month, c['end']!.day);

    return (aStartDay.isBefore(bEndDay) || aStartDay.isAtSameMomentAs(bEndDay)) &&
        (bStartDay.isBefore(cEndDay) || bStartDay.isAtSameMomentAs(cEndDay)) &&
        (aEndDay.isAfter(cStartDay) || aEndDay.isAtSameMomentAs(cStartDay));
  }

  // Validate each step in the optimized route
  int validCount = 0;

  if (group.length == 2) {
    if (isTimeWindowWithinRange(timeWindows[0], timeWindows[1])) {
      validCount++;
    }
    if (isTimeWindowWithinRange(timeWindows[2], timeWindows[3])) {
      validCount++;
    }
    return validCount == 2;
  } else {
    if (isTimeWindowWithinRangeForThree(timeWindows[0], timeWindows[1], timeWindows[2])) {
      validCount++;
    }
    if (isTimeWindowWithinRangeForThree(timeWindows[3], timeWindows[4], timeWindows[5])) {
      validCount++;
    }
    return validCount == 2;
  }
}

// Helper functions for DateTime comparison
DateTime max(DateTime a, DateTime b) => a.isAfter(b) ? a : b;
DateTime min(DateTime a, DateTime b) => a.isBefore(b) ? a : b;