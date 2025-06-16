import 'package:cloud_firestore/cloud_firestore.dart';

class Comment {
  final String userID; // ID of the commenter
  final String commenterName; // Name of the commenter
  final String content; // The comment content
  final DateTime timestamp; // Date and time of the comment

  Comment({
    required this.userID,
    required this.commenterName,
    required this.content,
    required this.timestamp,
  });

  // Factory constructor for JSON parsing
  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      userID: json['userID'],
      commenterName: json['commenterName'],
      content: json['content'],
      timestamp: json['timestamp'] is Timestamp
          ? (json['timestamp'] as Timestamp).toDate().toLocal() // Convert Firestore timestamp to local time
          : DateTime.parse(json['timestamp']).toLocal(), // Parse ISO timestamp and convert to local time
    );
  }

  // Convert Comment to JSON
  Map<String, dynamic> toJson() {
    return {
      'userID': userID,
      'commenterName': commenterName,
      'content': content,
      'timestamp': timestamp.toIso8601String(), // Format as ISO string
    };
  }
}
