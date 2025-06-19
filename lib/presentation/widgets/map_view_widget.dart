import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_cancellable_tile_provider/flutter_map_cancellable_tile_provider.dart';
import 'package:ai_logistics_management_order_automation/config/app_colors.dart';
import 'package:ai_logistics_management_order_automation/config/app_text_styles.dart';
import 'package:ai_logistics_management_order_automation/domain/models/order_model.dart';
import 'package:ai_logistics_management_order_automation/domain/models/post_code_model.dart';
import 'package:ai_logistics_management_order_automation/generated/assets.dart';
import 'package:ai_logistics_management_order_automation/utils/route_optimizer.dart';
import 'package:latlong2/latlong.dart';
import 'package:osrm/osrm.dart';
import 'dart:math' as math;

class OrderMapView extends StatefulWidget {
  final List<OrderModel> orders;

  const OrderMapView({Key? key, required this.orders}) : super(key: key);

  @override
  _OrderMapViewState createState() => _OrderMapViewState();
}

class _OrderMapViewState extends State<OrderMapView> {
  final MapController _mapController = MapController();

  final osrm = Osrm(
    // source: OsrmSource(
    //     serverBuilder: (result) {
    //       return Uri.parse('https://routing.openstreetmap.de/routed-car/route/v1/driving');
    //     }
    // )
  );

  var points = <LatLng>[];
  Set<LatLng> uniquePoints = {};
  bool isLoading = true;
  double _zoom = 12.0;

  /// [distance] the distance between two coordinates [from] and [to]
  num distance = 0.0;

  /// [duration] the duration between two coordinates [from] and [to]
  num duration = 0.0;

  @override
  void initState() {
    super.initState();
    getRoute();
  }


  List<(double, double)> getCoordinatesForSingleOrder(List<OrderModel> orders) {
    if (orders.length == 1) {
      final order = orders.first;
      return [
        (order.pickupPlace.longitude, order.pickupPlace.latitude),
        (order.deliveryPlace.longitude, order.deliveryPlace.latitude),
      ];
    } else {
      List<int> optimizedGroup = RouteOptimizer.optimizeRoute(widget.orders);
      List<PostalCode> postalCodeList = [];
      for (int index in optimizedGroup) {
        if (index == 0) {
          postalCodeList.add(widget.orders[0].pickupPlace);
          print(widget.orders[0].pickupPlace.name);
        } else if (index == 1) {
          postalCodeList.add(widget.orders[0].deliveryPlace);
          print(widget.orders[0].deliveryPlace.name);
        } else if (index == 2) {
          postalCodeList.add(widget.orders[1].pickupPlace);
          print(widget.orders[1].pickupPlace.name);
        } else if (index == 3) {
          postalCodeList.add(widget.orders[1].deliveryPlace);
          print(widget.orders[1].deliveryPlace.name);
        } else if (index == 4) {
          postalCodeList.add(widget.orders[2].pickupPlace);
        } else if (index == 5) {
          postalCodeList.add(widget.orders[2].pickupPlace);
        }
        else if (index == 6) {
          postalCodeList.add(widget.orders[3].pickupPlace);
        } else if (index == 7) {
          postalCodeList.add(widget.orders[3].deliveryPlace);
        } else if (index == 8) {
          postalCodeList.add(widget.orders[4].pickupPlace);
        } else if (index == 9) {
          postalCodeList.add(widget.orders[4].deliveryPlace);
        } else if (index == 10) {
          postalCodeList.add(widget.orders[5].pickupPlace);
        } else if (index == 11) {
          postalCodeList.add(widget.orders[5].deliveryPlace);
        }
      }

      return [
        ...List.generate(postalCodeList.length, (index) {
          return (postalCodeList[index].latitude, postalCodeList[index].longitude,);
        })
      ];

    }
  }

  Future<void> getRoute() async {
    setState(() {
      isLoading = true;
    });

    // get the route
    final options = RouteRequest(
        profile: OsrmRequestProfile.car,
      coordinates: getCoordinatesForSingleOrder(widget.orders),
      geometries: OsrmGeometries.geojson,
      overview: OsrmOverview.full,
      continueStraight: OsrmContinueStraight.true_,
      // alternatives: OsrmAlternative.number(2),
      // annotations: OsrmAnnotation.true_,
      steps: true,
    );
    try {

      final route = await osrm.route(options);

      if (route.routes.isEmpty || route.routes.first.geometry?.lineString == null) {
        throw Exception('No valid route found');
      }

      distance = route.routes.first.distance!;
      duration = route.routes.first.duration!;

      if(widget.orders.length == 1) {
        points = route.routes.first.geometry!.lineString!.coordinates
            .map((coord) => LatLng(coord.toLocation().lat, coord.toLocation().lng))  // Direct conversion
            .toList();
        uniquePoints = points.toSet();
      } else {
        // points = route.routes.last.geometry!.lineString!.coordinates
        //     .map((coord) => LatLng(coord.$1, coord.$2))  // Direct conversion
        //     .toList();
        points = route.routes.first.geometry!.lineString!.coordinates
            .map((coord) => LatLng(coord.toLocation().lng, coord.toLocation().lat))  // Direct conversion
            .toList();
        uniquePoints = points.toSet();
        // points = route.routes.first.geometry!.lineString!.coordinates
        //     .map((coord) => LatLng(coord.toCoordinateList().first, coord.toCoordinateList().last))  // Direct conversion
        //     .toList();
        // points = route.routes.first.geometry!.lineString!.coordinates
        //     .map((coord) => LatLng(coord.toCoordinateList().first, coord.toCoordinateList().last))  // Direct conversion
        //     .toList();
      }

      setState(() {
        isLoading = false;
        if (points.isNotEmpty) {
          _mapController.fitCamera(CameraFit.coordinates(
            coordinates: [points.first, points.last],
            padding: const EdgeInsets.all(50),
          ));
        }
      });

    } catch (e, stack) {
      setState(() {
        isLoading = false;
        _mapController.fitCamera(CameraFit.coordinates(
          coordinates: [LatLng(getCoordinatesForSingleOrder(widget.orders).first.$1, getCoordinatesForSingleOrder(widget.orders).first.$2), LatLng(getCoordinatesForSingleOrder(widget.orders).last.$1, getCoordinatesForSingleOrder(widget.orders).last.$2)],
          padding: const EdgeInsets.all(50),
        ));
        print('Unexpected error: ${e.toString()}');
      });
      print('Stack trace: $stack');
    }
  }

  void _zoomIn() {
    setState(() {
      _zoom = (_zoom + 1).clamp(2.0, 18.0);
      _mapController.move(_mapController.camera.center, _zoom);
    });
  }

  void _zoomOut() {
    setState(() {
      _zoom = (_zoom - 1).clamp(2.0, 18.0);
      _mapController.move(_mapController.camera.center, _zoom);
    });
  }

  bool hasDuplicateLocations(List<OrderModel> orders) {
    Set<LatLng> uniqueLocations = {};

    for (var order in orders) {
      LatLng pickup = LatLng(order.pickupPlace.latitude, order.pickupPlace.longitude);
      LatLng delivery = LatLng(order.deliveryPlace.latitude, order.deliveryPlace.longitude);

      if (!uniqueLocations.add(pickup) || !uniqueLocations.add(delivery)) {
        return true; // Duplicate found
      }
    }

    return false; // No duplicates
  }


  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: LatLng(widget.orders.first.pickupPlace.latitude,
                widget.orders.first.pickupPlace.longitude),
            initialZoom: 10,
            interactionOptions: InteractionOptions(
                flags: InteractiveFlag.drag
            )
          ),
          children: [
      TileLayer(
      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
      userAgentPackageName: 'dev.fleaflet.flutter_map.example',
      // Use the recommended flutter_map_cancellable_tile_provider package to
      // support the cancellation of loading tiles.
      tileProvider: CancellableNetworkTileProvider(),
    ),
            if (points.isNotEmpty && hasDuplicateLocations(widget.orders) != true)
            PolylineLayer(
              polylines: [
                Polyline(
                  strokeWidth: 4,
                  strokeJoin: StrokeJoin.round,
                  points: points,
                  color: Colors.blue,
                ),
              ],
            ),
            if(hasDuplicateLocations(widget.orders) != true)
            MarkerLayer(markers: [
              ...widget.orders
                  .expand((order) => [
                Marker(
                  point: LatLng(order.pickupPlace.latitude,
                      order.pickupPlace.longitude),
                  child: const Icon(Icons.location_on,
                      color: Colors.green),
                ),
                Marker(
                  point: LatLng(order.deliveryPlace.latitude,
                      order.deliveryPlace.longitude),
                  child: const Icon(Icons.flag, color: Colors.red),
                ),
              ]).toList(),
            ]
            ),
          ],
        ),
        if (isLoading) const Center(child: CircularProgressIndicator()),

        /// **Zoom Controls**
        Positioned(
          top: 20,
          right: 20,
          child: SizedBox(
            width: 65,
            height: 30,
            child: Row(
              children: [
                GestureDetector(
                  onTap: () {
                    _zoomIn();
                  },
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                      color: AppColors.white,
                    ),
                    child: Center(child: Icon(Icons.add, color: AppColors.black,)),
                  ),
                ),
                const SizedBox(width: 5),
                GestureDetector(
                  onTap: () {
                    _zoomOut();
                  },
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: AppColors.white,
                    ),
                    child: Center(child: Icon(Icons.remove, color: AppColors.black,)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}