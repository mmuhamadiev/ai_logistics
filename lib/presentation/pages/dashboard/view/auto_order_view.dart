import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ai_logistics_management_order_automation/config/app_colors.dart';
import 'package:ai_logistics_management_order_automation/config/app_text_styles.dart';
import 'package:ai_logistics_management_order_automation/config/constants.dart';
import 'package:ai_logistics_management_order_automation/config/screen_size.dart';
import 'package:ai_logistics_management_order_automation/domain/models/car_type_model.dart';
import 'package:ai_logistics_management_order_automation/domain/models/order_group_model.dart';
import 'package:ai_logistics_management_order_automation/domain/models/order_model.dart';
import 'package:ai_logistics_management_order_automation/presentation/manager/order_list/order_list_cubit.dart';
import 'package:ai_logistics_management_order_automation/presentation/manager/user_profile_cubit/user_profile_cubit.dart';
import 'package:ai_logistics_management_order_automation/presentation/pages/dashboard/components/grouped_order_card.dart';
import 'package:ai_logistics_management_order_automation/presentation/pages/dashboard/components/order_details_dialog_components.dart';
import 'package:ai_logistics_management_order_automation/presentation/pages/dashboard/components/order_selection_constructor.dart';
import 'package:ai_logistics_management_order_automation/presentation/widgets/clock.dart';
import 'package:ai_logistics_management_order_automation/presentation/widgets/notifications/error_notification.dart';
import 'package:ai_logistics_management_order_automation/presentation/widgets/notifications/top_snackbar_info.dart';
import 'package:ai_logistics_management_order_automation/utils/clustering_dbscan_isolate_service.dart';
import 'package:ai_logistics_management_order_automation/utils/clustering_dbscan_service.dart';
import 'package:isolate_manager/isolate_manager.dart';
import 'package:timezone/timezone.dart' as tz;

class AutoOrderView extends StatefulWidget {
  @override
  _AutoOrderViewState createState() => _AutoOrderViewState();
}

class _AutoOrderViewState extends State<AutoOrderView>
    with SingleTickerProviderStateMixin {

  ResponsiveScreenSize responsiveScreenSize = ResponsiveScreenSize();

  late TabController _tabController;

  List<OrderGroupModel> bestOrders = [];
  List<OrderGroupModel> suggestions = [];
  List<OrderModel> noise = [];
  bool isLoading = false;

  final IsolateManager _isolateManager = IsolateManager.create(
    performClusteringIsolate,
    workerName: 'performClusteringIsolate',
    concurrent: 2,);

  Future<void> performClustering(List<OrderModel> orders) async {
    setState(() {
      isLoading = true;
    });
    print("Starting clustering process...");
    bestOrders.clear();
    suggestions.clear();
    noise.clear();

    print("Running initial DBSCAN...");
    var result = await context.read<UserProfileCubit>().checkIfUserProfileActive(context);
    if (result) {
      print("User profile check completed, status: active");
      final user = context.read<UserProfileCubit>().state as UserProfileLoaded;

      print("Serializing orders(${orders.length}) for isolate...");
      print("Serializing orders for isolate...");
      List<Map<String, dynamic>> serializedOrders = orders.map((order) => {
        'orderID': order.orderID,
        'orderName': order.orderName,
        'pickupPlace': {
          'countryCode': order.pickupPlace.countryCode ?? '',
          'postalCode': order.pickupPlace.postalCode ?? '',
          'name': order.pickupPlace.name ?? '',
          'code': order.pickupPlace.code ?? '',
          'latitude': order.pickupPlace.latitude,
          'longitude': order.pickupPlace.longitude,
        },
        'deliveryPlace': {
          'countryCode': order.deliveryPlace.countryCode ?? '',
          'postalCode': order.deliveryPlace.postalCode ?? '',
          'name': order.deliveryPlace.name ?? '',
          'code': order.deliveryPlace.code ?? '',
          'latitude': order.deliveryPlace.latitude,
          'longitude': order.deliveryPlace.longitude,
        },
        'price': order.price,
        'weight': order.weight,
        'ldm': order.ldm,
        'carTypeName': order.carTypeName,
        'pickupTimeWindow': {
          'start': order.pickupTimeWindow.start.toIso8601String(),
          'end': order.pickupTimeWindow.end.toIso8601String(),
        },
        'deliveryTimeWindow': {
          'start': order.deliveryTimeWindow.start.toIso8601String(),
          'end': order.deliveryTimeWindow.end.toIso8601String(),
        },
        'isAdrOrder': order.isAdrOrder,
        'canGroupWithAdr': order.canGroupWithAdr,
        'status': order.status.toString().split('.').last,
        'isConnected': order.isConnected,
        'connectedGroupID': order.connectedGroupID,
        'createdAt': order.createdAt.toIso8601String(),
        'creatorID': order.creatorID,
        'creatorName': order.creatorName,
        'lastModifiedAt': order.lastModifiedAt?.toIso8601String(),
        'isEditing': order.isEditing,
        'distance': order.distance,
        'comments': order.comments.map((comment) => {
          'userID': comment.userID,
          'commenterName': comment.commenterName,
          'content': comment.content,
          'timestamp': comment.timestamp.toIso8601String(),
        }).toList(),
        'orderLogs': order.orderLogs.map((log) => {
          'action': log.action,
          'userID': log.userID,
          'userName': log.userName,
          'timestamp': log.timestamp.toIso8601String(),
        }).toList(),
        'driverInfo': order.driverInfo != null
            ? {
          'driverCar': order.driverInfo!.driverCar,
          'driverName': order.driverInfo!.driverName,
          'carTypeName': order.driverInfo!.carTypeName,
        }
            : null,
      }).toList();
      print("Orders serialized, count: ${serializedOrders.length}");

      print("Serializing car types...");
      List<Map<String, dynamic>> carTypesData = CarTypeModel.carTypes.map((c) => {
        'name': c.name,
        'maxWeight': c.maxWeight,
        'length': c.length,
      }).toList();
      print("Car types serialized, count: ${carTypesData.length}");

      print("Precomputing German time...");
      final germanTimeZone = tz.getLocation('Europe/Berlin');
      final currentTime = tz.TZDateTime.now(germanTimeZone).toIso8601String();
      print("German time computed: $currentTime");

      print("Preparing isolate parameters...");
      Map<String, dynamic> isolateParams = {
        'orders': serializedOrders,
        'eps': user.user.filterModel.maxRadius,
        'minPts': 2,
        'minPricePerKm': user.user.filterModel.pricePerKmThreshold ?? 2.0,
        'maxRadius': user.user.filterModel.maxRadius,
        'carTypes': carTypesData,
        'currentTime': currentTime,
      };
      print("Isolate parameters prepared");
      try {
        print("Sending message to isolate for clustering...");
        final String jsonParams = jsonEncode(isolateParams);

        // Map<String, dynamic> isolateResult = jsonDecode(performClusteringIsolate(jsonParams));
        Map<String, dynamic> isolateResult = jsonDecode(await _isolateManager.sendMessage(jsonParams));
        print("Isolate clustering completed, processing results...");

        List<Map<String, dynamic>> bestOrdersData = (isolateResult['bestOrders'] as List).cast<Map<String, dynamic>>();
        List<Map<String, dynamic>> suggestionsData = (isolateResult['suggestions'] as List).cast<Map<String, dynamic>>();
        List<Map<String, dynamic>> noiseData = (isolateResult['noise'] as List).cast<Map<String, dynamic>>();

        print("Deserializing best orders, count: ${bestOrdersData.length}");
        print("Deserializing best orders: ${bestOrdersData.toString()}");
        bestOrders = bestOrdersData.map((groupData) => OrderGroupModel.fromJson(groupData)).toList();
        print("Best orders deserialized");

        print("Deserializing suggestions, count: ${suggestionsData.length}");
        suggestions = suggestionsData.map((groupData) => OrderGroupModel.fromJson(groupData)).toList();
        print("Suggestions deserialized");

        print("Deserializing noise, count: ${noiseData.length}");
        noise = noiseData.map((orderData) => OrderModel.fromJson(orderData)).toList();
        print("Noise deserialized");

        print("Processing Best Orders...");
        bestOrders.forEach((groupOrders) {
          if (bestOrders.any((data) => data.groupID == groupOrders.groupID)) {
            print("Duplicate Best Order Group detected: GroupID ${groupOrders.groupID}");
          } else {
            print("Adding Best Order Group: GroupID ${groupOrders.groupID}");
          }
        });

        print("Processing Suggestions...");
        suggestions.forEach((groupOrders) {
          if (suggestions.any((data) => data.groupID == groupOrders.groupID)) {
            print("Duplicate Suggestion Group detected: GroupID ${groupOrders.groupID}");
          } else {
            print("Adding Suggestion Group: GroupID ${groupOrders.groupID}");
          }
        });

        print("Processing Noise...");
        noise.forEach((order) {
          if (noise.any((data) => data.orderID == order.orderID)) {
            print("Duplicate Noise Order detected: OrderID ${order.orderID}");
          } else {
            print("Adding Noise Order: OrderID ${order.orderID}");
          }
        });

        print("Clustering process completed.");
        print("Final Best Orders count: ${bestOrders.length}");
        print("Final Suggestions count: ${suggestions.length}");
        print("Final Noise count: ${noise.length}");
        setState(() {
          isLoading = false;
        });
        print("UI state updated, loading finished");
      } catch (e) {
        print('Error during clustering: $e');
        setState(() {
          isLoading = false;
        });
        print("UI state updated due to error, loading finished");
      }
    } else {
      print("User profile check failed, connection lost");
      showErrorNotification(context, 'Sorry action your connection is lost');
      setState(() {
        isLoading = false;
      });
      print("UI state updated due to connection loss, loading finished");
    }
  }

  // void performClustering(List<OrderModel> orders) async {
  //   setState(() {
  //     isLoading = true;
  //   });
  //   print("Starting clustering process...");
  //   bestOrders.clear();
  //   suggestions.clear();
  //   noise.clear();
  //
  //   print("Running initial DBSCAN...");
  //   var result = await context
  //       .read<UserProfileCubit>()
  //       .checkIfUserProfileActive(context);
  //   if (result) {
  //     final user = context.read<UserProfileCubit>().state as UserProfileLoaded;
  //     final result = await ClusteringDBSCANService.performDBSCAN(
  //       orders,
  //       eps: user.user.filterModel.maxRadius,
  //       minPts: 2,
  //       minPricePerKm: user.user.filterModel.pricePerKmThreshold ?? 2,
  //     );
  //
  //     print("Processing Best Orders...");
  //     var best = result["Best"] as List<OrderGroupModel>;
  //
  //     best.forEach((groupOrders) {
  //       if (bestOrders.any((data) => data.groupID == groupOrders.groupID)) {
  //         print(
  //             "Duplicate Best Order Group detected: GroupID ${groupOrders.groupID}");
  //       } else {
  //         print("Adding Best Order Group: GroupID ${groupOrders.groupID}");
  //         bestOrders.add(groupOrders);
  //       }
  //     });
  //
  //     final clusters =
  //         result["Clusters"] != null && result["Clusters"].isNotEmpty
  //             ? result["Clusters"] as Map<int, List<OrderModel>>
  //             : <int, List<OrderModel>>{};
  //
  //     if (clusters.isNotEmpty) {
  //       print("Processing Clusters... Total Clusters: ${clusters.length}");
  //       final result2 =
  //           await ClusteringDBSCANService.processClustersForGrouping(
  //         clusters,
  //         maxRadius: user.user.filterModel.maxRadius,
  //         pricePerKmThreshold: user.user.filterModel.pricePerKmThreshold,
  //       );
  //
  //       print("Processing Best Orders from Clustering...");
  //       final bestOrders2 = result2["Best"] as List<OrderGroupModel>;
  //       final suggestions2 = result2["Suggestions"] as List<OrderGroupModel>;
  //       final noise2 = result2["Noise"] as List<OrderModel>;
  //
  //       bestOrders2.forEach((groupOrders) {
  //         if (bestOrders.any((data) => data.groupID == groupOrders.groupID)) {
  //           print(
  //               "Duplicate Best Order Group detected in Clustering: GroupID ${groupOrders.groupID}");
  //         } else {
  //           print(
  //               "Adding Best Order Group from Clustering: GroupID ${groupOrders.groupID}");
  //           bestOrders.add(groupOrders);
  //         }
  //       });
  //
  //       print("Processing Suggestions...");
  //       suggestions2.forEach((groupOrders) {
  //         if (suggestions.any((data) => data.groupID == groupOrders.groupID)) {
  //           print(
  //               "Duplicate Suggestion Group detected: GroupID ${groupOrders.groupID}");
  //         } else {
  //           print("Adding Suggestion Group: GroupID ${groupOrders.groupID}");
  //           suggestions.add(groupOrders);
  //         }
  //       });
  //
  //       print("Processing Noise...");
  //       noise2.forEach((orders) {
  //         if (noise.any((data) => data.orderID == orders.orderID)) {
  //           print("Duplicate Noise Order detected: OrderID ${orders.orderID}");
  //         } else {
  //           print("Adding Noise Order: OrderID ${orders.orderID}");
  //           noise.add(orders);
  //         }
  //       });
  //     } else {
  //       final noise2 = result["Noise"] as List<OrderModel>;
  //       noise2.forEach((orders) {
  //         if (noise.any((data) => data.orderID == orders.orderID)) {
  //           print("Duplicate Noise Order detected: OrderID ${orders.orderID}");
  //         } else {
  //           print("Adding Noise Order: OrderID ${orders.orderID}");
  //           noise.add(orders);
  //         }
  //       });
  //       print("No clusters found.");
  //     }
  //
  //     print("Clustering process completed.");
  //     print("Best Orders: ${bestOrders.length}");
  //     print("Suggestions: ${suggestions.length}");
  //     print("Noise: ${noise.length}");
  //     setState(() {
  //       isLoading = false;
  //     });
  //   } else {
  //     showErrorNotification(context, 'Sorry action your connection is lost');
  //     setState(() {
  //       isLoading = false;
  //     });
  //   }
  // }

  List<OrderModel> filterPendingOrders(List<OrderModel> orders) {
    print('🔹 Total Orders: ${orders.length}');

    final germanTimeZone = tz.getLocation('Europe/Berlin');
    final nowInGermanTime = tz.TZDateTime.now(germanTimeZone);
    final minStartDate = DateTime(2024, 1, 1); // Start filtering from Jan 1, 2024

    final filteredOrders = orders.where((order) {
      final bool isDeliveryNotPostponed = order.deliveryTimeWindow.end.isAfter(nowInGermanTime);
      final bool isPickupTimeValid = order.pickupTimeWindow.end.isAfter(minStartDate);

      return isDeliveryNotPostponed && isPickupTimeValid;
    }).toList();

    print('✅ Filtered Orders: ${filteredOrders.length}');
    return filteredOrders;
  }

  void initPerformClustering() {
    if(context.read<OrderListCubit>().state is OrderListLoaded) {
      debugPrint('Is Order Loaded State');
      performClustering(filterPendingOrders((context.read<OrderListCubit>().state as OrderListLoaded).orders)).whenComplete(() {
        setState(() {

        });
      });
    } else {
      debugPrint('Not Order Loaded State');
    }
  }
  
  @override
  void initState() {
    super.initState();
    _isolateManager.start();
    initPerformClustering();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _isolateManager.stop();
    _tabController.dispose();
    super.dispose();
  }

  // @override
  // void initState() {
  //   if(context.read<OrderListCubit>().state is OrderListLoaded) {
  //     // performClustering((context.read<OrderListCubit>().state as OrderListLoaded).orders);
  //     performClustering(filterPendingOrders(context.read<OrderListCubit>().allOrders));
  //   }
  //   super.initState();
  //   _tabController = TabController(length: 3, vsync: this);
  // }
  //
  // @override
  // void dispose() {
  //   _tabController.dispose();
  //   super.dispose();
  // }

  @override
  Widget build(BuildContext context) {
    return BlocListener<OrderListCubit, OrderListState>(
  listener: (context, state) {
    if(state is OrderListLoaded) {
      performClustering(filterPendingOrders(state.orders)).whenComplete(() {
        setState(() {

        });
      });
    }
  },
  child: LayoutBuilder(builder: (context, constraints) {
      if (responsiveScreenSize.isDesktopScreen(context)) {
        return Scaffold(
          backgroundColor: AppColors.lightGray,
          body: isLoading? Center(child: CircularProgressIndicator(),): Column(
            children: [
              _buildTopRow(),
              buildHeaderWithFilter(context),
              TabBar(
                controller: _tabController,
                labelColor: AppColors.black,
                indicatorColor: AppColors.black,
                unselectedLabelColor: Colors.grey,
                tabs: const [
                  Tab(text: "Best Orders"),
                  Tab(text: "Suggestions"),
                  Tab(text: "Noise Orders"),
                ],
              ),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    buildOrderGrid(bestOrders, "Best Orders"),
                    buildOrderGrid(suggestions, "Suggestions"),
                    buildOrderList(noise, "Noise Orders"),
                  ],
                ),
              ),
            ],
          ),
        );
      } else if (responsiveScreenSize.isTabletScreen(context)) {
        return Scaffold(
          backgroundColor: AppColors.lightGray,
          body: isLoading? Center(child: CircularProgressIndicator(),): Column(
            children: [
              _buildTopRow(),
              buildHeaderWithFilter(context),
              TabBar(
                controller: _tabController,
                labelColor: AppColors.black,
                indicatorColor: AppColors.black,
                unselectedLabelColor: Colors.grey,
                tabs: const [
                  Tab(text: "Best Orders"),
                  Tab(text: "Suggestions"),
                  Tab(text: "Noise Orders"),
                ],
              ),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    buildOrderGrid(bestOrders, "Best Orders"),
                    buildOrderGrid(suggestions, "Suggestions"),
                    buildOrderList(noise, "Noise Orders"),
                  ],
                ),
              ),
            ],
          ),
        );
      } else {
        return Scaffold(
          floatingActionButton: FloatingActionButton.small(
            backgroundColor: AppColors.lightBlue,
            tooltip: 'Constructor',
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) {
                  return FullScreenOrderSelectionDialog(isMobile: true,);
                },
              );
            },
            child: Icon(
              Icons.add_circle_outline,
              color: AppColors.white,
            ),
          ),
          body: Column(
            children: [
              const SizedBox(height: 12),
              Container(
                color: AppColors.white,
                height: 70,
                width: MediaQuery.sizeOf(context).width,
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Auto Order",
                      style: Theme.of(context)
                          .textTheme
                          .headlineMedium
                          ?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Divider(
                thickness: 1,
                height: 1,
              ),

              // Quick Actions
              const SizedBox(height: 12),
              Center(child: BeautifulClock()),
              const SizedBox(height: 5),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                child: BlocBuilder<UserProfileCubit, UserProfileState>(
                    builder: (context, state) {
                      if (state is UserProfileLoading) {
                        return const Text('Waiting data');
                      }
                      if (state is UserProfileLoaded) {
                        final userModel = state.user;
                        final filter = userModel.filterModel;

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Container(
                              height: 36,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: AppColors.grey),
                                  color: AppColors.white
                              ),
                              padding: EdgeInsets.symmetric(horizontal: 13),
                              alignment: Alignment.center,
                              child: Row(
                                children: [
                                  Text('Radius: ${filter.maxRadius} km'),
                                  SizedBox(
                                    width: 5,
                                  ),
                                  VerticalDivider(),
                                  SizedBox(
                                    width: 5,
                                  ),
                                  Text('Min Price/Km: ${filter.pricePerKmThreshold.toStringAsFixed(2)} EUR'),
                                ],
                              ),
                            ),
                            SizedBox(
                              height: 5,
                            ),
                            // Edit Filter Button
                            OutlinedButton.icon(
                              onPressed: () {
                                showEditFilterDialog(context);
                              },
                              icon: const Icon(Icons.edit_note),
                              label: const Text("Edit User Filter"),
                            ),
                          ],
                        );
                      }
                      return const Text('Waiting data');
                    }),
              ),
              TabBar(
                controller: _tabController,
                tabs: const [
                  Tab(text: "Best Orders"),
                  Tab(text: "Suggestions"),
                  Tab(text: "Noise Orders"),
                ],
              ),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    buildOrderGridMobile(bestOrders, "Best Orders"),
                    buildOrderGridMobile(suggestions, "Suggestions"),
                    buildOrderList(noise, "Noise Orders"),
                  ],
                ),
              ),
            ],
          ),
        );
      }
    }),
);
  }

  Widget _buildTopRow() {
    return Column(
      children: [
        Container(
          color: AppColors.white,
          height: 70,
          width: MediaQuery.sizeOf(context).width,
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Auto Order",
                style: Theme.of(context)
                    .textTheme
                    .headlineMedium
                    ?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              // Quick Actions
              Row(
                children: [
                  BeautifulClock(),
                  const SizedBox(
                    width: 16,
                  ),
                  _buildQuickActions(),
                ],
              )
            ],
          ),
        ),
        Divider(
          thickness: 1,
          height: 1,
        ),
      ],
    );
  }

  Widget _buildQuickActions() {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(backgroundColor: AppColors.black),
      icon: Icon(
        Icons.add,
        color: AppColors.white,
      ),
      label: Text(
        'Constructor',
        style: AppTextStyles.body14RobotoMedium
            .copyWith(color: AppColors.white),
      ),
      onPressed: () {
        showDialog(
          context: context,
          builder: (context) {
            return FullScreenOrderSelectionDialog(isMobile: false,);
          },
        );
      },
    );
  }

  Widget buildOrderGridMobile(List<OrderGroupModel> orderGroups, String title) {
    if (orderGroups.isEmpty) {
      return Center(child: Text("No $title available"));
    }

    return ListView.builder(
      itemCount: orderGroups.length,
      itemBuilder: (context, index) {
        final orderGroup = orderGroups[index];
        return GroupInfoCardMobile(orderGroup: orderGroup,);
      },
    );
  }

  Widget buildOrderGrid(List<OrderGroupModel> orderGroups, String title) {
    if (orderGroups.isEmpty) {
      return Center(child: Text("No $title available"));
    }

    return ListView.builder(
      itemCount: orderGroups.length,
      itemBuilder: (context, index) {
        final orderGroup = orderGroups[index];
        return GroupInfoCard(orderGroup: orderGroup,);
      },
    );
  }

  Widget buildOrderList(List<OrderModel> orders, String title) {
    if (orders.isEmpty) {
      return Center(child: Text("No $title available"));
    }

    return ListView.builder(
      itemCount: orders.length,
      itemBuilder: (context, index) {
        final order = orders[index];
        return _buildOrderCard(order);
      },
    );
  }

  Widget _buildOrderCard(OrderModel order) {
    return Column(
      children: [
        ListTile(
          leading: Icon(Icons.local_shipping, color: AppColors.grey),
          title: SelectableText(
            "Order: ${order.orderID} || Order Name: ${order.orderName}",
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                  "Pickup: ${order.pickupPlace.countryCode}, ${order.pickupPlace.postalCode}, ${order.pickupPlace.name}"),
              Text(
                  "Delivery: ${order.deliveryPlace.name}, ${order.deliveryPlace.postalCode}"),
              Text("LDM: ${order.ldm.toStringAsFixed(1)}"),
              Text("Weight: ${order.weight.toStringAsFixed(1)} tons"),
              Text(
                  "Distance: ${ClusteringDBSCANService.calculateDistance(order.pickupPlace.latitude, order.pickupPlace.longitude, order.deliveryPlace.latitude, order.deliveryPlace.longitude).toStringAsFixed(2)} km", style: TextStyle(fontSize: 12, color: Colors.grey.shade600),),
              Text(
                  "Price/Km: ${ClusteringDBSCANService.calculateOrderPricePerKm(order).toStringAsFixed(2)} EUR/km", style: TextStyle(fontSize: 12, color: Colors.grey.shade600),),
            ],
          ),
          trailing: Container(
            decoration: BoxDecoration(
                border: Border.all(color: AppColors.black, width: 1),
                borderRadius: BorderRadius.circular(8)),
            child: TextButton(
              onPressed: () {
                    _showOrderDetails(
                      order,
                      context.read<UserProfileCubit>().state is UserProfileLoaded
                          ? (context.read<UserProfileCubit>().state
                      as UserProfileLoaded)
                          .user
                          .userRole ==
                          UserRoles.allRoles[1]
                          : false,
                      false
                  );
                },
              child: Text(
                "Details",
                style: AppTextStyles.body17RobotoMedium,
              ),
            ),
          ),
        ),
        Divider(),
      ],
    );
  }

  void _showOrderDetails(OrderModel order, bool isTeamLead, bool canComment) {
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierLabel: "OrderDetails",
      pageBuilder: (context, _, __) {
        return StatefulBuilder(
            builder: (context, setState) {
              return Align(
                alignment: Alignment.centerRight, // Align dialog to the right
                child: Material(
                  color: Colors.white,
                  child: Container(
                    width: MediaQuery.of(context).size.width * (responsiveScreenSize.isTabletScreen(context) || responsiveScreenSize.isMobileScreen(context)? 1: 0.5), // 50% of screen width
                    height: MediaQuery.of(context).size.height, // Full screen height
                    padding: const EdgeInsets.all(12.0),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Top Bar: Order ID and Close Button
                          if(responsiveScreenSize.isTabletScreen(context) || responsiveScreenSize.isMobileScreen(context))...[
                            SizedBox(
                              height: 20,
                            ),
                          ],
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              SelectableText(
                                'Order ID: ${order.orderID}',
                                style: AppTextStyles.head20RobotoMedium,
                              ),
                              IconButton(
                                icon: const Icon(Icons.close),
                                onPressed: () => context.pop(),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          // Order Overview Map Placeholder
                          buildMapPlaceholder(order),
                          const SizedBox(height: 12),
                          // Pickup and Delivery Timelines
                          buildTimelineSection(order),
                          const SizedBox(height: 12),
                          // Order Data
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              buildSectionTitle('Order Details'),
                              const SizedBox(height: 5),
                              Row(
                                children: [
                                  Expanded(
                                    child: Container(
                                      padding: const EdgeInsets.all(8.0),
                                      decoration: BoxDecoration(
                                        border: Border.all(color: AppColors.grey),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Column(
                                        children: [
                                          buildDetailRow('Order Name:', order.orderName),
                                          buildDetailRow('Car Type:', order.carTypeName),
                                          buildDetailRow('Status:', order.status.name),
                                          buildDetailRow('Price:', '€${order.price.toStringAsFixed(2)}'),
                                          buildDetailRow('Price/Km:', '${ClusteringDBSCANService.calculateOrderPricePerKm(order).toStringAsFixed(2)} €/km'),
                                        ],
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Expanded(
                                    child: Container(
                                      padding: const EdgeInsets.all(8.0),
                                      decoration: BoxDecoration(
                                        border: Border.all(color: AppColors.grey),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Column(
                                        children: [
                                          buildDetailRow('LDM:', '${order.ldm.toStringAsFixed(1)}'),
                                          buildDetailRow('Weight:', '${order.weight.toStringAsFixed(1)} tons'),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(vertical: 3.0),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Text('Is ADR:', maxLines: 1,
                                                    softWrap: true,
                                                    overflow: TextOverflow.ellipsis,
                                                    style: AppTextStyles.body17RobotoMedium),
                                                Icon(
                                                  order.isAdrOrder ? Icons.check_circle : Icons.cancel,
                                                  color: order.isAdrOrder ? Colors.green : Colors.red,
                                                  size: 14,
                                                ),
                                              ],
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(vertical: 3.0),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Flexible(
                                                  child: Text('Can Group with ADR:', maxLines: 1,
                                                      softWrap: true,
                                                      overflow: TextOverflow.ellipsis,
                                                      style: AppTextStyles.body17RobotoMedium),
                                                ),
                                                Icon(
                                                  order.canGroupWithAdr
                                                      ? Icons.check_circle
                                                      : Icons.cancel,
                                                  color:
                                                  order.canGroupWithAdr ? Colors.green : Colors.red,
                                                  size: 14,
                                                ),
                                              ],
                                            ),
                                          ),
                                          buildDetailRow('Distance:', '${ClusteringDBSCANService.calculateDistance(order.pickupPlace.latitude, order.pickupPlace.longitude, order.deliveryPlace.latitude, order.deliveryPlace.longitude).toStringAsFixed(2)} km'),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              buildSectionTitle('Created By'),
                              const SizedBox(height: 5),
                              buildOrderCreator(order),
                              const SizedBox(height: 12),
                              buildSectionTitle('Comments'),
                              const SizedBox(height: 5),
                              buildCommentsSection(context, order, canComment),
                              if (isTeamLead) ...[
                                const SizedBox(height: 12),
                                buildSectionTitle('Logs'),
                                const SizedBox(height: 5),
                                buildLogsSection(order),
                              ],
                              //TODO
                              // const SizedBox(height: 12),
                              // ElevatedButton.icon(
                              //   icon: const Icon(Icons.file_download),
                              //   label: const Text('Export Order'),
                              //   onPressed: () {
                              //     // Export logic here
                              //   },
                              // ),
                            ],
                          ),
                          if(responsiveScreenSize.isTabletScreen(context) || responsiveScreenSize.isMobileScreen(context))...[
                            SizedBox(
                              height: 20,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }
        );
      },
    );
  }

  Widget buildHeaderWithFilter(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      child: BlocBuilder<UserProfileCubit, UserProfileState>(
          builder: (context, state) {
        if (state is UserProfileLoading) {
          return const Text('Waiting data');
        }
        if (state is UserProfileLoaded) {
          final userModel = state.user;
          final filter = userModel.filterModel;

          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                height: 36,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.grey),
                    color: AppColors.white
                ),
                padding: EdgeInsets.symmetric(horizontal: 13),
                alignment: Alignment.center,
                child: Row(
                  children: [
                    Text('Radius: ${filter.maxRadius} km'),
                    SizedBox(
                      width: 5,
                    ),
                    VerticalDivider(),
                    SizedBox(
                      width: 5,
                    ),
                    Text('Min Price/Km: ${filter.pricePerKmThreshold.toStringAsFixed(2)} EUR'),
                  ],
                ),
              ),
              SizedBox(
                width: 10,
              ),
              // Edit Filter Button
              OutlinedButton.icon(
                onPressed: () {
                  showEditFilterDialog(context);
                },
                icon: const Icon(Icons.edit_note),
                label: const Text("Edit User Filter"),
              ),
            ],
          );
        }
        return const Text('Waiting data');
      }),
    );
  }

  void showEditFilterDialog(BuildContext context) {
    final userModel =
        (context.read<UserProfileCubit>().state as UserProfileLoaded).user;
    final currentFilter = userModel.filterModel;

    final radiusController =
        TextEditingController(text: currentFilter.maxRadius.toString());
    final minPriceController = TextEditingController(
        text: currentFilter.pricePerKmThreshold.toString());

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return BlocConsumer<UserProfileCubit, UserProfileState>(
            listener: (context, state) {
          if (state is UserProfileError) {
            showErrorNotification(context, state.message);
          }
          if (state is UserProfileFilterSuccess) {
            // User logged in successfully after choosing auto-login
            showTopSnackbarInfo(context, 'Filter successfully updated');
          }
          if (state is UserProfileLoaded) {
            context.pop();
            performClustering(filterPendingOrders(context.read<OrderListCubit>().allOrders));
          }
        }, builder: (context, state) {
          final isLoading = state is UserProfileLoading;
          return AlertDialog(
            title: const Text("Edit Filter"),
            backgroundColor: AppColors.white,
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Radius Input
                  TextField(
                    controller: radiusController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: "Radius (km)"),
                  ),
                  const SizedBox(height: 16),

                  // Minimum Price/Km Input
                  TextField(
                    controller: minPriceController,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,1}$')),
                    ],
                    keyboardType:
                        TextInputType.numberWithOptions(decimal: true),
                    decoration:
                        const InputDecoration(labelText: "Min Price/Km (EUR)"),
                  ),
                ],
              ),
            ),
            actions: [
              IgnorePointer(
                ignoring: isLoading,
                child: TextButton(
                  onPressed: () {
                    context.pop();
                  },
                  child: const Text("Cancel"),
                ),
              ),
              IgnorePointer(
                ignoring: isLoading,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
                  onPressed: () async {
                    final updatedFilter = currentFilter.copyWith(
                      maxRadius: double.tryParse(radiusController.text) ??
                          currentFilter.maxRadius,
                      pricePerKmThreshold:
                          double.tryParse(minPriceController.text) ??
                              currentFilter.pricePerKmThreshold,
                    );
                    var result = await context
                        .read<UserProfileCubit>()
                        .checkIfUserProfileActive(context);
                    if (result) {
                      final user = context.read<UserProfileCubit>().state
                          as UserProfileLoaded;
                      context
                          .read<UserProfileCubit>()
                          .updateUserFilter(updatedFilter, user.user);
                    } else {
                      showErrorNotification(
                          context, 'Sorry action your connection is lost');
                    }
                  },
                  child: isLoading
                      ? CircularProgressIndicator(
                    color: AppColors.white,
                  )
                      : Text("Save", style: AppTextStyles.body17RobotoMedium.copyWith(color: AppColors.white)),
                ),
              ),
            ],
          );
        });
      },
    );
  }
}
