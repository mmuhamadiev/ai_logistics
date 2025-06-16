import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hegelmann_order_automation/config/constants.dart';
import 'package:hegelmann_order_automation/domain/models/commnet_model.dart';
import 'package:hegelmann_order_automation/domain/models/driver_info_model.dart';
import 'package:hegelmann_order_automation/domain/models/order_log_model.dart';
import 'package:hegelmann_order_automation/domain/models/post_code_model.dart';
import 'package:hegelmann_order_automation/domain/models/time_window.dart';

class OrderModel {
  final String orderID;
  String orderName;
  PostalCode pickupPlace;
  PostalCode deliveryPlace;
  double ldm;
  double weight;
  double price;
  String carTypeName;
  OrderStatus status;
  bool isConnected;
  String? connectedGroupID;
  DateTime createdAt;
  String creatorID;
  String creatorName;
  DateTime? lastModifiedAt;
  DateTime? lastStartEditTime;
  bool isEditing;
  double? distance;
  List<Comment> comments;
  List<OrderLog> orderLogs;
  DriverInfo? driverInfo;
  TimeWindow pickupTimeWindow;
  TimeWindow deliveryTimeWindow;

  bool isAdrOrder;
  bool canGroupWithAdr;

  OrderModel({
    required this.orderID,
    required this.orderName,
    required this.pickupPlace,
    required this.deliveryPlace,
    required this.ldm,
    required this.weight,
    required this.price,
    required this.carTypeName,
    required this.status,
    required this.isConnected,
    this.connectedGroupID,
    required this.createdAt,
    required this.creatorID,
    required this.creatorName,
    this.lastModifiedAt,
    this.lastStartEditTime,
    this.isEditing = false,
    this.distance,
    this.comments = const [],
    this.orderLogs = const [],
    this.driverInfo,
    required this.pickupTimeWindow,
    required this.deliveryTimeWindow,

    required this.isAdrOrder,
    required this.canGroupWithAdr,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      orderID: json['orderID'],
      orderName: json['orderName'],
      pickupPlace: PostalCode.fromJson(json['pickupPlace']),
      // pickupDate: _parseExactDateTime(json['pickupDate']), // No conversion
      // pickupDateTill: json['pickupDateTill'] ?? false,
      // pickupDateIsFixed: json['pickupDateIsFixed'] ?? false,
      deliveryPlace: PostalCode.fromJson(json['deliveryPlace']),
      // deliveryDate: _parseExactDateTime(json['deliveryDate']), // No conversion
      // deliveryDateTill: json['deliveryDateTill'] ?? false,
      // deliveryDateIsFixed: json['deliveryDateIsFixed'] ?? false,
      ldm: json['ldm'],
      weight: json['weight'],
      price: json['price'],
      carTypeName: json['carTypeName'],
      status: OrderStatus.values.firstWhere(
            (status) => status.name == json['status'],
        orElse: () => OrderStatus.Pending,
      ),
      isConnected: json['isConnected'],
      connectedGroupID: json['connectedGroupID'],
      createdAt: _parseExactDateTime(json['createdAt']), // Retain exact
      creatorID: json['creatorID'],
      creatorName: json['creatorName'],
      lastModifiedAt: json['lastModifiedAt'] != null
          ? _parseExactDateTime(json['lastModifiedAt'])
          : null,
      lastStartEditTime: json['lastStartEditTime'] != null
          ? _parseExactDateTime(json['lastStartEditTime'])
          : null,
      pickupTimeWindow: TimeWindow.fromJson(json['pickupTimeWindow']),
      deliveryTimeWindow: TimeWindow.fromJson(json['deliveryTimeWindow']),
      isEditing: json['isEditing'] ?? false,
      distance: json['distance'],
      comments: (json['comments'] as List<dynamic>? ?? [])
          .map((comment) => Comment.fromJson(comment))
          .toList(),
      orderLogs: (json['orderLogs'] as List<dynamic>? ?? [])
          .map((log) => OrderLog.fromJson(log))
          .toList(),
      driverInfo: json['driverInfo'] != null
          ? DriverInfo.fromJson(json['driverInfo'])
          : null,
      isAdrOrder: json['isAdrOrder'],
      canGroupWithAdr: json['canGroupWithAdr'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'orderID': orderID,
      'orderName': orderName,
      'pickupPlace': pickupPlace.toJson(),
      // 'pickupDate': pickupDate.toString(), // Retain as entered
      // 'pickupDateTill': pickupDateTill,
      // 'pickupDateIsFixed': pickupDateIsFixed,
      'deliveryPlace': deliveryPlace.toJson(),
      // 'deliveryDate': deliveryDate.toString(), // Retain as entered
      // 'deliveryDateTill': deliveryDateTill,
      // 'deliveryDateIsFixed': deliveryDateIsFixed,
      'pickupTimeWindow': pickupTimeWindow.toJson(),
      'deliveryTimeWindow': deliveryTimeWindow.toJson(),
      'ldm': ldm,
      'weight': weight,
      'price': price,
      'carTypeName': carTypeName,
      'status': status.name,
      'isConnected': isConnected,
      'connectedGroupID': connectedGroupID,
      'createdAt': createdAt.toIso8601String(),
      'creatorID': creatorID,
      'creatorName': creatorName,
      'lastModifiedAt': lastModifiedAt?.toIso8601String(),
      'lastStartEditTime': lastStartEditTime?.toIso8601String(),
      'isEditing': isEditing,
      'distance': distance,
      'driverInfo': driverInfo?.toJson(),
      'comments': comments.map((comment) => comment.toJson()).toList(),
      'orderLogs': orderLogs.map((log) => log.toJson()).toList(),
      'isAdrOrder': isAdrOrder,
      'canGroupWithAdr': canGroupWithAdr,
    };
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

/// CopyWith function for immutability
  OrderModel copyWith({
    String? orderID,
    String? orderName,
    PostalCode? pickupPlace,
    DateTime? pickupDate,
    bool? pickupDateTill,
    bool? pickupDateIsFixed,
    PostalCode? deliveryPlace,
    DateTime? deliveryDate,
    bool? deliveryDateTill,
    bool? deliveryDateIsFixed,
    double? ldm,
    double? weight,
    double? price,
    String? carTypeName,
    OrderStatus? status,
    bool? isConnected,
    String? connectedGroupID,
    DateTime? createdAt,
    String? creatorID,
    String? creatorName,
    DateTime? lastModifiedAt,
    DateTime? lastStartEditTime,
    bool? isEditing,
    double? distance,
    List<Comment>? comments,
    List<OrderLog>? orderLogs,
    DriverInfo? driverInfo,
    TimeWindow? pickupTimeWindow,
    TimeWindow? deliveryTimeWindow,
    bool? isAdrOrder,
    bool? canGroupWithAdr,
  }) {
    return OrderModel(
      orderID: orderID ?? this.orderID,
      orderName: orderName ?? this.orderName,
      pickupPlace: pickupPlace ?? this.pickupPlace,
      // pickupDate: pickupDate ?? this.pickupDate,
      // pickupDateTill: pickupDateTill ?? this.pickupDateTill,
      // pickupDateIsFixed: pickupDateIsFixed ?? this.pickupDateIsFixed,
      deliveryPlace: deliveryPlace ?? this.deliveryPlace,
      // deliveryDate: deliveryDate ?? this.deliveryDate,
      // deliveryDateTill: deliveryDateTill ?? this.deliveryDateTill,
      // deliveryDateIsFixed: deliveryDateIsFixed ?? this.deliveryDateIsFixed,
      ldm: ldm ?? this.ldm,
      weight: weight ?? this.weight,
      price: price ?? this.price,
      carTypeName: carTypeName ?? this.carTypeName,
      status: status ?? this.status,
      isConnected: isConnected ?? this.isConnected,
      connectedGroupID: connectedGroupID ?? this.connectedGroupID,
      createdAt: createdAt ?? this.createdAt,
      creatorID: creatorID ?? this.creatorID,
      creatorName: creatorName ?? this.creatorName,
      lastModifiedAt: lastModifiedAt ?? this.lastModifiedAt,
      lastStartEditTime: lastStartEditTime ?? this.lastStartEditTime,
      isEditing: isEditing ?? this.isEditing,
      distance: distance ?? this.distance,
      comments: comments ?? this.comments,
      orderLogs: orderLogs ?? this.orderLogs,
      driverInfo: driverInfo ?? this.driverInfo,
      pickupTimeWindow: pickupTimeWindow ?? this.pickupTimeWindow,
      deliveryTimeWindow: deliveryTimeWindow ?? this.deliveryTimeWindow,
      isAdrOrder: isAdrOrder ?? this.isAdrOrder,
      canGroupWithAdr: canGroupWithAdr ?? this.canGroupWithAdr,
    );
  }
}