import 'package:hegelmann_order_automation/domain/models/commnet_model.dart';
import 'package:hegelmann_order_automation/domain/models/driver_info_model.dart';
import 'package:hegelmann_order_automation/domain/models/order_log_model.dart';
import 'package:hegelmann_order_automation/domain/models/order_model.dart';
import 'package:hegelmann_order_automation/domain/models/post_code_model.dart';
import 'package:hegelmann_order_automation/domain/models/time_window.dart';

class UserRoles {
  static const String admin = "ADMIN"; // Admin role with full control
  static const String teamLead = "TEAM_LEAD"; // Team Lead role for managing orders and filters
  static const String user = "USER"; // User role for creating orders
  static const String planner = "PLANNER"; //  PLANNER role for updating confirm orders status and provide driver

  // List of all roles
  static List<String> get allRoles => [admin, teamLead, user, planner];
}

enum OrderStatus {
  Pending,         // The order has been created but not yet processed.
  Confirmed,       // The order has been reviewed and approved by the team lead.
  Assigned,        // A driver has been assigned for the order or group.
  OnTheWay,        // The order is currently being shipped by the driver.
  Complete,        // The order has been successfully delivered.
  Canceled,        // The order has been canceled.
  ClientCanceled,  // The order has been canceled by client.
  Loaded,  // The order has been Loaded to car.
  Unloaded,  // The order has been Unloaded from car.
  Problematic,     // The order has encountered issues (e.g., delays, damaged goods).
}

final List<String> countries = ["DE", "FR", "IT", "BE", "AT", "CH", "ES", "NL"];


// List<OrderModel> templateOrdersForClusterTest = [
//   OrderModel(
//     orderID: 'ORDER001',
//     orderName: 'Order 1',
//     pickupPlace: PostalCode(
//       countryCode: 'DE',
//       postalCode: '06258',
//       name: 'Schkopau',
//       latitude: 51.4036,
//       longitude: 11.9835,
//     ),
//     deliveryPlace: PostalCode(
//       countryCode: 'FR',
//       postalCode: '58300',
//       name: 'Decize',
//       latitude: 46.8283,
//       longitude: 3.4619,
//     ),
//     ldm: 8.0,
//     weight: 10.3,
//     price: 1400.0,
//     carTypeName: 'TAUTLINER_PLANA',
//     status: OrderStatus.Pending,
//     isConnected: false,
//     connectedGroupID: null,
//     createdAt: DateTime.now(),
//     creatorID: 'admin001',
//     creatorName: 'Admin',
//     comments: [],
//     orderLogs: [],
//     pickupTimeWindow: TimeWindow(end: DateTime.parse('2025-01-14')),
//     deliveryTimeWindow: TimeWindow(end: DateTime.parse('2025-01-17')),
//   ),
//   OrderModel(
//     orderID: 'ORDER002',
//     orderName: 'Order 2',
//     pickupPlace: PostalCode(
//       countryCode: 'DE',
//       postalCode: '04442',
//       name: 'Zwenkau',
//       latitude: 51.2161,
//       longitude: 12.3156,
//     ),
//     deliveryPlace: PostalCode(
//       countryCode: 'FR',
//       postalCode: '62800',
//       name: 'Lievin',
//       latitude: 50.4195,
//       longitude: 2.7783,
//     ),
//     ldm: 4.8,
//     weight: 2.0,
//     price: 1000.0,
//     carTypeName: 'TAUTLINER_PLANA',
//     status: OrderStatus.Pending,
//     isConnected: false,
//     connectedGroupID: null,
//     createdAt: DateTime.now(),
//     creatorID: 'admin001',
//     creatorName: 'Admin',
//     comments: [],
//     orderLogs: [],
//     pickupTimeWindow: TimeWindow(end: DateTime.parse('2025-01-14')),
//     deliveryTimeWindow: TimeWindow(end: DateTime.parse('2025-01-17')),
//   ),
//   OrderModel(
//     orderID: 'ORDER003',
//     orderName: 'Order 3',
//     pickupPlace: PostalCode(
//       countryCode: 'DE',
//       postalCode: '06803',
//       name: 'Bitterfeld-Wolfen',
//       latitude: 51.6232,
//       longitude: 12.3209,
//     ),
//     deliveryPlace: PostalCode(
//       countryCode: 'FR',
//       postalCode: '40260',
//       name: 'Castets',
//       latitude: 43.8515,
//       longitude: -1.1392,
//     ),
//     pickupTimeWindow: TimeWindow(end: DateTime.parse('2025-01-14')),
//     deliveryTimeWindow: TimeWindow(end: DateTime.parse('2025-01-17')),
//     ldm: 7.2,
//     weight: 10.9,
//     price: 1500.0,
//     carTypeName: 'TAUTLINER_PLANA',
//     status: OrderStatus.Pending,
//     isConnected: false,
//     connectedGroupID: null,
//     createdAt: DateTime.now(),
//     creatorID: 'admin001',
//     creatorName: 'Admin',
//     comments: [],
//     orderLogs: [],
//   ),
//   OrderModel(
//     orderID: 'ORDER004',
//     orderName: 'Order 4',
//     pickupPlace: PostalCode(
//       countryCode: 'DE',
//       postalCode: '98744',
//       name: 'Cursdorf',
//       latitude: 50.5801,
//       longitude: 11.0824,
//     ),
//     deliveryPlace: PostalCode(
//       countryCode: 'FR',
//       postalCode: '86200',
//       name: 'Loudun',
//       latitude: 47.0186,
//       longitude: 0.0889,
//     ),
//     ldm: 3.2,
//     weight: 3.2,
//     price: 950.0,
//     carTypeName: 'TAUTLINER_PLANA',
//     status: OrderStatus.Pending,
//     isConnected: false,
//     connectedGroupID: null,
//     createdAt: DateTime.now(),
//     creatorID: 'admin001',
//     creatorName: 'Admin',
//     comments: [],
//     orderLogs: [],
//     pickupTimeWindow: TimeWindow(end: DateTime.parse('2025-01-14')),
//     deliveryTimeWindow: TimeWindow(end: DateTime.parse('2025-01-17')),
//   ),
//   OrderModel(
//     orderID: 'ORDER005',
//     orderName: 'Order 5',
//     pickupPlace: PostalCode(
//       countryCode: 'DE',
//       postalCode: '86843',
//       name: 'Rennersthofen',
//       latitude: 48.133,
//       longitude: 10.725,
//     ),
//     deliveryPlace: PostalCode(
//       countryCode: 'FR',
//       postalCode: '21011',
//       name: 'Harbonneil',
//       latitude: 46.0333,
//       longitude: 4.8333,
//     ),
//     ldm: 10.0,
//     weight: 17.0,
//     price: 1600.0,
//     carTypeName: 'TAUTLINER_PLANA',
//     status: OrderStatus.Pending,
//     isConnected: false,
//     connectedGroupID: null,
//     createdAt: DateTime.now(),
//     creatorID: 'admin001',
//     creatorName: 'Admin',
//     comments: [],
//     orderLogs: [],
//     pickupTimeWindow: TimeWindow(end: DateTime.parse('2025-01-14')),
//     deliveryTimeWindow: TimeWindow(end: DateTime.parse('2025-01-17')),
//   ),
//   OrderModel(
//     orderID: 'ORDER006',
//     orderName: 'Order 6',
//     pickupPlace: PostalCode(
//       countryCode: 'DE',
//       postalCode: '35216',
//       name: 'Biedenkopf',
//       latitude: 50.9075,
//       longitude: 8.5294,
//     ),
//     deliveryPlace: PostalCode(
//       countryCode: 'FR',
//       postalCode: '73000',
//       name: 'Méry',
//       latitude: 45.6333,
//       longitude: 5.9167,
//     ),
//     ldm: 1.8,
//     weight: 2.5,
//     price: 800.0,
//     carTypeName: 'TAUTLINER_PLANA',
//     status: OrderStatus.Pending,
//     isConnected: false,
//     connectedGroupID: null,
//     createdAt: DateTime.now(),
//     creatorID: 'admin001',
//     creatorName: 'Admin',
//     comments: [],
//     orderLogs: [],
//     pickupTimeWindow: TimeWindow(end: DateTime.parse('2025-01-14')),
//     deliveryTimeWindow: TimeWindow(end: DateTime.parse('2025-01-17')),
//   ),
//   OrderModel(
//     orderID: 'ORDER007',
//     orderName: 'Order 7',
//     pickupPlace: PostalCode(
//       countryCode: 'DE',
//       postalCode: '039221',
//       name: 'Bördeland',
//       latitude: 51.9265,
//       longitude: 11.7885,
//     ),
//     deliveryPlace: PostalCode(
//       countryCode: 'FR',
//       postalCode: '84110',
//       name: 'Romilly Sur-Seine',
//       latitude: 48.5167,
//       longitude: 3.7167,
//     ),
//     ldm: 3.5,
//     weight: 3.5,
//     price: 1000.0,
//     carTypeName: 'TAUTLINER_PLANA',
//     status: OrderStatus.Pending,
//     isConnected: false,
//     connectedGroupID: null,
//     createdAt: DateTime.now(),
//     creatorID: 'admin001',
//     creatorName: 'Admin',
//     comments: [],
//     orderLogs: [],
//     pickupTimeWindow: TimeWindow(end: DateTime.parse('2025-01-14')),
//     deliveryTimeWindow: TimeWindow(end: DateTime.parse('2025-01-17')),
//   ),
//   OrderModel(
//     orderID: 'ORDER008',
//     orderName: 'Order 8',
//     pickupPlace: PostalCode(
//       countryCode: 'DE',
//       postalCode: '07554',
//       name: 'Korbussen',
//       latitude: 50.857,
//       longitude: 12.171,
//     ),
//     deliveryPlace: PostalCode(
//       countryCode: 'FR',
//       postalCode: '63500',
//       name: 'Issoire',
//       latitude: 45.55,
//       longitude: 3.25,
//     ),
//     ldm: 6.8,
//     weight: 12.3,
//     price: 1500.0,
//     carTypeName: 'TAUTLINER_PLANA',
//     status: OrderStatus.Pending,
//     isConnected: false,
//     connectedGroupID: null,
//     createdAt: DateTime.now(),
//     creatorID: 'admin001',
//     creatorName: 'Admin',
//     comments: [],
//     orderLogs: [],
//     pickupTimeWindow: TimeWindow(end: DateTime.parse('2025-01-14')),
//     deliveryTimeWindow: TimeWindow(end: DateTime.parse('2025-01-17')),
//   ),
//   OrderModel(
//     orderID: 'ORDER009',
//     orderName: 'Order 9',
//     pickupPlace: PostalCode(
//       countryCode: 'DE',
//       postalCode: '68923',
//       name: 'Bürgschmiedbach',
//       latitude: 49.5771,
//       longitude: 8.1786,
//     ),
//     deliveryPlace: PostalCode(
//       countryCode: 'FR',
//       postalCode: '74140',
//       name: 'Veigy-Foncenex',
//       latitude: 46.2411,
//       longitude: 6.2316,
//     ),
//     ldm: 5.5,
//     weight: 8.2,
//     price: 1200.0,
//     carTypeName: 'TAUTLINER_PLANA',
//     status: OrderStatus.Pending,
//     isConnected: false,
//     connectedGroupID: null,
//     createdAt: DateTime.now(),
//     creatorID: 'admin001',
//     creatorName: 'Admin',
//     comments: [],
//     orderLogs: [],
//     pickupTimeWindow: TimeWindow(end: DateTime.parse('2025-01-14')),
//     deliveryTimeWindow: TimeWindow(end: DateTime.parse('2025-01-17')),
//   ),
//   OrderModel(
//     orderID: 'ORDER010',
//     orderName: 'Order 10',
//     pickupPlace: PostalCode(
//       countryCode: 'DE',
//       postalCode: '41238',
//       name: 'Mönchengladbach',
//       latitude: 51.1854,
//       longitude: 6.4418,
//     ),
//     deliveryPlace: PostalCode(
//       countryCode: 'FR',
//       postalCode: '37300',
//       name: 'Joué-les-Tours',
//       latitude: 47.3474,
//       longitude: 0.6698,
//     ),
//     ldm: 4.0,
//     weight: 6.0,
//     price: 1100.0,
//     carTypeName: 'TAUTLINER_PLANA',
//     status: OrderStatus.Pending,
//     isConnected: false,
//     connectedGroupID: null,
//     createdAt: DateTime.now(),
//     creatorID: 'admin001',
//     creatorName: 'Admin',
//     comments: [],
//     orderLogs: [],
//     pickupTimeWindow: TimeWindow(end: DateTime.parse('2025-01-14')),
//     deliveryTimeWindow: TimeWindow(end: DateTime.parse('2025-01-17')),
//   ),
//   OrderModel(
//     orderID: 'ORDER011',
//     orderName: 'L-vis-3 22km leer OB',
//     pickupPlace: PostalCode(
//       countryCode: 'DE',
//       postalCode: '64521',
//       name: 'GROSS-GERAU',
//       latitude: 49.9196, // Approx latitude
//       longitude: 8.4965, // Approx longitude
//     ),
//     deliveryPlace: PostalCode(
//       countryCode: 'FR',
//       postalCode: '29700',
//       name: 'PLUGUFFAN',
//       latitude: 47.9821, // Approx latitude
//       longitude: -4.1677, // Approx longitude
//     ),
//     ldm: 3.6,
//     weight: 2.0,
//     price: 1500.0,
//     carTypeName: 'TAUTLINER_PLANA', // Assuming this as a car type for the example
//     status: OrderStatus.Pending,
//     isConnected: false,
//     connectedGroupID: null,
//     createdAt: DateTime.now(),
//     creatorID: 'admin002',
//     creatorName: 'Admin',
//     comments: [],
//     orderLogs: [],
//     pickupTimeWindow: TimeWindow(end: DateTime.parse('2025-01-14')),
//     deliveryTimeWindow: TimeWindow(end: DateTime.parse('2025-01-17')),
//   ),
//   OrderModel(
//     orderID: 'ORDER012',
//     orderName: 'L-vis-3 22km leer OB',
//     pickupPlace: PostalCode(
//       countryCode: 'DE',
//       postalCode: '63699',
//       name: 'Kefenrofd',
//       latitude: 50.4167, // Approx latitude
//       longitude: 9.0, // Approx longitude
//     ),
//     deliveryPlace: PostalCode(
//       countryCode: 'FR',
//       postalCode: '29530',
//       name: 'Plonévez-du-Faou',
//       latitude: 48.1875, // Approx latitude
//       longitude: -3.7333, // Approx longitude
//     ),
//     ldm: 3.0, // Assuming an equivalent LDM calculation for 500*80+120*80
//     weight: 2.0,
//     price: 1350.0,
//     carTypeName: 'TAUTLINER_PLANA', // Assuming this as a car type for the example
//     status: OrderStatus.Pending,
//     isConnected: false,
//     connectedGroupID: null,
//     createdAt: DateTime.now(),
//     creatorID: 'admin002',
//     creatorName: 'Admin',
//     comments: [],
//     orderLogs: [],
//     pickupTimeWindow: TimeWindow(end: DateTime.parse('2025-01-14')),
//     deliveryTimeWindow: TimeWindow(end: DateTime.parse('2025-01-17')),
//   ),
// ];

// List<OrderModel> anotherBigOrdersListForTest = [
//   OrderModel(
//     orderID: 'ORDER001',
//     orderName: 'Order 1',
//     pickupPlace: PostalCode(
//       countryCode: 'DE',
//       postalCode: '06258',
//       name: 'Schkopau',
//       latitude: 51.4036, // Replace with actual latitude
//       longitude: 11.9835, // Replace with actual longitude
//     ),
//     pickupDate: DateTime(2024, 6, 7),
//     pickupDateIsFixed: false,
//     deliveryPlace: PostalCode(
//       countryCode: 'FR',
//       postalCode: '58300',
//       name: 'Decize',
//       latitude: 46.8283, // Replace with actual latitude
//       longitude: 3.4619, // Replace with actual longitude
//     ),
//     deliveryDate: DateTime(2024, 6, 10),
//     deliveryDateIsFixed: false,
//     ldm: 8.0,
//     weight: 10.3,
//     price: 1400.0,
//     carTypeName: 'TAUTLINER_PLANA',
//     status: OrderStatus.Pending,
//     isConnected: false,
//     connectedGroupID: null,
//     createdAt: DateTime.now(),
//     creatorID: 'admin001',
//     creatorName: 'Admin',
//     comments: [],
//     orderLogs: [],
//   ),
//   OrderModel(
//     orderID: 'ORDER024',
//     orderName: 'Order 24',
//     pickupPlace: PostalCode(
//       countryCode: 'DE',
//       postalCode: '83512',
//       name: 'Wasserburg A. Inn',
//       latitude: 48.0546, // Replace with actual latitude
//       longitude: 12.2203, // Replace with actual longitude
//     ),
//     pickupDate: null, // No pickup date provided
//     pickupDateIsFixed: false,
//     deliveryPlace: PostalCode(
//       countryCode: 'FR',
//       postalCode: '71100',
//       name: 'Chalon-sur-Saône',
//       latitude: 46.7795, // Replace with actual latitude
//       longitude: 4.8552, // Replace with actual longitude
//     ),
//     deliveryDate: null, // No delivery date provided
//     deliveryDateIsFixed: false,
//     ldm: 5.0,
//     weight: 2.5,
//     price: 650.0,
//     carTypeName: 'plane',
//     status: OrderStatus.Pending,
//     isConnected: false,
//     connectedGroupID: null,
//     createdAt: DateTime.now(),
//     creatorID: 'admin001',
//     creatorName: 'Admin',
//     comments: [],
//     orderLogs: [],
//   ),
//   OrderModel(
//     orderID: 'ORDER026',
//     orderName: 'Order 26',
//     pickupPlace: PostalCode(
//       countryCode: 'FR',
//       postalCode: '59553',
//       name: 'LAUWIN-PLANQUE',
//       latitude: 50.4214, // Replace with actual latitude
//       longitude: 3.1216, // Replace with actual longitude
//     ),
//     pickupDate: DateTime(2024, 6, 5),
//     pickupDateIsFixed: false,
//     deliveryPlace: PostalCode(
//       countryCode: 'FR',
//       postalCode: '36100',
//       name: 'ISSOUDUN',
//       latitude: 46.9495, // Replace with actual latitude
//       longitude: 1.9916, // Replace with actual longitude
//     ),
//     deliveryDate: DateTime(2024, 6, 7),
//     deliveryDateIsFixed: false,
//     ldm: 6.0,
//     weight: 12.0,
//     price: 700.0,
//     carTypeName: 'plane',
//     status: OrderStatus.Pending,
//     isConnected: false,
//     connectedGroupID: null,
//     createdAt: DateTime.now(),
//     creatorID: 'admin001',
//     creatorName: 'Admin',
//     comments: [],
//     orderLogs: [],
//   ),
//   OrderModel(
//     orderID: 'ORDER027',
//     orderName: 'Order 27',
//     pickupPlace: PostalCode(
//       countryCode: 'DE',
//       postalCode: '12099',
//       name: 'Berlin',
//       latitude: 52.468, // Replace with actual latitude
//       longitude: 13.4032, // Replace with actual longitude
//     ),
//     pickupDate: DateTime(2024, 6, 8),
//     pickupDateIsFixed: false,
//     deliveryPlace: PostalCode(
//       countryCode: 'FR',
//       postalCode: '75001',
//       name: 'Paris',
//       latitude: 48.8566, // Replace with actual latitude
//       longitude: 2.3522, // Replace with actual longitude
//     ),
//     deliveryDate: DateTime(2024, 6, 9),
//     deliveryDateIsFixed: false,
//     ldm: 10.5,
//     weight: 8.3,
//     price: 1200.0,
//     carTypeName: 'TAUTLINER_PLANA',
//     status: OrderStatus.Pending,
//     isConnected: false,
//     connectedGroupID: null,
//     createdAt: DateTime.now(),
//     creatorID: 'admin001',
//     creatorName: 'Admin',
//     comments: [],
//     orderLogs: [],
//   ),
//   OrderModel(
//     orderID: 'ORDER028',
//     orderName: 'Order 28',
//     pickupPlace: PostalCode(
//       countryCode: 'DE',
//       postalCode: '20095',
//       name: 'Hamburg',
//       latitude: 53.5511, // Replace with actual latitude
//       longitude: 9.9937, // Replace with actual longitude
//     ),
//     pickupDate: DateTime(2024, 6, 7),
//     pickupDateIsFixed: false,
//     deliveryPlace: PostalCode(
//       countryCode: 'FR',
//       postalCode: '69000',
//       name: 'Lyon',
//       latitude: 45.764, // Replace with actual latitude
//       longitude: 4.8357, // Replace with actual longitude
//     ),
//     deliveryDate: DateTime(2024, 6, 9),
//     deliveryDateIsFixed: false,
//     ldm: 4.0,
//     weight: 3.0,
//     price: 900.0,
//     carTypeName: 'TAUTLINER_PLANA',
//     status: OrderStatus.Pending,
//     isConnected: false,
//     connectedGroupID: null,
//     createdAt: DateTime.now(),
//     creatorID: 'admin002',
//     creatorName: 'Admin',
//     comments: [],
//     orderLogs: [],
//   ),
//   OrderModel(
//     orderID: 'ORDER029',
//     orderName: 'Order 29',
//     pickupPlace: PostalCode(
//       countryCode: 'DE',
//       postalCode: '80331',
//       name: 'Munich',
//       latitude: 48.1351, // Replace with actual latitude
//       longitude: 11.582, // Replace with actual longitude
//     ),
//     pickupDate: DateTime(2024, 6, 6),
//     pickupDateIsFixed: false,
//     deliveryPlace: PostalCode(
//       countryCode: 'FR',
//       postalCode: '75015',
//       name: 'Paris 15th Arrondissement',
//       latitude: 48.8411, // Replace with actual latitude
//       longitude: 2.3201, // Replace with actual longitude
//     ),
//     deliveryDate: DateTime(2024, 6, 8),
//     deliveryDateIsFixed: false,
//     ldm: 8.2,
//     weight: 5.1,
//     price: 1100.0,
//     carTypeName: 'TAUTLINER_PLANA',
//     status: OrderStatus.Pending,
//     isConnected: false,
//     connectedGroupID: null,
//     createdAt: DateTime.now(),
//     creatorID: 'admin001',
//     creatorName: 'Admin',
//     comments: [],
//     orderLogs: [],
//   ),
//   OrderModel(
//     orderID: 'ORDER030',
//     orderName: 'Order 30',
//     pickupPlace: PostalCode(
//       countryCode: 'DE',
//       postalCode: '50667',
//       name: 'Cologne',
//       latitude: 50.9375, // Replace with actual latitude
//       longitude: 6.9603, // Replace with actual longitude
//     ),
//     pickupDate: DateTime(2024, 6, 5),
//     pickupDateIsFixed: false,
//     deliveryPlace: PostalCode(
//       countryCode: 'FR',
//       postalCode: '67000',
//       name: 'Strasbourg',
//       latitude: 48.5734, // Replace with actual latitude
//       longitude: 7.7521, // Replace with actual longitude
//     ),
//     deliveryDate: DateTime(2024, 6, 6),
//     deliveryDateIsFixed: false,
//     ldm: 2.5,
//     weight: 1.2,
//     price: 600.0,
//     carTypeName: 'TAUTLINER_PLANA',
//     status: OrderStatus.Pending,
//     isConnected: false,
//     connectedGroupID: null,
//     createdAt: DateTime.now(),
//     creatorID: 'admin002',
//     creatorName: 'Admin',
//     comments: [],
//     orderLogs: [],
//   ),
//
// ];
