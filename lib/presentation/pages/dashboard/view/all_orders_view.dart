import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get_rx/src/rx_workers/utils/debouncer.dart';
import 'package:go_router/go_router.dart';
import 'package:hegelmann_order_automation/config/app_colors.dart';
import 'package:hegelmann_order_automation/config/app_text_styles.dart';
import 'package:hegelmann_order_automation/config/constants.dart';
import 'package:hegelmann_order_automation/config/screen_size.dart';
import 'package:hegelmann_order_automation/domain/models/order_model.dart';
import 'package:hegelmann_order_automation/presentation/manager/order_list/order_list_cubit.dart';
import 'package:hegelmann_order_automation/presentation/manager/user_profile_cubit/user_profile_cubit.dart';
import 'package:hegelmann_order_automation/presentation/pages/dashboard/components/create_order_dialog.dart';
import 'package:hegelmann_order_automation/presentation/pages/dashboard/components/edit_order_dialog.dart';
import 'package:hegelmann_order_automation/presentation/pages/dashboard/components/order_details_dialog_components.dart';
import 'package:hegelmann_order_automation/presentation/pages/dashboard/components/order_filter.dart';
import 'package:hegelmann_order_automation/presentation/widgets/clock.dart';
import 'package:hegelmann_order_automation/presentation/widgets/notifications/error_notification.dart';
import 'package:hegelmann_order_automation/presentation/widgets/notifications/top_snackbar_info.dart';
import 'package:intl/intl.dart';

class AllOrdersListView extends StatefulWidget {
  const AllOrdersListView({Key? key}) : super(key: key);

  @override
  State<AllOrdersListView> createState() => _AllOrdersListViewState();
}

class _AllOrdersListViewState extends State<AllOrdersListView>
    with SingleTickerProviderStateMixin {

  ResponsiveScreenSize responsiveScreenSize = ResponsiveScreenSize();
  final Debouncer _debouncer = Debouncer(delay: Duration(milliseconds: 500));

  final TextEditingController _searchController = TextEditingController();
  ScrollController _horizontalScrollController = ScrollController();
  ScrollController _verticalScrollController = ScrollController();

  bool _onlyMyOrders = false; // Add this as a state variable

  // Store selected order IDs
  final Set<String> _selectedOrders = {};

  String? fromCountry;
  String? toCountry;
  DateTime? startDate;
  DateTime? endDate;
  String selectedStatus = OrderStatus.Pending.name;

  final List<OrderStatus> statuses = OrderStatus.values; // List of all statuses

  @override
  void initState() {
    super.initState();
    context.read<OrderListCubit>().tabController =
        TabController(length: statuses.length, vsync: this);
    selectedStatus = statuses[context.read<OrderListCubit>().tabController.index].name;
    context.read<OrderListCubit>().tabController.addListener(_handleTabChange);
  }

  void _clearFilters() {
    setState(() {
      fromCountry = null;
      toCountry = null;
      startDate = null;
      endDate = null;
    });
  }

  void _handleTabChange() {
    if (!context.read<OrderListCubit>().tabController.indexIsChanging) {
      selectedStatus = statuses[context.read<OrderListCubit>().tabController.index].name;
      setState(() {

      });
      // context.read<OrderListCubit>().filterByStatus(selectedStatus);
    }
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getFilteredQuery() {
    Query<Map<String, dynamic>> query =
    FirebaseFirestore.instance.collection('orders');

    // final selectedStatus = statuses[context.read<OrderListCubit>().tabController.index];
    if(_onlyMyOrders) {
      query = query.where('creatorID', isEqualTo: (context.read<UserProfileCubit>().state as UserProfileLoaded).user.userID);
    }
    query = query.where('status', isEqualTo: selectedStatus);
    debugPrint('🔹 Status Filter: ${selectedStatus}');

    if (fromCountry != null) {
      if (_searchController.text.isEmpty && (startDate != null || endDate != null)) {
        query = query
            .where('pickupPlace.countryCode', isEqualTo: fromCountry)
            .orderBy('pickupPlace.countryCode');
        debugPrint('🔹 From Country (Ordered): $fromCountry');
      } else {
        query = query.where('pickupPlace.countryCode', isEqualTo: fromCountry);
        debugPrint('🔹 From Country: $fromCountry');
      }
    }

    if (toCountry != null) {
      if (_searchController.text.isEmpty && (startDate != null || endDate != null)) {
        query = query
            .where('deliveryPlace.countryCode', isEqualTo: toCountry)
            .orderBy('deliveryPlace.countryCode');
        debugPrint('🔹 To Country (Ordered): $toCountry');
      } else {
        query = query.where('deliveryPlace.countryCode', isEqualTo: toCountry);
        debugPrint('🔹 To Country: $toCountry');
      }
    }

    if (_searchController.text.isNotEmpty) {
      query = query.orderBy('orderName').startAt([
        _searchController.text.toUpperCase(),
      ]).endAt([
        '${_searchController.text.toUpperCase()}\uf8ff',
      ]);
      debugPrint('🔹 Search Query: ${_searchController.text.toUpperCase()}');
    }

    if (startDate != null && endDate != null) {
      if (_searchController.text.isNotEmpty) {
        query = query.where('pickupTimeWindow.start',
            isGreaterThanOrEqualTo: startDate.toString());
        debugPrint('🔹 Start Date Filter: ${startDate.toString()}');
      } else {
        query = query
            .where('pickupTimeWindow.start',
            isGreaterThanOrEqualTo: startDate.toString())
            .where('pickupTimeWindow.end',
            isLessThanOrEqualTo: endDate.toString())
            .orderBy('pickupTimeWindow.start')
            .orderBy('pickupTimeWindow.end');
        debugPrint(
            '🔹 Date Range: ${startDate.toString()} - ${endDate.toString()}');
      }
    } else {
      if (startDate != null && endDate == null) {
        query = query.where('pickupTimeWindow.start',
            isGreaterThanOrEqualTo: startDate.toString());
        debugPrint('🔹 Start Date Filter: ${startDate.toString()}');
      } else if (endDate != null && startDate == null) {
        query = query.where('pickupTimeWindow.end',
            isLessThanOrEqualTo: endDate.toString());
        debugPrint('🔹 End Date Filter: ${endDate.toString()}');
      }
    }

    if (_searchController.text.isEmpty && startDate == null && endDate == null) {
      query = query.orderBy('createdAt', descending: true);
      debugPrint('🔹 Ordering by createdAt (descending)');
    }

    debugPrint('✅ FINAL QUERY BUILT ✅');
    return query.snapshots();
  }

  @override
  Widget build(BuildContext context) {
    print('width ${MediaQuery.sizeOf(context).width}');
    print('height ${MediaQuery.sizeOf(context).height}');
    // width 1512
    // height 857 when full screen on mac
    return LayoutBuilder(builder: (context, constraints) {
      if (responsiveScreenSize.isDesktopScreen(context)) {
        return Scaffold(
          backgroundColor: AppColors.lightGray,
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTopRow(),
              const SizedBox(height: 12),
              _buildSearchRow(),
              const SizedBox(height: 12),
              _buildShipmentInfoRow(responsiveScreenSize.isTabletScreen(context) || responsiveScreenSize.isMobileScreen(context)),
              const SizedBox(height: 12),
              _selectedFilters(),
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
                        print('Empty');
                        return _buildOrderTable([], true);
                      }

                      List<OrderModel> orders = snapshot.data!.docs.map((doc) {
                        final data = doc.data() as Map<String, dynamic>;
                        return OrderModel.fromJson(
                            data); // Ensure OrderModel has a `fromMap` method
                      }).toList();
                      print(orders.length);

                      // Apply endDate filter manually in UI if search is active**
                      if (startDate != null && endDate != null && _searchController.text.isNotEmpty) {
                        orders = orders.where((order) {
                          final orderEndDate = DateTime.parse(order.pickupTimeWindow.end.toString()); // Ensure it's parsed correctly
                          return orderEndDate.isBefore(endDate!);
                        }).toList();
                        print(orders.length);
                      }

                      // **🔹 Sort orders by createdAt (latest first)**
                      orders.sort((a, b) {
                        final createdAtA = DateTime.parse(a.createdAt.toString());
                        final createdAtB = DateTime.parse(b.createdAt.toString());
                        return createdAtB.compareTo(createdAtA); // Descending order (latest first)
                      });

                      return _buildOrderTable(orders, true);
                    }),
              )
            ],
          ),
        );
      } else if (responsiveScreenSize.isTabletScreen(context)) {
        return Scaffold(
          backgroundColor: AppColors.lightGray,
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTopRow(),
              const SizedBox(height: 12),
              _buildSearchRow(),
              const SizedBox(height: 12),
              _buildShipmentInfoRow(responsiveScreenSize.isTabletScreen(context) || responsiveScreenSize.isMobileScreen(context)),
              const SizedBox(height: 12),
              _selectedFilters(),
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
                        print('Empty');
                        return _buildOrderTable([], true);
                      }

                      List<OrderModel> orders = snapshot.data!.docs.map((doc) {
                        final data = doc.data() as Map<String, dynamic>;
                        return OrderModel.fromJson(
                            data); // Ensure OrderModel has a `fromMap` method
                      }).toList();
                      print(orders.length);

                      // Apply endDate filter manually in UI if search is active**
                      if (startDate != null && endDate != null && _searchController.text.isNotEmpty) {
                        orders = orders.where((order) {
                          final orderEndDate = DateTime.parse(order.pickupTimeWindow.end.toString()); // Ensure it's parsed correctly
                          return orderEndDate.isBefore(endDate!);
                        }).toList();
                        print(orders.length);
                      }

                      // **🔹 Sort orders by createdAt (latest first)**
                      orders.sort((a, b) {
                        final createdAtA = DateTime.parse(a.createdAt.toString());
                        final createdAtB = DateTime.parse(b.createdAt.toString());
                        return createdAtB.compareTo(createdAtA); // Descending order (latest first)
                      });

                      return _buildOrderTable(orders, true);
                    }),
              )
            ],
          ),
        );
      } else {
        return Scaffold(
          backgroundColor: AppColors.lightGray,
          floatingActionButton: FloatingActionButton.small(
            backgroundColor: AppColors.lightBlue,
            tooltip: 'Create Order',
            onPressed: () {
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => const CreateOrderDialog(),
              );
            },
            child: Icon(
              Icons.add,
              color: AppColors.white,
            ),
          ),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
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
                      "Order Management",
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
              const SizedBox(height: 12),
              _buildSearchRow(),
              const SizedBox(height: 12),
              if(!responsiveScreenSize.isMobileScreen(context))...[
                _buildShipmentInfoRow(responsiveScreenSize.isTabletScreen(context) || responsiveScreenSize.isMobileScreen(context)),
                const SizedBox(height: 12),
              ],
              _selectedFilters(),
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
                        print('Empty');
                        return _buildOrderTable([], responsiveScreenSize.isTabletScreen(context) || responsiveScreenSize.isMobileScreen(context));
                      }

                      List<OrderModel> orders = snapshot.data!.docs.map((doc) {
                        final data = doc.data() as Map<String, dynamic>;
                        return OrderModel.fromJson(
                            data); // Ensure OrderModel has a `fromMap` method
                      }).toList();
                      print(orders.length);

                      // Apply endDate filter manually in UI if search is active**
                      if (startDate != null && endDate != null && _searchController.text.isNotEmpty) {
                        orders = orders.where((order) {
                          final orderEndDate = DateTime.parse(order.pickupTimeWindow.end.toString()); // Ensure it's parsed correctly
                          return orderEndDate.isBefore(endDate!);
                        }).toList();
                        print(orders.length);
                      }

                      // **🔹 Sort orders by createdAt (latest first)**
                      orders.sort((a, b) {
                        final createdAtA = DateTime.parse(a.createdAt.toString());
                        final createdAtB = DateTime.parse(b.createdAt.toString());
                        return createdAtB.compareTo(createdAtA); // Descending order (latest first)
                      });

                      return _buildOrderTable(orders, responsiveScreenSize.isTabletScreen(context) || responsiveScreenSize.isMobileScreen(context));
                    }),
              ),
            ],
          ),
        );
      }
    });
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
                            buildOrderDetails(order),
                            const SizedBox(height: 12),
                            buildOrderDriverDetails(order.driverInfo),
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

  Widget _buildStatusTabs(bool isSmallScreen) {
    return TabBar(
      controller: context.read<OrderListCubit>().tabController,
      isScrollable: isSmallScreen? true: false,
      labelColor: AppColors.black,
      indicatorColor: AppColors.black,
      unselectedLabelColor: Colors.grey,
      labelStyle: AppTextStyles.body14RobotoMedium,
      unselectedLabelStyle: AppTextStyles.body14RobotoMedium.copyWith(color: AppColors.grey),
      onTap: (tab) {
        context.read<OrderListCubit>().filterStatus = statuses[tab];
      },
      tabs: statuses
          .map((status) => Tab(
                text: status.name, // Display the status name
              ))
          .toList(),
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
                "Order Management",
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

  Widget _buildSearchRow() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                _debouncer.call(() {
                  setState(() {

                  });
                });
              },
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.search, color: AppColors.grey),
                hintText: "Search orders...",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.clear, color: AppColors.grey),
                    onPressed: () {
                      _searchController.clear();
                      setState(() {

                      });
                      // context.read<OrderListCubit>().searchOrders('');
                    },
                  ),
                contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
              ),
            ),
          ),
          Row(
            children: [
              const SizedBox(
                width: 5,
              ),
              Text("My Orders", style: AppTextStyles.body14RobotoMedium,),
              Checkbox(
                value: _onlyMyOrders,
                onChanged: (bool? value) {
                  setState(() {
                    _onlyMyOrders = value ?? false;
                  });
                },
              ),
              const SizedBox(
                width: 5,
              ),
              OutlinedButton.icon(
                onPressed: () async{
                  var result = await showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (context) {
                        return FilterDialog(
                          fromCountry: fromCountry,
                          toCountry: toCountry,
                          startDate: startDate,
                          endDate: endDate,
                        );
                      }
                  );
                  if (result != null) {
                    fromCountry = result['From'];
                    toCountry = result['To'];
                    startDate = result['StartDate'];
                    endDate = result['EndDate'];
                  } else {

                  }
                  setState(() {

                  });
                },
                icon: const Icon(Icons.filter_list),
                label: const Text("Filter"),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildShipmentInfoRow(bool isSmallScreen) {
      return StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance.collection('metrics').doc('orders_count').snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData || snapshot.data == null) {
              return Center(child: CircularProgressIndicator());
            }

            final data = snapshot.data!.data() as Map<String, dynamic>? ?? {};
            var statusCounts = data["statusCounts"] as Map<String, dynamic>? ?? {};

            // Extract metrics safely
            final confirmedOrders = statusCounts['Confirmed'] ?? 0;
            final pendingOrders = statusCounts['Pending'] ?? 0;
            final assignedOrders = statusCounts['Assigned'] ?? 0;
            final onTheWayOrders = statusCounts['OnTheWay'] ?? 0;
            final completeOrders = statusCounts['Complete'] ?? 0;

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildInfoCard(
                  title: 'Pending Orders',
                  value: pendingOrders.toString(),
                  boxColor: Colors.grey.shade300,
                  iconColor: Colors.black87,
                  icon: Icons.pending_actions,
                  isSmallScreen: isSmallScreen
                ),
                _buildInfoCard(
                  title: 'Confirmed Groups',
                  value: confirmedOrders.toString(),
                  boxColor: Colors.green.withOpacity(0.2),
                  iconColor: Colors.green,
                  icon: Icons.done_all,
                    isSmallScreen: isSmallScreen
                ),
                _buildInfoCard(
                  title: 'Drivers Assigned',
                  value: assignedOrders.toString(),
                  boxColor: Colors.grey.shade300,
                  iconColor: Colors.black87,
                  icon: Icons.badge,
                    isSmallScreen: isSmallScreen
                ),
                _buildInfoCard(
                  title: 'On The Way',
                  value: onTheWayOrders.toString(),
                  boxColor: Colors.blue.withOpacity(0.2),
                  iconColor: Colors.blue,
                  icon: Icons.local_shipping,
                    isSmallScreen: isSmallScreen
                ),
                _buildInfoCard(
                  title: 'Completed Orders',
                  value: completeOrders.toString(),
                  boxColor: Colors.green.shade100,
                  iconColor: Colors.green,
                  icon: Icons.check_circle,
                    isSmallScreen: isSmallScreen
                ),
              ],
            ),
          );
        }
      );
    }

// Reusing _buildMetricCard but keeping the function name _buildInfoCard
  Widget _buildInfoCard({
    required String title,
    required String value,
    required Color boxColor,
    required Color iconColor,
    required IconData icon,
    required bool isSmallScreen
  }) {
    return Expanded(
      child: Card(
        elevation: 2,
        color: AppColors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              if(!isSmallScreen)...[
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: boxColor,
                  ),
                  child: Icon(icon, color: iconColor),
                ),
                const SizedBox(width: 20),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.head20RobotoMedium
                          .copyWith(color: AppColors.grey),
                    ),
                    Text(
                      value,
                      maxLines: 1,
                      softWrap: true,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.head32RobotoMedium
                          .copyWith(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOrderTable(List<OrderModel> orders, bool isSmallScreen) {
    return Container(
      decoration: BoxDecoration(
        borderRadius:
        BorderRadius.circular(8), // Rounded corners for the entire table
      ),
      clipBehavior: Clip.hardEdge,
      margin: EdgeInsets.symmetric(horizontal: 20),
      child: Card(
        elevation: 2,
        color: AppColors.white,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatusTabs(isSmallScreen),
            Expanded(
              child: Scrollbar(
                controller: _horizontalScrollController,
                thumbVisibility: true, // Always show the scrollbar
                thickness: 8.0, // Set the thickness of the scrollbar
                radius: const Radius.circular(8.0), // Rounded corners for the scrollbar
                child: SingleChildScrollView(
                  controller: _horizontalScrollController,
                  scrollDirection: Axis.horizontal,
                  child: Scrollbar(
                    controller: _verticalScrollController,
                    thumbVisibility: true,
                    thickness: 8.0,
                    radius: const Radius.circular(8.0),
                    child: SingleChildScrollView(
                      controller: _verticalScrollController,
                      scrollDirection: Axis.vertical,
                      child: SizedBox(
                        width: MediaQuery.sizeOf(context).width > 1765? MediaQuery.sizeOf(context).width - 180.w: null,
                        child: DataTable(
                          columnSpacing: 10,
                          headingRowColor: WidgetStateColor.resolveWith(
                              (states) => AppColors.lightGray),
                          headingTextStyle: AppTextStyles.body14RobotoMedium,
                          dataRowMaxHeight: 80, // Height for data rows
                          dividerThickness: 1, // Thickness for row dividers
                          border: TableBorder(
                            verticalInside: BorderSide(
                              color: AppColors.grey.withOpacity(0.3),

                            )
                          ),
                          columns: [
                            // Checkbox Column
                            DataColumn(
                              label: Checkbox(
                                value: _selectedOrders.length == orders.length &&
                                    orders.isNotEmpty,
                                onChanged: (bool? value) {
                                  setState(() {
                                    if (value == true) {
                                      _selectedOrders.clear();
                                      _selectedOrders.addAll(
                                          orders.map((order) => order.orderID));
                                    } else {
                                      _selectedOrders.clear();
                                    }
                                  });
                                },
                              ),
                              numeric: false,
                            ),
                            // Row Index Column
                            DataColumn(
                              label: Text(
                                '#',
                                style: AppTextStyles.body14RobotoMedium,
                              ),
                            ),
                            DataColumn(label: Text('Order ID', style: AppTextStyles.body14RobotoMedium,), headingRowAlignment: MainAxisAlignment.start),
                            DataColumn(label: Text('Order Name', style: AppTextStyles.body14RobotoMedium,), headingRowAlignment: MainAxisAlignment.center),
                            DataColumn(label: Text('Car Type', style: AppTextStyles.body14RobotoMedium,), headingRowAlignment: MainAxisAlignment.center),
                            DataColumn(label: Text('Pickup Place', style: AppTextStyles.body14RobotoMedium,), headingRowAlignment: MainAxisAlignment.start),
                            DataColumn(label: Text('Pickup Date', style: AppTextStyles.body14RobotoMedium,), headingRowAlignment: MainAxisAlignment.start),
                            DataColumn(label: Text('Delivery Place', style: AppTextStyles.body14RobotoMedium,), headingRowAlignment: MainAxisAlignment.end),
                            DataColumn(label: Text('Delivery Date', style: AppTextStyles.body14RobotoMedium,), headingRowAlignment: MainAxisAlignment.end),
                            DataColumn(label: Text('LDM', style: AppTextStyles.body14RobotoMedium,), headingRowAlignment: MainAxisAlignment.center),
                            DataColumn(label: Text('Weight', style: AppTextStyles.body14RobotoMedium,), headingRowAlignment: MainAxisAlignment.center),
                            DataColumn(label: Text('Is ADR', style: AppTextStyles.body14RobotoMedium,), headingRowAlignment: MainAxisAlignment.center),
                            DataColumn(
                                label: Text(
                              'Can Group\nWith ADR',
                              style: AppTextStyles.body14RobotoMedium,
                              softWrap: true,
                            ), headingRowAlignment: MainAxisAlignment.center),
                            DataColumn(label: Text('Status', style: AppTextStyles.body14RobotoMedium,), headingRowAlignment: MainAxisAlignment.center),
                            DataColumn(label: Text('Price', style: AppTextStyles.body14RobotoMedium,), headingRowAlignment: MainAxisAlignment.end),
                            DataColumn(label: Text('Actions', style: AppTextStyles.body14RobotoMedium,), headingRowAlignment: MainAxisAlignment.center),
                          ],
                          rows: orders.asMap().entries.map((entry) {
                            int index = entry.key + 1; // Row index (1-based)
                            OrderModel order = entry.value;

                            final isDeadlineReached =
                                order.deliveryTimeWindow.end.isBefore(DateTime.now());
                            return DataRow(
                              color: WidgetStateColor.resolveWith((states) {
                                if (isDeadlineReached) {
                                  return Colors.red
                                      .withOpacity(0.2); // Highlight overdue orders
                                }
                                return Colors.white; // Default row color
                              }),
                              cells: [
                                // Checkbox for each row
                                DataCell(Checkbox(
                                  value: _selectedOrders.contains(order.orderID),
                                  onChanged: (bool? value) {
                                    setState(() {
                                      if (value == true) {
                                        _selectedOrders.add(order.orderID);
                                      } else {
                                        _selectedOrders.remove(order.orderID);
                                      }
                                    });
                                  },
                                )),
                                // Row index
                                DataCell(Text(index.toString())),
                                DataCell(SizedBox(
                                    width: 95, child: SelectableText(order.orderID))),
                                DataCell(
                                    SizedBox(width: 80, child: Text(order.orderName, textAlign: TextAlign.end,))),
                                DataCell(Text(order.carTypeName, textAlign: TextAlign.end,)),
                                DataCell(
                                  SelectableText(
                                    '${order.pickupPlace.countryCode}, ${order.pickupPlace.postalCode}, ${order.pickupPlace.name}',
                                  ),
                                ),
                                DataCell(
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${order.pickupTimeWindow.start.toString().split(' ')[0]} ${order.pickupTimeWindow.start?.hour}:${order.pickupTimeWindow.start?.minute.toString().padLeft(2, '0')}',
                                        style: const TextStyle(fontSize: 14),
                                      ),
                                      Text(
                                        '${order.pickupTimeWindow.end.toString().split(' ')[0]} ${order.pickupTimeWindow.end.hour}:${order.pickupTimeWindow.end.minute.toString().padLeft(2, '0')}',
                                        style: const TextStyle(
                                            fontSize: 14, color: Colors.grey),
                                      ),
                                    ],
                                  ),
                                ),
                                DataCell(
                                  SelectableText(
                                    '${order.deliveryPlace.countryCode}, ${order.deliveryPlace.postalCode}, ${order.deliveryPlace.name}',
                                    textAlign: TextAlign.end,
                                  ),
                                ),
                                DataCell(
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        '${order.deliveryTimeWindow.start.toString().split(' ')[0]} ${order.deliveryTimeWindow.start?.hour}:${order.deliveryTimeWindow.start?.minute.toString().padLeft(2, '0')}',
                                        style: const TextStyle(fontSize: 14),
                                      ),
                                      Text(
                                        '${order.deliveryTimeWindow.end.toString().split(' ')[0]} ${order.deliveryTimeWindow.end.hour}:${order.deliveryTimeWindow.end.minute.toString().padLeft(2, '0')}',
                                        style: const TextStyle(
                                            fontSize: 14, color: Colors.grey),
                                      ),
                                    ],
                                  ),
                                ),
                                DataCell(
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        '${order.ldm}',
                                      ),
                                    ],
                                  ),
                                ),
                                DataCell(
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        '${order.weight}',
                                      ),
                                    ],
                                  ),
                                ),
                                DataCell(
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        order.isAdrOrder
                                            ? Icons.check_circle
                                            : Icons.cancel,
                                        color: order.isAdrOrder ? Colors.green : Colors.red,
                                      ),
                                    ],
                                  ),
                                ),
                                DataCell(
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        order.canGroupWithAdr
                                            ? Icons.check_circle
                                            : Icons.cancel,
                                        color: order.canGroupWithAdr
                                            ? Colors.blue
                                            : Colors.grey,
                                      ),
                                    ],
                                  ),
                                ),
                                DataCell(
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
                                ),
                                DataCell(Text('€${order.price.toStringAsFixed(2)}', textAlign: TextAlign.end,)),
                                DataCell(
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      PopupMenuButton<String>(
                                        icon: const Icon(Icons.more_vert), // Three-dot icon
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                              8), // Rounded corners for the menu
                                        ),
                                        onSelected: (value) async {
                                          switch (value) {
                                            case 'View':
                                              _showOrderDetails(
                                                  order,
                                                  context.read<UserProfileCubit>().state
                                                          is UserProfileLoaded
                                                      ? (context.read<UserProfileCubit>().state as UserProfileLoaded).user.userRole == UserRoles.allRoles[1]
                                                      : false,
                                                true
                                              );
                                              break;
                                            case 'Edit':
                                              if (order.status.name != 'Confirmed' &&
                                                  order.status.name != 'Assigned' &&
                                                  order.status.name != 'OnTheWay' &&
                                                  order.status.name != 'Complete') {
                                                if(context.read<UserProfileCubit>().state is UserProfileLoaded) {
                                                  if((context.read<UserProfileCubit>().state as UserProfileLoaded).user.userRole == UserRoles.allRoles[1] || (context.read<UserProfileCubit>().state as UserProfileLoaded).user.userID == order.creatorID) {
                                                    var canEdit = await context.read<OrderListCubit>().canEditing(order.orderID);
                                                    if(canEdit) {
                                                      context.read<OrderListCubit>().startEditing(order.orderID, (context.read<UserProfileCubit>().state as UserProfileLoaded).user.userID, (context.read<UserProfileCubit>().state as UserProfileLoaded).user.name);
                                                      var result = await showDialog(
                                                        context: context,
                                                        barrierDismissible: false,
                                                        builder: (context) => EditOrderDialog(
                                                          order: order,
                                                        ),
                                                      );
                                                      if(result) {
                                                        context.read<OrderListCubit>().stopEditing(order.orderID, (context.read<UserProfileCubit>().state as UserProfileLoaded).user.userID, (context.read<UserProfileCubit>().state as UserProfileLoaded).user.name);
                                                      } else {
                                                        context.read<OrderListCubit>().stopEditing(order.orderID, (context.read<UserProfileCubit>().state as UserProfileLoaded).user.userID, (context.read<UserProfileCubit>().state as UserProfileLoaded).user.name);
                                                      }
                                                    } else {
                                                      ScaffoldMessenger.of(context).showSnackBar(
                                                        const SnackBar(
                                                          content: Text(
                                                              'Currently Someone else editing this order'),
                                                        ),
                                                      );
                                                    }
                                                  } else {
                                                    ScaffoldMessenger.of(context).showSnackBar(
                                                      const SnackBar(
                                                        content: Text(
                                                            'You are not eligible to edit this order please contact Team Lead or Admin'),
                                                      ),
                                                    );
                                                  }
                                                } else {
                                                  ScaffoldMessenger.of(context).showSnackBar(
                                                    const SnackBar(
                                                      content: Text(
                                                          'Please login again'),
                                                    ),
                                                  );
                                                }
                                              } else if(order.status.name != 'ClientCanceled' && order.connectedGroupID != null) {
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  const SnackBar(
                                                    content: Text(
                                                        'Editing is not allowed for this order status.'),
                                                  ),
                                                );
                                              } else {
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  const SnackBar(
                                                    content: Text(
                                                        'Editing is not allowed for this order status.'),
                                                  ),
                                                );
                                              }
                                              break;
                                            case 'EditBulk':
                                              if (order.status.name != 'Confirmed' &&
                                                  order.status.name != 'Assigned' &&
                                                  order.status.name != 'OnTheWay' &&
                                                  order.status.name != 'Complete') {
                                                if(context.read<UserProfileCubit>().state is UserProfileLoaded) {
                                                  if((context.read<UserProfileCubit>().state as UserProfileLoaded).user.userRole == UserRoles.allRoles[1]) {
                                                        if(_selectedOrders.contains(order.orderID)) {
                                                          _showEditOrdersDialog(_selectedOrders, orders.firstWhere((order) => _selectedOrders.contains(order.orderID)).status,  (context.read<UserProfileCubit>().state as UserProfileLoaded).user.userID,  (context.read<UserProfileCubit>().state as UserProfileLoaded).user.name, true);
                                                        } else {
                                                          ScaffoldMessenger.of(context).showSnackBar(
                                                            const SnackBar(
                                                              content: Text(
                                                                  'You can delete only selected orders'),
                                                            ),
                                                          );
                                                        }
                                                  } else {
                                                    ScaffoldMessenger.of(context).showSnackBar(
                                                      const SnackBar(
                                                        content: Text(
                                                            'You are not eligible to edit this order please contact Team Lead or Admin'),
                                                      ),
                                                    );
                                                  }
                                                } else {
                                                  ScaffoldMessenger.of(context).showSnackBar(
                                                    const SnackBar(
                                                      content: Text(
                                                          'Please login again'),
                                                    ),
                                                  );
                                                }
                                              } else {
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  const SnackBar(
                                                    content: Text(
                                                        'Editing is not allowed for this order status.'),
                                                  ),
                                                );
                                              }
                                              break;
                                            case 'Delete':
                                              if (order.status.name != 'Confirmed' &&
                                                  order.status.name != 'Assigned' &&
                                                  order.status.name != 'OnTheWay' &&
                                                  order.status.name != 'Complete') {
                                                if(context.read<UserProfileCubit>().state is UserProfileLoaded) {
                                                  if((context.read<UserProfileCubit>().state as UserProfileLoaded).user.userRole == UserRoles.allRoles[1] || (context.read<UserProfileCubit>().state as UserProfileLoaded).user.userID == order.creatorID) {
                                                    if(_selectedOrders.isEmpty) {
                                                      _confirmDelete(order, _selectedOrders.toList(), false);
                                                    } else {
                                                      if(_selectedOrders.length == 1) {
                                                          _confirmDelete(order, _selectedOrders.toList(), false);
                                                      } else if(_selectedOrders.length > 1) {
                                                        if(_selectedOrders.contains(order.orderID)) {
                                                          _confirmDelete(order, _selectedOrders.toList(), true);
                                                        } else {
                                                          ScaffoldMessenger.of(context).showSnackBar(
                                                            const SnackBar(
                                                              content: Text(
                                                                  'You can delete only selected orders'),
                                                            ),
                                                          );
                                                        }
                                                      }
                                                    }
                                                  } else {
                                                    ScaffoldMessenger.of(context).showSnackBar(
                                                      const SnackBar(
                                                        content: Text(
                                                            'You are not eligible to delete this order please contact Team Lead or Admin'),
                                                      ),
                                                    );
                                                  }
                                                } else {
                                                  ScaffoldMessenger.of(context).showSnackBar(
                                                    const SnackBar(
                                                      content: Text(
                                                          'Please login again'),
                                                    ),
                                                  );
                                                }
                                              } else {
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  const SnackBar(
                                                    content: Text(
                                                        'Deleting is not allowed for this order status.'),
                                                  ),
                                                );
                                              }

                                              break;
                                          }
                                        },
                                        itemBuilder: (BuildContext context) => [
                                          const PopupMenuItem(
                                            value: 'View',
                                            child: Text('View Details'),
                                          ),
                                          const PopupMenuItem(
                                            value: 'Edit',
                                            child: Text('Edit Order'),
                                          ),
                                          if(_selectedOrders.length > 1)...[
                                            const PopupMenuItem(
                                              value: 'EditBulk',
                                              child: Text('Edit Orders'),
                                            ),
                                          ],
                                          const PopupMenuItem(
                                            value: 'Delete',
                                            child: Text('Delete Order'),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditOrdersDialog(Set<String> orderIDs, OrderStatus status, String userID, String userName, bool isTeamLead) async{
    if(!isTeamLead) {
      showTopSnackbarInfo(context, 'You do not have access');
      return;
    }
    OrderStatus? selectedStatus = status;

    var result = await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
            builder: (context, setST) {
              return BlocConsumer<OrderListCubit, OrderListState>(
                listener: (context, state) {
                  if (state is OrderListActionSuccess) {
                    context.pop(true); // Close the dialog on success
                  } else if (state is OrderListActionError) {
                    showErrorNotification(context, state.message);
                  }
                },
                builder: (context, state) {
                  var isLoading = state is OrderListActionLoading;
                  return IgnorePointer(
                    ignoring: isLoading,
                    child: AlertDialog(
                      backgroundColor: AppColors.white,
                      title: Text('Edit All Selected Orders'),
                      content: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Status Dropdown
                            DropdownButtonFormField<OrderStatus>(
                              value: selectedStatus,
                              items: [OrderStatus.Pending, OrderStatus.Canceled, OrderStatus.ClientCanceled, OrderStatus.Problematic]
                                  .map(
                                    (status) => DropdownMenuItem(
                                  value: status,
                                  child: Text(status.name),
                                ),
                              )
                                  .toList(),
                              decoration: const InputDecoration(labelText: 'Status'),
                              onChanged: (value) {
                                selectedStatus = value;
                              },
                            ),
                          ],
                        ),
                      ),
                      actions: [
                        OutlinedButton.icon(
                          onPressed: () {
                            context.pop(false);
                          },
                          label: Text('Cancel'),
                        ),
                        isLoading? CircularProgressIndicator(): ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          ),
                          onPressed: () async{

                            if(selectedStatus?.name == status.name) {
                              context.pop(false);
                            } else {
                              var result = await context.read<UserProfileCubit>().checkIfUserProfileActive(context);
                              if(result) {
                                final user = context.read<UserProfileCubit>().state as UserProfileLoaded;

                                  context.read<OrderListCubit>().updateOrderStatusBulk(
                                      orderIDs.toList(),
                                      selectedStatus!.name,
                                      user.user.userID,
                                      user.user.name,
                                  );
                                } else {
                                    showErrorNotification(context, 'Sorry action your connection is lost');
                                  }
                              }
                          },
                          child: Text("Save", style: AppTextStyles.body17RobotoMedium.copyWith(color: AppColors.white)),
                        ),
                      ],
                    ),
                  );
                },
              );
            }
        );
      },
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

  void _confirmDelete(OrderModel order, List<String> ordersIDs, bool isBatchDelete) {
    showDialog(
      context: context,
      builder: (context) {
        return BlocListener<OrderListCubit, OrderListState>(
          listener: (context, state) {
            if (state is OrderListActionSuccess) {
              context.pop(); // Close the dialog on success
            } else if (state is OrderListActionError) {
              showErrorNotification(context, state.message);
            }
          },
          child: AlertDialog(
            title: isBatchDelete? const Text('Delete Orders'): const Text('Delete Order'),
            content:
                Text('Are you sure you want to delete "${isBatchDelete? 'orders': order.orderName}"?'),
            actions: [
              OutlinedButton.icon(
                onPressed: () {
                  context.pop();
                },
                label: Text('Cancel'),
              ),
              BlocBuilder<OrderListCubit, OrderListState>(
                builder: (context, state) {
                  final isLoading =
                      context.read<OrderListCubit>().deletingOrderID ==
                          order.orderID;
                  return ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.red
                    ),
                    onPressed: isLoading
                        ? null // Disable the button while loading
                        : () async {
                            var result = await context
                                .read<UserProfileCubit>()
                                .checkIfUserProfileActive(context);
                            if (result) {
                              if(isBatchDelete) {
                                final user = context
                                    .read<UserProfileCubit>()
                                    .state as UserProfileLoaded;
                                context.read<OrderListCubit>().deleteOrders(
                                  ordersIDs,
                                  user.user
                                      .userID, // Replace with actual userID
                                  user.user
                                      .username, // Replace with actual userName
                                );
                              } else {
                                final user = context
                                    .read<UserProfileCubit>()
                                    .state as UserProfileLoaded;
                                context.read<OrderListCubit>().deleteOrder(
                                  order.orderID,
                                  user.user
                                      .userID, // Replace with actual userID
                                  user.user
                                      .username, // Replace with actual userName
                                );
                              }
                            } else {
                              showErrorNotification(context,
                                  'Sorry action your connection is lost');
                            }
                          },
                    child: isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(),
                          )
                        : Text('Delete', style: AppTextStyles.body17RobotoMedium.copyWith(color: AppColors.white),),
                  );
                },
              ),
            ],
          ),
        );
      },
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
        'CREATE ORDER',
        style: AppTextStyles.body14RobotoMedium
            .copyWith(color: AppColors.white),
      ),
      onPressed: () {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const CreateOrderDialog(),
        );
        // showDialog(
        //   context: context,
        //   barrierDismissible: false,
        //   builder: (context) => CreateOrderView(),
        // );
      },
    );
  }

  Widget _selectedFilters() {
    if(fromCountry == null && toCountry == null && startDate == null && endDate == null) return SizedBox.shrink();
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Wrap(
          spacing: 8.0,
          children: [
            if(fromCountry != null)...[
              Chip(
                label: Text('From Country: ${fromCountry}'),
                onDeleted: () {
                  setState(() {
                    fromCountry = null;
                  });
                },
              )
            ],
            if(toCountry != null)...[
              Chip(
                label: Text('To Country: ${toCountry}'),
                onDeleted: () {
                  setState(() {
                    toCountry = null;
                  });
                },
              )
            ],
            if(startDate != null)...[
              Chip(
                label: Text('Pickup Start Date: ${DateFormat('yyyy-MM-dd').format(startDate!)}'),
                onDeleted: () {
                  setState(() {
                    startDate = null;
                  });
                },
              )
            ],
            if(endDate != null)...[
              Chip(
                label: Text('Delivery End Date: ${DateFormat('yyyy-MM-dd').format(endDate!)}'),
                onDeleted: () {
                  setState(() {
                    endDate = null;
                  });
                },
              )
            ],
            TextButton(
              onPressed: _clearFilters,
              child: Text("Clear All", style: TextStyle(fontSize: 16, color: Colors.black)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
