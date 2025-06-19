import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ai_logistics_management_order_automation/domain/models/filter_model.dart';
import 'package:ai_logistics_management_order_automation/domain/models/ip_info_model.dart';

class UserModel {
  final String userID;
  String username;
  String name;
  String password;
  DateTime? lastLoginTime;
  bool currentLoginStatus;
  int ordersCreatedCount;
  int ordersAcceptedCount;
  int ordersDeletedCount;
  List<UserActionLog> actionsLog;
  String userRole;
  List<String> myOrdersIdList;
  final DateTime createdDate;
  bool isEditing;
  DateTime? lastStartEditTime; // New field
  FilterModel filterModel;
  IpInfoModel? ipInfo; // Added IpInfoModel

  UserModel({
    required this.userID,
    required this.username,
    required this.name,
    required this.password,
    this.lastLoginTime,
    required this.currentLoginStatus,
    required this.ordersCreatedCount,
    required this.ordersAcceptedCount,
    required this.ordersDeletedCount,
    required this.actionsLog,
    required this.userRole,
    required this.myOrdersIdList,
    required this.createdDate,
    this.isEditing = false,
    this.lastStartEditTime, // Default to null if not provided
    required this.filterModel,
    this.ipInfo, // Default to null if not provided
  });

  // Factory constructor to create a UserModel from a JSON map (Firestore document snapshot)
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      userID: json['userID'] as String,
      username: json['username'] as String,
      name: json['name'] as String,
      password: json['password'] as String,
      lastLoginTime: json['lastLoginTime'] != null
          ? (json['lastLoginTime'] is Timestamp
          ? (json['lastLoginTime'] as Timestamp).toDate().toLocal() // Convert to local time
          : DateTime.parse(json['lastLoginTime']).toLocal()) // Parse and convert to local time
          : null,
      currentLoginStatus: json['currentLoginStatus'] as bool,
      ordersCreatedCount: json['ordersCreatedCount'] as int,
      ordersAcceptedCount: json['ordersAcceptedCount'] as int,
      ordersDeletedCount: json['ordersDeletedCount'] as int,
      actionsLog: (json['actionsLog'] as List<dynamic>? ?? [])
          .map((log) => UserActionLog.fromJson(log))
          .toList(),
      userRole: json['userRole'] as String,
      myOrdersIdList: List<String>.from(json['myOrdersIdList'] ?? []),
      createdDate: json['createdDate'] is Timestamp
          ? (json['createdDate'] as Timestamp).toDate().toLocal() // Convert to local time
          : DateTime.parse(json['createdDate']).toLocal(), // Parse and convert to local time
      isEditing: json['isEditing'] ?? false,
      lastStartEditTime: json['lastStartEditTime'] != null
          ? (json['lastStartEditTime'] is Timestamp
          ? (json['lastStartEditTime'] as Timestamp).toDate().toLocal() // Convert to local time
          : DateTime.parse(json['lastStartEditTime']).toLocal()) // Parse and convert to local time
          : null,
      filterModel: FilterModel.fromJson(json['filter']),
      ipInfo: json['ipInfo'] != null ? IpInfoModel.fromJson(json['ipInfo']) : null,
    );
  }

  // Method to convert UserModel into a JSON map for Firestore
  Map<String, dynamic> toJson() {
    return {
      'userID': userID,
      'username': username,
      'name': name,
      'password': password,
      'lastLoginTime': lastLoginTime?.toIso8601String(), // Convert to ISO string
      'currentLoginStatus': currentLoginStatus,
      'ordersCreatedCount': ordersCreatedCount,
      'ordersAcceptedCount': ordersAcceptedCount,
      'ordersDeletedCount': ordersDeletedCount,
      'actionsLog': actionsLog.map((log) => log.toJson()).toList(),
      'userRole': userRole,
      'myOrdersIdList': myOrdersIdList,
      'createdDate': createdDate.toIso8601String(), // Convert to ISO string
      'isEditing': isEditing,
      'lastStartEditTime': lastStartEditTime?.toIso8601String(), // Convert to ISO string
      'filter': filterModel.toJson(),
      'ipInfo': ipInfo?.toJson(), // Convert to JSON
    };
  }
}

class UserActionLog {
  final String action;
  final DateTime timestamp;

  UserActionLog({required this.action, required this.timestamp});

  // Factory constructor for UserActionLog
  factory UserActionLog.fromJson(Map<String, dynamic> json) {
    return UserActionLog(
      action: json['action'] as String,
      timestamp: json['timestamp'] is Timestamp
          ? (json['timestamp'] as Timestamp).toDate().toLocal() // Convert to local time
          : DateTime.parse(json['timestamp']).toLocal(), // Parse and convert to local time
    );
  }

  // Convert UserActionLog to JSON
  Map<String, dynamic> toJson() {
    return {
      'action': action,
      'timestamp': timestamp.toIso8601String(), // Convert to ISO string
    };
  }
}