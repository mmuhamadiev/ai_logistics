import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ai_logistics_management_order_automation/config/constants.dart';
import 'package:ai_logistics_management_order_automation/domain/models/commnet_model.dart';
import 'package:ai_logistics_management_order_automation/domain/models/order_log_model.dart';
import 'package:ai_logistics_management_order_automation/domain/models/order_model.dart';
import 'package:ai_logistics_management_order_automation/domain/models/driver_info_model.dart'; // Assuming this contains DriverInfo model

class OrderGroupModel {
  final String groupID;
  final List<OrderModel> orders; // Full order models for UI
  double totalDistance; // Total distance in km (provided externally)
  double pricePerKm; // Price per km (provided externally)
  final double totalPrice; // Total price for all orders
  final double totalLDM; // Sum of LDMs of all orders
  final double totalWeight; // Sum of weights (tons) of all orders
  OrderStatus status; // Aligns with OrderModel's status
  final String creatorID;
  final String creatorName;
  final DateTime createdAt;
  DateTime? lastModifiedAt; // Last modification time
  DateTime? lastStartEditTime;
  bool isEditing; // Prevents concurrent editing
  bool isNeedAddMore; // Prevents concurrent editing
  Comment? carComment; // Prevents concurrent editing
  List<Comment> comments; // Comments for the order group
  List<OrderLog> logs; // Logs for tracking actions on the order group
  DriverInfo? driverInfo; // Information about the assigned driver

  OrderGroupModel({
    required this.groupID,
    required this.orders,
    required this.totalDistance, // Provided externally
    required this.pricePerKm, // Provided externally
    required this.totalPrice,
    required this.totalLDM,
    required this.totalWeight,
    required this.status,
    required this.creatorID,
    required this.creatorName,
    required this.createdAt,
    this.lastModifiedAt,
    this.lastStartEditTime,
    this.isEditing = false, // Default: Not being edited
    this.isNeedAddMore = false, // Default: Not being edited
    this.carComment, // Default: Not being edited
    this.comments = const [], // Default: No comments
    this.logs = const [], // Default: No logs
    this.driverInfo, // Default: No driver assigned
  });

  // Factory constructor for JSON deserialization
  factory OrderGroupModel.fromJson(Map<String, dynamic> json) {
    return OrderGroupModel(
      groupID: json['groupID'],
      orders: (json['orders'] as List<dynamic>)
          .map((order) => OrderModel.fromJson(order))
          .toList(),
      totalDistance: json['totalDistance'], // External value
      pricePerKm: json['pricePerKm'], // External value
      totalPrice: json['totalPrice'],
      totalLDM: json['totalLDM'],
      totalWeight: json['totalWeight'],
      status: OrderStatus.values.firstWhere(
            (status) => status.name == json['status'],
        orElse: () => OrderStatus.Pending,
      ),
      creatorID: json['creatorID'],
      creatorName: json['creatorName'],
      createdAt: json['createdAt'] is Timestamp
          ? (json['createdAt'] as Timestamp).toDate().toLocal() // Convert to local time
          : DateTime.parse(json['createdAt']).toLocal(), // Parse and convert to local time
      lastModifiedAt: json['lastModifiedAt'] != null
          ? _parseExactDateTime(json['lastModifiedAt']): null,
      lastStartEditTime: json['lastStartEditTime'] != null
          ? _parseExactDateTime(json['lastStartEditTime']): null,
      isEditing: json['isEditing'] ?? false,
      isNeedAddMore: json['isNeedAddMore'] ?? false,
      comments: (json['comments'] as List<dynamic>? ?? [])
          .map((comment) => Comment.fromJson(comment))
          .toList(),
        carComment: json['carComment'] != null? Comment.fromJson(json['carComment']): null,
      logs: (json['logs'] as List<dynamic>? ?? [])
          .map((log) => OrderLog.fromJson(log))
          .toList(),
      driverInfo: json['driverInfo'] != null
          ? DriverInfo.fromJson(json['driverInfo'])
          : null, // Deserialize driver info if available
    );
  }

  // Convert OrderGroup to JSON
  Map<String, dynamic> toJson() {
    return {
      'groupID': groupID,
      'orders': orders.map((order) => order.toJson()).toList(),
      'totalDistance': totalDistance,
      'pricePerKm': pricePerKm,
      'totalPrice': totalPrice,
      'totalLDM': totalLDM,
      'totalWeight': totalWeight,
      'status': status.name,
      'creatorID': creatorID,
      'creatorName': creatorName,
      'createdAt': createdAt.toIso8601String(), // Convert to ISO string
      'lastModifiedAt': lastModifiedAt?.toIso8601String(), // Convert to ISO string
      'lastStartEditTime': lastStartEditTime?.toIso8601String(), // Convert to ISO string
      'isEditing': isEditing,
      'isNeedAddMore': isNeedAddMore,
      'comments': comments.map((comment) => comment.toJson()).toList(),
      'carComment': carComment?.toJson(),
      'logs': logs.map((log) => log.toJson()).toList(),
      'driverInfo': driverInfo?.toJson(), // Serialize driver info if available
    };
  }

  /// Returns a JSON map with only the fields required for Genkit.
  Map<String, dynamic> toGenkitJson() {
    return {
      'groupID': groupID,
      'totalDistance': totalDistance,
      'pricePerKm': pricePerKm,
      'totalPrice': totalPrice,
      'totalLDM': totalLDM,
      'totalWeight': totalWeight,
      'orders': orders.map((order) => order.toGenkitJson()).toList(),
    };
  }

  // CopyWith method for creating modified copies of OrderGroup
  OrderGroupModel copyWith({
    String? groupID,
    List<OrderModel>? orders,
    double? totalDistance,
    double? pricePerKm,
    double? totalPrice,
    double? totalLDM,
    double? totalWeight,
    OrderStatus? status,
    String? creatorID,
    String? creatorName,
    DateTime? createdAt,
    DateTime? lastModifiedAt,
    DateTime? lastStartEditTime,
    bool? isEditing,
    bool? isNeedAddMore,
    Comment? carComment,
    List<Comment>? comments,
    List<OrderLog>? logs,
    DriverInfo? driverInfo,
  }) {
    return OrderGroupModel(
      groupID: groupID ?? this.groupID,
      orders: orders ?? this.orders,
      totalDistance: totalDistance ?? this.totalDistance,
      pricePerKm: pricePerKm ?? this.pricePerKm,
      totalPrice: totalPrice ?? this.totalPrice,
      totalLDM: totalLDM ?? this.totalLDM,
      totalWeight: totalWeight ?? this.totalWeight,
      status: status ?? this.status,
      creatorID: creatorID ?? this.creatorID,
      creatorName: creatorName ?? this.creatorName,
      createdAt: createdAt ?? this.createdAt,
      lastModifiedAt: lastModifiedAt ?? this.lastModifiedAt,
      lastStartEditTime: lastStartEditTime ?? this.lastStartEditTime,
      isEditing: isEditing ?? this.isEditing,
      isNeedAddMore: isNeedAddMore ?? this.isNeedAddMore,
      carComment: carComment ?? this.carComment,
      comments: comments ?? this.comments,
      logs: logs ?? this.logs,
      driverInfo: driverInfo ?? this.driverInfo,
    );
  }

  // Static method to calculate the total price of all orders in the group
  static double calculateTotalPrice(List<OrderModel> orders) {
    return orders.fold(0, (total, order) => total + order.price);
  }

  // Static method to calculate the total LDM of all orders in the group
  static double calculateTotalLDM(List<OrderModel> orders) {
    return orders.fold(0, (total, order) => total + order.ldm);
  }

  // Static method to calculate the total weight of all orders in the group
  static double calculateTotalWeight(List<OrderModel> orders) {
    return orders.fold(0, (total, order) => total + order.weight);
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