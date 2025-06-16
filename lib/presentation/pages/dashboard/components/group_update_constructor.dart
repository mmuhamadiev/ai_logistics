import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get_rx/src/rx_workers/utils/debouncer.dart';
import 'package:go_router/go_router.dart';
import 'package:hegelmann_order_automation/config/app_colors.dart';
import 'package:hegelmann_order_automation/config/app_text_styles.dart';
import 'package:hegelmann_order_automation/config/constants.dart';
import 'package:hegelmann_order_automation/utils/adr_validator_service.dart';
import 'package:hegelmann_order_automation/domain/models/car_type_model.dart';
import 'package:hegelmann_order_automation/domain/models/order_group_model.dart';
import 'package:hegelmann_order_automation/domain/models/order_model.dart';
import 'package:hegelmann_order_automation/presentation/manager/filter/filter_cubit.dart';
import 'package:hegelmann_order_automation/presentation/manager/group_order_list/group_order_list_cubit.dart';
import 'package:hegelmann_order_automation/presentation/manager/order_list/order_list_cubit.dart';
import 'package:hegelmann_order_automation/presentation/manager/user_profile_cubit/user_profile_cubit.dart';
import 'package:hegelmann_order_automation/presentation/widgets/notifications/error_notification.dart';
import 'package:hegelmann_order_automation/presentation/widgets/notifications/top_snackbar_info.dart';
import 'package:hegelmann_order_automation/utils/clustering_dbscan_service.dart';
import 'package:hegelmann_order_automation/utils/route_optimizer.dart';
import 'package:hegelmann_order_automation/utils/time_manager.dart';

class GroupUpdateConstructor extends StatefulWidget {

  const GroupUpdateConstructor({Key? key, required this.isMobile, required this.group}) : super(key: key);

  final OrderGroupModel group;
  final bool isMobile;

  @override
  _GroupUpdateConstructorState createState() =>
      _GroupUpdateConstructorState();
}

class _GroupUpdateConstructorState extends State<GroupUpdateConstructor> with SingleTickerProviderStateMixin{

  final Debouncer _debouncer = Debouncer(delay: Duration(milliseconds: 500));

  TextEditingController _searchController = TextEditingController();

  late TabController _tabController;

  final List<OrderModel> selectedOrders = [];
  double totalDistance = 0;
  double totalPrice = 0;
  double pricePerKm = 0;
  double totalWeight = 0;
  double totalLDM = 0;
  bool validateWeight = false;
  bool validateLDM = false;
  bool validateDate = false;
  bool validateAdr = false;

  AdrValidatorService adrValidatorService = AdrValidatorService();

  Future<void> _updateOrder(BuildContext context, OrderGroupModel oldGroup,) async {
    try {
      List<int> optimizedGroup = RouteOptimizer.optimizeRoute(selectedOrders);

      double totalDistance = ClusteringDBSCANService.calculateRouteDistance(
          selectedOrders, optimizedGroup);
      double totalPrice = selectedOrders.fold(
          0, (sum, order) => sum + order.price);
      double pricePerKm = totalDistance > 0 ? totalPrice / totalDistance : 0.0;
      double totalWeight = selectedOrders.fold(
          0, (sum, order) => sum + order.weight);
      double totalLDM = selectedOrders.fold(0, (sum, order) => sum + order.ldm);
      var orderIdsList = [];
      selectedOrders.forEach((order) {
        orderIdsList.add(order.orderID);
      });

      var group = OrderGroupModel(
        groupID: orderIdsList.join('-'),
        orders: selectedOrders.map((order) {
          return order.copyWith(
            lastModifiedAt: DateTime.now(),
            isEditing: false,
            lastStartEditTime: null,
            connectedGroupID: orderIdsList.join('-'),
          );
        }).toList(),
        totalDistance: totalDistance,
        pricePerKm: pricePerKm,
        totalPrice: totalPrice,
        totalLDM: totalLDM,
        totalWeight: totalWeight,
        status: oldGroup.status,
        creatorID: oldGroup.creatorID,
        creatorName: oldGroup.creatorName,
        createdAt: oldGroup.createdAt,
        isNeedAddMore: oldGroup.isNeedAddMore,
        comments: oldGroup.comments,
        logs: oldGroup.logs,
        driverInfo: oldGroup.driverInfo,
        isEditing: false,
        lastModifiedAt: DateTime.now(),
        lastStartEditTime: null,
      );
      // Step 1: Fetch the global filter
      await context.read<FilterCubit>().fetchFilter();
      final filterState = context
          .read<FilterCubit>()
          .state;

      if (filterState is FilterLoaded) {
        final filter = filterState.filter;

        // Step 2: Validate the group order against the filter criteria

        final meetsPricePerKmThreshold = pricePerKm >=
            filter.pricePerKmThreshold;

        if (meetsPricePerKmThreshold) {
          // Criteria met: Add order directly
          var result = await context
              .read<UserProfileCubit>()
              .checkIfUserProfileActive(context);
          if (result) {
            final user = context
                .read<UserProfileCubit>()
                .state
            as UserProfileLoaded;

            var isOrderLastStartGroupEditTimeChanged = await context.read<GroupOrderListCubit>().isOrderLastStartGroupEditTimeChanged(group.groupID, oldGroup.lastModifiedAt);
            if(isOrderLastStartGroupEditTimeChanged) {
              showErrorNotification(context, 'Group has been updated recently, please retrieve new data first');
            } else {
              context
                  .read<GroupOrderListCubit>()
                  .updateOrderGroup(
                  group,
                  user.user.userID,
                  user.user.name,
                  oldGroup
              );
            }

          } else {
            showErrorNotification(context,
                'Sorry action your connection is lost');
          }
        } else {
          // Criteria not met: Show confirmation dialog
          final shouldConfirm = await showDialog<bool>(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: const Text('Confirm Adding Order'),
                content: const Text(
                  'The order group does not fully meet the filter criteria. Do you want to add it anyway?',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text('Cancel'),
                  ),
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    child: const Text('Update'),
                  ),
                ],
              );
            },
          );

          // If the user confirms, add the order group
          if (shouldConfirm == true) {
            var result = await context
                .read<UserProfileCubit>()
                .checkIfUserProfileActive(context);
            if (result) {
              final user = context
                  .read<UserProfileCubit>()
                  .state
              as UserProfileLoaded;

              context
                  .read<GroupOrderListCubit>()
                  .updateOrderGroup(
                  group,
                  user.user.userID,
                  user.user.name,
                  oldGroup
              );
            } else {
              showErrorNotification(context,
                  'Sorry action your connection is lost');
            }
          } else {
            showTopSnackbarInfo(context, 'Order group addition was canceled.');
          }
        }
      } else if (filterState is FilterError) {
        // Handle filter fetch error
        showErrorNotification(context, filterState.message);
      } else {
        // Handle unexpected state
        showErrorNotification(
            context, 'Failed to validate filter criteria. Please try again.');
      }
    } catch (e) {
      // Handle any other errors
      showErrorNotification(context, 'Error fetching filter: ${e.toString()}');
    }
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getFilteredQuery() {
    Query<Map<String, dynamic>> query =
    FirebaseFirestore.instance.collection('orders');

    query = query.where('status', whereIn: ['Pending', 'ClientCanceled']);

    if (_searchController.text.isNotEmpty) {
      query = query.orderBy('orderName').startAt([
        _searchController.text.toUpperCase(),
      ]).endAt([
        '${_searchController.text.toUpperCase()}\uf8ff',
      ]);
      debugPrint('🔹 Search Query: ${_searchController.text.toUpperCase()}');
    }

    if (_searchController.text.isEmpty) {
      query = query.orderBy('createdAt', descending: true);
      debugPrint('🔹 Ordering by createdAt (descending)');
    }

    debugPrint('✅ FINAL QUERY BUILT ✅');
    return query.snapshots();
  }

  @override
  void initState() {
    super.initState();
    widget.group.orders.forEach((orders) {
      selectedOrders.add(orders);
    });
    if (selectedOrders.length == 1) {
      totalPrice =
          selectedOrders.first.price;
      totalDistance =
          ClusteringDBSCANService
              .calculateDistance(
            selectedOrders.first
                .pickupPlace.latitude,
            selectedOrders.first
                .pickupPlace.longitude,
            selectedOrders.first
                .deliveryPlace.latitude,
            selectedOrders.first
                .deliveryPlace.longitude,
          );
      pricePerKm = ClusteringDBSCANService.calculateOrderPricePerKm(selectedOrders.first);
      CarTypeModel? carType = CarTypeModel
          .carTypes.firstWhere(
            (type) =>
        type.name == selectedOrders.first
            .carTypeName,
      );
      totalLDM = selectedOrders.first.ldm;
      totalWeight =
          selectedOrders.first.weight;
      validateLDM =
          selectedOrders.first.ldm <=
              carType.length;
      validateWeight =
          selectedOrders.first.weight <=
              carType.maxWeight;
      validateDate = true;
      validateAdr = true;
    }
    else {
      List<int> optimizedGroup = RouteOptimizer
          .optimizeRoute(selectedOrders);
      totalDistance =
          ClusteringDBSCANService
              .calculateRouteDistance(
              selectedOrders,
              optimizedGroup);
      totalPrice = selectedOrders.fold(
          0, (sum, order) => sum +
          order.price);
      pricePerKm =
      totalDistance > 0 ? totalPrice /
          totalDistance : 0.0;
      totalWeight = selectedOrders.fold(
          0, (sum, order) => sum +
          order.weight);
      totalLDM = selectedOrders.fold(
          0, (sum, order) => sum +
          order.ldm);
      CarTypeModel carType = CarTypeModel
          .carTypes.firstWhere(
            (type) =>
        type.name == selectedOrders.first
            .carTypeName,
        orElse: () =>
        CarTypeModel.carTypes.first,
      );

      validateWeight = totalWeight <=
          carType.maxWeight;
      validateLDM =
          totalLDM <= carType.length;
      validateDate =
          TimeManager.validateTimeWindows(
              selectedOrders,
              optimizedGroup);
      validateAdr = adrValidatorService
          .canGroupOrders(selectedOrders);
    }
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog.fullscreen(
      child: Scaffold(
        backgroundColor: AppColors.lightGray,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Text(
            "Order Group Constructor",
            style: Theme.of(context)
                .textTheme
                .headlineMedium
                ?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () {
                context.pop(false);
              },
            ),
          ],
        ),
        body: widget.isMobile? Column(
          children: [
            TabBar(
              controller: _tabController,
              tabs: const [
                Tab(text: "Orders List"),
                Tab(text: "Summary"),
              ],
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0, bottom: 8.0, left: 10, right: 5),
                    child: Card(
                      elevation: 2,
                      color: AppColors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        children: [
                          // Search Bar
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 10),
                            child: TextField(
                              controller: _searchController,
                              onChanged: (value) {
                                _debouncer.call(() {
                                  setState(() {

                                  });
                                });
                              },
                              decoration: InputDecoration(
                                hintText: "Search",
                                labelStyle: AppTextStyles.head20RobotoRegular,
                                fillColor: Theme.of(context).colorScheme.surfaceVariant,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                prefixIcon: const Icon(Icons.search, color: Colors.black54),
                                filled: true,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          // Order List
                          Expanded(
                            child: StreamBuilder<QuerySnapshot>(
                                stream: getFilteredQuery(),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return const Center(
                                        child: CircularProgressIndicator());
                                  } else if (snapshot.hasError) {
                                    return Center(
                                        child: Text('Error: ${snapshot.error}'));
                                  } else if (!snapshot.hasData ||
                                      snapshot.data!.docs.isEmpty) {
                                    return const Center(
                                        child: Text("No orders"));
                                  }

                                  List<OrderModel> orders = snapshot.data!.docs.map((doc) {
                                    final data = doc.data() as Map<String, dynamic>;
                                    return OrderModel.fromJson(
                                        data); // Ensure OrderModel has a `fromMap` method
                                  }).toList();
                                  print(orders.length);

                                  // **🔹 Sort orders by createdAt (latest first)**
                                  orders.sort((a, b) {
                                    final createdAtA = DateTime.parse(a.createdAt.toString());
                                    final createdAtB = DateTime.parse(b.createdAt.toString());
                                    return createdAtB.compareTo(createdAtA); // Descending order (latest first)
                                  });

                                  return ListView.builder(
                                    itemCount: orders.length,
                                    itemBuilder: (context, index) {
                                      final order = orders[index];
                                      final isSelected = selectedOrders.any((data) => data.orderID == order.orderID);

                                      return UpdateOrderCard(order: order, isSelected: isSelected, onTap: () {
                                        setState(() {
                                          bool isClientCanceled = order.status ==
                                              OrderStatus.ClientCanceled;
                                          int pendingCount = selectedOrders
                                              .where((o) =>
                                          o.status != OrderStatus.ClientCanceled)
                                              .length;
                                          int clientCanceledCount = selectedOrders
                                              .where((o) =>
                                          o.status == OrderStatus.ClientCanceled)
                                              .length;

                                          if (!isSelected == true) {
                                            if ((isClientCanceled &&
                                                clientCanceledCount < 3) ||
                                                (!isClientCanceled &&
                                                    pendingCount < 6)) {
                                              var newOrder = order.copyWith(
                                                status: OrderStatus.Confirmed,
                                                driverInfo: widget.group.driverInfo,
                                              );
                                              selectedOrders.add(newOrder);

                                              if (selectedOrders.length == 1) {
                                                totalPrice =
                                                    selectedOrders.first.price;
                                                totalDistance =
                                                    ClusteringDBSCANService
                                                        .calculateDistance(
                                                      selectedOrders.first
                                                          .pickupPlace.latitude,
                                                      selectedOrders.first
                                                          .pickupPlace.longitude,
                                                      selectedOrders.first
                                                          .deliveryPlace.latitude,
                                                      selectedOrders.first
                                                          .deliveryPlace.longitude,
                                                    );
                                                pricePerKm = ClusteringDBSCANService
                                                    .calculateOrderPricePerKm(
                                                    order);
                                                CarTypeModel? carType = CarTypeModel
                                                    .carTypes.firstWhere(
                                                      (type) =>
                                                  type.name == selectedOrders.first
                                                      .carTypeName,
                                                );
                                                totalLDM = selectedOrders.first.ldm;
                                                totalWeight =
                                                    selectedOrders.first.weight;
                                                validateLDM =
                                                    selectedOrders.first.ldm <=
                                                        carType.length;
                                                validateWeight =
                                                    selectedOrders.first.weight <=
                                                        carType.maxWeight;
                                                validateDate = true;
                                                validateAdr = true;
                                              }
                                              else {
                                                List<int> optimizedGroup = RouteOptimizer
                                                    .optimizeRoute(selectedOrders);
                                                totalDistance =
                                                    ClusteringDBSCANService
                                                        .calculateRouteDistance(
                                                        selectedOrders,
                                                        optimizedGroup);
                                                totalPrice = selectedOrders.fold(
                                                    0, (sum, order) => sum +
                                                    order.price);
                                                pricePerKm =
                                                totalDistance > 0 ? totalPrice /
                                                    totalDistance : 0.0;
                                                totalWeight = selectedOrders.fold(
                                                    0, (sum, order) => sum +
                                                    order.weight);
                                                totalLDM = selectedOrders.fold(
                                                    0, (sum, order) => sum +
                                                    order.ldm);
                                                CarTypeModel carType = CarTypeModel
                                                    .carTypes.firstWhere(
                                                      (type) =>
                                                  type.name == selectedOrders.first
                                                      .carTypeName,
                                                  orElse: () =>
                                                  CarTypeModel.carTypes.first,
                                                );

                                                validateWeight = totalWeight <=
                                                    carType.maxWeight;
                                                validateLDM =
                                                    totalLDM <= carType.length;
                                                validateDate =
                                                    TimeManager.validateTimeWindows(
                                                        selectedOrders,
                                                        optimizedGroup);
                                                validateAdr = adrValidatorService
                                                    .canGroupOrders(selectedOrders);
                                              }
                                            } else {
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                const SnackBar(content: Text(
                                                    "You can select up to 3 pending and 3 client canceled orders only.")),
                                              );
                                            }
                                          } else {
                                            selectedOrders.remove(order);

                                            if (selectedOrders.length == 1) {
                                              totalPrice =
                                                  selectedOrders.first.price;
                                              totalDistance =
                                                  ClusteringDBSCANService
                                                      .calculateDistance(
                                                    selectedOrders.first.pickupPlace
                                                        .latitude,
                                                    selectedOrders.first.pickupPlace
                                                        .longitude,
                                                    selectedOrders.first
                                                        .deliveryPlace.latitude,
                                                    selectedOrders.first
                                                        .deliveryPlace.longitude,
                                                  );
                                              pricePerKm = ClusteringDBSCANService
                                                  .calculateOrderPricePerKm(order);
                                              CarTypeModel? carType = CarTypeModel
                                                  .carTypes.firstWhere(
                                                    (type) =>
                                                type.name == selectedOrders.first
                                                    .carTypeName,
                                              );
                                              totalLDM = selectedOrders.first.ldm;
                                              totalWeight =
                                                  selectedOrders.first.weight;
                                              validateLDM =
                                                  selectedOrders.first.ldm <=
                                                      carType.length;
                                              validateWeight =
                                                  selectedOrders.first.weight <=
                                                      carType.maxWeight;

                                              validateDate = true;
                                              validateAdr = true;
                                            }
                                            else if (selectedOrders.length > 1) {
                                              List<int> optimizedGroup = RouteOptimizer
                                                  .optimizeRoute(selectedOrders);
                                              totalDistance =
                                                  ClusteringDBSCANService
                                                      .calculateRouteDistance(
                                                      selectedOrders,
                                                      optimizedGroup);
                                              totalPrice = selectedOrders.fold(
                                                  0, (sum, order) => sum +
                                                  order.price);
                                              pricePerKm =
                                              totalDistance > 0 ? totalPrice /
                                                  totalDistance : 0.0;
                                              totalWeight = selectedOrders.fold(
                                                  0, (sum, order) => sum +
                                                  order.weight);
                                              totalLDM = selectedOrders.fold(
                                                  0, (sum, order) => sum +
                                                  order.ldm);
                                              CarTypeModel carType = CarTypeModel
                                                  .carTypes.firstWhere(
                                                      (type) =>
                                                  type.name == selectedOrders.first
                                                      .carTypeName,
                                                  orElse: () =>
                                                  CarTypeModel.carTypes.first);

                                              validateWeight =
                                                  totalWeight <= carType.maxWeight;
                                              validateLDM =
                                                  totalLDM <= carType.length;
                                              validateDate =
                                                  TimeManager.validateTimeWindows(
                                                      selectedOrders,
                                                      optimizedGroup);
                                              validateAdr = adrValidatorService
                                                  .canGroupOrders(selectedOrders);
                                            } else {
                                              totalDistance = 0;
                                              totalPrice = 0;
                                              pricePerKm = 0;
                                              totalWeight = 0;
                                              totalLDM = 0;
                                              validateWeight = false;
                                              validateLDM = false;
                                              validateDate = false;
                                              validateAdr = false;
                                            }
                                          }
                                        });
                                      });
                                    },
                                  );
                                }),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0, bottom: 8.0, left: 5, right: 10),
                    child: Card(
                      elevation: 2,
                      color: AppColors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        children: [
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Padding(
                              padding: const EdgeInsets.only(top: 8.0, left: 8.0, right: 8.0, bottom: 0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Selected Orders",
                                    style: Theme
                                        .of(context)
                                        .textTheme
                                        .headlineSmall
                                        ?.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                  ElevatedButton(
                                    onPressed: () {
                                      selectedOrders.clear();
                                      widget.group.orders.forEach((orders) {
                                        selectedOrders.add(orders);
                                      });
                                      setState(() {
                                        if (selectedOrders.length == 1) {
                                          totalPrice =
                                              selectedOrders.first.price;
                                          totalDistance =
                                              ClusteringDBSCANService
                                                  .calculateDistance(
                                                selectedOrders.first
                                                    .pickupPlace.latitude,
                                                selectedOrders.first
                                                    .pickupPlace.longitude,
                                                selectedOrders.first
                                                    .deliveryPlace.latitude,
                                                selectedOrders.first
                                                    .deliveryPlace.longitude,
                                              );
                                          pricePerKm = ClusteringDBSCANService.calculateOrderPricePerKm(selectedOrders.first);
                                          CarTypeModel? carType = CarTypeModel
                                              .carTypes.firstWhere(
                                                (type) =>
                                            type.name == selectedOrders.first
                                                .carTypeName,
                                          );
                                          totalLDM = selectedOrders.first.ldm;
                                          totalWeight =
                                              selectedOrders.first.weight;
                                          validateLDM =
                                              selectedOrders.first.ldm <=
                                                  carType.length;
                                          validateWeight =
                                              selectedOrders.first.weight <=
                                                  carType.maxWeight;
                                          validateDate = true;
                                          validateAdr = true;
                                        }
                                        else {
                                          List<int> optimizedGroup = RouteOptimizer
                                              .optimizeRoute(selectedOrders);
                                          totalDistance =
                                              ClusteringDBSCANService
                                                  .calculateRouteDistance(
                                                  selectedOrders,
                                                  optimizedGroup);
                                          totalPrice = selectedOrders.fold(
                                              0, (sum, order) => sum +
                                              order.price);
                                          pricePerKm =
                                          totalDistance > 0 ? totalPrice /
                                              totalDistance : 0.0;
                                          totalWeight = selectedOrders.fold(
                                              0, (sum, order) => sum +
                                              order.weight);
                                          totalLDM = selectedOrders.fold(
                                              0, (sum, order) => sum +
                                              order.ldm);
                                          CarTypeModel carType = CarTypeModel
                                              .carTypes.firstWhere(
                                                (type) =>
                                            type.name == selectedOrders.first
                                                .carTypeName,
                                            orElse: () =>
                                            CarTypeModel.carTypes.first,
                                          );

                                          validateWeight = totalWeight <=
                                              carType.maxWeight;
                                          validateLDM =
                                              totalLDM <= carType.length;
                                          validateDate =
                                              TimeManager.validateTimeWindows(
                                                  selectedOrders,
                                                  optimizedGroup);
                                          validateAdr = adrValidatorService
                                              .canGroupOrders(selectedOrders);
                                        }
                                      });
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.black,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                                    ),
                                    child: Text(
                                      'Reset List',
                                      style: TextStyle(color: Colors.white, fontSize: 16),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Padding(
                              padding: const EdgeInsets.only(top: 8.0, left: 8.0, right: 8.0, bottom: 0),
                              child: Text(
                                "When grouping, details are calculated from first selected order to last. Group detail result will differ by swapping orders.",
                                style: AppTextStyles.subtitle12RobotoRegular.copyWith(fontWeight: FontWeight.bold, color: AppColors.red),
                              ),
                            ),
                          ),
                          const Divider(),
                          Expanded(
                            child: selectedOrders.isEmpty
                                ? const Center(child: Text("No orders selected."))
                                : ReorderableList(
                              onReorder: (int oldIndex, int newIndex) {
                                if (oldIndex < newIndex) {
                                  newIndex -= 1;
                                }
                                final OrderModel item = selectedOrders.removeAt(oldIndex);
                                selectedOrders.insert(newIndex, item);
                                setState(() {
                                  if (selectedOrders.length == 1) {
                                    totalPrice = selectedOrders.first.price;
                                    totalDistance =
                                        ClusteringDBSCANService.calculateDistance(
                                          selectedOrders.first.pickupPlace
                                              .latitude,
                                          selectedOrders.first.pickupPlace
                                              .longitude,
                                          selectedOrders.first.deliveryPlace
                                              .latitude,
                                          selectedOrders.first.deliveryPlace
                                              .longitude,
                                        );
                                    pricePerKm = ClusteringDBSCANService
                                        .calculateOrderPricePerKm(selectedOrders.first);
                                    CarTypeModel? carType = CarTypeModel.carTypes
                                        .firstWhere(
                                          (type) =>
                                      type.name ==
                                          selectedOrders.first.carTypeName,
                                    );
                                    totalLDM = selectedOrders.first.ldm;
                                    totalWeight = selectedOrders.first.weight;
                                    validateLDM = selectedOrders.first.ldm <=
                                        carType.length;
                                    validateWeight =
                                        selectedOrders.first.weight <=
                                            carType.maxWeight;

                                    validateDate = true;
                                    validateAdr = true;
                                  } else if (selectedOrders.length > 1) {
                                    List<int> optimizedGroup = RouteOptimizer
                                        .optimizeRoute(selectedOrders);
                                    totalDistance = ClusteringDBSCANService
                                        .calculateRouteDistance(
                                        selectedOrders, optimizedGroup);
                                    totalPrice = selectedOrders.fold(
                                        0, (sum, order) => sum + order.price);
                                    pricePerKm = totalDistance > 0
                                        ? totalPrice / totalDistance
                                        : 0.0;
                                    totalWeight = selectedOrders.fold(
                                        0, (sum, order) => sum + order.weight);
                                    totalLDM = selectedOrders.fold(
                                        0, (sum, order) => sum + order.ldm);
                                    CarTypeModel carType = CarTypeModel.carTypes
                                        .firstWhere(
                                            (type) =>
                                        type.name ==
                                            selectedOrders.first.carTypeName,
                                        orElse: () =>
                                        CarTypeModel.carTypes.first);

                                    validateWeight =
                                        totalWeight <= carType.maxWeight;
                                    validateLDM = totalLDM <= carType.length;
                                    validateDate =
                                        TimeManager.validateTimeWindows(
                                            selectedOrders, optimizedGroup);
                                    validateAdr =
                                        adrValidatorService.canGroupOrders(
                                            selectedOrders);
                                  } else {
                                    totalDistance = 0;
                                    totalPrice = 0;
                                    pricePerKm = 0;
                                    totalWeight = 0;
                                    totalLDM = 0;
                                    validateWeight = false;
                                    validateLDM = false;
                                    validateDate = false;
                                    validateAdr = false;
                                  }
                                });
                              },
                              itemCount: selectedOrders.length,
                              itemBuilder: (context, index) {
                                final order = selectedOrders[index];
                                return UpdateSelectedOrderCard(index: index, order: order, key: Key('$index'), onRemove: () {
                                  if(widget.group.orders.any((data) => data.orderID == order.orderID)) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                            'Can\'t delete this order'),
                                      ),
                                    );
                                    return;
                                  }
                                  setState(() {
                                    selectedOrders.remove(order);

                                    if (selectedOrders.length == 1) {
                                      totalPrice = selectedOrders.first.price;
                                      totalDistance =
                                          ClusteringDBSCANService.calculateDistance(
                                            selectedOrders.first.pickupPlace
                                                .latitude,
                                            selectedOrders.first.pickupPlace
                                                .longitude,
                                            selectedOrders.first.deliveryPlace
                                                .latitude,
                                            selectedOrders.first.deliveryPlace
                                                .longitude,
                                          );
                                      pricePerKm = ClusteringDBSCANService
                                          .calculateOrderPricePerKm(order);
                                      CarTypeModel? carType = CarTypeModel.carTypes
                                          .firstWhere(
                                            (type) =>
                                        type.name ==
                                            selectedOrders.first.carTypeName,
                                      );
                                      totalLDM = selectedOrders.first.ldm;
                                      totalWeight = selectedOrders.first.weight;
                                      validateLDM = selectedOrders.first.ldm <=
                                          carType.length;
                                      validateWeight =
                                          selectedOrders.first.weight <=
                                              carType.maxWeight;

                                      validateDate = true;
                                      validateAdr = true;
                                    } else if (selectedOrders.length > 1) {
                                      List<int> optimizedGroup = RouteOptimizer
                                          .optimizeRoute(selectedOrders);
                                      totalDistance = ClusteringDBSCANService
                                          .calculateRouteDistance(
                                          selectedOrders, optimizedGroup);
                                      totalPrice = selectedOrders.fold(
                                          0, (sum, order) => sum + order.price);
                                      pricePerKm = totalDistance > 0
                                          ? totalPrice / totalDistance
                                          : 0.0;
                                      totalWeight = selectedOrders.fold(
                                          0, (sum, order) => sum + order.weight);
                                      totalLDM = selectedOrders.fold(
                                          0, (sum, order) => sum + order.ldm);
                                      CarTypeModel carType = CarTypeModel.carTypes
                                          .firstWhere(
                                              (type) =>
                                          type.name ==
                                              selectedOrders.first.carTypeName,
                                          orElse: () =>
                                          CarTypeModel.carTypes.first);

                                      validateWeight =
                                          totalWeight <= carType.maxWeight;
                                      validateLDM = totalLDM <= carType.length;
                                      validateDate =
                                          TimeManager.validateTimeWindows(
                                              selectedOrders, optimizedGroup);
                                      validateAdr =
                                          adrValidatorService.canGroupOrders(
                                              selectedOrders);
                                    } else {
                                      totalDistance = 0;
                                      totalPrice = 0;
                                      pricePerKm = 0;
                                      totalWeight = 0;
                                      totalLDM = 0;
                                      validateWeight = false;
                                      validateLDM = false;
                                      validateDate = false;
                                      validateAdr = false;
                                    }
                                  });
                                });
                              },
                            ),
                          ),
                          const Divider(),
                          // Calculated Data
                          selectedOrders.isNotEmpty
                              ? UpdateGroupSummary(
                            totalDistance: totalDistance,
                            totalPrice: totalPrice,
                            pricePerKm: pricePerKm,
                            totalWeight: totalWeight,
                            totalLDM: totalLDM,
                            validateWeight: validateWeight,
                            validateLDM: validateLDM,
                            validateDate: validateDate,
                            validateAdr: validateAdr,
                            onConfirm: () async{
                              var result = await context.read<UserProfileCubit>().checkIfUserProfileActive(context);
                              if(result) {
                                final user = context.read<UserProfileCubit>().state as UserProfileLoaded;
                                var isTeamLead = user.user.userRole == UserRoles.allRoles[1] || user.user.userRole == UserRoles.user;
                                if (isTeamLead == false) {
                                  showTopSnackbarInfo(
                                      context, 'You do not have access');
                                  return;
                                } else {
                                  _updateOrder(context, widget.group);
                                }
                              } else {
                                showErrorNotification(context, 'Sorry action your connection is lost');
                                return;
                              }
                            },
                          ): SizedBox(),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            )
          ],
        ): Row(
          children: [
            // Left Panel: Order Selection
            Expanded(
              flex: 1,
              child: Padding(
                padding: const EdgeInsets.only(top: 8.0, bottom: 8.0, left: 10, right: 5),
                child: Card(
                  elevation: 2,
                  color: AppColors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      // Search Bar
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 10),
                        child: TextField(
                          controller: _searchController,
                          onChanged: (value) {
                            _debouncer.call(() {
                              setState(() {

                              });
                            });
                          },
                          decoration: InputDecoration(
                            hintText: "Search",
                            labelStyle: AppTextStyles.head20RobotoRegular,
                            fillColor: Theme.of(context).colorScheme.surfaceVariant,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            prefixIcon: const Icon(Icons.search, color: Colors.black54),
                            filled: true,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Order List
                      Expanded(
                        child: StreamBuilder<QuerySnapshot>(
                            stream: getFilteredQuery(),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const Center(
                                    child: CircularProgressIndicator());
                              } else if (snapshot.hasError) {
                                return Center(
                                    child: Text('Error: ${snapshot.error}'));
                              } else if (!snapshot.hasData ||
                                  snapshot.data!.docs.isEmpty) {
                                return const Center(
                                    child: Text("No orders"));
                              }

                              List<OrderModel> orders = snapshot.data!.docs.map((doc) {
                                final data = doc.data() as Map<String, dynamic>;
                                return OrderModel.fromJson(
                                    data); // Ensure OrderModel has a `fromMap` method
                              }).toList();
                              print(orders.length);

                              // **🔹 Sort orders by createdAt (latest first)**
                              orders.sort((a, b) {
                                final createdAtA = DateTime.parse(a.createdAt.toString());
                                final createdAtB = DateTime.parse(b.createdAt.toString());
                                return createdAtB.compareTo(createdAtA); // Descending order (latest first)
                              });

                              return ListView.builder(
                                itemCount: orders.length,
                                itemBuilder: (context, index) {
                                  final order = orders[index];
                                  final isSelected = selectedOrders.any((data) => data.orderID == order.orderID);

                                  return UpdateOrderCard(order: order, isSelected: isSelected, onTap: () {
                                    setState(() {
                                      bool isClientCanceled = order.status ==
                                          OrderStatus.ClientCanceled;
                                      int pendingCount = selectedOrders
                                          .where((o) =>
                                      o.status != OrderStatus.ClientCanceled)
                                          .length;
                                      int clientCanceledCount = selectedOrders
                                          .where((o) =>
                                      o.status == OrderStatus.ClientCanceled)
                                          .length;

                                      if (!isSelected == true) {
                                        if ((isClientCanceled &&
                                            clientCanceledCount < 3) ||
                                            (!isClientCanceled &&
                                                pendingCount < 6)) {
                                          var newOrder = order.copyWith(
                                              status: OrderStatus.Confirmed,
                                              driverInfo: widget.group.driverInfo,
                                          );
                                          selectedOrders.add(newOrder);

                                          if (selectedOrders.length == 1) {
                                            totalPrice =
                                                selectedOrders.first.price;
                                            totalDistance =
                                                ClusteringDBSCANService
                                                    .calculateDistance(
                                                  selectedOrders.first
                                                      .pickupPlace.latitude,
                                                  selectedOrders.first
                                                      .pickupPlace.longitude,
                                                  selectedOrders.first
                                                      .deliveryPlace.latitude,
                                                  selectedOrders.first
                                                      .deliveryPlace.longitude,
                                                );
                                            pricePerKm = ClusteringDBSCANService
                                                .calculateOrderPricePerKm(
                                                order);
                                            CarTypeModel? carType = CarTypeModel
                                                .carTypes.firstWhere(
                                                  (type) =>
                                              type.name == selectedOrders.first
                                                  .carTypeName,
                                            );
                                            totalLDM = selectedOrders.first.ldm;
                                            totalWeight =
                                                selectedOrders.first.weight;
                                            validateLDM =
                                                selectedOrders.first.ldm <=
                                                    carType.length;
                                            validateWeight =
                                                selectedOrders.first.weight <=
                                                    carType.maxWeight;
                                            validateDate = true;
                                            validateAdr = true;
                                          } else {
                                            List<
                                                int> optimizedGroup = RouteOptimizer
                                                .optimizeRoute(selectedOrders);
                                            totalDistance =
                                                ClusteringDBSCANService
                                                    .calculateRouteDistance(
                                                    selectedOrders,
                                                    optimizedGroup);
                                            totalPrice = selectedOrders.fold(
                                                0, (sum, order) => sum +
                                                order.price);
                                            pricePerKm =
                                            totalDistance > 0 ? totalPrice /
                                                totalDistance : 0.0;
                                            totalWeight = selectedOrders.fold(
                                                0, (sum, order) => sum +
                                                order.weight);
                                            totalLDM = selectedOrders.fold(
                                                0, (sum, order) => sum +
                                                order.ldm);
                                            CarTypeModel carType = CarTypeModel
                                                .carTypes.firstWhere(
                                                  (type) =>
                                              type.name == selectedOrders.first
                                                  .carTypeName,
                                              orElse: () =>
                                              CarTypeModel.carTypes.first,
                                            );

                                            validateWeight = totalWeight <=
                                                carType.maxWeight;
                                            validateLDM =
                                                totalLDM <= carType.length;
                                            validateDate =
                                                TimeManager.validateTimeWindows(
                                                    selectedOrders,
                                                    optimizedGroup);
                                            validateAdr = adrValidatorService
                                                .canGroupOrders(selectedOrders);
                                          }
                                        } else {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(content: Text(
                                                "You can select up to 3 pending and 3 client canceled orders only.")),
                                          );
                                        }
                                      } else {
                                        selectedOrders.remove(order);

                                        if (selectedOrders.length == 1) {
                                          totalPrice =
                                              selectedOrders.first.price;
                                          totalDistance =
                                              ClusteringDBSCANService
                                                  .calculateDistance(
                                                selectedOrders.first.pickupPlace
                                                    .latitude,
                                                selectedOrders.first.pickupPlace
                                                    .longitude,
                                                selectedOrders.first
                                                    .deliveryPlace.latitude,
                                                selectedOrders.first
                                                    .deliveryPlace.longitude,
                                              );
                                          pricePerKm = ClusteringDBSCANService
                                              .calculateOrderPricePerKm(order);
                                          CarTypeModel? carType = CarTypeModel
                                              .carTypes.firstWhere(
                                                (type) =>
                                            type.name == selectedOrders.first
                                                .carTypeName,
                                          );
                                          totalLDM = selectedOrders.first.ldm;
                                          totalWeight =
                                              selectedOrders.first.weight;
                                          validateLDM =
                                              selectedOrders.first.ldm <=
                                                  carType.length;
                                          validateWeight =
                                              selectedOrders.first.weight <=
                                                  carType.maxWeight;

                                          validateDate = true;
                                          validateAdr = true;
                                        } else if (selectedOrders.length > 1) {
                                          List<
                                              int> optimizedGroup = RouteOptimizer
                                              .optimizeRoute(selectedOrders);
                                          totalDistance =
                                              ClusteringDBSCANService
                                                  .calculateRouteDistance(
                                                  selectedOrders,
                                                  optimizedGroup);
                                          totalPrice = selectedOrders.fold(
                                              0, (sum, order) => sum +
                                              order.price);
                                          pricePerKm =
                                          totalDistance > 0 ? totalPrice /
                                              totalDistance : 0.0;
                                          totalWeight = selectedOrders.fold(
                                              0, (sum, order) => sum +
                                              order.weight);
                                          totalLDM = selectedOrders.fold(
                                              0, (sum, order) => sum +
                                              order.ldm);
                                          CarTypeModel carType = CarTypeModel
                                              .carTypes.firstWhere(
                                                  (type) =>
                                              type.name == selectedOrders.first
                                                  .carTypeName,
                                              orElse: () =>
                                              CarTypeModel.carTypes.first);

                                          validateWeight =
                                              totalWeight <= carType.maxWeight;
                                          validateLDM =
                                              totalLDM <= carType.length;
                                          validateDate =
                                              TimeManager.validateTimeWindows(
                                                  selectedOrders,
                                                  optimizedGroup);
                                          validateAdr = adrValidatorService
                                              .canGroupOrders(selectedOrders);
                                        } else {
                                          totalDistance = 0;
                                          totalPrice = 0;
                                          pricePerKm = 0;
                                          totalWeight = 0;
                                          totalLDM = 0;
                                          validateWeight = false;
                                          validateLDM = false;
                                          validateDate = false;
                                          validateAdr = false;
                                        }
                                      }
                                    });
                                  });
                                },
                              );
                            }),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Right Panel: Selected Orders
            Expanded(
              flex: 1,
              child: Padding(
                padding: const EdgeInsets.only(top: 8.0, bottom: 8.0, left: 5, right: 10),
                child: Card(
                  elevation: 2,
                  color: AppColors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0, left: 8.0, right: 8.0, bottom: 0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Selected Orders",
                              style: Theme
                                  .of(context)
                                  .textTheme
                                  .headlineSmall
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                selectedOrders.clear();
                                widget.group.orders.forEach((orders) {
                                  selectedOrders.add(orders);
                                });
                                setState(() {
                                  if (selectedOrders.length == 1) {
                                    totalPrice =
                                        selectedOrders.first.price;
                                    totalDistance =
                                        ClusteringDBSCANService
                                            .calculateDistance(
                                          selectedOrders.first
                                              .pickupPlace.latitude,
                                          selectedOrders.first
                                              .pickupPlace.longitude,
                                          selectedOrders.first
                                              .deliveryPlace.latitude,
                                          selectedOrders.first
                                              .deliveryPlace.longitude,
                                        );
                                    pricePerKm = ClusteringDBSCANService.calculateOrderPricePerKm(selectedOrders.first);
                                    CarTypeModel? carType = CarTypeModel
                                        .carTypes.firstWhere(
                                          (type) =>
                                      type.name == selectedOrders.first
                                          .carTypeName,
                                    );
                                    totalLDM = selectedOrders.first.ldm;
                                    totalWeight =
                                        selectedOrders.first.weight;
                                    validateLDM =
                                        selectedOrders.first.ldm <=
                                            carType.length;
                                    validateWeight =
                                        selectedOrders.first.weight <=
                                            carType.maxWeight;
                                    validateDate = true;
                                    validateAdr = true;
                                  }
                                  else {
                                    List<int> optimizedGroup = RouteOptimizer
                                        .optimizeRoute(selectedOrders);
                                    totalDistance =
                                        ClusteringDBSCANService
                                            .calculateRouteDistance(
                                            selectedOrders,
                                            optimizedGroup);
                                    totalPrice = selectedOrders.fold(
                                        0, (sum, order) => sum +
                                        order.price);
                                    pricePerKm =
                                    totalDistance > 0 ? totalPrice /
                                        totalDistance : 0.0;
                                    totalWeight = selectedOrders.fold(
                                        0, (sum, order) => sum +
                                        order.weight);
                                    totalLDM = selectedOrders.fold(
                                        0, (sum, order) => sum +
                                        order.ldm);
                                    CarTypeModel carType = CarTypeModel
                                        .carTypes.firstWhere(
                                          (type) =>
                                      type.name == selectedOrders.first
                                          .carTypeName,
                                      orElse: () =>
                                      CarTypeModel.carTypes.first,
                                    );

                                    validateWeight = totalWeight <=
                                        carType.maxWeight;
                                    validateLDM =
                                        totalLDM <= carType.length;
                                    validateDate =
                                        TimeManager.validateTimeWindows(
                                            selectedOrders,
                                            optimizedGroup);
                                    validateAdr = adrValidatorService
                                        .canGroupOrders(selectedOrders);
                                  }
                                });
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.black,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                              ),
                              child: Text(
                                'Reset List',
                                style: TextStyle(color: Colors.white, fontSize: 16),
                              ),
                            )
                          ],
                        ),
                      ),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 8.0, left: 8.0, right: 8.0, bottom: 0),
                          child: Text(
                            "When grouping, details are calculated from first selected order to last. Group detail result will differ by swapping orders.",
                            style: AppTextStyles.subtitle12RobotoRegular.copyWith(fontWeight: FontWeight.bold, color: AppColors.red),
                          ),
                        ),
                      ),
                      const Divider(),
                      Expanded(
                        child: selectedOrders.isEmpty
                            ? const Center(child: Text("No orders selected."))
                            : ReorderableList(
                          onReorder: (int oldIndex, int newIndex) {
                            if (oldIndex < newIndex) {
                              newIndex -= 1;
                            }
                            final OrderModel item = selectedOrders.removeAt(oldIndex);
                            selectedOrders.insert(newIndex, item);
                            setState(() {
                              if (selectedOrders.length == 1) {
                                totalPrice = selectedOrders.first.price;
                                totalDistance =
                                    ClusteringDBSCANService.calculateDistance(
                                      selectedOrders.first.pickupPlace
                                          .latitude,
                                      selectedOrders.first.pickupPlace
                                          .longitude,
                                      selectedOrders.first.deliveryPlace
                                          .latitude,
                                      selectedOrders.first.deliveryPlace
                                          .longitude,
                                    );
                                pricePerKm = ClusteringDBSCANService
                                    .calculateOrderPricePerKm(selectedOrders.first);
                                CarTypeModel? carType = CarTypeModel.carTypes
                                    .firstWhere(
                                      (type) =>
                                  type.name ==
                                      selectedOrders.first.carTypeName,
                                );
                                totalLDM = selectedOrders.first.ldm;
                                totalWeight = selectedOrders.first.weight;
                                validateLDM = selectedOrders.first.ldm <=
                                    carType.length;
                                validateWeight =
                                    selectedOrders.first.weight <=
                                        carType.maxWeight;

                                validateDate = true;
                                validateAdr = true;
                              } else if (selectedOrders.length > 1) {
                                List<int> optimizedGroup = RouteOptimizer
                                    .optimizeRoute(selectedOrders);
                                totalDistance = ClusteringDBSCANService
                                    .calculateRouteDistance(
                                    selectedOrders, optimizedGroup);
                                totalPrice = selectedOrders.fold(
                                    0, (sum, order) => sum + order.price);
                                pricePerKm = totalDistance > 0
                                    ? totalPrice / totalDistance
                                    : 0.0;
                                totalWeight = selectedOrders.fold(
                                    0, (sum, order) => sum + order.weight);
                                totalLDM = selectedOrders.fold(
                                    0, (sum, order) => sum + order.ldm);
                                CarTypeModel carType = CarTypeModel.carTypes
                                    .firstWhere(
                                        (type) =>
                                    type.name ==
                                        selectedOrders.first.carTypeName,
                                    orElse: () =>
                                    CarTypeModel.carTypes.first);

                                validateWeight =
                                    totalWeight <= carType.maxWeight;
                                validateLDM = totalLDM <= carType.length;
                                validateDate =
                                    TimeManager.validateTimeWindows(
                                        selectedOrders, optimizedGroup);
                                validateAdr =
                                    adrValidatorService.canGroupOrders(
                                        selectedOrders);
                              } else {
                                totalDistance = 0;
                                totalPrice = 0;
                                pricePerKm = 0;
                                totalWeight = 0;
                                totalLDM = 0;
                                validateWeight = false;
                                validateLDM = false;
                                validateDate = false;
                                validateAdr = false;
                              }
                            });
                          },
                          itemCount: selectedOrders.length,
                          itemBuilder: (context, index) {
                            final order = selectedOrders[index];
                            return UpdateSelectedOrderCard(index: index, order: order, key: Key('$index'), onRemove: () {
                              if(selectedOrders.length < 2) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                        'Can\'t delete this order'),
                                  ),
                                );
                                return;
                              }
                              setState(() {
                                selectedOrders.remove(order);

                                if (selectedOrders.length == 1) {
                                  totalPrice = selectedOrders.first.price;
                                  totalDistance =
                                      ClusteringDBSCANService.calculateDistance(
                                        selectedOrders.first.pickupPlace
                                            .latitude,
                                        selectedOrders.first.pickupPlace
                                            .longitude,
                                        selectedOrders.first.deliveryPlace
                                            .latitude,
                                        selectedOrders.first.deliveryPlace
                                            .longitude,
                                      );
                                  pricePerKm = ClusteringDBSCANService
                                      .calculateOrderPricePerKm(order);
                                  CarTypeModel? carType = CarTypeModel.carTypes
                                      .firstWhere(
                                        (type) =>
                                    type.name ==
                                        selectedOrders.first.carTypeName,
                                  );
                                  totalLDM = selectedOrders.first.ldm;
                                  totalWeight = selectedOrders.first.weight;
                                  validateLDM = selectedOrders.first.ldm <=
                                      carType.length;
                                  validateWeight =
                                      selectedOrders.first.weight <=
                                          carType.maxWeight;

                                  validateDate = true;
                                  validateAdr = true;
                                } else if (selectedOrders.length > 1) {
                                  List<int> optimizedGroup = RouteOptimizer
                                      .optimizeRoute(selectedOrders);
                                  totalDistance = ClusteringDBSCANService
                                      .calculateRouteDistance(
                                      selectedOrders, optimizedGroup);
                                  totalPrice = selectedOrders.fold(
                                      0, (sum, order) => sum + order.price);
                                  pricePerKm = totalDistance > 0
                                      ? totalPrice / totalDistance
                                      : 0.0;
                                  totalWeight = selectedOrders.fold(
                                      0, (sum, order) => sum + order.weight);
                                  totalLDM = selectedOrders.fold(
                                      0, (sum, order) => sum + order.ldm);
                                  CarTypeModel carType = CarTypeModel.carTypes
                                      .firstWhere(
                                          (type) =>
                                      type.name ==
                                          selectedOrders.first.carTypeName,
                                      orElse: () =>
                                      CarTypeModel.carTypes.first);

                                  validateWeight =
                                      totalWeight <= carType.maxWeight;
                                  validateLDM = totalLDM <= carType.length;
                                  validateDate =
                                      TimeManager.validateTimeWindows(
                                          selectedOrders, optimizedGroup);
                                  validateAdr =
                                      adrValidatorService.canGroupOrders(
                                          selectedOrders);
                                } else {
                                  totalDistance = 0;
                                  totalPrice = 0;
                                  pricePerKm = 0;
                                  totalWeight = 0;
                                  totalLDM = 0;
                                  validateWeight = false;
                                  validateLDM = false;
                                  validateDate = false;
                                  validateAdr = false;
                                }
                              });
                            });
                          },
                        ),
                      ),
                      const Divider(),
                      // Calculated Data
                      selectedOrders.isNotEmpty
                          ? UpdateGroupSummary(
                        totalDistance: totalDistance,
                        totalPrice: totalPrice,
                        pricePerKm: pricePerKm,
                        totalWeight: totalWeight,
                        totalLDM: totalLDM,
                        validateWeight: validateWeight,
                        validateLDM: validateLDM,
                        validateDate: validateDate,
                        validateAdr: validateAdr,
                        onConfirm: () {
                          var isTeamLead = context
                              .read<UserProfileCubit>()
                              .state is UserProfileLoaded ? (context
                              .read<UserProfileCubit>()
                              .state as UserProfileLoaded).user.userRole ==
                              UserRoles.allRoles[1] : false;
                          if (isTeamLead == false) {
                            showTopSnackbarInfo(
                                context, 'You do not have access');
                            return;
                          } else {
                            _updateOrder(context, widget.group);
                          }
                        },
                      ): SizedBox(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class UpdateOrderCard extends StatelessWidget {
  final OrderModel order;
  final bool isSelected;
  final VoidCallback onTap;

  UpdateOrderCard({required this.order, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isSelected? AppColors.black: Colors.grey.shade300),
      ),
      padding: EdgeInsets.all(12),
      margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.all(12.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Order ID: ${order.orderID}',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      Text(
                        'Creator: ${order.creatorName}',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 4.0, horizontal: 8.0),
                    decoration: BoxDecoration(
                      color: _getStatusColor(order.status),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      order.status.name,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
              Divider(),
              SizedBox(height: 8.0),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Left Column (Order Details)
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Route:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'Pickup: ${order.pickupPlace.countryCode}, ${order.pickupPlace.postalCode}, ${order.pickupPlace.name} → Delivery: ${order.deliveryPlace.countryCode}, ${order.deliveryPlace.postalCode}, ${order.deliveryPlace.name}',
                          style: TextStyle(color: Colors.grey[700]),
                        ),
                        SizedBox(height: 8.0),
                        Text(
                          'Customer:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          order.orderName,
                          style: TextStyle(color: Colors.grey[700]),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  // Right Column (Customer and Schedule)
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Details:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'LDM: ${order.ldm}, Wight: ${order.weight.toStringAsFixed(1)} tons',
                          style: TextStyle(color: Colors.grey[700]),
                        ),
                        SizedBox(height: 8.0),
                        Text(
                          'Price:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '€${order.price.toStringAsFixed(2)}',
                          style: TextStyle(color: Colors.grey[700]),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.Pending:
        return Colors.orange;
      case OrderStatus.Confirmed:
        return Colors.blue;
      case OrderStatus.Assigned:
        return Colors.teal;
      case OrderStatus.OnTheWay:
        return Colors.amber;
      case OrderStatus.Complete:
        return Colors.green;
      case OrderStatus.Canceled:
        return Colors.red;
      case OrderStatus.ClientCanceled:
        return Colors.redAccent;
      case OrderStatus.Loaded:
        return Colors.orange;
      case OrderStatus.Unloaded:
        return Colors.brown;
      case OrderStatus.Problematic:
        return Colors.deepOrange;
      default:
        return Colors.grey;
    }
  }

  // Helper list for month names (since DateTime.month returns 1-12)
  static const List<String> monthNames = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
  ];
}

class UpdateSelectedOrderCard extends StatelessWidget {
  final int index;
  final OrderModel order;
  final VoidCallback onRemove;
  Key key;

  UpdateSelectedOrderCard({required this.index, required this.order, required this.key, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Container(
      key: key,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      padding: EdgeInsets.all(12),
      margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    '${index + 1}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Order ID: ${order.orderID}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: 8.0),
                      Text(
                        'Pickup: ${order.pickupPlace.name} → Delivery: ${order.deliveryPlace.name}',
                        style: TextStyle(
                          color: Colors.blueGrey[700], // Matches the blue-grey text in the image
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.close, color: Colors.red, size: 24),
            onPressed: onRemove,
            padding: EdgeInsets.zero, // Remove padding for a tighter fit
          ),
          ReorderableDragStartListener(
            index: index,
            child: Icon(Icons.drag_handle, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}

class UpdateGroupSummary extends StatelessWidget {
  final double totalDistance;
  final double totalPrice;
  final double pricePerKm;
  final double totalWeight;
  final double totalLDM;
  final bool validateWeight;
  final bool validateLDM;
  final bool validateDate;
  final bool validateAdr;
  final VoidCallback onConfirm;

  UpdateGroupSummary({
    required this.totalDistance,
    required this.totalPrice,
    required this.pricePerKm,
    required this.totalWeight,
    required this.totalLDM,
    required this.validateWeight,
    required this.validateLDM,
    required this.validateDate,
    required this.validateAdr,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Group Summary',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
          ),
          SizedBox(height: 16.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Total Distance', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
                    Text('${totalDistance.toStringAsFixed(2)} km', style: TextStyle(color: Colors.grey[700])),
                    SizedBox(height: 8.0),
                    Text('Price per Km', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
                    Text('€${pricePerKm.toStringAsFixed(2)}', style: TextStyle(color: Colors.grey[700])),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Total Price', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
                    Text('€${totalPrice.toStringAsFixed(2)}', style: TextStyle(color: Colors.grey[700])),
                    SizedBox(height: 8.0),
                    Text('Total Weight', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
                    Text('${totalWeight.toStringAsFixed(2)} tons', style: TextStyle(color: Colors.grey[700])),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 16.0),
          Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildValidationRow(Icons.scale, 'Valid Weight:', validateWeight),
                      _buildValidationRow(Icons.local_shipping, 'Valid LDM:', validateLDM),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildValidationRow(Icons.security, 'Valid ADR:', validateAdr),
                      _buildValidationRow(Icons.calendar_today, 'Valid Dates:', validateDate),
                    ],
                  ),
                ),
              ]
          ),
          SizedBox(height: 16.0),
          BlocConsumer<GroupOrderListCubit,
              GroupOrderListState>(
              listener: (context, state) {
                if (state is GroupOrderListActionSuccess) {
                  context.pop(true);
                  showTopSnackbarInfo(
                      context, 'Group Order Updated');
                }
              },
              builder: (context, state) {
                var isLoading = state is GroupOrderListActionLoading;
                return isLoading
                    ? const CircularProgressIndicator()
                    : ElevatedButton(
                  onPressed: onConfirm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    minimumSize: Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                  ),
                  child: Text(
                    'Update Group',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                );
              }),
        ],
      ),
    );
  }

  Widget _buildValidationRow(IconData icon, String label, bool isValid) {
    return Row(
      children: [
        Icon(icon, color: Colors.grey[500], size: 20),
        SizedBox(width: 8.0),
        Text(
          label,
          style: TextStyle(color: Colors.grey[700], fontSize: 14),
        ),
        SizedBox(width: 8.0),
        Icon(
          isValid ? Icons.check_circle : Icons.cancel,
          color: isValid ? Colors.green : Colors.red,
          size: 20,
        ),
      ],
    );
  }
}