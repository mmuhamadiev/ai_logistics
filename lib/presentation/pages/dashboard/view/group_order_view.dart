import 'dart:async';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_expandable_table/flutter_expandable_table.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get_rx/src/rx_workers/utils/debouncer.dart';
import 'package:go_router/go_router.dart';
import 'package:hegelmann_order_automation/config/app_colors.dart';
import 'package:hegelmann_order_automation/config/app_text_styles.dart';
import 'package:hegelmann_order_automation/config/constants.dart';
import 'package:hegelmann_order_automation/config/screen_size.dart';
import 'package:hegelmann_order_automation/domain/models/car_type_model.dart';
import 'package:hegelmann_order_automation/domain/models/commnet_model.dart';
import 'package:hegelmann_order_automation/domain/models/driver_info_model.dart';
import 'package:hegelmann_order_automation/domain/models/order_group_model.dart';
import 'package:hegelmann_order_automation/domain/models/order_model.dart';
import 'package:hegelmann_order_automation/presentation/manager/group_order_list/group_order_list_cubit.dart';
import 'package:hegelmann_order_automation/presentation/manager/order_list/order_list_cubit.dart';
import 'package:hegelmann_order_automation/presentation/manager/user_profile_cubit/user_profile_cubit.dart';
import 'package:hegelmann_order_automation/presentation/pages/dashboard/components/edit_order_group_dialog.dart';
import 'package:hegelmann_order_automation/presentation/pages/dashboard/components/group_update_constructor.dart';
import 'package:hegelmann_order_automation/presentation/pages/dashboard/components/order_details_dialog_components.dart';
import 'package:hegelmann_order_automation/presentation/pages/dashboard/components/order_filter.dart';
import 'package:hegelmann_order_automation/presentation/pages/dashboard/components/order_group_detail_dialog_component.dart';
import 'package:hegelmann_order_automation/presentation/widgets/clock.dart';
import 'package:hegelmann_order_automation/presentation/widgets/map_view_widget.dart';
import 'package:hegelmann_order_automation/presentation/widgets/notifications/error_notification.dart';
import 'package:hegelmann_order_automation/presentation/widgets/notifications/top_snackbar_error.dart';
import 'package:hegelmann_order_automation/presentation/widgets/notifications/top_snackbar_info.dart';
import 'package:intl/intl.dart';

class ConfirmedGroupsView extends StatefulWidget {
  const ConfirmedGroupsView({Key? key}) : super(key: key);

  @override
  State<ConfirmedGroupsView> createState() => _ConfirmedGroupsViewState();
}

class _ConfirmedGroupsViewState extends State<ConfirmedGroupsView>
    with SingleTickerProviderStateMixin {

  StreamSubscription? _subscription;

  late TabController tabController;
  ResponsiveScreenSize responsiveScreenSize = ResponsiveScreenSize();

  final TextEditingController _searchController = TextEditingController();

  final Debouncer _debouncer = Debouncer(delay: Duration(milliseconds: 500));

  // Store selected order IDs
  final Set<String> _selectedGroups = {};

  bool _onlyMyOrders = false; // Add this as a state variable
  String? fromCountry;
  String? toCountry;
  DateTime? startDate;
  DateTime? endDate;
  String selectedStatus = OrderStatus.Confirmed.name;

  final List<OrderStatus> statuses = [OrderStatus.Confirmed, OrderStatus.Assigned, OrderStatus.Loaded, OrderStatus.OnTheWay, OrderStatus.Unloaded, OrderStatus.Complete];

  List<OrderGroupModel> groups = [];
  void _clearFilters() {
    setState(() {
      fromCountry = null;
      toCountry = null;
      startDate = null;
      endDate = null;
    });
  }

  @override
  void initState() {
    tabController = TabController(length: statuses.length, vsync: this);
    selectedStatus = statuses[tabController.index].name;
    tabController.addListener(_handleTabChange);
    super.initState();
  }

  void _handleTabChange() {
    if (!tabController.indexIsChanging) {
      selectedStatus = statuses[tabController.index].name;
      setState(() {

      });
      // context.read<OrderListCubit>().filterByStatus(selectedStatus);
    }
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getFilteredQuery() {
    Query<Map<String, dynamic>> query =
    FirebaseFirestore.instance.collection('orderGroups');

    // final selectedStatus = statuses[context.read<OrderListCubit>().tabController.index];
    if(_onlyMyOrders) {
      query = query.where('creatorID', isEqualTo: (context.read<UserProfileCubit>().state as UserProfileLoaded).user.userID);
    }
    query = query.where('status', isEqualTo: selectedStatus);
    debugPrint('🔹 Status Filter: ${selectedStatus}');

    if (_searchController.text.isNotEmpty) {
      query = query.orderBy('groupID').startAt([
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
  Widget build(BuildContext context) {

    return BlocListener<GroupOrderListCubit, GroupOrderListState>(
  listener: (context, state) {
    if(state is GroupOrderListLoaded) {
      setState(() {

      });
    }
  },
  child: LayoutBuilder(builder: (context, constraints) {
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
                        return _buildGroupTable([], true);
                      }

                      groups = snapshot.data!.docs.map((doc) {
                        final data = doc.data() as Map<String, dynamic>;
                        return OrderGroupModel.fromJson(
                            data); // Ensure OrderModel has a `fromMap` method
                      }).toList();
                      print('groups length desktop ${groups.length}');
                      print('groups length desktop ${groups.first.totalLDM}');

                      // Apply endDate filter manually in UI if search is active**
                      if (fromCountry != null) {
                        groups = groups.where((group) {
                          return group.orders.any((order) =>
                          order.pickupPlace.countryCode == fromCountry);
                        }).toList();
                      }
                      // Apply 'To' filter
                      if (toCountry != null) {
                        groups = groups.where((group) {
                          return group.orders.any((order) =>
                          order.deliveryPlace.countryCode == toCountry);
                        }).toList();
                      }

                      // Apply date range filter
                      if (startDate != null && endDate != null) {
                        groups = groups.where((group) {
                          return group.orders.any((order) => order.pickupTimeWindow.start.isAfter(startDate!) && order.pickupTimeWindow.end.isBefore(endDate!));
                        }).toList();
                      } else if (startDate != null && endDate == null) {
                        groups = groups.where((group) {
                          return group.orders.any((order) => order.pickupTimeWindow.start.isAfter(startDate!));
                        }).toList();
                      } else if (startDate == null && endDate != null) {
                        groups = groups.where((group) {
                          return group.orders.any((order) => order.pickupTimeWindow.end.isBefore(endDate!));
                        }).toList();
                      }

                      // **🔹 Sort orders by createdAt (latest first)**
                      groups.sort((a, b) {
                        final createdAtA = DateTime.parse(a.createdAt.toString());
                        final createdAtB = DateTime.parse(b.createdAt.toString());
                        return createdAtB.compareTo(createdAtA); // Descending order (latest first)
                      });

                      return _buildGroupTable(groups, true);
                    }),
              ),
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
                        return _buildGroupTable([], true);
                      }

                      groups = snapshot.data!.docs.map((doc) {
                        final data = doc.data() as Map<String, dynamic>;
                        return OrderGroupModel.fromJson(
                            data); // Ensure OrderModel has a `fromMap` method
                      }).toList();
                      print('groups length ${groups.length}');

                      // Apply endDate filter manually in UI if search is active**
                      if (fromCountry != null) {
                        groups = groups.where((group) {
                          return group.orders.any((order) =>
                          order.pickupPlace.countryCode == fromCountry);
                        }).toList();
                      }
                      // Apply 'To' filter
                      if (toCountry != null) {
                        groups = groups.where((group) {
                          return group.orders.any((order) =>
                          order.deliveryPlace.countryCode == toCountry);
                        }).toList();
                      }

                      // Apply date range filter
                      if (startDate != null && endDate != null) {
                        groups = groups.where((group) {
                          return group.orders.any((order) => order.pickupTimeWindow.start.isAfter(startDate!) && order.pickupTimeWindow.end.isBefore(endDate!));
                        }).toList();
                      } else if (startDate != null && endDate == null) {
                        groups = groups.where((group) {
                          return group.orders.any((order) => order.pickupTimeWindow.start.isAfter(startDate!));
                        }).toList();
                      } else if (startDate == null && endDate != null) {
                        groups = groups.where((group) {
                          return group.orders.any((order) => order.pickupTimeWindow.end.isBefore(endDate!));
                        }).toList();
                      }

                      // **🔹 Sort orders by createdAt (latest first)**
                      groups.sort((a, b) {
                        final createdAtA = DateTime.parse(a.createdAt.toString());
                        final createdAtB = DateTime.parse(b.createdAt.toString());
                        return createdAtB.compareTo(createdAtA); // Descending order (latest first)
                      });

                      return _buildGroupTable(groups, true);
                    }),
              ),
            ],
          ),
        );
      } else {
        return Scaffold(
          backgroundColor: AppColors.lightGray,
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
                      "Group Management",
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
                        return _buildGroupTable([], responsiveScreenSize.isTabletScreen(context) || responsiveScreenSize.isMobileScreen(context));
                      }

                      groups = snapshot.data!.docs.map((doc) {
                        final data = doc.data() as Map<String, dynamic>;
                        return OrderGroupModel.fromJson(
                            data); // Ensure OrderModel has a `fromMap` method
                      }).toList();
                      print(groups.length);

                      // Apply endDate filter manually in UI if search is active**
                      if (fromCountry != null) {
                        groups = groups.where((group) {
                          return group.orders.any((order) =>
                          order.pickupPlace.countryCode == fromCountry);
                        }).toList();
                      }
                      // Apply 'To' filter
                      if (toCountry != null) {
                        groups = groups.where((group) {
                          return group.orders.any((order) =>
                          order.deliveryPlace.countryCode == toCountry);
                        }).toList();
                      }

                      // Apply date range filter
                      if (startDate != null && endDate != null) {
                        groups = groups.where((group) {
                          return group.orders.any((order) => order.pickupTimeWindow.start.isAfter(startDate!) && order.pickupTimeWindow.end.isBefore(endDate!));
                        }).toList();
                      } else if (startDate != null && endDate == null) {
                        groups = groups.where((group) {
                          return group.orders.any((order) => order.pickupTimeWindow.start.isAfter(startDate!));
                        }).toList();
                      } else if (startDate == null && endDate != null) {
                        groups = groups.where((group) {
                          return group.orders.any((order) => order.pickupTimeWindow.end.isBefore(endDate!));
                        }).toList();
                      }

                      // **🔹 Sort orders by createdAt (latest first)**
                      groups.sort((a, b) {
                        final createdAtA = DateTime.parse(a.createdAt.toString());
                        final createdAtB = DateTime.parse(b.createdAt.toString());
                        return createdAtB.compareTo(createdAtA); // Descending order (latest first)
                      });

                      return _buildGroupTable(groups, responsiveScreenSize.isTabletScreen(context) || responsiveScreenSize.isMobileScreen(context));
                    }),
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
                "Group Management",
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
              Text("My Groups", style: AppTextStyles.body14RobotoMedium,),
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
        stream: FirebaseFirestore.instance.collection('metrics').doc('group_orders_count').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData || snapshot.data == null) {
            return Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data!.data() as Map<String, dynamic>? ?? {};
          var statusCounts = data["statusCounts"] as Map<String, dynamic>? ?? {};

          // Extract metrics safely
          final confirmedOrders = statusCounts['Confirmed'] ?? 0;
          final assignedOrders = statusCounts['Assigned'] ?? 0;
          final onTheWayOrders = statusCounts['OnTheWay'] ?? 0;
          final completeOrders = statusCounts['Complete'] ?? 0;

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
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

  Widget _buildStatusTabs(bool isSmallScreen) {
    return TabBar(
      controller: tabController,
      isScrollable: isSmallScreen? true: false,
      labelColor: AppColors.black,
      indicatorColor: AppColors.black,
      unselectedLabelColor: Colors.grey,
      labelStyle: AppTextStyles.body14RobotoMedium,
      unselectedLabelStyle: AppTextStyles.body14RobotoMedium.copyWith(color: AppColors.grey),
      onTap: (tab) {},
      tabs: statuses
          .map((status) => Tab(
        text: status.name, // Display the status name
      ))
          .toList(),
    );
  }

  Widget _buildGroupTable(List<OrderGroupModel> groups, bool isSmallScreen) {
    List<ExpandableTableHeader> headers = [
      ExpandableTableHeader(cell: _buildHeaderCell('Car Comment')),
      ExpandableTableHeader(cell: _buildHeaderCell('Total LDM')),
      ExpandableTableHeader(cell: _buildHeaderCell('Total Weight')),
      ExpandableTableHeader(cell: _buildHeaderCell('Load More')),
      ExpandableTableHeader(cell: _buildHeaderCell('Creator')),
      ExpandableTableHeader(cell: _buildHeaderCell('Driver Info')),
      ExpandableTableHeader(cell: _buildHeaderCell('Total Distance')),
      ExpandableTableHeader(cell: _buildHeaderCell('Price Per Km')),
      ExpandableTableHeader(cell: _buildHeaderCell('Total Price')),
      ExpandableTableHeader(cell: _buildHeaderCell('Status')),
      ExpandableTableHeader(cell: _buildHeaderCell('Actions')),
    ];

    // Create or update the controller with the current data
    print(MediaQuery.sizeOf(context).width);
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
              child: ExpandableTable(
                firstHeaderCell: ExpandableTableCell(
                  child: Container(
                    decoration: BoxDecoration(
                        color: AppColors.lightGray,
                        border: Border.all(
                            color: AppColors.grey.withOpacity(0.3)
                        )
                    ),
                    padding: const EdgeInsets.symmetric(
                        vertical: 4.0, horizontal: 8.0),
                    child: Center(
                      child: Row(
                        children: [
                          Checkbox(
                            value: _selectedGroups.length == groups.length &&
                                groups.isNotEmpty,
                            onChanged: (bool? value) {
                              setState(() {
                                if (value == true) {
                                  _selectedGroups.clear();
                                  _selectedGroups.addAll(
                                      groups.map((gr) => gr.groupID));
                                } else {
                                  _selectedGroups.clear();
                                }
                              });
                            },
                          ),
                          Text('#'),
                          VerticalDivider(),
                          SelectableText(
                            'GroupID',
                            style: AppTextStyles.body14RobotoMedium,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                defaultsColumnWidth: MediaQuery.sizeOf(context).width > 1560? (127.w * (MediaQuery.sizeOf(context).width / (MediaQuery.sizeOf(context).width * 0.75))): 120,
                headers: headers,
                headerHeight: 60,
                rows: _generateRows(groups),
                defaultsRowHeight: 80,
                scrollShadowColor: AppColors.lightGray,
                visibleScrollbar: true,
                expanded: true,
              ),
            ),
          ],
        ),
      ),
    );
  }

  ExpandableTableCell _buildCell(String content) => ExpandableTableCell(
    child: Container(
      decoration: BoxDecoration(
          color: AppColors.white,
          border: Border.all(
              color: AppColors.grey.withOpacity(0.3)
          )
      ),
      child: Center(
        child: SelectableText(
          content,
        ),
      ),
    ),
  );

  ExpandableTableCell _buildHeaderCell(String text) => ExpandableTableCell(
    child: Container(
      decoration: BoxDecoration(
          color: AppColors.lightGray,
          border: Border.all(
              color: AppColors.grey.withOpacity(0.3)
          )
      ),
      child: Center(
        child: SelectableText(
          text,
          style: AppTextStyles.body14RobotoMedium,
        ),
      ),
    ),
  );

  ExpandableTableCell _buildSubHeaderCell(String text) => ExpandableTableCell(
    child: Container(
      decoration: BoxDecoration(
          color: AppColors.grey.withOpacity(0.2),
          border: Border.all(
              color: AppColors.grey.withOpacity(0.3)
          )
      ),
      child: Center(
        child: SelectableText(
          text,
          style: AppTextStyles.body14RobotoMedium,
        ),
      ),
    ),
  );

  ExpandableTableCell _buildSubDataCell(String text) => ExpandableTableCell(
    child: Container(
      decoration: BoxDecoration(
          color: AppColors.grey.withOpacity(0.1),
          border: Border.all(
              color: AppColors.grey.withOpacity(0.4)
          )
      ),
      child: Center(
        child: SelectableText(
          text,
        ),
      ),
    ),
  );

  List<ExpandableTableRow> _generateRows(List<OrderGroupModel> orderGroups) {
    return orderGroups.asMap().entries.map((entry) {
      int index = entry.key + 1; // Row index (1-based)
      OrderGroupModel group = entry.value;
      return ExpandableTableRow(
        firstCell: ExpandableTableCell(
          child: Container(
            decoration: BoxDecoration(
                color: AppColors.white,
                border: Border.all(
                    color: AppColors.grey.withOpacity(0.3)
                )
            ),
            padding: const EdgeInsets.symmetric(
                vertical: 4.0, horizontal: 8.0),
            child: Center(
              child: Row(
                children: [
                  Checkbox(
                    value: _selectedGroups.contains(group.groupID),
                    onChanged: (bool? value) {
                      setState(() {
                        if (value == true) {
                          _selectedGroups.add(group.groupID);
                        } else {
                          _selectedGroups.remove(group.groupID);
                        }
                      });
                    },
                  ),
                  Text('$index'),
                  VerticalDivider(),
                  Flexible(
                    child: SelectableText(
                      group.groupID,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        cells: [
          ExpandableTableCell(
            child: group.carComment != null? Container(
              decoration: BoxDecoration(
                color: AppColors.white,
                  border: Border.all(
                      color: AppColors.grey.withOpacity(0.3)
                  )
              ),
              padding: EdgeInsets.all(8),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(group.carComment!.content, style: const TextStyle(fontSize: 14),),
                  Text('By ${group.carComment!.commenterName}', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 14, color: AppColors.grey),)
                ],
              ),
            ): Center(
              child: Text('N/A'),
            )
          ),
          _buildCell('${group.totalLDM.toStringAsFixed(1)}'),
          _buildCell('${group.totalWeight.toStringAsFixed(1)}'),
          _buildCell(group.isNeedAddMore ? 'Yes' : 'No'),
          _buildCell(group.creatorName),
          ExpandableTableCell(
            child: Container(
              decoration: BoxDecoration(
                  color: AppColors.white,
                  border: Border.all(
                      color: AppColors.grey.withOpacity(0.3)
                  )
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Driver Name: ${group.driverInfo != null ? group.driverInfo!.driverName: 'N/A'}',
                      style: const TextStyle(fontSize: 14),
                    ),
                    Text('Driver Car: ${group.driverInfo != null ? group.driverInfo!.driverCar: 'N/A'}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
          ),
          _buildCell('${group.totalDistance.toStringAsFixed(2)}'),
          _buildCell('€${group.pricePerKm.toStringAsFixed(1)}'),
          _buildCell('€${group.totalPrice.toStringAsFixed(2)}'),
          ExpandableTableCell(
            child: Container(
              decoration: BoxDecoration(
                  color: AppColors.white,
                  border: Border.all(
                      color: AppColors.grey.withOpacity(0.3)
                  )
              ),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      vertical: 4.0, horizontal: 8.0),
                  decoration: BoxDecoration(
                    color: _getStatusColor(group.status),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    group.status.name,
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ),
          ),
          ExpandableTableCell(
            child: Container(
              decoration: BoxDecoration(
                  color: AppColors.white,
                  border: Border.all(
                      color: AppColors.grey.withOpacity(0.3)
                  )
              ),
              child: Center(
                child: PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert), // Three-dot icon
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8), // Rounded corners for the menu
                  ),
                  onSelected: (value) async{
                    switch (value) {
                      case 'View':
                        _showGroupDetails(group, context.read<UserProfileCubit>().state is UserProfileLoaded? (context.read<UserProfileCubit>().state as UserProfileLoaded).user.userRole == UserRoles.allRoles[1]: false);
                        break;
                      case 'Edit':
                        if(context.read<UserProfileCubit>().state is UserProfileLoaded) {
                          if((context.read<UserProfileCubit>().state as UserProfileLoaded).user.userRole == UserRoles.allRoles[1] || group.orders.any((data) => data.creatorID == (context.read<UserProfileCubit>().state as UserProfileLoaded).user.userID) || (context.read<UserProfileCubit>().state as UserProfileLoaded).user.userRole == UserRoles.planner) {
                            var canEditGroupOrder = await context.read<GroupOrderListCubit>().canEditGroupOrder(group.groupID);
                            if(canEditGroupOrder) {
                              context.read<GroupOrderListCubit>().startGroupEditing(group.groupID, (context.read<UserProfileCubit>().state as UserProfileLoaded).user.userID, (context.read<UserProfileCubit>().state as UserProfileLoaded).user.name);
                              _showEditGroupOrderDialog(group, (context.read<UserProfileCubit>().state as UserProfileLoaded).user.userID, (context.read<UserProfileCubit>().state as UserProfileLoaded).user.name, context.read<UserProfileCubit>().state is UserProfileLoaded? (context.read<UserProfileCubit>().state as UserProfileLoaded).user.userRole == UserRoles.allRoles[1]? 1: (context.read<UserProfileCubit>().state as UserProfileLoaded).user.userRole == UserRoles.planner? 2: group.orders.any((data) => data.creatorID == (context.read<UserProfileCubit>().state as UserProfileLoaded).user.userID)? 3: 0: 0);
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
                                    'You are not eligible to edit this group please contact Team Lead or Admin'),
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
                        break;
                      case 'EditBulk':
                          if(context.read<UserProfileCubit>().state is UserProfileLoaded) {
                            if((context.read<UserProfileCubit>().state as UserProfileLoaded).user.userRole == UserRoles.allRoles[1] || group.orders.any((data) => data.creatorID == (context.read<UserProfileCubit>().state as UserProfileLoaded).user.userID) || (context.read<UserProfileCubit>().state as UserProfileLoaded).user.userRole == UserRoles.planner) {
                              if(_selectedGroups.contains(group.groupID)) {
                                _showEditGroupsStatusDialog(_selectedGroups, orderGroups.firstWhere((order) => _selectedGroups.contains(order.groupID)).status,  (context.read<UserProfileCubit>().state as UserProfileLoaded).user.userID,  (context.read<UserProfileCubit>().state as UserProfileLoaded).user.name, (context.read<UserProfileCubit>().state as UserProfileLoaded).user.userRole == UserRoles.allRoles[1]? 1: (context.read<UserProfileCubit>().state as UserProfileLoaded).user.userRole == UserRoles.planner? 2: 0);
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
                                      'You are not eligible to edit this group please contact Team Lead or Admin'),
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
                        break;
                      case 'Add':
                        if(context.read<UserProfileCubit>().state is UserProfileLoaded) {
                          if((context.read<UserProfileCubit>().state as UserProfileLoaded).user.userRole == UserRoles.allRoles[1] || group.orders.any((data) => data.creatorID == (context.read<UserProfileCubit>().state as UserProfileLoaded).user.userID)) {
                            var canEditGroupOrder = await context.read<GroupOrderListCubit>().canEditGroupOrder(group.groupID);
                            if(canEditGroupOrder) {
                              context.read<GroupOrderListCubit>().startGroupEditing(group.groupID, (context.read<UserProfileCubit>().state as UserProfileLoaded).user.userID, (context.read<UserProfileCubit>().state as UserProfileLoaded).user.name);
                              var result = await showDialog(
                                context: context,
                                builder: (context) {
                                  return GroupUpdateConstructor(isMobile: false, group: group,);
                                },
                              );
                              if(result) {
                                context.read<GroupOrderListCubit>().stopGroupEditing(group.groupID, (context.read<UserProfileCubit>().state as UserProfileLoaded).user.userID, (context.read<UserProfileCubit>().state as UserProfileLoaded).user.name);
                              } else {
                                context.read<GroupOrderListCubit>().stopGroupEditing(group.groupID, (context.read<UserProfileCubit>().state as UserProfileLoaded).user.userID, (context.read<UserProfileCubit>().state as UserProfileLoaded).user.name);
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
                                    'You are not eligible to add to group please contact Team Lead or Admin'),
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
                        break;
                      case 'Delete':
                        if(context.read<UserProfileCubit>().state is UserProfileLoaded) {
                          if((context.read<UserProfileCubit>().state as UserProfileLoaded).user.userRole == UserRoles.allRoles[1]) {
                            _confirmDeleteGroup(group, true);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                    'You are not eligible to delete this group please contact Team Lead or Admin'),
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
                      child: Text('Edit Group'),
                    ),
                    if(_selectedGroups.length > 1)...[
                      const PopupMenuItem(
                        value: 'EditBulk',
                        child: Text('Edit Groups'),
                      ),
                    ],
                      const PopupMenuItem(
                        value: 'Add',
                        child: Text('Constructor'),
                      ),
                    const PopupMenuItem(
                      value: 'Delete',
                      child: Text('Delete Group'),
                    ),
                  ],
                ),
              ),
            ),
          )
        ],
        children: [
          // Expanded Row 1: Order Column Headers
          ExpandableTableRow(
            firstCell: _buildSubHeaderCell('Order ID'),
            cells: [
              _buildSubHeaderCell('Order Name'),
              _buildSubHeaderCell('LDM'),
              _buildSubHeaderCell('Weight'),
              _buildSubHeaderCell('Pickup Place'),
              _buildSubHeaderCell('Pickup Date'),
              _buildSubHeaderCell('Driver Info'),
              _buildSubHeaderCell('Delivery Place'),
              _buildSubHeaderCell('Delivery Date'),
              _buildSubHeaderCell('Price'),
              _buildSubHeaderCell('Status'),
              _buildSubHeaderCell('Actions'),
            ],
          ),
          // Expanded Row 2: Order Data
          ...group.orders.map((order) => ExpandableTableRow(
            firstCell: _buildSubDataCell(order.orderID.toString()),
            cells: [
              _buildSubDataCell(order.orderName),
              _buildSubDataCell(order.ldm.toStringAsFixed(1)),
              _buildSubDataCell(order.weight.toStringAsFixed(1)),
              ExpandableTableCell(
                child: Container(
                  decoration: BoxDecoration(
                      color: AppColors.grey.withOpacity(0.1),
                      border: Border.all(
                          color: AppColors.grey.withOpacity(0.4)
                      )
                  ),
                  child: Center(
                    child: SelectableText(
                      '${order.pickupPlace.countryCode}, ${order.pickupPlace.postalCode}, ${order.pickupPlace.name}',
                    ),
                  ),
                ),
              ),
              ExpandableTableCell(
                  child: Container(
                    decoration: BoxDecoration(
                        color: AppColors.grey.withOpacity(0.1),
                        border: Border.all(
                            color: AppColors.grey.withOpacity(0.4)
                        )
                    ),
                    child: Center(
                      child: Text(
                        '${order.pickupTimeWindow.start.toString().split(' ')[0]} ${order.pickupTimeWindow.start?.hour}:${order.pickupTimeWindow.start?.minute.toString().padLeft(2, '0')}\n${order.pickupTimeWindow.end.toString().split(' ')[0]} ${order.pickupTimeWindow.end.hour}:${order.pickupTimeWindow.end.minute.toString().padLeft(2, '0')}',
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                  )
              ),
              ExpandableTableCell(
                child: Container(
                  decoration: BoxDecoration(
                      color: AppColors.grey.withOpacity(0.1),
                      border: Border.all(
                          color: AppColors.grey.withOpacity(0.4)
                      )
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Driver Name: ${order.driverInfo != null ? order.driverInfo!.driverName: 'N/A'}',
                          style: const TextStyle(fontSize: 14),
                        ),
                        Text('Driver Car: ${order.driverInfo != null ? order.driverInfo!.driverCar: 'N/A'}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontSize: 14, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              ExpandableTableCell(
                child: Container(
                  decoration: BoxDecoration(
                      color: AppColors.grey.withOpacity(0.1),
                      border: Border.all(
                          color: AppColors.grey.withOpacity(0.4)
                      )
                  ),
                  child: Center(
                    child: SelectableText(
                      '${order.deliveryPlace.countryCode}, ${order.deliveryPlace.postalCode}, ${order.deliveryPlace.name}',
                    ),
                  ),
                ),
              ),
              ExpandableTableCell(
                  child: Container(
                    decoration: BoxDecoration(
                        color: AppColors.grey.withOpacity(0.1),
                        border: Border.all(
                            color: AppColors.grey.withOpacity(0.4)
                        )
                    ),
                    child: Center(
                      child: Text(
                        '${order.deliveryTimeWindow.start.toString().split(' ')[0]} ${order.deliveryTimeWindow.start?.hour}:${order.deliveryTimeWindow.start?.minute.toString().padLeft(2, '0')}\n${order.deliveryTimeWindow.end.toString().split(' ')[0]} ${order.deliveryTimeWindow.end.hour}:${order.deliveryTimeWindow.end.minute.toString().padLeft(2, '0')}',
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                  )
              ),
              _buildSubDataCell(order.price.toStringAsFixed(2)),
              ExpandableTableCell(
                child: Container(
                  decoration: BoxDecoration(
                      color: AppColors.grey.withOpacity(0.1),
                      border: Border.all(
                          color: AppColors.grey.withOpacity(0.4)
                      )
                  ),
                  child: Center(
                    child: Container(
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
                ),
              ),
              ExpandableTableCell(
                child: Container(
                  decoration: BoxDecoration(
                      color: AppColors.grey.withOpacity(0.1),
                      border: Border.all(
                          color: AppColors.grey.withOpacity(0.4)
                      )
                  ),
                  child: Center(
                    child: PopupMenuButton<String>(
                      icon: Text('More', style: AppTextStyles.body14RobotoMedium.copyWith(color: AppColors.green),), // Three-dot icon
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8), // Rounded corners for the menu
                      ),
                      onSelected: (value) async{
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
                            if(context.read<UserProfileCubit>().state is UserProfileLoaded) {
                              if((context.read<UserProfileCubit>().state as UserProfileLoaded).user.userRole == UserRoles.allRoles[1] || (context.read<UserProfileCubit>().state as UserProfileLoaded).user.userID == group.creatorID) {
                                var canEditGroupOrder = await context.read<GroupOrderListCubit>().canEditGroupOrder(group.groupID);
                                if(canEditGroupOrder) {
                                  context.read<GroupOrderListCubit>().startGroupEditing(group.groupID, (context.read<UserProfileCubit>().state as UserProfileLoaded).user.userID, (context.read<UserProfileCubit>().state as UserProfileLoaded).user.name);
                                  var result = await showDialog(
                                    context: context,
                                    barrierDismissible: false,
                                    builder: (context) => EditOrderInGroupDialog(
                                      order: order,
                                      group: group,
                                    ),
                                  );
                                  if(result) {
                                    context.read<GroupOrderListCubit>().stopGroupEditing(group.groupID, (context.read<UserProfileCubit>().state as UserProfileLoaded).user.userID, (context.read<UserProfileCubit>().state as UserProfileLoaded).user.name);
                                  } else {
                                    context.read<GroupOrderListCubit>().stopGroupEditing(group.groupID, (context.read<UserProfileCubit>().state as UserProfileLoaded).user.userID, (context.read<UserProfileCubit>().state as UserProfileLoaded).user.name);
                                  }
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                          'Currently Someone else editing this order'),
                                    ),
                                  );
                                }
                              } else if((context.read<UserProfileCubit>().state as UserProfileLoaded).user.userRole == UserRoles.planner) {
                                var canEditGroupOrder = await context.read<GroupOrderListCubit>().canEditGroupOrder(group.groupID);
                                if(canEditGroupOrder) {
                                  context.read<GroupOrderListCubit>().startGroupEditing(group.groupID, (context.read<UserProfileCubit>().state as UserProfileLoaded).user.userID, (context.read<UserProfileCubit>().state as UserProfileLoaded).user.name);
                                  _showEditOrderDialog(order, group.groupID, group.lastModifiedAt, (context.read<UserProfileCubit>().state as UserProfileLoaded).user.userID, (context.read<UserProfileCubit>().state as UserProfileLoaded).user.name, (context.read<UserProfileCubit>().state as UserProfileLoaded).user.userRole == UserRoles.planner);
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
                      ],
                    ),
                  ),
                ),
              )
            ],
          )),
        ],
      );
    }).toList();
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

  void _showEditGroupOrderDialog(OrderGroupModel orderGroup, String userID, String userName, int isTeamLeadOrPlanner) async{
    if(0 == isTeamLeadOrPlanner) {
      showTopSnackbarInfo(context, 'You do not have access');
      return;
    }
    bool isNeedAddMore = orderGroup.isNeedAddMore;
    final driverNameController = TextEditingController(
        text: orderGroup.driverInfo?.driverName ?? '');
    final caCommentController = TextEditingController(
        text: orderGroup.carComment?.content ?? '');
    final driverIDController = TextEditingController(
        text: orderGroup.driverInfo?.driverCar ?? '');
    String? selectedCarType = orderGroup.driverInfo?.carTypeName;
    OrderStatus? selectedStatus = orderGroup.status;

    var result = await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setST) {
            return BlocConsumer<GroupOrderListCubit, GroupOrderListState>(
              listener: (context, state) {
                if (state is GroupOrderListActionSuccess) {
                  context.pop(true); // Close the dialog on success
                } else if (state is GroupOrderListActionError) {
                  showErrorNotification(context, state.message);
                }
              },
              builder: (context, state) {
                var isLoading = state is GroupOrderListActionLoading;
                return IgnorePointer(
                  ignoring: isLoading,
                  child: AlertDialog(
            backgroundColor: AppColors.white,
                title: Text('Edit Group Order: ${orderGroup.groupID}'),
                content: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Driver Name
                      TextField(
                        controller: caCommentController,
                        decoration: InputDecoration(
                          hintText: 'Car Comment',
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8)
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: driverNameController,
                        decoration: InputDecoration(
                          hintText: 'Driver Name',
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8)
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Driver ID
                      TextField(
                        controller: driverIDController,
                        decoration: InputDecoration(
                          hintText: 'Driver ID',
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8)
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Car Type Dropdown
                      DropdownButtonFormField<String>(
                        value: selectedCarType,
                        items: CarTypeModel.carTypes
                            .map(
                              (carType) => DropdownMenuItem(
                            value: carType.name,
                            child: Text(carType.name),
                          ),
                        )
                            .toList(),
                        decoration: const InputDecoration(labelText: 'Car Type'),
                        onChanged: (value) {
                          selectedCarType = value;
                        },
                      ),
                      const SizedBox(height: 12),
                      Container(
                        height: 50,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppColors.grey),
                            color: AppColors.white
                        ),
                        padding: EdgeInsets.symmetric(horizontal: 13),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Dokinte'),
                            Checkbox(
                              value: isNeedAddMore,
                              onChanged: (bool? value) {
                                setST(() {
                                  isNeedAddMore = value ?? false;
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Status Dropdown
                      DropdownButtonFormField<OrderStatus>(
                        value: selectedStatus,
                        items: [OrderStatus.Confirmed, OrderStatus.Assigned, OrderStatus.Loaded, OrderStatus.OnTheWay, OrderStatus.Unloaded, OrderStatus.Complete]
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
                      if (driverNameController.text.isNotEmpty && driverIDController.text.isNotEmpty && selectedCarType == null) {
                        showTopSnackbarError(context, 'Car Type is required.');
                        return;
                      } else if (driverNameController.text.isEmpty && driverIDController.text.isEmpty && selectedCarType == null) {
                        // All fields are empty, allow proceeding
                      } else if (driverNameController.text.isEmpty || driverIDController.text.isEmpty || selectedCarType == null) {
                        showTopSnackbarError(context, 'All Driver fields must be filled.');
                        return;
                      }

                      if(selectedStatus == OrderStatus.Assigned || selectedStatus == OrderStatus.Loaded || selectedStatus == OrderStatus.OnTheWay || selectedStatus == OrderStatus.Unloaded) {
                        if(driverNameController.text.isEmpty || driverIDController.text.isEmpty || selectedCarType == null) {
                          showTopSnackbarError(context, 'All Driver fields must be filled.');
                          return;
                        }
                      }
                      // Ensure driver info is updated or kept the same
                      final updatedDriverInfo = driverNameController.text.isNotEmpty &&
                          driverIDController.text.isNotEmpty &&
                          selectedCarType != null
                          ? DriverInfo(
                        driverName: driverNameController.text,
                        driverCar: driverIDController.text,
                        carTypeName: selectedCarType!,
                      )
                          : orderGroup.driverInfo;

                      var result = await context.read<UserProfileCubit>().checkIfUserProfileActive(context);
                      if(result) {
                        final user = context.read<UserProfileCubit>().state as UserProfileLoaded;

                        var isOrderLastStartGroupEditTimeChanged = await context.read<GroupOrderListCubit>().isOrderLastStartGroupEditTimeChanged(orderGroup.groupID, orderGroup.lastModifiedAt);
                        if(isOrderLastStartGroupEditTimeChanged) {
                          showErrorNotification(context, 'Group has been updated recently, please retrieve new data first');
                        } else {
                          // Update the group and orders using Cubit
                          Comment? carComment;

                          if (orderGroup.carComment != null) {
                            // If a car comment exists, check if it has changed
                            if (caCommentController.text == orderGroup.carComment!.content) {
                              carComment = orderGroup.carComment; // Keep existing comment
                            } else {
                              // If user typed something different, create a new comment
                              if (caCommentController.text.isNotEmpty) {
                                carComment = Comment(
                                  userID: user.user.userID,
                                  commenterName: user.user.name,
                                  content: caCommentController.text,
                                  timestamp: DateTime.now(),
                                );
                              } else {
                                carComment = null; // If cleared, remove the comment
                              }
                            }
                          } else {
                            // If no existing car comment, check if the user typed anything
                            if (caCommentController.text.isNotEmpty) {
                              carComment = Comment(
                                userID: user.user.userID,
                                commenterName: user.user.name,
                                content: caCommentController.text,
                                timestamp: DateTime.now(),
                              );
                            } else {
                              carComment = null; // No comment exists, and no new comment typed
                            }
                          }

                          context.read<GroupOrderListCubit>().editOrderInGroup(
                              orderGroup.groupID,
                              selectedStatus?.name ?? orderGroup.status.name,
                              updatedDriverInfo,
                              user.user.userID,
                              user.user.name,
                              isNeedAddMore,
                              carComment
                          );
                        }

                      } else {
                        showErrorNotification(context, 'Sorry action your connection is lost');
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
    if(result) {
      context.read<GroupOrderListCubit>().stopGroupEditing(orderGroup.groupID, userID, userName);
    } else {
      context.read<GroupOrderListCubit>().stopGroupEditing(orderGroup.groupID, userID, userName);
    }
  }

  void _showEditGroupsStatusDialog(Set<String> orderGroupsIds, OrderStatus status, String userID, String userName, int isTeamLeadOrPlanner) async{
    if(0 == isTeamLeadOrPlanner) {
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
            return BlocConsumer<GroupOrderListCubit, GroupOrderListState>(
              listener: (context, state) {
                if (state is GroupOrderListActionSuccess) {
                  context.pop(true); // Close the dialog on success
                } else if (state is GroupOrderListActionError) {
                  showErrorNotification(context, state.message);
                }
              },
              builder: (context, state) {
                var isLoading = state is GroupOrderListActionLoading;
                return IgnorePointer(
                  ignoring: isLoading,
                  child: AlertDialog(
            backgroundColor: AppColors.white,
                title: Text('Edit Groups Status'),
                content: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Status Dropdown
                      DropdownButtonFormField<OrderStatus>(
                        value: selectedStatus,
                        items: [OrderStatus.Confirmed, OrderStatus.Assigned, OrderStatus.Loaded, OrderStatus.OnTheWay, OrderStatus.Unloaded, OrderStatus.Complete]
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

                      var result = await context.read<UserProfileCubit>().checkIfUserProfileActive(context);
                      if(result) {
                        final user = context.read<UserProfileCubit>().state as UserProfileLoaded;
                          context.read<GroupOrderListCubit>().bulkUpdateGroupsAndOrdersStatus(
                              orderGroupsIds.toList(),
                              selectedStatus!,
                              user.user.userID,
                              user.user.name,
                          );

                      } else {
                        showErrorNotification(context, 'Sorry action your connection is lost');
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

  void _showEditOrderDialog(OrderModel order, String groupID, DateTime? lastModifiedAt, String userID, String userName, bool isPlanner) async{
    if(!isPlanner) {
      showTopSnackbarInfo(context, 'You do not have access');
      return;
    }
    final driverNameController = TextEditingController(
        text: order.driverInfo?.driverName ?? '');
    final driverIDController = TextEditingController(
        text: order.driverInfo?.driverCar ?? '');
    String? selectedCarType = order.driverInfo?.carTypeName;
    OrderStatus? selectedStatus = order.status;

    var result = await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
            builder: (context, setST) {
              return BlocConsumer<GroupOrderListCubit, GroupOrderListState>(
                listener: (context, state) {
                  if (state is GroupOrderListActionSuccess) {
                    context.pop(true); // Close the dialog on success
                  } else if (state is GroupOrderListActionError) {
                    showErrorNotification(context, state.message);
                  }
                },
                builder: (context, state) {
                  var isLoading = state is GroupOrderListActionLoading;
                  return IgnorePointer(
                    ignoring: isLoading,
                    child: AlertDialog(
                      backgroundColor: AppColors.white,
                      title: Text('Edit Order: ${order.orderID}'),
                      content: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Driver Name
                            TextField(
                              controller: driverNameController,
                              decoration: InputDecoration(
                                hintText: 'Driver Name',
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8)
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            // Driver ID
                            TextField(
                              controller: driverIDController,
                              decoration: InputDecoration(
                                hintText: 'Driver ID',
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8)
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            // Car Type Dropdown
                            DropdownButtonFormField<String>(
                              value: selectedCarType,
                              items: CarTypeModel.carTypes
                                  .map(
                                    (carType) => DropdownMenuItem(
                                  value: carType.name,
                                  child: Text(carType.name),
                                ),
                              )
                                  .toList(),
                              decoration: const InputDecoration(labelText: 'Car Type'),
                              onChanged: (value) {
                                selectedCarType = value;
                              },
                            ),
                            const SizedBox(height: 12),
                            // Status Dropdown
                            DropdownButtonFormField<OrderStatus>(
                              value: selectedStatus,
                              items: [OrderStatus.Assigned, OrderStatus.Loaded, OrderStatus.OnTheWay, OrderStatus.Unloaded].map(
                                    (status) => DropdownMenuItem(
                                  value: status,
                                  child: Text(status.name),
                                ),
                              ).toList(),
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

                            if (driverNameController.text.isNotEmpty && driverIDController.text.isNotEmpty && selectedCarType == null) {
                              showTopSnackbarError(context, 'Car Type is required.');
                              return;
                            } else if (driverNameController.text.isEmpty && driverIDController.text.isEmpty && selectedCarType == null) {
                              // All fields are empty, allow proceeding
                            } else if (driverNameController.text.isEmpty || driverIDController.text.isEmpty || selectedCarType == null) {
                              showTopSnackbarError(context, 'All Driver fields must be filled.');
                              return;
                            }

                            if(selectedStatus == OrderStatus.Assigned || selectedStatus == OrderStatus.Loaded || selectedStatus == OrderStatus.OnTheWay || selectedStatus == OrderStatus.Unloaded) {
                              if(driverNameController.text.isEmpty || driverIDController.text.isEmpty || selectedCarType == null) {
                                showTopSnackbarError(context, 'All Driver fields must be filled.');
                                return;
                              }
                            }
                            // Ensure driver info is updated or kept the same
                            final updatedDriverInfo = driverNameController.text.isNotEmpty &&
                                driverIDController.text.isNotEmpty &&
                                selectedCarType != null
                                ? DriverInfo(
                              driverName: driverNameController.text,
                              driverCar: driverIDController.text,
                              carTypeName: selectedCarType!,
                            )
                                : order.driverInfo;

                            // Save order via cubit
                            var result = await context.read<UserProfileCubit>().checkIfUserProfileActive(context);
                            if(result) {
                              final user = context.read<UserProfileCubit>().state as UserProfileLoaded;
                              final updatedOrder = order.copyWith(
                                orderName: order.orderName,
                                pickupPlace: order.pickupPlace,
                                deliveryPlace: order.deliveryPlace,
                                ldm: order.ldm,
                                weight: order.weight,
                                price: order.price,
                                carTypeName: updatedDriverInfo != null? updatedDriverInfo.carTypeName: order.carTypeName,
                                driverInfo: updatedDriverInfo,
                                status: selectedStatus?? order.status,
                                pickupTimeWindow: order.pickupTimeWindow,
                                deliveryTimeWindow: order.deliveryTimeWindow,
                                isAdrOrder: order.isAdrOrder,
                                canGroupWithAdr: order.canGroupWithAdr,
                              );

                              var isOrderLastStartGroupEditTimeChanged = await context.read<GroupOrderListCubit>().isOrderLastStartGroupEditTimeChanged(groupID, lastModifiedAt);
                              if(isOrderLastStartGroupEditTimeChanged) {
                                showErrorNotification(context, 'Group has been updated recently, please retrieve new data first');
                              } else {
                                context.read<GroupOrderListCubit>().updateOrderAndGroupOrderStatus(updatedOrder, groupID, user.user.userID, user.user.username);
                              }
                            } else {
                              showErrorNotification(context, 'Sorry action your connection is lost');
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
    if(result) {
      context.read<GroupOrderListCubit>().stopGroupEditing(groupID, userID, userName);
    } else {
      context.read<GroupOrderListCubit>().stopGroupEditing(groupID, userID, userName);
    }
  }

  void _showGroupDetails(OrderGroupModel group, bool isTeamLead) {
    log(group.toJson().toString(), level: 2000);
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierLabel: "GroupDetails",
      pageBuilder: (context, _, __) {
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
                    // Top Bar: Group ID and Close Button
                    if(responsiveScreenSize.isTabletScreen(context) || responsiveScreenSize.isMobileScreen(context))...[
                      SizedBox(
                        height: 20,
                      ),
                    ],
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SelectableText(
                          'Group ID: ${group.groupID}',
                          style: AppTextStyles.head20RobotoMedium,
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => context.pop(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Group Overview Map Placeholder
                    buildGroupMapPlaceholder(group),
                    const SizedBox(height: 12),
                    buildFullRouteWidget(group),
                    const SizedBox(height: 12),
                    // Pickup and Delivery Timelines
                    buildGroupTimelineSection(group),
                    const SizedBox(height: 12),
                    // Group Data
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        buildSectionTitle('Group Details'),
                        const SizedBox(height: 5),
                        buildGroupDetails(group),
                        const SizedBox(height: 12),
                        buildOrderDriverDetails(group.driverInfo),
                        const SizedBox(height: 12),
                        buildSectionTitle('Group Creator'),
                        const SizedBox(height: 5),
                        buildGroupCreator(group),
                        const SizedBox(height: 12),
                        buildSectionTitle('Comments'),
                        const SizedBox(height: 5),
                        buildGroupCommentsSection(group, true, context),
                        if (isTeamLead) ...[
                          const SizedBox(height: 12),
                          buildSectionTitle('Logs'),
                          const SizedBox(height: 5),
                          buildGroupLogsSection(group),
                        ],
                        //TODO
                        // const SizedBox(height: 12),
                        // ElevatedButton.icon(
                        //   icon: const Icon(Icons.file_download),
                        //   label: const Text('Export Group'),
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
      },
    );
  }

  void _confirmDeleteGroup(OrderGroupModel group, bool isTeamLead) async{
    if(isTeamLead == false) {
      showTopSnackbarInfo(context, 'You do not have access');
      return;
    }
    var result = await showDialog(
      context: context,
      builder: (context) {
        return BlocConsumer<GroupOrderListCubit, GroupOrderListState>(
          listener: (context, state) {
            if (state is GroupOrderListActionSuccess) {
              if(_selectedGroups.contains(group.groupID)) {
              _selectedGroups.remove(group.groupID);
            }
              context.pop(true);
            } else if (state is GroupOrderListActionError) {
              showErrorNotification(context, state.message);
            }
          },
          builder: (context, state) {
            final isLoading = context
                .read<GroupOrderListCubit>()
                .deletingGroupID == group.groupID;
            return AlertDialog(
              backgroundColor: AppColors.white,
              title: const Text('Delete Order'),
              content: Text(
                  'Are you sure you want to delete "${group.groupID}"?'),
              actions: [
                OutlinedButton.icon(
                  onPressed: () {
                    context.pop(false);
                  },
                  label: Text('Cancel'),
                ),
                ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.red
                    ),
                    onPressed: isLoading
                        ? null // Disable the button while loading
                        : () async {
                      var result = await context.read<UserProfileCubit>()
                          .checkIfUserProfileActive(context);
                      if (result) {
                        final user = context
                            .read<UserProfileCubit>()
                            .state as UserProfileLoaded;
                        context.read<GroupOrderListCubit>().deleteGroup(
                          group.groupID,
                          OrderStatus.Pending,
                          user.user.userID, // Replace with actual userID
                          user.user.username, // Replace with actual userName
                        );
                      } else {
                        showErrorNotification(
                            context, 'Sorry action your connection is lost');
                      }
                    },
                    child: isLoading
                        ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.0,
                        color: Colors.white,
                      ),
                    ): Text("Delete",
                        style: AppTextStyles.body17RobotoMedium.copyWith(
                            color: AppColors.white)),
                )
              ],
            );
          }
        );
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