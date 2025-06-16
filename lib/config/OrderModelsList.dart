
import 'package:hegelmann_order_automation/config/constants.dart';
import 'package:hegelmann_order_automation/domain/models/order_model.dart';
import 'package:hegelmann_order_automation/domain/models/post_code_model.dart';
import 'package:hegelmann_order_automation/domain/models/time_window.dart';

List<OrderModel> templateOrdersForClusterTest2 = [

  // OrderModel(
  //   orderID: 'ORDER001',
  //   orderName: 'Order 1',
  //   pickupPlace: PostalCode(
  //     countryCode: '',
  //     postalCode: '',
  //     name: 'DE 94339 LEIBLFING',
  //     latitude: 48.7757, // Placeholder
  //     longitude: 12.5179, // Placeholder
  //   ),
  //   deliveryPlace: PostalCode(
  //     countryCode: '',
  //     postalCode: '',
  //     name: 'FR 83430 ST MANDRIER',
  //     latitude: 43.078, // Placeholder
  //     longitude: 5.929, // Placeholder
  //   ),
  //   pickupTimeWindow: TimeWindow(start: DateTime.parse('2025-01-05'), end: DateTime.parse('2025-01-14')),
  //   deliveryTimeWindow: TimeWindow(start: DateTime.parse('2025-01-05'), end: DateTime.parse('2025-01-17')),
  //   ldm: 2.4,
  //   weight: 3.0,
  //   price: 1100.0,
  //   carTypeName: 'TAUTLINER_PLANA',
  //   status: OrderStatus.Pending,
  //   isConnected: false,
  //   connectedGroupID: null,
  //   createdAt: DateTime.now(),
  //   creatorID: 'admin001',
  //   creatorName: 'Admin',
  //   comments: [],
  //   orderLogs: [],
  // ),
  //
  // OrderModel(
  //   orderID: 'ORDER002',
  //   orderName: 'Order 2',
  //   pickupPlace: PostalCode(
  //     countryCode: '',
  //     postalCode: '',
  //     name: 'AT 4653 Eberstalzell',
  //     latitude: 48.0439, // Placeholder
  //     longitude: 13.9832, // Placeholder
  //   ),
  //   deliveryPlace: PostalCode(
  //     countryCode: '',
  //     postalCode: '',
  //     name: 'FR 84130 Pontet',
  //     latitude: 43.9612, // Placeholder
  //     longitude: 4.8601, // Placeholder
  //   ),
  //   pickupTimeWindow: TimeWindow(start: DateTime.parse('2025-01-11'), end: DateTime.parse('2025-01-15')),
  //   deliveryTimeWindow: TimeWindow(start: DateTime.parse('2025-01-15'), end: DateTime.parse('2025-01-20')),
  //   ldm: 6.8,
  //   weight: 10.7,
  //   price: 1650.0,
  //   carTypeName: 'TAUTLINER_PLANA',
  //   status: OrderStatus.Pending,
  //   isConnected: false,
  //   connectedGroupID: null,
  //   createdAt: DateTime.now(),
  //   creatorID: 'admin001',
  //   creatorName: 'Admin',
  //   comments: [],
  //   orderLogs: [],
  // ),
  //
  // OrderModel(
  //   orderID: 'ORDER003',
  //   orderName: 'Order 3',
  //   pickupPlace: PostalCode(
  //     countryCode: '',
  //     postalCode: '',
  //     name: 'D-93149 Nittenau',
  //     latitude: 49.1942, // Placeholder
  //     longitude: 12.2674, // Placeholder
  //   ),
  //   deliveryPlace: PostalCode(
  //     countryCode: '',
  //     postalCode: '',
  //     name: 'F-44880 Sautron',
  //     latitude: 47.2634, // Placeholder
  //     longitude: -1.6722, // Placeholder
  //   ),
  //   pickupTimeWindow: TimeWindow(start: DateTime.parse('2025-01-07'), end: DateTime.parse('2025-01-07')),
  //   deliveryTimeWindow: TimeWindow(start: DateTime.parse('2025-01-07'), end: DateTime.parse('2025-01-09')),
  //   ldm: 9.8,
  //   weight: 10.0,
  //   price: 1600.0,
  //   carTypeName: 'TAUTLINER_PLANA',
  //   status: OrderStatus.Pending,
  //   isConnected: false,
  //   connectedGroupID: null,
  //   createdAt: DateTime.now(),
  //   creatorID: 'admin001',
  //   creatorName: 'Admin',
  //   comments: [],
  //   orderLogs: [],
  // ),
  //
  // OrderModel(
  //   orderID: 'ORDER004',
  //   orderName: 'Order 4',
  //   pickupPlace: PostalCode(
  //     countryCode: '',
  //     postalCode: '',
  //     name: 'DE, 85622 Feldkirchen ',
  //     latitude: 48.1481, // Placeholder
  //     longitude: 11.731, // Placeholder
  //   ),
  //   deliveryPlace: PostalCode(
  //     countryCode: '',
  //     postalCode: '',
  //     name: 'F-44150 Ancenis',
  //     latitude: 47.3667, // Placeholder
  //     longitude: -1.1667, // Placeholder
  //   ),
  //   pickupTimeWindow: TimeWindow(start: DateTime.parse('2025-01-07'), end: DateTime.parse('2025-01-07')),
  //   deliveryTimeWindow: TimeWindow(start: DateTime.parse('2025-01-07'), end: DateTime.parse('2025-01-09')),
  //   ldm: 3.7,
  //   weight: 4.0,
  //   price: 600.0,
  //   carTypeName: 'TAUTLINER_PLANA',
  //   status: OrderStatus.Pending,
  //   isConnected: false,
  //   connectedGroupID: null,
  //   createdAt: DateTime.now(),
  //   creatorID: 'admin001',
  //   creatorName: 'Admin',
  //   comments: [],
  //   orderLogs: [],
  // ),
  //
  // OrderModel(
  //   orderID: 'ORDER005',
  //   orderName: 'Order 5',
  //   pickupPlace: PostalCode(
  //     countryCode: '',
  //     postalCode: '',
  //     name: 'CZ-34701 TACHOV ',
  //     latitude:  49.795, // Placeholder
  //     longitude:  12.634, // Placeholder
  //   ),
  //   deliveryPlace: PostalCode(
  //     countryCode: '',
  //     postalCode: '',
  //     name: 'FR-44150 ANCENIS ',
  //     latitude: 47.367, // Placeholder
  //     longitude: -1.167, // Placeholder
  //   ),
  //   pickupTimeWindow: TimeWindow(start: DateTime.parse('2025-01-07'), end: DateTime.parse('2025-01-07')),
  //   deliveryTimeWindow: TimeWindow(start: DateTime.parse('2025-01-07'), end: DateTime.parse('2025-01-09')),
  //   ldm: 8.0,
  //   weight: 7.0,
  //   price: 1850.0,
  //   carTypeName: 'TAUTLINER_PLANA',
  //   status: OrderStatus.Pending,
  //   isConnected: false,
  //   connectedGroupID: null,
  //   createdAt: DateTime.now(),
  //   creatorID: 'admin001',
  //   creatorName: 'Admin',
  //   comments: [],
  //   orderLogs: [],
  // ),
  //
  // OrderModel(
  //   orderID: 'ORDER006',
  //   orderName: 'Order 6',
  //   pickupPlace: PostalCode(
  //     countryCode: '',
  //     postalCode: '',
  //     name: 'DE, 85276 Hettenshausen ',
  //     latitude: 48.5, // Placeholder
  //     longitude: 11.5, // Placeholder
  //   ),
  //   deliveryPlace: PostalCode(
  //     countryCode: '',
  //     postalCode: '',
  //     name: 'FR, 44860 Pont-Saint-Martin ',
  //     latitude: 47.124, // Placeholder
  //     longitude: -1.585, // Placeholder
  //   ),
  //   pickupTimeWindow: TimeWindow(start: DateTime.parse('2025-01-07'), end: DateTime.parse('2025-01-08')),
  //   deliveryTimeWindow: TimeWindow(start: DateTime.parse('2025-01-08'), end: DateTime.parse('2025-01-10')),
  //   ldm: 2.0,
  //   weight: 2.0,
  //   price: 900.0,
  //   carTypeName: 'TAUTLINER_PLANA',
  //   status: OrderStatus.Pending,
  //   isConnected: false,
  //   connectedGroupID: null,
  //   createdAt: DateTime.now(),
  //   creatorID: 'admin001',
  //   creatorName: 'Admin',
  //   comments: [],
  //   orderLogs: [],
  // ),
  //
  // OrderModel(
  //   orderID: 'ORDER007',
  //   orderName: 'Order 7',
  //   pickupPlace: PostalCode(
  //     countryCode: '',
  //     postalCode: '',
  //     name: 'D- 91710 GUNZENHAUSEN',
  //     latitude: 49.117, // Placeholder
  //     longitude: 10.76, // Placeholder
  //   ),
  //   deliveryPlace: PostalCode(
  //     countryCode: '',
  //     postalCode: '',
  //     name: 'F- 74930 PERS JUSSY',
  //     latitude: 46.106, // Placeholder
  //     longitude: 6.27, // Placeholder
  //   ),
  //   pickupTimeWindow: TimeWindow(start: DateTime.parse('2025-01-05'), end: DateTime.parse('2025-01-07 14:30:00')),
  //   deliveryTimeWindow: TimeWindow(start: DateTime.parse('2025-01-08'), end: DateTime.parse('2025-01-10')),
  //   ldm: 5.0,
  //   weight: 2.5,
  //   price: 900.0,
  //   carTypeName: 'TAUTLINER_PLANA',
  //   status: OrderStatus.Pending,
  //   isConnected: false,
  //   connectedGroupID: null,
  //   createdAt: DateTime.now(),
  //   creatorID: 'admin001',
  //   creatorName: 'Admin',
  //   comments: [],
  //   orderLogs: [],
  // ),
  // OrderModel(
  //   orderID: 'ORDER0065',
  //   orderName: 'Order 65',
  //   pickupPlace: PostalCode(
  //     countryCode: '',
  //     postalCode: '',
  //     name: 'FR71700 TOURNUS',
  //     latitude: 46.568, // Placeholder
  //     longitude: 4.906, // Placeholder
  //   ),
  //   deliveryPlace: PostalCode(
  //     countryCode: '',
  //     postalCode: '',
  //     name: 'F- 74930 PERS JUSSY',
  //     latitude: 46.106, // Placeholder
  //     longitude: 6.27, // Placeholder
  //   ),
  //   pickupTimeWindow: TimeWindow(start: DateTime.parse('2025-01-05'), end: DateTime.parse('2025-01-07 14:30:00')),
  //   deliveryTimeWindow: TimeWindow(start: DateTime.parse('2025-01-08'), end: DateTime.parse('2025-01-10')),
  //   ldm: 5.0,
  //   weight: 2.5,
  //   price: 200.0,
  //   carTypeName: 'TAUTLINER_PLANA',
  //   status: OrderStatus.Pending,
  //   isConnected: false,
  //   connectedGroupID: null,
  //   createdAt: DateTime.now(),
  //   creatorID: 'admin001',
  //   creatorName: 'Admin',
  //   comments: [],
  //   orderLogs: [],
  // ),
  // OrderModel(
  //   orderID: 'ORDER008',
  //   orderName: 'Order 8',
  //   pickupPlace: PostalCode(
  //     countryCode: '',
  //     postalCode: '',
  //     name: 'DE 97234 Reichenberg',
  //     latitude: 49.732, // Placeholder
  //     longitude: 9.915, // Placeholder
  //   ),
  //   deliveryPlace: PostalCode(
  //     countryCode: '',
  //     postalCode: '',
  //     name: 'FR 73100 Aix-les-Bains',
  //     latitude: 45.692, // Placeholder
  //     longitude: 5.909, // Placeholder
  //   ),
  //   pickupTimeWindow: TimeWindow(start: DateTime.parse('2025-01-05'), end: DateTime.parse('2025-01-07')),
  //   deliveryTimeWindow: TimeWindow(start: DateTime.parse('2025-01-05'), end: DateTime.parse('2025-01-10')),
  //   ldm: 5.0,
  //   weight: 3.7,
  //   price: 900.0,
  //   carTypeName: 'TAUTLINER_PLANA',
  //   status: OrderStatus.Pending,
  //   isConnected: false,
  //   connectedGroupID: null,
  //   createdAt: DateTime.now(),
  //   creatorID: 'admin001',
  //   creatorName: 'Admin',
  //   comments: [],
  //   orderLogs: [],
  // ),
  //
  // OrderModel(
  //   orderID: 'ORDER009',
  //   orderName: 'Order 9',
  //   pickupPlace: PostalCode(
  //     countryCode: '',
  //     postalCode: '',
  //     name: 'De-86643 Rennertshofen',
  //     latitude: 48.759, // Placeholder
  //     longitude: 48.759, // Placeholder
  //   ),
  //   deliveryPlace: PostalCode(
  //     countryCode: '',
  //     postalCode: '',
  //     name: 'Fr-76170 Lillebonne',
  //     latitude: 49.52, // Placeholder
  //     longitude: 0.536, // Placeholder
  //   ),
  //   pickupTimeWindow: TimeWindow(start: DateTime.parse('2025-01-05'), end: DateTime.parse('2025-01-07 15:00:00')),
  //   deliveryTimeWindow: TimeWindow(start: DateTime.parse('2025-01-05'), end: DateTime.parse('2025-01-09 14:00:00')),
  //   ldm: 6.0,
  //   weight: 11.6,
  //   price: 1050.0,
  //   carTypeName: 'TAUTLINER_PLANA',
  //   status: OrderStatus.Pending,
  //   isConnected: false,
  //   connectedGroupID: null,
  //   createdAt: DateTime.now(),
  //   creatorID: 'admin001',
  //   creatorName: 'Admin',
  //   comments: [],
  //   orderLogs: [],
  // ),
  //
  // OrderModel(
  //   orderID: 'ORDER010',
  //   orderName: 'Order 10',
  //   pickupPlace: PostalCode(
  //     countryCode: '',
  //     postalCode: '',
  //     name: 'De-86643 Rennertshofen',
  //     latitude: 48.759, // Placeholder
  //     longitude: 11.045, // Placeholder
  //   ),
  //   deliveryPlace: PostalCode(
  //     countryCode: '',
  //     postalCode: '',
  //     name: 'Fr-95500 Le Thillay',
  //     latitude: 49.007, // Placeholder
  //     longitude: 2.472, // Placeholder
  //   ),
  //   pickupTimeWindow: TimeWindow(start: DateTime.parse('2025-01-05'), end: DateTime.parse('2025-01-07 15:00:00')),
  //   deliveryTimeWindow: TimeWindow(start: DateTime.parse('2025-01-05'), end: DateTime.parse('2025-01-09 14:00:00')),
  //   ldm: 4.6,
  //   weight: 6.0,
  //   price: 800.0,
  //   carTypeName: 'TAUTLINER_PLANA',
  //   status: OrderStatus.Pending,
  //   isConnected: false,
  //   connectedGroupID: null,
  //   createdAt: DateTime.now(),
  //   creatorID: 'admin001',
  //   creatorName: 'Admin',
  //   comments: [],
  //   orderLogs: [],
  // ),
  //
  // OrderModel(
  //   orderID: 'ORDER011',
  //   orderName: 'Order 11',
  //   pickupPlace: PostalCode(
  //     countryCode: '',
  //     postalCode: '',
  //     name: 'DE 74613 Öhringen',
  //     latitude: 49.199, // Placeholder
  //     longitude: 9.507, // Placeholder
  //   ),
  //   deliveryPlace: PostalCode(
  //     countryCode: '',
  //     postalCode: '',
  //     name: 'FR 44242 La Chapelle Sur Erdre',
  //     latitude: 47.3, // Placeholder
  //     longitude: -1.552, // Placeholder
  //   ),
  //   pickupTimeWindow: TimeWindow(start: DateTime.parse('2025-01-05'), end: DateTime.parse('2025-01-07')),
  //   deliveryTimeWindow: TimeWindow(start: DateTime.parse('2025-01-09'), end: DateTime.parse('2025-01-09')),
  //   ldm: 4.4,
  //   weight: 1.5,
  //   price: 1100.0,
  //   carTypeName: 'TAUTLINER_PLANA',
  //   status: OrderStatus.Pending,
  //   isConnected: false,
  //   connectedGroupID: null,
  //   createdAt: DateTime.now(),
  //   creatorID: 'admin001',
  //   creatorName: 'Admin',
  //   comments: [],
  //   orderLogs: [],
  // ),
  //
  // OrderModel(
  //   orderID: 'ORDER012',
  //   orderName: 'Order 12',
  //   pickupPlace: PostalCode(
  //     countryCode: '',
  //     postalCode: '',
  //     name: 'DE 72172 SULZ AM NECKAR',
  //     latitude: 48.362, // Placeholder
  //     longitude: 8.633, // Placeholder
  //   ),
  //   deliveryPlace: PostalCode(
  //     countryCode: '',
  //     postalCode: '',
  //     name: 'FR 44240 LA CHAPELLE SUR ERDRE',
  //     latitude: 47.3, // Placeholder
  //     longitude: -1.552, // Placeholder
  //   ),
  //   pickupTimeWindow: TimeWindow(start: DateTime.parse('2025-01-05'), end: DateTime.parse('2025-01-07')),
  //   deliveryTimeWindow: TimeWindow(start: DateTime.parse('2025-01-07'), end: DateTime.parse('2025-01-09')),
  //   ldm: 4.0,
  //   weight: 3.5,
  //   price: 1000.0,
  //   carTypeName: 'TAUTLINER_PLANA',
  //   status: OrderStatus.Pending,
  //   isConnected: false,
  //   connectedGroupID: null,
  //   createdAt: DateTime.now(),
  //   creatorID: 'admin001',
  //   creatorName: 'Admin',
  //   comments: [],
  //   orderLogs: [],
  // ),
  //
  // OrderModel(
  //   orderID: 'ORDER013',
  //   orderName: 'Order 13',
  //   pickupPlace: PostalCode(
  //     countryCode: '',
  //     postalCode: '',
  //     name: 'Be-7190 Marche lez ecaussinnes',
  //     latitude: 50.546, // Placeholder
  //     longitude: 4.182, // Placeholder
  //   ),
  //   deliveryPlace: PostalCode(
  //     countryCode: '',
  //     postalCode: '',
  //     name: 'FR 38160 Saint Marcelin',
  //     latitude: 45.149, // Placeholder
  //     longitude: 5.317, // Placeholder
  //   ),
  //   pickupTimeWindow: TimeWindow(start: DateTime.parse('2025-01-05'), end: DateTime.parse('2025-01-07')),
  //   deliveryTimeWindow: TimeWindow(start: DateTime.parse('2025-01-07'), end: DateTime.parse('2025-01-08')),
  //   ldm: 6.1,
  //   weight: 12.7,
  //   price: 720.0,
  //   carTypeName: 'TAUTLINER_PLANA',
  //   status: OrderStatus.Pending,
  //   isConnected: false,
  //   connectedGroupID: null,
  //   createdAt: DateTime.now(),
  //   creatorID: 'admin001',
  //   creatorName: 'Admin',
  //   comments: [],
  //   orderLogs: [],
  // ),
  //
  // OrderModel(
  //   orderID: 'ORDER014',
  //   orderName: 'Order 14',
  //   pickupPlace: PostalCode(
  //     countryCode: '',
  //     postalCode: '',
  //     name: 'BE-7181 SENEFFE',
  //     latitude: 50.5565, // Placeholder
  //     longitude: 4.2611, // Placeholder
  //   ),
  //   deliveryPlace: PostalCode(
  //     countryCode: '',
  //     postalCode: '',
  //     name: 'FR 69830 SAINT-GEORGES-DE-RENEINS',
  //     latitude: 46.062, // Placeholder
  //     longitude: 4.722, // Placeholder
  //   ),
  //   pickupTimeWindow: TimeWindow(start: DateTime.parse('2025-01-05'), end: DateTime.parse('2025-01-07')),
  //   deliveryTimeWindow: TimeWindow(start: DateTime.parse('2025-01-07'), end: DateTime.parse('2025-01-09')),
  //   ldm: 6.1,
  //   weight: 12.7,
  //   price: 850.0,
  //   carTypeName: 'TAUTLINER_PLANA',
  //   status: OrderStatus.Pending,
  //   isConnected: false,
  //   connectedGroupID: null,
  //   createdAt: DateTime.now(),
  //   creatorID: 'admin001',
  //   creatorName: 'Admin',
  //   comments: [],
  //   orderLogs: [],
  // ),
  //
  // OrderModel(
  //   orderID: 'ORDER015',
  //   orderName: 'Order 15',
  //   pickupPlace: PostalCode(
  //     countryCode: '',
  //     postalCode: '',
  //     name: 'D-29478 Hohbeck',
  //     latitude: 53.056, // Placeholder
  //     longitude: 11.434, // Placeholder
  //   ),
  //   deliveryPlace: PostalCode(
  //     countryCode: '',
  //     postalCode: '',
  //     name: 'F-93600 Aulnay/ rampa',
  //     latitude: 48.938, // Placeholder
  //     longitude: 2.494, // Placeholder
  //   ),
  //   pickupTimeWindow: TimeWindow(start: DateTime.parse('2025-01-05'), end: DateTime.parse('2025-01-06')),
  //   deliveryTimeWindow: TimeWindow(start: DateTime.parse('2025-01-08'), end: DateTime.parse('2025-01-08')),
  //   ldm: 6.5,
  //   weight: 11.7,
  //   price: 1400.0,
  //   carTypeName: 'TAUTLINER_PLANA',
  //   status: OrderStatus.Pending,
  //   isConnected: false,
  //   connectedGroupID: null,
  //   createdAt: DateTime.now(),
  //   creatorID: 'admin001',
  //   creatorName: 'Admin',
  //   comments: [],
  //   orderLogs: [],
  // ),
  //
  // OrderModel(
  //   orderID: 'ORDER016',
  //   orderName: 'Order 16',
  //   pickupPlace: PostalCode(
  //     countryCode: '',
  //     postalCode: '',
  //     name: 'D- 32479 Hille ',
  //     latitude: 52.333, // Placeholder
  //     longitude: 8.75, // Placeholder
  //   ),
  //   deliveryPlace: PostalCode(
  //     countryCode: '',
  //     postalCode: '',
  //     name: 'F- 45 Boigny sur Bionne/ rampa',
  //     latitude: 47.933, // Placeholder
  //     longitude: 2.017, // Placeholder
  //   ),
  //   pickupTimeWindow: TimeWindow(start: DateTime.parse('2025-01-05'), end: DateTime.parse('2025-01-06 14:00:00')),
  //   deliveryTimeWindow: TimeWindow(start: DateTime.parse('2025-01-06 14:00:00'), end: DateTime.parse('2025-01-08')),
  //   ldm: 4.0,
  //   weight: 2.4,
  //   price: 900.0,
  //   carTypeName: 'TAUTLINER_PLANA',
  //   status: OrderStatus.Pending,
  //   isConnected: false,
  //   connectedGroupID: null,
  //   createdAt: DateTime.now(),
  //   creatorID: 'admin001',
  //   creatorName: 'Admin',
  //   comments: [],
  //   orderLogs: [],
  // ),
  //
  // OrderModel(
  //   orderID: 'ORDER017',
  //   orderName: 'Order 17',
  //   pickupPlace: PostalCode(
  //     countryCode: '',
  //     postalCode: '',
  //     name: 'De-99510 Apolda',
  //     latitude: 51.026, // Placeholder
  //     longitude: 11.516, // Placeholder
  //   ),
  //   pickupDate: DateTime.parse('2025-01-07'),
  //       pickupDateTill: false,
  //   pickupDateIsFixed: false,
  //   deliveryPlace: PostalCode(
  //     countryCode: '',
  //     postalCode: '',
  //     name: 'Fr-78610 Le Perray en yvelines',
  //     latitude: 48.694, // Placeholder
  //     longitude: 1.856, // Placeholder
  //   ),
  //   deliveryDate: DateTime.parse('2025-01-07'),
  //       deliveryDateTill: false,
  //   deliveryDateIsFixed: false,
  //   ldm: 4.0,
  //   weight: 2.5,
  //   price: 1100.0,
  //   carTypeName: 'TAUTLINER_PLANA',
  //   status: OrderStatus.Pending,
  //   isConnected: false,
  //   connectedGroupID: null,
  //   createdAt: DateTime.now(),
  //   creatorID: 'admin001',
  //   creatorName: 'Admin',
  //   comments: [],
  //   orderLogs: [],
  // ),
  // OrderModel(
  //   orderID: 'ORDER018',
  //   orderName: 'Order 18',
  //   pickupPlace: PostalCode(
  //     countryCode: '',
  //     postalCode: '',
  //     name: 'De-99610 Sommerda',
  //     latitude: 67.453, // Placeholder
  //     longitude: 26.855, // Placeholder
  //   ),
  //   pickupDate: DateTime.parse('2025-01-07'),
  //       pickupDateTill: false,
  //   pickupDateIsFixed: false,
  //   deliveryPlace: PostalCode(
  //     countryCode: '',
  //     postalCode: '',
  //     name: 'Fr-91090 Lisses',
  //     latitude: 48.602, // Placeholder
  //     longitude: 2.422, // Placeholder
  //   ),
  //   deliveryDate: DateTime.parse('2025-01-10'),
  //       deliveryDateTill: false,
  //   deliveryDateIsFixed: false,
  //   ldm: 6.8,
  //   weight: 4.0,
  //   price: 1250.0,
  //   carTypeName: 'TAUTLINER_PLANA',
  //   status: OrderStatus.Pending,
  //   isConnected: false,
  //   connectedGroupID: null,
  //   createdAt: DateTime.now(),
  //   creatorID: 'admin001',
  //   creatorName: 'Admin',
  //   comments: [],
  //   orderLogs: [],
  // ),
  // OrderModel(
  //   orderID: 'ORDER019',
  //   orderName: 'Order 19',
  //   pickupPlace: PostalCode(
  //     countryCode: '',
  //     postalCode: '',
  //     name: 'D- 99091 Erfurt ',
  //     latitude: 51.014, // Placeholder
  //     longitude: 10.993, // Placeholder
  //   ),
  //   pickupDate: DateTime.parse('2025-01-07'),
  //       pickupDateTill: false,
  //   pickupDateIsFixed: false,
  //   deliveryPlace: PostalCode(
  //     countryCode: '',
  //     postalCode: '',
  //     name: 'F- 45 Boigny sur Bionne',
  //     latitude: 47.933, // Placeholder
  //     longitude: 2.017, // Placeholder
  //   ),
  //   deliveryDate: DateTime.parse('2025-01-01'),
  //       deliveryDateTill: false,
  //   deliveryDateIsFixed: false,
  //   ldm: 2.0,
  //   weight: 1.2,
  //   price: 850.0,
  //   carTypeName: 'TAUTLINER_PLANA',
  //   status: OrderStatus.Pending,
  //   isConnected: false,
  //   connectedGroupID: null,
  //   createdAt: DateTime.now(),
  //   creatorID: 'admin001',
  //   creatorName: 'Admin',
  //   comments: [],
  //   orderLogs: [],
  // ),
  // OrderModel(
  //   orderID: 'ORDER020',
  //   orderName: 'Order 20',
  //   pickupPlace: PostalCode(
  //     countryCode: '',
  //     postalCode: '',
  //     name: 'DE 95632 WUNSIEDEL',
  //     latitude: 50.039, // Placeholder
  //     longitude: 12.003, // Placeholder
  //   ),
  //   pickupDate: DateTime.parse('2025-01-08'),
  //       pickupDateTill: true,
  //   pickupDateIsFixed: false,
  //   deliveryPlace: PostalCode(
  //     countryCode: '',
  //     postalCode: '',
  //     name: 'FR 57340 MORHANGE',
  //     latitude: 48.924, // Placeholder
  //     longitude: 6.642, // Placeholder
  //   ),
  //   deliveryDate: DateTime.parse('2025-01-10'),
  //       deliveryDateTill: false,
  //   deliveryDateIsFixed: false,
  //   ldm: 2.0,
  //   weight: 4.3,
  //   price: 800.0,
  //   carTypeName: 'TAUTLINER_PLANA',
  //   status: OrderStatus.Pending,
  //   isConnected: false,
  //   connectedGroupID: null,
  //   createdAt: DateTime.now(),
  //   creatorID: 'admin001',
  //   creatorName: 'Admin',
  //   comments: [],
  //   orderLogs: [],
  // ),
  // OrderModel(
  //   orderID: 'ORDER021',
  //   orderName: 'Order 21',
  //   pickupPlace: PostalCode(
  //     countryCode: '',
  //     postalCode: '',
  //     name: 'DE 90403+DE 71384',
  //     latitude: 49.454, // Placeholder
  //     longitude: 11.077, // Placeholder
  //   ),
  //   pickupDate: DateTime.parse('2024-01-08'),
  //       pickupDateTill: false,
  //   pickupDateIsFixed: false,
  //   deliveryPlace: PostalCode(
  //     countryCode: '',
  //     postalCode: '',
  //     name: 'FR 69400 Arnas',
  //     latitude: 46.024, // Placeholder
  //     longitude: 4.708, // Placeholder
  //   ),
  //   deliveryDate: DateTime.parse('2025-01-10'),
  //       deliveryDateTill: true,
  //   deliveryDateIsFixed: false,
  //   ldm: 10.8,
  //   weight: 10.0,
  //   price: 825.0,
  //   carTypeName: 'TAUTLINER_PLANA',
  //   status: OrderStatus.Pending,
  //   isConnected: false,
  //   connectedGroupID: null,
  //   createdAt: DateTime.now(),
  //   creatorID: 'admin001',
  //   creatorName: 'Admin',
  //   comments: [],
  //   orderLogs: [],
  // ),
  // OrderModel(
  //   orderID: 'ORDER066',
  //   orderName: 'Order 66',
  //   pickupPlace: PostalCode(
  //     countryCode: '',
  //     postalCode: '',
  //     name: 'DE 71384',
  //     latitude:  48.809, // Placeholder
  //     longitude:  9.377, // Placeholder
  //   ),
  //   pickupDate: DateTime.parse('2024-01-08'),
  //       pickupDateTill: false,
  //   pickupDateIsFixed: false,
  //   deliveryPlace: PostalCode(
  //     countryCode: '',
  //     postalCode: '',
  //     name: 'FR 69400 Arnas',
  //     latitude: 46.024, // Placeholder
  //     longitude: 4.708, // Placeholder
  //   ),
  //   deliveryDate: DateTime.parse('2025-01-10'),
  //       deliveryDateTill: true,
  //   deliveryDateIsFixed: false,
  //   ldm: 10.8,
  //   weight: 10.0,
  //   price: 825.0,
  //   carTypeName: 'TAUTLINER_PLANA',
  //   status: OrderStatus.Pending,
  //   isConnected: false,
  //   connectedGroupID: null,
  //   createdAt: DateTime.now(),
  //   creatorID: 'admin001',
  //   creatorName: 'Admin',
  //   comments: [],
  //   orderLogs: [],
  // ),
  // OrderModel(
  //   orderID: 'ORDER022',
  //   orderName: 'Order 22',
  //   pickupPlace: PostalCode(
  //     countryCode: '',
  //     postalCode: '',
  //     name: 'De-73494 Rosenberg',
  //     latitude: 49.019, // Placeholder
  //     longitude: 10.03, // Placeholder
  //   ),
  //   pickupDate: DateTime.parse('2025-01-07'),
  //       pickupDateTill: false,
  //   pickupDateIsFixed: false,
  //   deliveryPlace: PostalCode(
  //     countryCode: '',
  //     postalCode: '',
  //     name: 'Fr-76490 Rives en seine caudebec en caux',
  //     latitude: 49.526, // Placeholder
  //     longitude: 0.726, // Placeholder
  //   ),
  //   deliveryDate: DateTime.parse('2025-01-09'),
  //       deliveryDateTill: true,
  //   deliveryDateIsFixed: false,
  //   ldm: 8.05,
  //   weight: 6.5,
  //   price: 1150.0,
  //   carTypeName: 'TAUTLINER_PLANA',
  //   status: OrderStatus.Pending,
  //   isConnected: false,
  //   connectedGroupID: null,
  //   createdAt: DateTime.now(),
  //   creatorID: 'admin001',
  //   creatorName: 'Admin',
  //   comments: [],
  //   orderLogs: [],
  // ),
  // OrderModel(
  //   orderID: 'ORDER023',
  //   orderName: 'Order 23',
  //   pickupPlace: PostalCode(
  //     countryCode: '',
  //     postalCode: '',
  //     name: 'DE 74613 Öhringen',
  //     latitude: 49.199, // Placeholder
  //     longitude: 9.507, // Placeholder
  //   ),
  //   pickupDate: DateTime.parse('2025-01-08'),
  //       pickupDateTill: false,
  //   pickupDateIsFixed: false,
  //   deliveryPlace: PostalCode(
  //     countryCode: '',
  //     postalCode: '',
  //     name: 'F - 91830 Le Coudray-Montceaux',
  //     latitude: 48.564, // Placeholder
  //     longitude: 2.5, // Placeholder
  //   ),
  //   deliveryDate: DateTime.parse('2025-01-10'),
  //       deliveryDateTill: false,
  //   deliveryDateIsFixed: true,
  //   ldm: 3.4,
  //   weight: 2.0,
  //   price: 950.0,
  //   carTypeName: 'TAUTLINER_PLANA',
  //   status: OrderStatus.Pending,
  //   isConnected: false,
  //   connectedGroupID: null,
  //   createdAt: DateTime.now(),
  //   creatorID: 'admin001',
  //   creatorName: 'Admin',
  //   comments: [],
  //   orderLogs: [],
  // ),
  // OrderModel(
  //   orderID: 'ORDER024',
  //   orderName: 'Order 24',
  //   pickupPlace: PostalCode(
  //     countryCode: '',
  //     postalCode: '',
  //     name: 'De-53902 Bad Munstereifel',
  //     latitude: 50.557, // Placeholder
  //     longitude: 6.764, // Placeholder
  //   ),
  //   pickupDate: DateTime.parse('2025-01-06'),
  //       pickupDateTill: true,
  //   pickupDateIsFixed: false,
  //   deliveryPlace: PostalCode(
  //     countryCode: '',
  //     postalCode: '',
  //     name: 'Fr-70220 Fougerolles / by side bokom',
  //     latitude: 47.885, // Placeholder
  //     longitude: 6.405, // Placeholder
  //   ),
  //   deliveryDate: DateTime.parse('2025-01-07'),
  //       deliveryDateTill: true,
  //   deliveryDateIsFixed: false,
  //   ldm: 4.1,
  //   weight: 5.3,
  //   price: 600.0,
  //   carTypeName: 'TAUTLINER_PLANA',
  //   status: OrderStatus.Pending,
  //   isConnected: false,
  //   connectedGroupID: null,
  //   createdAt: DateTime.now(),
  //   creatorID: 'admin001',
  //   creatorName: 'Admin',
  //   comments: [],
  //   orderLogs: [],
  // ),
  // OrderModel(
  //   orderID: 'ORDER025',
  //   orderName: 'Order 25',
  //   pickupPlace: PostalCode(
  //     countryCode: '',
  //     postalCode: '',
  //     name: 'D-52146 WURSELEN',
  //     latitude: 50.818, // Placeholder
  //     longitude: 6.135, // Placeholder
  //   ),
  //   pickupDate: DateTime.parse('2025-01-06'),
  //       pickupDateTill: false,
  //   pickupDateIsFixed: false,
  //   deliveryPlace: PostalCode(
  //     countryCode: '',
  //     postalCode: '',
  //     name: 'FR90100 DELLE',
  //     latitude: 47.508, // Placeholder
  //     longitude: 7, // Placeholder
  //   ),
  //   deliveryDate: DateTime.parse('2025-01-07'),
  //       deliveryDateTill: false,
  //   deliveryDateIsFixed: false,
  //   ldm: 2.5,
  //   weight: 2.0,
  //   price: 620.0,
  //   carTypeName: 'TAUTLINER_PLANA',
  //   status: OrderStatus.Pending,
  //   isConnected: false,
  //   connectedGroupID: null,
  //   createdAt: DateTime.now(),
  //   creatorID: 'admin001',
  //   creatorName: 'Admin',
  //   comments: [],
  //   orderLogs: [],
  // ),
  // OrderModel(
  //   orderID: 'ORDER026',
  //   orderName: 'Order 26',
  //   pickupPlace: PostalCode(
  //     countryCode: '',
  //     postalCode: '',
  //     name: 'Be-2830 Willebroek',
  //     latitude: 51.06, // Placeholder
  //     longitude: 4.36, // Placeholder
  //   ),
  //   pickupDate: DateTime.parse('2025-01-06'),
  //       pickupDateTill: true,
  //   pickupDateIsFixed: false,
  //   deliveryPlace: PostalCode(
  //     countryCode: '',
  //     postalCode: '',
  //     name: 'Fr-52130 Brousseval / side bokom',
  //     latitude: 48.49, // Placeholder
  //     longitude: 4.967, // Placeholder
  //   ),
  //   deliveryDate: DateTime.parse('2025-01-08'),
  //       deliveryDateTill: true,
  //   deliveryDateIsFixed: false,
  //   ldm: 6.0,
  //   weight: 10.2,
  //   price: 650.0,
  //   carTypeName: 'TAUTLINER_PLANA',
  //   status: OrderStatus.Pending,
  //   isConnected: false,
  //   connectedGroupID: null,
  //   createdAt: DateTime.now(),
  //   creatorID: 'admin001',
  //   creatorName: 'Admin',
  //   comments: [],
  //   orderLogs: [],
  // ),
  // OrderModel(
  //   orderID: 'ORDER027',
  //   orderName: 'Order 27',
  //   pickupPlace: PostalCode(
  //     countryCode: '',
  //     postalCode: '',
  //     name: 'DE-65555 Limburg',
  //     latitude: 50.383, // Placeholder
  //     longitude: 8.05, // Placeholder
  //   ),
  //   pickupDate: DateTime.parse('2025-01-07'),
  //       pickupDateTill: false,
  //   pickupDateIsFixed: false,
  //   deliveryPlace: PostalCode(
  //     countryCode: '',
  //     postalCode: '',
  //     name: 'F-45250 Briare',
  //     latitude: 47.633, // Placeholder
  //     longitude: 2.744, // Placeholder
  //   ),
  //   deliveryDate: DateTime.parse('2025-01-09'),
  //       deliveryDateTill: false,
  //   deliveryDateIsFixed: false,
  //   ldm: 7.2,
  //   weight: 3.0,
  //   price: 850.0,
  //   carTypeName: 'TAUTLINER_PLANA',
  //   status: OrderStatus.Pending,
  //   isConnected: false,
  //   connectedGroupID: null,
  //   createdAt: DateTime.now(),
  //   creatorID: 'admin001',
  //   creatorName: 'Admin',
  //   comments: [],
  //   orderLogs: [],
  // ),
  // OrderModel(
  //   orderID: 'ORDER028',
  //   orderName: 'Order 28',
  //   pickupPlace: PostalCode(
  //     countryCode: '',
  //     postalCode: '',
  //     name: 'DE-56357, Miehlen',
  //     latitude: 50.226, // Placeholder
  //     longitude: 7.832, // Placeholder
  //   ),
  //   pickupDate: DateTime.parse('2025-01-07'),
  //       pickupDateTill: false,
  //   pickupDateIsFixed: false,
  //   deliveryPlace: PostalCode(
  //     countryCode: '',
  //     postalCode: '',
  //     name: 'F-45700 Pannes',
  //     latitude: 48.019, // Placeholder
  //     longitude: 2.668, // Placeholder
  //   ),
  //   deliveryDate: DateTime.parse('2025-01-09'),
  //       deliveryDateTill: false,
  //   deliveryDateIsFixed: false,
  //   ldm: 6.0,
  //   weight: 11.0,
  //   price: 850.0,
  //   carTypeName: 'TAUTLINER_PLANA',
  //   status: OrderStatus.Pending,
  //   isConnected: false,
  //   connectedGroupID: null,
  //   createdAt: DateTime.now(),
  //   creatorID: 'admin001',
  //   creatorName: 'Admin',
  //   comments: [],
  //   orderLogs: [],
  // ),
  // OrderModel(
  //   orderID: 'ORDER029',
  //   orderName: 'Order 29',
  //   pickupPlace: PostalCode(
  //     countryCode: '',
  //     postalCode: '',
  //     name: 'DEU - 94469 DEGGENDORF',
  //     latitude: 48.841, // Placeholder
  //     longitude: 12.961, // Placeholder
  //   ),
  //   pickupDate: DateTime.parse('2025-01-08'),
  //       pickupDateTill: true,
  //   pickupDateIsFixed: false,
  //   deliveryPlace: PostalCode(
  //     countryCode: '',
  //     postalCode: '',
  //     name: 'ITA - 00034 COLLEFERRO',
  //     latitude: 41.727, // Placeholder
  //     longitude: 13.005, // Placeholder
  //   ),
  //   deliveryDate: DateTime.parse('2025-01-13'),
  //       deliveryDateTill: true,
  //   deliveryDateIsFixed: false,
  //   ldm: 6.0,
  //   weight: 1.5,
  //   price: 1200.0,
  //   carTypeName: 'TAUTLINER_PLANA',
  //   status: OrderStatus.Pending,
  //   isConnected: false,
  //   connectedGroupID: null,
  //   createdAt: DateTime.now(),
  //   creatorID: 'admin001',
  //   creatorName: 'Admin',
  //   comments: [],
  //   orderLogs: [],
  // ),
  // OrderModel(
  //   orderID: 'ORDER030',
  //   orderName: 'Order 30',
  //   pickupPlace: PostalCode(
  //     countryCode: '',
  //     postalCode: '',
  //     name: 'DE-86368 Gersthofen',
  //     latitude: 48.424, // Placeholder
  //     longitude: 10.873, // Placeholder
  //   ),
  //   pickupDate: DateTime.parse('2025-01-07'),
  //       pickupDateTill: true,
  //   pickupDateIsFixed: false,
  //   deliveryPlace: PostalCode(
  //     countryCode: '',
  //     postalCode: '',
  //     name: 'IT 03012 ANAGNI',
  //     latitude: 41.744, // Placeholder
  //     longitude: 13.155, // Placeholder
  //   ),
  //   deliveryDate: DateTime.parse('2025-01-13'),
  //       deliveryDateTill: true,
  //   deliveryDateIsFixed: false,
  //   ldm: 1.0,
  //   weight: 1.0,
  //   price: 1000.0,
  //   carTypeName: 'TAUTLINER_PLANA',
  //   status: OrderStatus.Pending,
  //   isConnected: false,
  //   connectedGroupID: null,
  //   createdAt: DateTime.now(),
  //   creatorID: 'admin001',
  //   creatorName: 'Admin',
  //   comments: [],
  //   orderLogs: [],
  // ),
  // OrderModel(
  //   orderID: 'ORDER031',
  //   orderName: 'Order 31',
  //   pickupPlace: PostalCode(
  //     countryCode: '',
  //     postalCode: '',
  //     name: 'BE 4042 Liers – Milmort',
  //     latitude: 50.694, // Placeholder
  //     longitude: 5.565, // Placeholder
  //   ),
  //   pickupDate: DateTime.parse('2025-01-08'),
  //       pickupDateTill: false,
  //   pickupDateIsFixed: false,
  //   deliveryPlace: PostalCode(
  //     countryCode: '',
  //     postalCode: '',
  //     name: 'IT 41015 Nonantola ',
  //     latitude: 44.678, // Placeholder
  //     longitude: 11.038, // Placeholder
  //   ),
  //   deliveryDate: DateTime.parse('2025-01-10'),
  //       deliveryDateTill: false,
  //   deliveryDateIsFixed: false,
  //   ldm: 6.0,
  //   weight: 5.9,
  //   price: 1400.0,
  //   carTypeName: 'TAUTLINER_PLANA',
  //   status: OrderStatus.Pending,
  //   isConnected: false,
  //   connectedGroupID: null,
  //   createdAt: DateTime.now(),
  //   creatorID: 'admin001',
  //   creatorName: 'Admin',
  //   comments: [],
  //   orderLogs: [],
  // ),
  // OrderModel(
  //   orderID: 'ORDER032',
  //   orderName: 'Order 32',
  //   pickupPlace: PostalCode(
  //     countryCode: '',
  //     postalCode: '',
  //     name: 'DE 54518 Sehlem',
  //     latitude: 49.9, // Placeholder
  //     longitude: 6.833, // Placeholder
  //   ),
  //   pickupDate: DateTime.parse('2025-01-08'),
  //       pickupDateTill: true,
  //   pickupDateIsFixed: false,
  //   deliveryPlace: PostalCode(
  //     countryCode: '',
  //     postalCode: '',
  //     name: 'IT 36015 Schio',
  //     latitude: 45.713, // Placeholder
  //     longitude: 11.357, // Placeholder
  //   ),
  //   deliveryDate: DateTime.parse('2025-01-10'),
  //       deliveryDateTill: true,
  //   deliveryDateIsFixed: false,
  //   ldm: 4.5,
  //   weight: 1.3,
  //   price: 880.0,
  //   carTypeName: 'TAUTLINER_PLANA',
  //   status: OrderStatus.Pending,
  //   isConnected: false,
  //   connectedGroupID: null,
  //   createdAt: DateTime.now(),
  //   creatorID: 'admin001',
  //   creatorName: 'Admin',
  //   comments: [],
  //   orderLogs: [],
  // ),
  // OrderModel(
  //   orderID: 'ORDER033',
  //   orderName: 'Order 33',
  //   pickupPlace: PostalCode(
  //     countryCode: '',
  //     postalCode: '',
  //     name: 'De-59302 Oelde',
  //     latitude: 51.829, // Placeholder
  //     longitude: 8.147, // Placeholder
  //   ),
  //   pickupDate: DateTime.parse('2025-01-10'),
  //       pickupDateTill: false,
  //   pickupDateIsFixed: false,
  //   deliveryPlace: PostalCode(
  //     countryCode: '',
  //     postalCode: '',
  //     name: 'IT-71100 Foggia / by side bokom',
  //     latitude: 41.458, // Placeholder
  //     longitude: 15.552, // Placeholder
  //   ),
  //   deliveryDate: DateTime.parse('2025-01-10'),
  //       deliveryDateTill: false,
  //   deliveryDateIsFixed: false,
  //   ldm: 4.8,
  //   weight: 3.0,
  //   price: 2200.0,
  //   carTypeName: 'TAUTLINER_PLANA',
  //   status: OrderStatus.Pending,
  //   isConnected: false,
  //   connectedGroupID: null,
  //   createdAt: DateTime.now(),
  //   creatorID: 'admin001',
  //   creatorName: 'Admin',
  //   comments: [],
  //   orderLogs: [],
  // ),
  // OrderModel(
  //   orderID: 'ORDER034',
  //   orderName: 'Order 34',
  //   pickupPlace: PostalCode(
  //     countryCode: '',
  //     postalCode: '',
  //     name: 'De-06258 Schkopau',
  //     latitude: 51.4, // Placeholder
  //     longitude: 12.046, // Placeholder
  //   ),
  //   pickupDate: DateTime.parse('2025-01-10'),
  //       pickupDateTill: false,
  //   pickupDateIsFixed: false,
  //   deliveryPlace: PostalCode(
  //     countryCode: '',
  //     postalCode: '',
  //     name: 'IT-00071 Pomezia',
  //     latitude: 41.669, // Placeholder
  //     longitude: 12.501, // Placeholder
  //   ),
  //   deliveryDate: DateTime.parse('2025-01-10'),
  //       deliveryDateTill: false,
  //   deliveryDateIsFixed: false,
  //   ldm: 6.0,
  //   weight: 9.0,
  //   price: 2300.0,
  //   carTypeName: 'TAUTLINER_PLANA',
  //   status: OrderStatus.Pending,
  //   isConnected: false,
  //   connectedGroupID: null,
  //   createdAt: DateTime.now(),
  //   creatorID: 'admin001',
  //   creatorName: 'Admin',
  //   comments: [],
  //   orderLogs: [],
  // ),
  // OrderModel(
  //   orderID: 'ORDER035',
  //   orderName: 'Order 35',
  //   pickupPlace: PostalCode(
  //     countryCode: '',
  //     postalCode: '',
  //     name: 'DE 27318 Hoya',
  //     latitude: 52.833, // Placeholder
  //     longitude: 9.083, // Placeholder
  //   ),
  //   pickupDate: DateTime.parse('2025-01-06'),
  //       pickupDateTill: false,
  //   pickupDateIsFixed: false,
  //   deliveryPlace: PostalCode(
  //     countryCode: '',
  //     postalCode: '',
  //     name: 'IT 53018 Sovicille',
  //     latitude: 43.28, // Placeholder
  //     longitude: 11.228, // Placeholder
  //   ),
  //   deliveryDate: DateTime.parse('2025-01-08'),
  //       deliveryDateTill: false,
  //   deliveryDateIsFixed: false,
  //   ldm: 2.0,
  //   weight: 3.5,
  //   price: 1200.0,
  //   carTypeName: 'TAUTLINER_PLANA',
  //   status: OrderStatus.Pending,
  //   isConnected: false,
  //   connectedGroupID: null,
  //   createdAt: DateTime.now(),
  //   creatorID: 'admin001',
  //   creatorName: 'Admin',
  //   comments: [],
  //   orderLogs: [],
  // ),
  // OrderModel(
  //   orderID: 'ORDER036',
  //   orderName: 'Order 36',
  //   pickupPlace: PostalCode(
  //     countryCode: '',
  //     postalCode: '',
  //     name: 'DE-33334 GÜTERSLOH',
  //     latitude: 51.944, // Placeholder
  //     longitude: 8.428, // Placeholder
  //   ),
  //   pickupDate: DateTime.parse('2025-01-10'),
  //       pickupDateTill: false,
  //   pickupDateIsFixed: false,
  //   deliveryPlace: PostalCode(
  //     countryCode: '',
  //     postalCode: '',
  //     name: 'IT-53036 POGGIBONSI',
  //     latitude: 43.471, // Placeholder
  //     longitude: 11.148, // Placeholder
  //   ),
  //   deliveryDate: DateTime.parse('2025-01-08'),
  //       deliveryDateTill: false,
  //   deliveryDateIsFixed: false,
  //   ldm: 9.6,
  //   weight: 1.6,
  //   price: 1450.0,
  //   carTypeName: 'TAUTLINER_PLANA',
  //   status: OrderStatus.Pending,
  //   isConnected: false,
  //   connectedGroupID: null,
  //   createdAt: DateTime.now(),
  //   creatorID: 'admin001',
  //   creatorName: 'Admin',
  //   comments: [],
  //   orderLogs: [],
  // ),
  // OrderModel(
  //   orderID: 'ORDER037',
  //   orderName: 'Order 37',
  //   pickupPlace: PostalCode(
  //     countryCode: '',
  //     postalCode: '',
  //     name: 'FR , 81200 MAZAMET',
  //     latitude: 43.493, // Placeholder
  //     longitude: 2.374, // Placeholder
  //   ),
  //   pickupDate: DateTime.parse('2024-12-30'),
  //       pickupDateTill: false,
  //   pickupDateIsFixed: false,
  //   deliveryPlace: PostalCode(
  //     countryCode: '',
  //     postalCode: '',
  //     name: 'DE, 24641 SIEVERSHUTTEN',
  //     latitude: 53.842, // Placeholder
  //     longitude: 10.112, // Placeholder
  //   ),
  //   deliveryDate: DateTime.parse('2024-01-02'),
  //       deliveryDateTill: false,
  //   deliveryDateIsFixed: false,
  //   ldm: 2.0,
  //   weight: 1.0,
  //   price: 850.0,
  //   carTypeName: 'TAUTLINER_PLANA',
  //   status: OrderStatus.Pending,
  //   isConnected: false,
  //   connectedGroupID: null,
  //   createdAt: DateTime.now(),
  //   creatorID: 'admin001',
  //   creatorName: 'Admin',
  //   comments: [],
  //   orderLogs: [],
  // ),
  // OrderModel(
  //   orderID: 'ORDER038',
  //   orderName: 'Order 38',
  //   pickupPlace: PostalCode(
  //     countryCode: '',
  //     postalCode: '',
  //     name: 'FR 81300 GRAULHET',
  //     latitude: 43.767, // Placeholder
  //     longitude: 1.989, // Placeholder
  //   ),
  //   pickupDate: DateTime.parse('2024-12-30'),
  //       pickupDateTill: false,
  //   pickupDateIsFixed: false,
  //   deliveryPlace: PostalCode(
  //     countryCode: '',
  //     postalCode: '',
  //     name: 'DE 49594 Alfhausen',
  //     latitude: 52.5, // Placeholder
  //     longitude: 7.95, // Placeholder
  //   ),
  //   deliveryDate: DateTime.parse('2024-01-02'),
  //       deliveryDateTill: false,
  //   deliveryDateIsFixed: false,
  //   ldm: 4.4,
  //   weight: 6.77,
  //   price: 840.0,
  //   carTypeName: 'TAUTLINER_PLANA',
  //   status: OrderStatus.Pending,
  //   isConnected: false,
  //   connectedGroupID: null,
  //   createdAt: DateTime.now(),
  //   creatorID: 'admin001',
  //   creatorName: 'Admin',
  //   comments: [],
  //   orderLogs: [],
  // ),
  // OrderModel(
  //   orderID: 'ORDER039',
  //   orderName: 'Order 39',
  //   pickupPlace: PostalCode(
  //     countryCode: '',
  //     postalCode: '',
  //     name: 'FR 47440 CASSENEUIL',
  //     latitude: 44.443, // Placeholder
  //     longitude: 0.621, // Placeholder
  //   ),
  //   pickupDate: DateTime.parse('2025-01-02'),
  //       pickupDateTill: false,
  //   pickupDateIsFixed: false,
  //   deliveryPlace: PostalCode(
  //     countryCode: '',
  //     postalCode: '',
  //     name: 'AT 4600 Wels',
  //     latitude: 48.167, // Placeholder
  //     longitude: 14.033, // Placeholder
  //   ),
  //   deliveryDate: DateTime.parse('2025-01-07'),
  //       deliveryDateTill: false,
  //   deliveryDateIsFixed: false,
  //   ldm: 7.6,
  //   weight: 5.5,
  //   price: 1120.0,
  //   carTypeName: 'TAUTLINER_PLANA',
  //   status: OrderStatus.Pending,
  //   isConnected: false,
  //   connectedGroupID: null,
  //   createdAt: DateTime.now(),
  //   creatorID: 'admin001',
  //   creatorName: 'Admin',
  //   comments: [],
  //   orderLogs: [],
  // ),
  // OrderModel(
  //   orderID: 'ORDER040',
  //   orderName: 'Order 40',
  //   pickupPlace: PostalCode(
  //     countryCode: '',
  //     postalCode: '',
  //     name: 'F- 06131 GRASSE',
  //     latitude: 43.658, // Placeholder
  //     longitude: 6.925, // Placeholder
  //   ),
  //   pickupDate: DateTime.parse('2025-01-06'),
  //       pickupDateTill: false,
  //   pickupDateIsFixed: false,
  //   deliveryPlace: PostalCode(
  //     countryCode: '',
  //     postalCode: '',
  //     name: 'B- 3001 HEVERLEE',
  //     latitude: 50.864, // Placeholder
  //     longitude: 4.696, // Placeholder
  //   ),
  //   deliveryDate: DateTime.parse('2025-01-08'),
  //       deliveryDateTill: false,
  //   deliveryDateIsFixed: false,
  //   ldm: 7.6,
  //   weight: 7.0,
  //   price: 900.0,
  //   carTypeName: 'TAUTLINER_PLANA',
  //   status: OrderStatus.Pending,
  //   isConnected: false,
  //   connectedGroupID: null,
  //   createdAt: DateTime.now(),
  //   creatorID: 'admin001',
  //   creatorName: 'Admin',
  //   comments: [],
  //   orderLogs: [],
  // ),
  // OrderModel(
  //   orderID: 'ORDER041',
  //   orderName: 'Order 41',
  //   pickupPlace: PostalCode(
  //     countryCode: '',
  //     postalCode: '',
  //     name: 'F- 13790 Rousset',
  //     latitude: 43.483, // Placeholder
  //     longitude: 5.62, // Placeholder
  //   ),
  //   pickupDate: DateTime.parse('2025-01-06'),
  //       pickupDateTill: false,
  //   pickupDateIsFixed: false,
  //   deliveryPlace: PostalCode(
  //     countryCode: '',
  //     postalCode: '',
  //     name: 'Be-7190 Marche lez ecaussinnes',
  //     latitude: 50.546, // Placeholder
  //     longitude: 4.182, // Placeholder
  //   ),
  //   deliveryDate: DateTime.parse('2025-01-08'),
  //       deliveryDateTill: false,
  //   deliveryDateIsFixed: false,
  //   ldm: 4.6,
  //   weight: 5.4,
  //   price: 390.0,
  //   carTypeName: 'TAUTLINER_PLANA',
  //   status: OrderStatus.Pending,
  //   isConnected: false,
  //   connectedGroupID: null,
  //   createdAt: DateTime.now(),
  //   creatorID: 'admin001',
  //   creatorName: 'Admin',
  //   comments: [],
  //   orderLogs: [],
  // ),
  // OrderModel(
  //   orderID: 'ORDER042',
  //   orderName: 'Order 42',
  //   pickupPlace: PostalCode(
  //     countryCode: '',
  //     postalCode: '',
  //     name: 'FR 85260 L Herbergement',
  //     latitude: 46.909, // Placeholder
  //     longitude: -1.376, // Placeholder
  //   ),
  //   pickupDate: DateTime.parse('2024-12-23'),
  //       pickupDateTill: false,
  //   pickupDateIsFixed: false,
  //   deliveryPlace: PostalCode(
  //     countryCode: '',
  //     postalCode: '',
  //     name: 'DE 50769 Köln',
  //     latitude: 51.046, // Placeholder
  //     longitude: 6.876, // Placeholder
  //   ),
  //   deliveryDate: DateTime.parse('2024-12-27'),
  //       deliveryDateTill: false,
  //   deliveryDateIsFixed: false,
  //   ldm: 6.0,
  //   weight: 5.0,
  //   price: 750.0,
  //   carTypeName: 'TAUTLINER_PLANA',
  //   status: OrderStatus.Pending,
  //   isConnected: false,
  //   connectedGroupID: null,
  //   createdAt: DateTime.now(),
  //   creatorID: 'admin001',
  //   creatorName: 'Admin',
  //   comments: [],
  //   orderLogs: [],
  // ),
  // OrderModel(
  //   orderID: 'ORDER043',
  //   orderName: 'Order 43',
  //   pickupPlace: PostalCode(
  //     countryCode: '',
  //     postalCode: '',
  //     name: 'FR 49160,Longue Jumelles ',
  //     latitude: 47.383, // Placeholder
  //     longitude: -0.117, // Placeholder
  //   ),
  //   pickupDate: DateTime.parse('2024-12-23'),
  //       pickupDateTill: false,
  //   pickupDateIsFixed: false,
  //   deliveryPlace: PostalCode(
  //     countryCode: '',
  //     postalCode: '',
  //     name: 'DE 4480,Hermalle Sous Huy ',
  //     latitude: 50.559, // Placeholder
  //     longitude: 5.364, // Placeholder
  //   ),
  //   deliveryDate: DateTime.parse('2025-01-10'),
  //       deliveryDateTill: false,
  //   deliveryDateIsFixed: false,
  //   ldm: 3.0,
  //   weight: 2.3,
  //   price: 260.0,
  //   carTypeName: 'TAUTLINER_PLANA',
  //   status: OrderStatus.Pending,
  //   isConnected: false,
  //   connectedGroupID: null,
  //   createdAt: DateTime.now(),
  //   creatorID: 'admin001',
  //   creatorName: 'Admin',
  //   comments: [],
  //   orderLogs: [],
  // ),
  // OrderModel(
  //   orderID: 'ORDER044',
  //   orderName: 'Order 44',
  //   pickupPlace: PostalCode(
  //     countryCode: '',
  //     postalCode: '',
  //     name: 'FR 76116 Martainville Épreville',
  //     latitude: 49.46, // Placeholder
  //     longitude: 1.293, // Placeholder
  //   ),
  //   pickupDate: DateTime.parse('2025-01-10'),
  //       pickupDateTill: false,
  //   pickupDateIsFixed: false,
  //   deliveryPlace: PostalCode(
  //     countryCode: '',
  //     postalCode: '',
  //     name: 'DE 64319 Pfungstadt',
  //     latitude: 49.806, // Placeholder
  //     longitude: 8.603, // Placeholder
  //   ),
  //   deliveryDate: DateTime.parse('2024-12-20'),
  //       deliveryDateTill: false,
  //   deliveryDateIsFixed: false,
  //   ldm: 8.5,
  //   weight: 3.3,
  //   price: 650.0,
  //   carTypeName: 'TAUTLINER_PLANA',
  //   status: OrderStatus.Pending,
  //   isConnected: false,
  //   connectedGroupID: null,
  //   createdAt: DateTime.now(),
  //   creatorID: 'admin001',
  //   creatorName: 'Admin',
  //   comments: [],
  //   orderLogs: [],
  // ),
  // OrderModel(
  //   orderID: 'ORDER045',
  //   orderName: 'Order 45',
  //   pickupPlace: PostalCode(
  //     countryCode: '',
  //     postalCode: '',
  //     name: 'FR 80210 Chepy ',
  //     latitude: 50.064, // Placeholder
  //     longitude: 1.647, // Placeholder
  //   ),
  //   pickupDate: DateTime.parse('2025-01-10'),
  //       pickupDateTill: false,
  //   pickupDateIsFixed: false,
  //   deliveryPlace: PostalCode(
  //     countryCode: '',
  //     postalCode: '',
  //     name: 'DE 60386 Frankfurt',
  //     latitude: 50.127, // Placeholder
  //     longitude: 8.755, // Placeholder
  //   ),
  //   deliveryDate: DateTime.parse('2025-01-10'),
  //       deliveryDateTill: false,
  //   deliveryDateIsFixed: false,
  //   ldm: 4.0,
  //   weight: 6.0,
  //   price: 900.0,
  //   carTypeName: 'TAUTLINER_PLANA',
  //   status: OrderStatus.Pending,
  //   isConnected: false,
  //   connectedGroupID: null,
  //   createdAt: DateTime.now(),
  //   creatorID: 'admin001',
  //   creatorName: 'Admin',
  //   comments: [],
  //   orderLogs: [],
  // ),
  // OrderModel(
  //   orderID: 'ORDER046',
  //   orderName: 'Order 46',
  //   pickupPlace: PostalCode(
  //     countryCode: '',
  //     postalCode: '',
  //     name: 'DE 52134 Herzogenrath',
  //     latitude: 50.869, // Placeholder
  //     longitude: 6.093, // Placeholder
  //   ),
  //   pickupDate: DateTime.parse('2025-01-10'),
  //       pickupDateTill: false,
  //   pickupDateIsFixed: false,
  //   deliveryPlace: PostalCode(
  //     countryCode: '',
  //     postalCode: '',
  //     name: 'FR 44840 LES SORINIERES',
  //     latitude: 47.147, // Placeholder
  //     longitude: -1.53, // Placeholder
  //   ),
  //   deliveryDate: DateTime.parse('2025-01-10'),
  //       deliveryDateTill: false,
  //   deliveryDateIsFixed: false,
  //   ldm: 2.84,
  //   weight: 1.3,
  //   price: 750.0,
  //   carTypeName: 'TAUTLINER_PLANA',
  //   status: OrderStatus.Pending,
  //   isConnected: false,
  //   connectedGroupID: null,
  //   createdAt: DateTime.now(),
  //   creatorID: 'admin001',
  //   creatorName: 'Admin',
  //   comments: [],
  //   orderLogs: [],
  // ),
  // OrderModel(
  //   orderID: 'ORDER047',
  //   orderName: 'Order 47',
  //   pickupPlace: PostalCode(
  //     countryCode: '',
  //     postalCode: '',
  //     name: 'BE 6590 Momignies',
  //     latitude: 50.027, // Placeholder
  //     longitude: 4.165, // Placeholder
  //   ),
  //   pickupDate: DateTime.parse('2025-01-07'),
  //       pickupDateTill: false,
  //   pickupDateIsFixed: false,
  //   deliveryPlace: PostalCode(
  //     countryCode: '',
  //     postalCode: '',
  //     name: 'FR 24190 Neuvic',
  //     latitude: 45.101, // Placeholder
  //     longitude: 0.469, // Placeholder
  //   ),
  //   deliveryDate: DateTime.parse('2025-01-10'),
  //       deliveryDateTill: false,
  //   deliveryDateIsFixed: false,
  //   ldm: 2.4,
  //   weight: 1.6,
  //   price: 750.0,
  //   carTypeName: 'TAUTLINER_PLANA',
  //   status: OrderStatus.Pending,
  //   isConnected: false,
  //   connectedGroupID: null,
  //   createdAt: DateTime.now(),
  //   creatorID: 'admin001',
  //   creatorName: 'Admin',
  //   comments: [],
  //   orderLogs: [],
  // ),
  // OrderModel(
  //   orderID: 'ORDER048',
  //   orderName: 'Order 48',
  //   pickupPlace: PostalCode(
  //     countryCode: '',
  //     postalCode: '',
  //     name: 'DE 41812 ERKELENZ',
  //     latitude: 51.079, // Placeholder
  //     longitude: 6.315, // Placeholder
  //   ),
  //   pickupDate: DateTime.parse('2025-01-10'),
  //       pickupDateTill: false,
  //   pickupDateIsFixed: false,
  //   deliveryPlace: PostalCode(
  //     countryCode: '',
  //     postalCode: '',
  //     name: 'FR 63800 COURNON-D AUVERGNE',
  //     latitude: 45.741, // Placeholder
  //     longitude: 3.196, // Placeholder
  //   ),
  //   deliveryDate: DateTime.parse('2024-01-10'),
  //       deliveryDateTill: false,
  //   deliveryDateIsFixed: false,
  //   ldm: 4.0,
  //   weight: 7.2,
  //   price: 950.0,
  //   carTypeName: 'TAUTLINER_PLANA',
  //   status: OrderStatus.Pending,
  //   isConnected: false,
  //   connectedGroupID: null,
  //   createdAt: DateTime.now(),
  //   creatorID: 'admin001',
  //   creatorName: 'Admin',
  //   comments: [],
  //   orderLogs: [],
  // ),
  // OrderModel(
  //   orderID: 'ORDER049',
  //   orderName: 'Order 49',
  //   pickupPlace: PostalCode(
  //     countryCode: '',
  //     postalCode: '',
  //     name: 'BE 6590 Momignies',
  //     latitude: 50.027, // Placeholder
  //     longitude: 4.165, // Placeholder
  //   ),
  //   pickupDate: DateTime.parse('2025-01-07'),
  //       pickupDateTill: false,
  //   pickupDateIsFixed: false,
  //   deliveryPlace: PostalCode(
  //     countryCode: '',
  //     postalCode: '',
  //     name: 'FR 35500 Vitre Cedex',
  //     latitude: 48.123, // Placeholder
  //     longitude: -1.21, // Placeholder
  //   ),
  //   deliveryDate: DateTime.parse('2025-01-10'),
  //       deliveryDateTill: false,
  //   deliveryDateIsFixed: false,
  //   ldm: 2.0,
  //   weight: 1.7,
  //   price: 750.0,
  //   carTypeName: 'TAUTLINER_PLANA',
  //   status: OrderStatus.Pending,
  //   isConnected: false,
  //   connectedGroupID: null,
  //   createdAt: DateTime.now(),
  //   creatorID: 'admin001',
  //   creatorName: 'Admin',
  //   comments: [],
  //   orderLogs: [],
  // ),
  // OrderModel(
  //   orderID: 'ORDER050',
  //   orderName: 'Order 50',
  //   pickupPlace: PostalCode(
  //     countryCode: '',
  //     postalCode: '',
  //     name: 'DE, 57319 Bad Berleburg',
  //     latitude: 51.052, // Placeholder
  //     longitude: 8.392, // Placeholder
  //   ),
  //   pickupDate: DateTime.parse('2025-01-10'),
  //       pickupDateTill: false,
  //   pickupDateIsFixed: false,
  //   deliveryPlace: PostalCode(
  //     countryCode: '',
  //     postalCode: '',
  //     name: 'FR, 64121 Serres-Castet',
  //     latitude: 43.386, // Placeholder
  //     longitude: -0.355, // Placeholder
  //   ),
  //   deliveryDate: DateTime.parse('2025-01-10'),
  //       deliveryDateTill: false,
  //   deliveryDateIsFixed: false,
  //   ldm: 5.5,
  //   weight: 8.0,
  //   price: 2000.0,
  //   carTypeName: 'TAUTLINER_PLANA',
  //   status: OrderStatus.Pending,
  //   isConnected: false,
  //   connectedGroupID: null,
  //   createdAt: DateTime.now(),
  //   creatorID: 'admin001',
  //   creatorName: 'Admin',
  //   comments: [],
  //   orderLogs: [],
  // ),
  // OrderModel(
  //   orderID: 'ORDER051',
  //   orderName: 'Order 51',
  //   pickupPlace: PostalCode(
  //     countryCode: '',
  //     postalCode: '',
  //     name: 'At-3533 Oberwaltenreith',
  //     latitude: 48.567, // Placeholder
  //     longitude: 15.25, // Placeholder
  //   ),
  //   pickupDate: DateTime.parse('2025-01-10'),
  //       pickupDateTill: false,
  //   pickupDateIsFixed: false,
  //   deliveryPlace: PostalCode(
  //     countryCode: '',
  //     postalCode: '',
  //     name: 'Fr-01190 Chavannes sur reyssouze',
  //     latitude: 46.431, // Placeholder
  //     longitude: 4.997, // Placeholder
  //   ),
  //   deliveryDate: DateTime.parse('2025-01-10'),
  //       deliveryDateTill: false,
  //   deliveryDateIsFixed: false,
  //   ldm: 7.2,
  //   weight: 12.0,
  //   price: 1500.0,
  //   carTypeName: 'TAUTLINER_PLANA',
  //   status: OrderStatus.Pending,
  //   isConnected: false,
  //   connectedGroupID: null,
  //   createdAt: DateTime.now(),
  //   creatorID: 'admin001',
  //   creatorName: 'Admin',
  //   comments: [],
  //   orderLogs: [],
  // ),
  // OrderModel(
  //   orderID: 'ORDER052',
  //   orderName: 'Order 52',
  //   pickupPlace: PostalCode(
  //     countryCode: '',
  //     postalCode: '',
  //     name: 'DE 78549 Spaichingen',
  //     latitude: 48.075, // Placeholder
  //     longitude: 8.735, // Placeholder
  //   ),
  //   pickupDate: DateTime.parse('2025-01-10'),
  //       pickupDateTill: false,
  //   pickupDateIsFixed: false,
  //   deliveryPlace: PostalCode(
  //     countryCode: '',
  //     postalCode: '',
  //     name: 'FR 29860 Le Drennec',
  //     latitude: 48.534, // Placeholder
  //     longitude: -4.372, // Placeholder
  //   ),
  //   deliveryDate: DateTime.parse('2025-01-09'),
  //       deliveryDateTill: false,
  //   deliveryDateIsFixed: false,
  //   ldm: 8.4,
  //   weight: 10.2,
  //   price: 1700.0,
  //   carTypeName: 'TAUTLINER_PLANA',
  //   status: OrderStatus.Pending,
  //   isConnected: false,
  //   connectedGroupID: null,
  //   createdAt: DateTime.now(),
  //   creatorID: 'admin001',
  //   creatorName: 'Admin',
  //   comments: [],
  //   orderLogs: [],
  // ),
  // OrderModel(
  //   orderID: 'ORDER053',
  //   orderName: 'Order 53',
  //   pickupPlace: PostalCode(
  //     countryCode: '',
  //     postalCode: '',
  //     name: 'NL 5047 RM Tilburg',
  //     latitude: 51.605, // Placeholder
  //     longitude: 4.989, // Placeholder
  //   ),
  //   pickupDate: DateTime.parse('2025-01-06'),
  //       pickupDateTill: false,
  //   pickupDateIsFixed: false,
  //   deliveryPlace: PostalCode(
  //     countryCode: '',
  //     postalCode: '',
  //     name: 'FR 13560 Senas',
  //     latitude: 43.744, // Placeholder
  //     longitude: 5.078, // Placeholder
  //   ),
  //   deliveryDate: DateTime.parse('2025-01-08'),
  //       deliveryDateTill: false,
  //   deliveryDateIsFixed: false,
  //   ldm: 4.5,
  //   weight: 3.0,
  //   price: 1100.0,
  //   carTypeName: 'TAUTLINER_PLANA',
  //   status: OrderStatus.Pending,
  //   isConnected: false,
  //   connectedGroupID: null,
  //   createdAt: DateTime.now(),
  //   creatorID: 'admin001',
  //   creatorName: 'Admin',
  //   comments: [],
  //   orderLogs: [],
  // ),
  // OrderModel(
  //   orderID: 'ORDER054',
  //   orderName: 'Order 54',
  //   pickupPlace: PostalCode(
  //     countryCode: '',
  //     postalCode: '',
  //     name: 'DE- 74613 Öhringen',
  //     latitude: 49.199, // Placeholder
  //     longitude: 9.507, // Placeholder
  //   ),
  //   pickupDate: DateTime.parse('2025-01-10'),
  //       pickupDateTill: false,
  //   pickupDateIsFixed: false,
  //   deliveryPlace: PostalCode(
  //     countryCode: '',
  //     postalCode: '',
  //     name: 'FR - 31450 Baziège',
  //     latitude: 43.455, // Placeholder
  //     longitude: 1.614, // Placeholder
  //   ),
  //   deliveryDate: DateTime.parse('2025-01-10'),
  //       deliveryDateTill: false,
  //   deliveryDateIsFixed: false,
  //   ldm: 5.0,
  //   weight: 3.0,
  //   price: 1250.0,
  //   carTypeName: 'TAUTLINER_PLANA',
  //   status: OrderStatus.Pending,
  //   isConnected: false,
  //   connectedGroupID: null,
  //   createdAt: DateTime.now(),
  //   creatorID: 'admin001',
  //   creatorName: 'Admin',
  //   comments: [],
  //   orderLogs: [],
  // ),
  // OrderModel(
  //   orderID: 'ORDER055',
  //   orderName: 'Order 55',
  //   pickupPlace: PostalCode(
  //     countryCode: '',
  //     postalCode: '',
  //     name: 'Be-9130 Kallo',
  //     latitude: 51.252, // Placeholder
  //     longitude: 4.275, // Placeholder
  //   ),
  //   pickupDate: DateTime.parse('2025-01-10'),
  //       pickupDateTill: false,
  //   pickupDateIsFixed: false,
  //   deliveryPlace: PostalCode(
  //     countryCode: '',
  //     postalCode: '',
  //     name: 'Fr-74800 La roche sur foron',
  //     latitude: 46.071, // Placeholder
  //     longitude: 6.305, // Placeholder
  //   ),
  //   deliveryDate: DateTime.parse('2025-01-10'),
  //       deliveryDateTill: false,
  //   deliveryDateIsFixed: false,
  //   ldm: 7.2,
  //   weight: 9.6,
  //   price: 1500.0,
  //   carTypeName: 'TAUTLINER_PLANA',
  //   status: OrderStatus.Pending,
  //   isConnected: false,
  //   connectedGroupID: null,
  //   createdAt: DateTime.now(),
  //   creatorID: 'admin001',
  //   creatorName: 'Admin',
  //   comments: [],
  //   orderLogs: [],
  // ),
  // OrderModel(
  //   orderID: 'ORDER056',
  //   orderName: 'Order 56',
  //   pickupPlace: PostalCode(
  //     countryCode: '',
  //     postalCode: '',
  //     name: 'DE-57462 OLPE',
  //     latitude: 51.029, // Placeholder
  //     longitude: 7.851, // Placeholder
  //   ),
  //   pickupDate: DateTime.parse('2025-01-08'),
  //       pickupDateTill: false,
  //   pickupDateIsFixed: false,
  //   deliveryPlace: PostalCode(
  //     countryCode: '',
  //     postalCode: '',
  //     name: 'FR-26130 SAINT PAUL TROIS CHATEAUX',
  //     latitude: 44.346, // Placeholder
  //     longitude: 4.764, // Placeholder
  //   ),
  //   deliveryDate: DateTime.parse('2025-01-10'),
  //       deliveryDateTill: false,
  //   deliveryDateIsFixed: false,
  //   ldm: 10.0,
  //   weight: 5.0,
  //   price: 1560.0,
  //   carTypeName: 'TAUTLINER_PLANA',
  //   status: OrderStatus.Pending,
  //   isConnected: false,
  //   connectedGroupID: null,
  //   createdAt: DateTime.now(),
  //   creatorID: 'admin001',
  //   creatorName: 'Admin',
  //   comments: [],
  //   orderLogs: [],
  // ),
  // OrderModel(
  //   orderID: 'ORDER057',
  //   orderName: 'Order 57',
  //   pickupPlace: PostalCode(
  //     countryCode: '',
  //     postalCode: '',
  //     name: 'At-2460 Bruck an der leithe',
  //     latitude: 48.017, // Placeholder
  //     longitude: 16.767, // Placeholder
  //   ),
  //   pickupDate: DateTime.parse('2025-01-10'),
  //       pickupDateTill: false,
  //   pickupDateIsFixed: false,
  //   deliveryPlace: PostalCode(
  //     countryCode: '',
  //     postalCode: '',
  //     name: 'Fr-11150 Bram',
  //     latitude: 43.244, // Placeholder
  //     longitude: 2.113, // Placeholder
  //   ),
  //   deliveryDate: DateTime.parse('2025-01-10'),
  //       deliveryDateTill: false,
  //   deliveryDateIsFixed: false,
  //   ldm: 9.5,
  //   weight: 16.0,
  //   price: 2400.0,
  //   carTypeName: 'TAUTLINER_PLANA',
  //   status: OrderStatus.Pending,
  //   isConnected: false,
  //   connectedGroupID: null,
  //   createdAt: DateTime.now(),
  //   creatorID: 'admin001',
  //   creatorName: 'Admin',
  //   comments: [],
  //   orderLogs: [],
  // ),
  // OrderModel(
  //   orderID: 'ORDER059',
  //   orderName: 'Order 59',
  //   pickupPlace: PostalCode(
  //     countryCode: '',
  //     postalCode: '',
  //     name: 'DE 97204 Höchberg',
  //     latitude: 49.784, // Placeholder
  //     longitude: 9.882, // Placeholder
  //   ),
  //   pickupDate: DateTime.parse('2025-01-10'),
  //       pickupDateTill: false,
  //   pickupDateIsFixed: false,
  //   deliveryPlace: PostalCode(
  //     countryCode: '',
  //     postalCode: '',
  //     name: 'FR 10000 Troyes',
  //     latitude: 48.301, // Placeholder
  //     longitude: 4.085, // Placeholder
  //   ),
  //   deliveryDate: DateTime.parse('2025-01-10'),
  //       deliveryDateTill: false,
  //   deliveryDateIsFixed: false,
  //   ldm: 4.0,
  //   weight: 4.0,
  //   price: 600.0,
  //   carTypeName: 'TAUTLINER_PLANA',
  //   status: OrderStatus.Pending,
  //   isConnected: false,
  //   connectedGroupID: null,
  //   createdAt: DateTime.now(),
  //   creatorID: 'admin001',
  //   creatorName: 'Admin',
  //   comments: [],
  //   orderLogs: [],
  // ),
  // OrderModel(
  //   orderID: 'ORDER060',
  //   orderName: 'Order 60',
  //   pickupPlace: PostalCode(
  //     countryCode: '',
  //     postalCode: '',
  //     name: 'DE 89584 Ehingen',
  //     latitude: 48.286, // Placeholder
  //     longitude: 9.688, // Placeholder
  //   ),
  //   pickupDate: DateTime.parse('2025-01-10'),
  //       pickupDateTill: false,
  //   pickupDateIsFixed: false,
  //   deliveryPlace: PostalCode(
  //     countryCode: '',
  //     postalCode: '',
  //     name: 'FR 91120 Palaiseau',
  //     latitude: 48.718, // Placeholder
  //     longitude: 2.25, // Placeholder
  //   ),
  //   deliveryDate: DateTime.parse('2025-01-10'),
  //       deliveryDateTill: false,
  //   deliveryDateIsFixed: false,
  //   ldm: 9.0,
  //   weight: 12.5,
  //   price: 1150.0,
  //   carTypeName: 'TAUTLINER_PLANA',
  //   status: OrderStatus.Pending,
  //   isConnected: false,
  //   connectedGroupID: null,
  //   createdAt: DateTime.now(),
  //   creatorID: 'admin001',
  //   creatorName: 'Admin',
  //   comments: [],
  //   orderLogs: [],
  // ),
  // OrderModel(
  //   orderID: 'ORDER061',
  //   orderName: 'Order 61',
  //   pickupPlace: PostalCode(
  //     countryCode: '',
  //     postalCode: '',
  //     name: 'DE 65479 Raunheim',
  //     latitude: 50.013, // Placeholder
  //     longitude: 8.453, // Placeholder
  //   ),
  //   pickupDate: DateTime.parse('2024-01-08'),
  //       pickupDateTill: false,
  //   pickupDateIsFixed: false,
  //   deliveryPlace: PostalCode(
  //     countryCode: '',
  //     postalCode: '',
  //     name: 'FR 76260 Longroy',
  //     latitude: 49.989, // Placeholder
  //     longitude: 1.54, // Placeholder
  //   ),
  //   deliveryDate: DateTime.parse('2025-01-10'),
  //       deliveryDateTill: false,
  //   deliveryDateIsFixed: false,
  //   ldm: 9.0,
  //   weight: 18.5,
  //   price: 1200.0,
  //   carTypeName: 'TAUTLINER_PLANA',
  //   status: OrderStatus.Pending,
  //   isConnected: false,
  //   connectedGroupID: null,
  //   createdAt: DateTime.now(),
  //   creatorID: 'admin001',
  //   creatorName: 'Admin',
  //   comments: [],
  //   orderLogs: [],
  // ),
  // OrderModel(
  //   orderID: 'ORDER062',
  //   orderName: 'Order 62',
  //   pickupPlace: PostalCode(
  //     countryCode: '',
  //     postalCode: '',
  //     name: 'DE 67547 Worms',
  //     latitude: 49.633, // Placeholder
  //     longitude: 8.362, // Placeholder
  //   ),
  //   pickupDate: DateTime.parse('2024-01-08'),
  //       pickupDateTill: false,
  //   pickupDateIsFixed: false,
  //   deliveryPlace: PostalCode(
  //     countryCode: '',
  //     postalCode: '',
  //     name: 'FR 89470',
  //     latitude: 47.849, // Placeholder
  //     longitude: 3.582, // Placeholder
  //   ),
  //   deliveryDate: DateTime.parse('2025-01-10'),
  //       deliveryDateTill: false,
  //   deliveryDateIsFixed: false,
  //   ldm: 3.0,
  //   weight: 3.0,
  //   price: 500.0,
  //   carTypeName: 'TAUTLINER_PLANA',
  //   status: OrderStatus.Pending,
  //   isConnected: false,
  //   connectedGroupID: null,
  //   createdAt: DateTime.now(),
  //   creatorID: 'admin001',
  //   creatorName: 'Admin',
  //   comments: [],
  //   orderLogs: [],
  // ),
  // OrderModel(
  //   orderID: 'ORDER063',
  //   orderName: 'Order 63',
  //   pickupPlace: PostalCode(
  //     countryCode: '',
  //     postalCode: '',
  //     name: 'BE1800 VILVOORDE',
  //     latitude: 50.928, // Placeholder
  //     longitude: 4.429, // Placeholder
  //   ),
  //   pickupDate: DateTime.parse('2025-01-10'),
  //       pickupDateTill: false,
  //   pickupDateIsFixed: false,
  //   deliveryPlace: PostalCode(
  //     countryCode: '',
  //     postalCode: '',
  //     name: 'FR53410 LA GRAVELLE',
  //     latitude: 48.073, // Placeholder
  //     longitude: -1.016, // Placeholder
  //   ),
  //   deliveryDate: DateTime.parse('2025-01-10'),
  //       deliveryDateTill: false,
  //   deliveryDateIsFixed: false,
  //   ldm: 5.3,
  //   weight: 9.0,
  //   price: 835,
  //   carTypeName: 'TAUTLINER_PLANA',
  //   status: OrderStatus.Pending,
  //   isConnected: false,
  //   connectedGroupID: null,
  //   createdAt: DateTime.now(),
  //   creatorID: 'admin001',
  //   creatorName: 'Admin',
  //   comments: [],
  //   orderLogs: [],
  // ),
  // OrderModel(
  //   orderID: 'ORDER064',
  //   orderName: 'Order 64',
  //   pickupPlace: PostalCode(
  //     countryCode: '',
  //     postalCode: '',
  //     name: 'DE 71032 BOEBLINGEN',
  //     latitude: 48.682, // Placeholder
  //     longitude: 9.012, // Placeholder
  //   ),
  //   pickupDate: DateTime.parse('2025-01-10'),
  //       pickupDateTill: false,
  //   pickupDateIsFixed: false,
  //   deliveryPlace: PostalCode(
  //     countryCode: '',
  //     postalCode: '',
  //     name: 'FR76380 CANTELEU',
  //     latitude: 49.441, // Placeholder
  //     longitude: 1.025, // Placeholder
  //   ),
  //   deliveryDate: DateTime.parse('2025-01-10'),
  //       deliveryDateTill: false,
  //   deliveryDateIsFixed: false,
  //   ldm: 5.0,
  //   weight: 10.0,
  //   price: 850,
  //   carTypeName: 'TAUTLINER_PLANA',
  //   status: OrderStatus.Pending,
  //   isConnected: false,
  //   connectedGroupID: null,
  //   createdAt: DateTime.now(),
  //   creatorID: 'admin001',
  //   creatorName: 'Admin',
  //   comments: [],
  //   orderLogs: [],
  // ),
];
