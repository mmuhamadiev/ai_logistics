import 'package:hegelmann_order_automation/domain/models/order_model.dart';
import 'package:hegelmann_order_automation/domain/models/time_window.dart';

class TimeManager {
  /// Check if two time windows overlap
  static bool isTimeWindowWithinRange(TimeWindow a, TimeWindow b) {
    //TODO
    DateTime now = DateTime.now();

    // If start is null, assume the start is "today"
    DateTime aStart = a.start ?? now;
    DateTime bStart = b.start ?? now;

    // Consider only the day part of the DateTime
    DateTime aStartDay = DateTime(aStart.year, aStart.month, aStart.day);
    DateTime aEndDay = DateTime(a.end.year, a.end.month, a.end.day);
    DateTime bStartDay = DateTime(bStart.year, bStart.month, bStart.day);
    DateTime bEndDay = DateTime(b.end.year, b.end.month, b.end.day);

    // Debugging prints for the time windows being compared
    print("Checking Time Window Overlap:");
    print("  TimeWindow A -> Start: ${a.start ?? "Now ($now)"}, End: ${a.end}");
    print("  TimeWindow B -> Start: ${b.start ?? "Now ($now)"}, End: ${b.end}");

    // Check if one window starts before the other ends and ends after the other starts
    bool overlaps = (aStartDay.isBefore(bEndDay) || aStartDay.isAtSameMomentAs(bEndDay)) &&
        (aEndDay.isAfter(bStartDay) || aEndDay.isAtSameMomentAs(bStartDay));

    print("  Overlap Result: $overlaps");
    return overlaps;
  }

  /// Check if three time windows overlap
  static bool isTimeWindowWithinRangeForThree(
      TimeWindow a, TimeWindow b, TimeWindow c) {
    //TODO
    DateTime now = DateTime.parse('2025-01-01');

    // If start is null, assume the start is "today"
    DateTime aStart = a.start ?? now;
    DateTime bStart = b.start ?? now;
    DateTime cStart = c.start ?? now;

    if(aStart.isAfter(a.end)) {
      return false;
    }
    if(bStart.isAfter(b.end)) {
      return false;
    }
    if(cStart.isAfter(c.end)) {
      return false;
    }

    // Consider only the day part of the DateTime
    DateTime aStartDay = DateTime(aStart.year, aStart.month, aStart.day);
    DateTime aEndDay = DateTime(a.end.year, a.end.month, a.end.day);
    DateTime bStartDay = DateTime(bStart.year, bStart.month, bStart.day);
    DateTime bEndDay = DateTime(b.end.year, b.end.month, b.end.day);
    DateTime cStartDay = DateTime(cStart.year, cStart.month, cStart.day);
    DateTime cEndDay = DateTime(c.end.year, c.end.month, c.end.day);

    // Debugging prints for the time windows being compared
    print("Checking Time Window Overlap for Three:");
    print("  TimeWindow A -> Start: ${a.start ?? "Now ($now)"}, End: ${a.end}");
    print("  TimeWindow B -> Start: ${b.start ?? "Now ($now)"}, End: ${b.end}");
    print("  TimeWindow C -> Start: ${c.start ?? "Now ($now)"}, End: ${c.end}");

    // Check if all three windows overlap
    bool overlaps = (aStartDay.isBefore(bEndDay) || aStartDay.isAtSameMomentAs(bEndDay)) &&
        (bStartDay.isBefore(cEndDay) || bStartDay.isAtSameMomentAs(cEndDay)) &&
        (aEndDay.isAfter(cStartDay) || aEndDay.isAtSameMomentAs(cStartDay));

    print("  Overlap Result for Three: $overlaps");
    return overlaps;
  }


  static bool validateTimeWindows(
      List<OrderModel> group, List<int> optimizedGroup) {
    if (group.isEmpty || optimizedGroup.isEmpty) {
      print("Group or optimized route is empty.");
      return false;
    }

    //TODO
    DateTime now = DateTime.parse('2025-01-01');

    // Determine the overall time window
    DateTime minStartDate = now;
    DateTime maxEndDate = now;

    for (var order in group) {
      DateTime pickupStart = order.pickupTimeWindow?.start ?? now;
      DateTime deliveryEnd = order.deliveryTimeWindow!.end;

      minStartDate = min(minStartDate, pickupStart);
      maxEndDate = max(maxEndDate, deliveryEnd);
    }

    for(var order in group) {
      DateTime pickupStart = order.pickupTimeWindow?.start ?? now;
      if(pickupStart.isAfter(order.pickupTimeWindow!.end)) {
        return false;
      }
    }

    print("Overall Time Frame: Start: $minStartDate, End: $maxEndDate");

    // Prepare time windows in the order of the optimized route
    //TODO check
    List<TimeWindow> timeWindows = [];
    for (int index in optimizedGroup) {
      if (index == 0) {
        timeWindows.add(group[0].pickupTimeWindow);
      } else if (index == 1) {
        timeWindows.add(group[0].deliveryTimeWindow);
      } else if (index == 2) {
        timeWindows.add(group[1].pickupTimeWindow);
      } else if (index == 3) {
        timeWindows.add(group[1].deliveryTimeWindow);
      } else if (index == 4) {
        timeWindows.add(group[2].pickupTimeWindow);
      } else if (index == 5) {
        timeWindows.add(group[2].deliveryTimeWindow);
      }
      else if (index == 6) {
        timeWindows.add(group[3].pickupTimeWindow);
      } else if (index == 7) {
        timeWindows.add(group[3].deliveryTimeWindow);
      } else if (index == 8) {
        timeWindows.add(group[4].pickupTimeWindow);
      } else if (index == 9) {
        timeWindows.add(group[4].deliveryTimeWindow);
      } else if (index == 10) {
        timeWindows.add(group[5].pickupTimeWindow);
      } else if (index == 11) {
        timeWindows.add(group[5].deliveryTimeWindow);
      }
    }

    // Validate each step in the optimized route
    int validCount = 0;

    if(group.length == 2){
      // Step 1: Check if pickups are within allowable dates
      print("\n--- Step 1: Checking Pickup Time Windows ---");
      if (isTimeWindowWithinRange(timeWindows[0], timeWindows[1])) {
        print(
            "  Pickup windows [0] and [1] are valid: ${timeWindows[0]} and ${timeWindows[1]}");
        validCount++;
      } else {
        print(
            "  Pickup windows [0] and [1] are invalid: ${timeWindows[0]} and ${timeWindows[1]}");
      }

      // Step 2: Check if deliveries are within allowable dates
      print("\n--- Step 2: Checking Delivery Time Windows ---");
      if (isTimeWindowWithinRange(timeWindows[2], timeWindows[3])) {
        print(
            "  Delivery windows [2] and [3] are valid: ${timeWindows[2]} and ${timeWindows[3]}");
        validCount++;
      } else {
        print(
            "  Delivery windows [2] and [3] are invalid: ${timeWindows[2]} and ${timeWindows[3]}");
      }

      print("\nTotal valid checks passed: $validCount");

      // Return whether all validations passed
      return validCount == 2;
    } else {
      // Step 1: Check if pickups are within allowable dates
      print("\n--- Step 1: Checking Pickup Time Windows ---");
      if (isTimeWindowWithinRangeForThree(timeWindows[0], timeWindows[1], timeWindows[2])) {
        print(
            "  Pickup windows [0] and [1] and [2] are valid: ${timeWindows[0]} and ${timeWindows[1]} and ${timeWindows[2]}");
        validCount++;
      } else {
        print(
            "  Pickup windows [0] and [1] and [2] are invalid: ${timeWindows[0]} and ${timeWindows[1]} and ${timeWindows[2]}");
      }

      // Step 2: Check if deliveries are within allowable dates
      print("\n--- Step 2: Checking Delivery Time Windows ---");
      if (isTimeWindowWithinRangeForThree(timeWindows[3], timeWindows[4], timeWindows[5])) {
        print(
            "  Delivery windows [3] and [4] and [5] are valid: ${timeWindows[3]} and ${timeWindows[4]} and ${timeWindows[5]}");
        validCount++;
      } else {
        print(
            "  Delivery windows [3] and [4] and [5] are invalid: ${timeWindows[3]} and ${timeWindows[4]} and ${timeWindows[5]}");
      }

      print("\nTotal valid checks passed: $validCount");

      // Return whether all validations passed
      return validCount == 2;
    }
  }


  static DateTime max(DateTime a, DateTime b) => a.isAfter(b) ? a : b;

  static DateTime min(DateTime a, DateTime b) => a.isBefore(b) ? a : b;
}
