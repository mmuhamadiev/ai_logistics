import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_pagination/firebase_pagination.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ai_logistics_management_order_automation/config/app_colors.dart';
import 'package:ai_logistics_management_order_automation/config/app_text_styles.dart';
import 'package:ai_logistics_management_order_automation/config/constants.dart';
import 'package:ai_logistics_management_order_automation/config/screen_size.dart';
import 'package:ai_logistics_management_order_automation/domain/models/commnet_model.dart';
import 'package:ai_logistics_management_order_automation/domain/models/order_group_model.dart';
import 'package:ai_logistics_management_order_automation/domain/models/order_model.dart';
import 'package:ai_logistics_management_order_automation/presentation/manager/group_order_list/group_order_list_cubit.dart';
import 'package:ai_logistics_management_order_automation/presentation/manager/order_list/order_list_cubit.dart';
import 'package:ai_logistics_management_order_automation/presentation/manager/user_profile_cubit/user_profile_cubit.dart';
import 'package:ai_logistics_management_order_automation/presentation/pages/dashboard/components/order_details_dialog_components.dart';
import 'package:ai_logistics_management_order_automation/presentation/pages/dashboard/components/order_group_detail_dialog_component.dart';
import 'package:ai_logistics_management_order_automation/presentation/widgets/clock.dart';
import 'package:ai_logistics_management_order_automation/presentation/widgets/map_view_widget.dart';
import 'package:ai_logistics_management_order_automation/presentation/widgets/notifications/error_notification.dart';
import 'package:intl/intl.dart';

class AdminDashboardView extends StatefulWidget {
  @override
  _AdminDashboardViewState createState() => _AdminDashboardViewState();
}

class _AdminDashboardViewState extends State<AdminDashboardView> {

  ResponsiveScreenSize responsiveScreenSize = ResponsiveScreenSize();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (responsiveScreenSize.isDesktopScreen(context)) {
          return Scaffold(
            backgroundColor: AppColors.lightGray,
            body: Column(
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
                        "Dashboard",
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
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Main Dashboard Content
                        Expanded(
                          flex: 4, // Adjust the proportion as needed
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 16),
                              // Key Metrics Section
                              _buildKeyMetrics(responsiveScreenSize.isMobileScreen(context) || responsiveScreenSize.isTabletScreen(context)),

                              const SizedBox(height: 16),
                              Expanded(
                                child: Card(
                                  elevation: 2,
                                  color: AppColors.white,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  child: Column(
                                    children: [
                                      // Section Title
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Recent Orders',
                                              style: AppTextStyles.head22RobotoMedium,
                                            ),
                                          ],
                                        ),
                                      ),
                                      const Divider(),
                                      // List of Items
                                      Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: FirestorePagination(
                                            query: FirebaseFirestore.instance
                                                .collection('orders') // Replace with your collection
                                                .orderBy('createdAt', descending: true),
                                            isLive: true, // Enables real-time updates
                                            limit: 10, // Number of items per page
                                            onEmpty: Column(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                Text(
                                                  'No Orders Available',
                                                  style: AppTextStyles.body16RobotoMedium
                                                      .copyWith(color: AppColors.lightBlue),
                                                ),
                                              ],
                                            ),
                                            itemBuilder: (context, documentSnapshot, index) {
                                              final order = OrderModel.fromJson(documentSnapshot[index].data() as Map<String, dynamic>);

                                              return _buildOrderCard(order);
                                            },
                                            bottomLoader: Center(child: CircularProgressIndicator()),
                                            initialLoader: Center(child: CircularProgressIndicator()),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              const SizedBox(height: 16),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),

                        // Right Panel for Newly Added Orders and Confirmed Groups
                        Expanded(
                          flex: 2, // Adjust the proportion as needed
                          child: _buildRightPanel(),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        } else if (responsiveScreenSize.isTabletScreen(context)) {
          return Scaffold(
            backgroundColor: AppColors.lightGray,
            body: Column(
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
                        "Dashboard",
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
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      // crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Main Dashboard Content
                        Expanded(
                          flex: 4, // Adjust the proportion as needed
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 16),
                              // Key Metrics Section
                              _buildKeyMetrics(responsiveScreenSize.isMobileScreen(context) || responsiveScreenSize.isTabletScreen(context)),

                              const SizedBox(height: 16),
                              Expanded(
                                child: Card(
                                  elevation: 2,
                                  color: AppColors.white,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  child: Column(
                                    children: [
                                      // Section Title
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Recent Orders',
                                              style: AppTextStyles.head22RobotoMedium,
                                            ),
                                          ],
                                        ),
                                      ),
                                      const Divider(),
                                      // List of Items
                                      Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: FirestorePagination(
                                            query: FirebaseFirestore.instance
                                                .collection('orders') // Replace with your collection
                                                .orderBy('createdAt', descending: true),
                                            isLive: true, // Enables real-time updates
                                            limit: 10, // Number of items per page
                                            onEmpty: Column(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                Text(
                                                  'No Orders Available',
                                                  style: AppTextStyles.body16RobotoMedium
                                                      .copyWith(color: AppColors.lightBlue),
                                                ),
                                              ],
                                            ),
                                            itemBuilder: (context, documentSnapshot, index) {
                                              final order = OrderModel.fromJson(documentSnapshot[index].data() as Map<String, dynamic>);

                                              return _buildOrderCard(order);
                                            },
                                            bottomLoader: Center(child: CircularProgressIndicator()),
                                            initialLoader: Center(child: CircularProgressIndicator()),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              const SizedBox(height: 16),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),

                        // Right Panel for Newly Added Orders and Confirmed Groups
                        Expanded(
                          flex: 2, // Adjust the proportion as needed
                          child: _buildRightPanel(),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        } else {
          return Scaffold(
            backgroundColor: AppColors.lightGray,
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
                        "Dashboard",
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
                BeautifulClock(),
                Divider(
                  thickness: 1,
                  height: 1,
                ),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      // crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Main Dashboard Content
                        Expanded(
                          flex: 3, // Adjust the proportion as needed
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 16),
                              Expanded(
                                child: Card(
                                  elevation: 2,
                                  color: AppColors.white,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  child: Column(
                                    children: [
                                      // Section Title
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Recent Orders',
                                              style: AppTextStyles.head22RobotoMedium,
                                            ),
                                          ],
                                        ),
                                      ),
                                      const Divider(),
                                      // List of Items
                                      Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: FirestorePagination(
                                            query: FirebaseFirestore.instance
                                                .collection('orders') // Replace with your collection
                                                .orderBy('createdAt', descending: true),
                                            isLive: true, // Enables real-time updates
                                            limit: 10, // Number of items per page
                                            onEmpty: Column(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                Text(
                                                  'No Orders Available',
                                                  style: AppTextStyles.body16RobotoMedium
                                                      .copyWith(color: AppColors.lightBlue),
                                                ),
                                              ],
                                            ),
                                            itemBuilder: (context, documentSnapshot, index) {
                                              final order = OrderModel.fromJson(documentSnapshot[index].data() as Map<String, dynamic>);

                                              return _buildOrderCard(order);
                                            },
                                            bottomLoader: Center(child: CircularProgressIndicator()),
                                            initialLoader: Center(child: CircularProgressIndicator()),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),

                        // Right Panel for Newly Added Orders and Confirmed Groups
                        Expanded(
                          flex: 2, // Adjust the proportion as needed
                          child: _buildRightPanel(),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        }
      },
    );
  }

  Widget _buildRightPanel() {
    return Column(
      children: [
        const SizedBox(height: 16),
        // Section: Confirmed Connected Order Groups
        Expanded(
          child: Card(
            elevation: 2,
            color: AppColors.white,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8)),
            child: Column(
              children: [
                // Section Title
                const SizedBox(
                  height: 10,
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        'Confirmed Order Groups',
                        style: AppTextStyles.head22RobotoMedium,
                      ),
                    ],
                  ),
                ),
                const Divider(),
                // List of Items

                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: FirestorePagination(
                      query: FirebaseFirestore.instance
                          .collection('orderGroups') // Replace with your collection
                          .orderBy('createdAt', descending: true),
                      isLive: true, // Enables real-time updates
                      limit: 10, // Number of items per page
                      onEmpty: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'No Group Orders Available',
                            style: AppTextStyles
                                .body16RobotoMedium
                                .copyWith(
                                color: AppColors
                                    .lightBlue),
                          ),
                        ],
                      ),
                      itemBuilder: (context, documentSnapshot, index) {
                        final group = OrderGroupModel.fromJson(documentSnapshot[index].data() as Map<String, dynamic>);

                        return _buildConnectedGroupCard(group);
                      },
                      bottomLoader: Center(child: CircularProgressIndicator()),
                      initialLoader: Center(child: CircularProgressIndicator()),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
        // BlocBuilder<GroupOrderListCubit, GroupOrderListState>(
        //   builder: (context, state) {
        //     if (state is GroupOrderListLoading) {
        //       return const Center(child: CircularProgressIndicator());
        //     } else if (state is GroupOrderListLoaded) {
        //       if (state.groups.length == 0) {
        //         return Expanded(
        //           child: Card(
        //             elevation: 2,
        //             color: AppColors.white,
        //             shape: RoundedRectangleBorder(
        //                 borderRadius: BorderRadius.circular(8)),
        //             child: Column(
        //               children: [
        //                 // Section Title
        //                 const SizedBox(
        //                   height: 10,
        //                 ),
        //                 Padding(
        //                   padding: const EdgeInsets.all(8.0),
        //                   child: Row(
        //                     mainAxisAlignment: MainAxisAlignment.start,
        //                     children: [
        //                       Text(
        //                         'Confirmed Order Groups',
        //                         style: AppTextStyles.head22RobotoMedium,
        //                       ),
        //                     ],
        //                   ),
        //                 ),
        //                 const Divider(),
        //                 // List of Items
        //                 Expanded(
        //                   child: Column(
        //                     mainAxisAlignment: MainAxisAlignment.center,
        //                     children: [
        //                       Text(
        //                         'No Group Orders Available',
        //                         style: AppTextStyles.body16RobotoMedium
        //                             .copyWith(color: AppColors.lightBlue),
        //                       ),
        //                     ],
        //                   ),
        //                 )
        //               ],
        //             ),
        //           ),
        //         );
        //       } else {
        //         return buildPanelSection(
        //           title: "Confirmed Order Groups",
        //           itemCount: state.groups.length,
        //           itemBuilder: (context, index) {
        //             final group = state.groups[index];
        //             return _buildConnectedGroupCard(group);
        //           },
        //         );
        //       }
        //     } else if (state is GroupOrderListError) {
        //       return Center(child: Text(state.message));
        //     } else {
        //       return buildPanelSection(
        //         title: "Confirmed Order Groups",
        //         itemCount: 0,
        //         itemBuilder: (context, index) => const SizedBox.shrink(),
        //       );
        //     }
        //   },
        // ),
        const SizedBox(height: 16),
        // Recent Logs Section

        // _buildRecentLogs(context),
      ],
    );
  }

  Widget _buildOrderCard(OrderModel order) {
    return Column(
      children: [
        ListTile(
          leading: Icon(Icons.local_shipping, color: AppColors.grey),
          title: SelectableText(
            "Order: ${order.orderID}",
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
              Text("Status: ${order.status.name}"),
              Text(
                "Created: ${DateFormat('dd.MM.yyyy HH:mm').format(order.createdAt)}",
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
            ],
          ),
          trailing: Container(
            decoration: BoxDecoration(
                border: Border.all(color: AppColors.black, width: 1),
                borderRadius: BorderRadius.circular(8)),
            child: TextButton(
              onPressed: () => _showOrderDetails(
                  order,
                  context.read<UserProfileCubit>().state is UserProfileLoaded
                      ? (context.read<UserProfileCubit>().state
                  as UserProfileLoaded)
                      .user
                      .userRole ==
                      UserRoles.allRoles[1]
                      : false,
                  false
              ),
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

  Widget _buildConnectedGroupCard(OrderGroupModel group) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      padding: EdgeInsets.all(12),
      margin: EdgeInsets.symmetric(vertical: 5),
      child: Stack(
        alignment: Alignment.centerRight,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SelectableText(group.groupID,
                      style: AppTextStyles.body16RobotoMedium
                          .copyWith(fontWeight: FontWeight.bold)),
                  Text("${group.orders.length} orders",
                      style: AppTextStyles.body15RobotoMedium
                          .copyWith(color: AppColors.grey)),
                ],
              ),
              SizedBox(height: 8),
              RichText(
                text: TextSpan(
                    text: "Total LDM: ",
                    style: AppTextStyles.body15RobotoMedium
                        .copyWith(color: AppColors.black.withOpacity(0.8)),
                    children: [
                      TextSpan(
                          text: "${group.totalLDM.toStringAsFixed(1)}",
                          style: AppTextStyles.body15RobotoMedium.copyWith(
                              color: AppColors.black,
                              fontWeight: FontWeight.bold),
                          children: []),
                    ]),
              ),
              SizedBox(height: 4),
              RichText(
                text: TextSpan(
                    text: "Total Weight: ",
                    style: AppTextStyles.body15RobotoMedium
                        .copyWith(color: AppColors.black.withOpacity(0.8)),
                    children: [
                      TextSpan(
                          text: "${group.totalWeight.toStringAsFixed(1)}",
                          style: AppTextStyles.body15RobotoMedium.copyWith(
                              color: AppColors.black,
                              fontWeight: FontWeight.bold),
                          children: []),
                    ]),
              ),
              SizedBox(height: 4),
              RichText(
                text: TextSpan(
                    text: "Total Distance: ",
                    style: AppTextStyles.body15RobotoMedium
                        .copyWith(color: AppColors.black.withOpacity(0.8)),
                    children: [
                      TextSpan(
                          text: "${group.totalDistance.toStringAsFixed(2)} km",
                          style: AppTextStyles.body15RobotoMedium.copyWith(
                              color: AppColors.black,
                              fontWeight: FontWeight.bold),
                          children: []),
                    ]),
              ),
              SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  RichText(
                    text: TextSpan(
                        text: "Total Price: ",
                        style: AppTextStyles.body15RobotoMedium
                            .copyWith(color: AppColors.black.withOpacity(0.8)),
                        children: [
                          TextSpan(
                            text: "€${group.totalPrice}",
                            style: AppTextStyles.body15RobotoMedium.copyWith(
                                color: AppColors.black,
                                fontWeight: FontWeight.bold),
                          ),
                        ]),
                  ),
                  Text(
                      "${DateFormat('dd.MM.yyyy HH:mm').format(group.createdAt)}",
                      style: AppTextStyles.body13RobotoMedium
                          .copyWith(color: AppColors.grey)),
                ],
              ),
            ],
          ),
          TextButton(
            onPressed: () {
              _showGroupDetails(
                  group,
                  context.read<UserProfileCubit>().state is UserProfileLoaded
                      ? (context.read<UserProfileCubit>().state
                  as UserProfileLoaded)
                      .user
                      .userRole ==
                      UserRoles.allRoles[1]
                      : false);
            },
            style: TextButton.styleFrom(
                padding: EdgeInsets.zero, backgroundColor: AppColors.lightGray),
            child: Text(
              'View',
              style: AppTextStyles.body17RobotoMedium
                  .copyWith(color: AppColors.lightBlue),
            ),
          )
        ],
      ),
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

  void _showGroupDetails(OrderGroupModel group, bool isTeamLead) {
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
                        buildGroupCommentsSection(group, false, context),
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

  Widget _buildKeyMetrics(bool isSmallScreen) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('metrics').doc('orders_count').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data == null) {
          return Center(child: CircularProgressIndicator());
        }

        final data = snapshot.data!.data() as Map<String, dynamic>? ?? {};
        var statusCounts = data["statusCounts"] as Map<String, dynamic>? ?? {};

        // Extract metrics safely
        final totalOrders = data['totalOrders'] ?? 0;
        final confirmedOrders = statusCounts['Confirmed'] ?? 0;
        final pendingOrders = statusCounts['Pending'] ?? 0;
        final completeOrders = statusCounts['Complete'] ?? 0;

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildMetricCard("Total Orders", totalOrders.toString(),
                AppColors.grey.withOpacity(0.6), AppColors.black, Icons.list, isSmallScreen),
            _buildMetricCard("Confirmed Groups", confirmedOrders.toString(),
                AppColors.lightGreen, AppColors.green, Icons.check, isSmallScreen),
            _buildMetricCard(
                "Pending Orders",
                pendingOrders.toString(),
                AppColors.grey.withOpacity(0.6),
                AppColors.black,
                Icons.pending_actions, isSmallScreen),
            _buildMetricCard(
                "Complete Orders",
                completeOrders.toString(),
                AppColors.grey.withOpacity(0.6),
                AppColors.black,
                Icons.done_all, isSmallScreen),
          ],
        );
      },
    );
  }

  Widget _buildMetricCard(String title, String value, Color boxColor,
      Color iconColor, IconData icon, bool isSmallScreen) {
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
                      borderRadius: BorderRadius.circular(8), color: boxColor),
                  child: Icon(
                    icon,
                    color: iconColor,
                  ),
                ),
                const SizedBox(
                  width: 20,
                ),
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
                    // const SizedBox(height: 8),
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
}



