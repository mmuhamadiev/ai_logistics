import 'package:cloud_firestore/cloud_firestore.dart';

class TimeWindow {
  DateTime start; // Earliest pickup/delivery
  DateTime end;   // Latest pickup/delivery

  TimeWindow({required this.start, required this.end});

  // Deserialize from JSON
  factory TimeWindow.fromJson(Map<String, dynamic> json) {
    return TimeWindow(
      start: _parseExactDateTime(json['start']),
      end: _parseExactDateTime(json['end']),
    );
  }

  // Serialize to JSON
  Map<String, dynamic> toJson() {
    return {
      'start': start.toString(),
      'end': end.toString(),
    };
  }

  // CopyWith method
  TimeWindow copyWith({DateTime? start, DateTime? end}) {
    return TimeWindow(
      start: start ?? this.start,
      end: end ?? this.end,
    );
  }

  static DateTime _parseExactDateTime(dynamic timestamp) {
    if (timestamp is Timestamp) {
      return timestamp.toDate();
    } else if (timestamp is String) {
      return DateTime.parse(timestamp);
    } else {
      throw Exception('Invalid timestamp format: $timestamp');
    }
  }
}
