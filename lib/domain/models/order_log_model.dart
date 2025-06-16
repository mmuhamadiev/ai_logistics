import 'package:cloud_firestore/cloud_firestore.dart';

class OrderLog {
  final String action; // E.g., "Status changed to Confirmed"
  final String userID; // Who performed the action
  final String userName; // User's name
  final DateTime timestamp; // When the action occurred

  OrderLog({
    required this.action,
    required this.userID,
    required this.userName,
    required this.timestamp,
  });

  // Factory constructor for JSON parsing
  factory OrderLog.fromJson(Map<String, dynamic> json) {
    return OrderLog(
      action: json['action'],
      userID: json['userID'],
      userName: json['userName'],
      timestamp: json['timestamp'] is Timestamp
          ? (json['timestamp'] as Timestamp).toDate().toLocal() // Convert Firestore timestamp to local time
          : DateTime.parse(json['timestamp']).toLocal(), // Parse ISO timestamp and convert to local time
    );
  }

  // Convert OrderLog to JSON
  Map<String, dynamic> toJson() {
    return {
      'action': action,
      'userID': userID,
      'userName': userName,
      'timestamp': timestamp.toIso8601String(), // Format as ISO string
    };
  }
}
