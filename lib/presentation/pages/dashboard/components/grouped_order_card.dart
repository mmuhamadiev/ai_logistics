import 'dart:developer';

import 'package:ai_logistics_management_order_automation/data/services/genkit.dart';
import 'package:ai_logistics_management_order_automation/domain/models/grouping_helper_result_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:ai_logistics_management_order_automation/config/app_colors.dart';
import 'package:ai_logistics_management_order_automation/config/app_text_styles.dart';
import 'package:ai_logistics_management_order_automation/config/constants.dart';
import 'package:ai_logistics_management_order_automation/config/screen_size.dart';
import 'package:ai_logistics_management_order_automation/utils/adr_validator_service.dart';
import 'package:ai_logistics_management_order_automation/domain/models/car_type_model.dart';
import 'package:ai_logistics_management_order_automation/domain/models/order_group_model.dart';
import 'package:ai_logistics_management_order_automation/presentation/manager/filter/filter_cubit.dart';
import 'package:ai_logistics_management_order_automation/presentation/manager/group_order_list/group_order_list_cubit.dart';
import 'package:ai_logistics_management_order_automation/presentation/manager/user_profile_cubit/user_profile_cubit.dart';
import 'package:ai_logistics_management_order_automation/presentation/pages/dashboard/components/order_details_dialog_components.dart';
import 'package:ai_logistics_management_order_automation/presentation/pages/dashboard/components/order_group_detail_dialog_component.dart';
import 'package:ai_logistics_management_order_automation/presentation/widgets/notifications/error_notification.dart';
import 'package:ai_logistics_management_order_automation/presentation/widgets/notifications/top_snackbar_info.dart';
import 'package:ai_logistics_management_order_automation/utils/clustering_dbscan_service.dart';
import 'package:ai_logistics_management_order_automation/utils/route_optimizer.dart';
import 'package:ai_logistics_management_order_automation/utils/time_manager.dart';

class GroupInfoCard extends StatefulWidget {
  final OrderGroupModel orderGroup;

  const GroupInfoCard({super.key, required this.orderGroup});

  @override
  State<GroupInfoCard> createState() => _GroupInfoCardState();
}

class _GroupInfoCardState extends State<GroupInfoCard> {

  ResponsiveScreenSize responsiveScreenSize = ResponsiveScreenSize();

  late List<int> optimizedRoute;
  late List<String> orderIdNamesList;
  late List<String> postalCodeNamesList;

  late double totalPrice;
  late double totalDistance;
  late double pricePerKm;
  late double totalLDM;
  late double totalWeight;

  late bool validateLDM;
  late bool validateWeight;
  late bool validateDate;
  late bool validateAdr;
  bool _isAiConfirmLoading = false;

  late CarTypeModel carType;

  AdrValidatorService adrValidatorService = AdrValidatorService();

  @override
  void initState() {
    super.initState();

    optimizedRoute = [];
    orderIdNamesList = [];
    postalCodeNamesList = [];

    totalPrice = 0.0;
    totalDistance = 0.0;
    pricePerKm = 0.0;
    totalLDM = 0.0;
    totalWeight = 0.0;

    validateLDM = false;
    validateWeight = false;
    validateDate = false;
    validateAdr = false;

    carType = CarTypeModel.carTypes.firstWhere(
          (type) => type.name == widget.orderGroup.orders.first.carTypeName,
      orElse: () => CarTypeModel.carTypes.first,
    );

    _initializeData();
  }

  void _initializeData() {
    if (widget.orderGroup.orders.length > 1) {
      optimizedRoute = RouteOptimizer.optimizeRoute(widget.orderGroup.orders);

      for (var order in widget.orderGroup.orders) {
        orderIdNamesList.add(order.orderID);
      }

      for (int index in optimizedRoute) {
        if (index < widget.orderGroup.orders.length) {
          postalCodeNamesList.add(
              '${widget.orderGroup.orders[index].pickupPlace.postalCode} ${widget.orderGroup.orders[index].pickupPlace.countryCode} ${widget.orderGroup.orders[index].pickupPlace.name}');
          postalCodeNamesList.add(
              '${widget.orderGroup.orders[index].deliveryPlace.postalCode} ${widget.orderGroup.orders[index].deliveryPlace.countryCode} ${widget.orderGroup.orders[index].deliveryPlace.name}');
        }
      }
    } else {
      final order = widget.orderGroup.orders.first;
      orderIdNamesList.add(order.orderID);
      postalCodeNamesList.add(
          '${order.pickupPlace.postalCode} ${order.pickupPlace.countryCode} ${order.pickupPlace.name}');
      postalCodeNamesList.add(
          '${order.deliveryPlace.postalCode} ${order.deliveryPlace.countryCode} ${order.deliveryPlace.name}');
    }

    if (widget.orderGroup.orders.length == 1) {
      final order = widget.orderGroup.orders.first;
      totalPrice = order.price;
      totalDistance = ClusteringDBSCANService.calculateDistance(
        order.pickupPlace.latitude,
        order.pickupPlace.longitude,
        order.deliveryPlace.latitude,
        order.deliveryPlace.longitude,
      );
      pricePerKm = ClusteringDBSCANService.calculateOrderPricePerKm(order);
      totalLDM = order.ldm;
      totalWeight = order.weight;
      validateLDM = totalLDM <= carType.length;
      validateWeight = totalWeight <= carType.maxWeight;
      validateDate = true;
      validateAdr = adrValidatorService.canGroupOrders(widget.orderGroup.orders);
    } else {
      List<int> optimizedGroup =
      RouteOptimizer.optimizeRoute(widget.orderGroup.orders);
      totalDistance = ClusteringDBSCANService.calculateRouteDistance(
        widget.orderGroup.orders,
        optimizedGroup,
      );
      totalPrice = widget.orderGroup.orders.fold(0, (sum, o) => sum + o.price);
      pricePerKm = totalDistance > 0 ? totalPrice / totalDistance : 0.0;
      totalWeight =
          widget.orderGroup.orders.fold(0, (sum, o) => sum + o.weight);
      totalLDM = widget.orderGroup.orders.fold(0, (sum, o) => sum + o.ldm);
      validateLDM = totalLDM <= carType.length;
      validateWeight = totalWeight <= carType.maxWeight;
      validateDate = TimeManager.validateTimeWindows(widget.orderGroup.orders, optimizedGroup);
      validateAdr = adrValidatorService.canGroupOrders(widget.orderGroup.orders);
    }
  }

  Future<void> _aiConfirmOrder(BuildContext context) async {
    try {
      // Step 1: Fetch the global filter
      await context.read<FilterCubit>().fetchFilter();
      final filterState = context.read<FilterCubit>().state;

      if (filterState is FilterLoaded) {
        final filter = filterState.filter;

          // Criteria met: Add order directly
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
                .addOrderGroup(
                widget.orderGroup,
                user.user.userID,
                user.user.name);
          } else {
            showErrorNotification(context,
                'Sorry action your connection is lost');
          }
      } else if (filterState is FilterError) {
        // Handle filter fetch error
        showErrorNotification(context, filterState.message);
      } else {
        // Handle unexpected state
        showErrorNotification(context, 'Failed to validate filter criteria. Please try again.');
      }
    } catch (e) {
      // Handle any other errors
      showErrorNotification(context, 'Error fetching filter: ${e.toString()}');
    }
  }

  Future<void> _confirmOrder(BuildContext context) async {
    try {
      // Step 1: Fetch the global filter
      await context.read<FilterCubit>().fetchFilter();
      final filterState = context.read<FilterCubit>().state;

      if (filterState is FilterLoaded) {
        final filter = filterState.filter;

        // Step 2: Validate the group order against the filter criteria
        final isWithinRadius = widget.orderGroup.totalDistance <= filter.maxRadius;
        final meetsPricePerKmThreshold = widget.orderGroup.pricePerKm >= filter.pricePerKmThreshold;

        if (isWithinRadius && meetsPricePerKmThreshold) {
          // Criteria met: Add order directly
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
                .addOrderGroup(
                widget.orderGroup,
                user.user.userID,
                user.user.name);
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
                    child: const Text('Confirm'),
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
                  .addOrderGroup(
                  widget.orderGroup,
                  user.user.userID,
                  user.user.name);
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
        showErrorNotification(context, 'Failed to validate filter criteria. Please try again.');
      }
    } catch (e) {
      // Handle any other errors
      showErrorNotification(context, 'Error fetching filter: ${e.toString()}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 445.h,
      child: Card(
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Group ID
              SelectableText.rich(
                TextSpan(
                  style: const TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),
                  children: [
                    const TextSpan(text: "Group ID: "),
                    TextSpan(text: widget.orderGroup.groupID, style: const TextStyle(fontWeight: FontWeight.w900)),
                  ],
                ),
              ),
              const SizedBox(height: 4),

              // Order ID
              SelectableText(
                "Orders ID: ${orderIdNamesList.join('-')}",
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 5),

              // Route Information
              _buildSectionTitle("Route Information"),
              _buildRouteInfo(postalCodeNamesList),

              const SizedBox(height: 5),

              // Total Distance & Price per km
              Row(
                children: [
                  _buildInfoBox(Icons.directions_car, "Total Distance", "${totalDistance.toStringAsFixed(2)} km"),
                  const SizedBox(width: 10),
                  _buildInfoBox(Icons.inventory, "Total LDM", "${totalLDM.toStringAsFixed(1)}"),
                  const SizedBox(width: 10),
                  _buildInfoBox(Icons.scale, "Total Weight", "${totalWeight.toStringAsFixed(1)} tons"),
                ],
              ),
              const SizedBox(height: 5),
              // Validations
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildValidationBox("LDM Valid", validateLDM),
                  _buildValidationBox("Weight Valid", validateWeight),
                  _buildValidationBox("Dates Valid", validateDate),
                  _buildValidationBox("ADR Valid", validateAdr),
                ],
              ),
              const Spacer(),

              // Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  _buildInfoBox(Icons.euro, "Total Price", "${widget.orderGroup.totalPrice} km"),
                  const SizedBox(width: 10),
                  _buildInfoBox(Icons.euro, "Price per km", "${widget.orderGroup.pricePerKm.toStringAsFixed(2)} EUR/km"),
                  Spacer(),
                  OutlinedButton(
                    onPressed: () {
                      _aiConfirmGroup(context);
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.black,
                      side: const BorderSide(color: Colors.black),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    ),
                    child: _isAiConfirmLoading
                        ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                        :Text('Ai Confirm'),
                  ),
                  _buildOutlinedButton("View Details", widget.orderGroup),
                  // const SizedBox(width: 10),
                  // _buildConfirmButton("Confirm Group"),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _aiConfirmGroup(BuildContext context) async {
    log(widget.orderGroup.toJson().toString());

    setState(() => _isAiConfirmLoading = true);
    try {
      final input = widget.orderGroup.toGenkitJson();
      final result = await Genkit.groupingHelperFlow(input);
      await showGroupingHelperResultDialog(context, result);
      // Use result as needed
    } catch (e, stack) {
      print('Error in groupingHelperFlow: $e');
      print('Stack trace: $stack');
      showErrorNotification(context, 'AI grouping failed');
    } finally {
      setState(() => _isAiConfirmLoading = false);
    }
  }

  Future<void> showGroupingHelperResultDialog(BuildContext context, GroupingHelperResultModel result) {
    if(result.isGoodGroup == true) {
      var isTeamLead = context.read<UserProfileCubit>().state is UserProfileLoaded? (context.read<UserProfileCubit>().state as UserProfileLoaded).user.userRole == UserRoles.allRoles[1]: false;
      if(isTeamLead == false) {
        showTopSnackbarInfo(context, 'You do not have access');
      } else {
        _aiConfirmOrder(context);
      }
    }
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('AI Grouping Result'),
        content: SizedBox(
        width: 400, // Adjust width as needed
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    result.isGoodGroup ? Icons.check_circle : Icons.cancel,
                    color: result.isGoodGroup ? Colors.green : Colors.red,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    result.isGoodGroup ? "Good Group" : "Not a Good Group",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: result.isGoodGroup ? Colors.green : Colors.red,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                'Reasoning',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(result.reasoning.isNotEmpty ? result.reasoning : "N/A"),
              const SizedBox(height: 16),
              Text(
                'Issues',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              if (result.issues.isNotEmpty)
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: result.issues.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 2),
                  itemBuilder: (context, i) => Text('• ${result.issues[i]}'),
                )
              else
                const Text('No issues.'),
              const SizedBox(height: 16),
              Text(
                'Recommendations',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              if (result.recommendations.isNotEmpty)
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: result.recommendations.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 2),
                  itemBuilder: (context, i) => Text('• ${result.recommendations[i]}'),
                )
              else
                const Text('No recommendations.'),
            ],
          ),
        ),
      ),
        actions: [
          TextButton(
            onPressed: () {
              context.pop();
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16));
  }

  Widget _buildRouteInfo(List<String> routes) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.place, color: Colors.black54, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              routes.join(" → "),
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoBox(IconData icon, String title, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.black54, size: 20),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildValidationBox(String title, bool isValid) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(5),
        margin: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: isValid ? AppColors.green.withOpacity(0.1) : AppColors.red.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isValid ? Icons.check_circle : Icons.cancel,
              color: isValid ? AppColors.green : AppColors.red,
              size: 16,
            ),
            const SizedBox(width: 4),
            Text(
              title,
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: isValid ? AppColors.green : AppColors.red),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOutlinedButton(String text, OrderGroupModel group,) {
    return OutlinedButton(
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
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.black,
        side: const BorderSide(color: Colors.black),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      ),
      child: Text(text),
    );
  }

  Widget _buildConfirmButton(String text, OrderGroupModel group,) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        BlocConsumer<GroupOrderListCubit, GroupOrderListState>(
            listener: (context, state) {
              if (state is GroupOrderListActionSuccess) {
                context.pop();
                showTopSnackbarInfo(context, 'Group Order Confirmed');
              }
            },
            builder: (context, state) {
              var isLoading = state is GroupOrderListActionLoading;
              return isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                ),
                onPressed: () async {
                  var isTeamLead = context.read<UserProfileCubit>().state is UserProfileLoaded? (context.read<UserProfileCubit>().state as UserProfileLoaded).user.userRole == UserRoles.allRoles[1]: false;
                  if(isTeamLead == false) {
                    showTopSnackbarInfo(context, 'You do not have access');
                    return;
                  } else {
                    _confirmOrder(context);
                  }
                },
                child: Text("Confirm Group", style: AppTextStyles.body17RobotoMedium.copyWith(color: AppColors.white),),
              );
            }),
      ],
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
              child: Column(
                children: [
                  Expanded(
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
                              Container(
                                padding: const EdgeInsets.all(8.0),
                                decoration: BoxDecoration(
                                  border: Border.all(color: AppColors.grey),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Column(
                                  children: [
                                    buildDetailRow('Total Orders:', '${group.orders.length}'),
                                    buildDetailRow('Total Weight:',
                                        '${group.totalWeight.toStringAsFixed(2)} tons'),
                                    buildDetailRow(
                                        'Total LDM:', '${group.totalLDM.toStringAsFixed(2)}'),
                                    buildDetailRow('Total Distance:',
                                        '${totalDistance.toStringAsFixed(2)} km'),
                                    buildDetailRow(
                                        'Total Price:', '€${group.totalPrice.toStringAsFixed(2)}'),
                                    buildDetailRow(
                                        'Price Per Km:', '€${group.pricePerKm.toStringAsFixed(2)}'),
                                    buildDetailRow('Status:', group.status.name),
                                  ],
                                ),
                              ),
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
                  _buildConfirmButton('CONFIRM GROUPING', group),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

}

class GroupInfoCardMobile extends StatefulWidget {
  final OrderGroupModel orderGroup;

  const GroupInfoCardMobile({super.key, required this.orderGroup});

  @override
  State<GroupInfoCardMobile> createState() => _GroupInfoCardMobileState();
}

class _GroupInfoCardMobileState extends State<GroupInfoCardMobile> {

  ResponsiveScreenSize responsiveScreenSize = ResponsiveScreenSize();

  late List<int> optimizedRoute;
  late List<String> orderIdNamesList;
  late List<String> postalCodeNamesList;

  late double totalPrice;
  late double totalDistance;
  late double pricePerKm;
  late double totalLDM;
  late double totalWeight;

  late bool validateLDM;
  late bool validateWeight;
  late bool validateDate;
  late bool validateAdr;

  late CarTypeModel carType;

  AdrValidatorService adrValidatorService = AdrValidatorService();

  @override
  void initState() {
    super.initState();

    optimizedRoute = [];
    orderIdNamesList = [];
    postalCodeNamesList = [];

    totalPrice = 0.0;
    totalDistance = 0.0;
    pricePerKm = 0.0;
    totalLDM = 0.0;
    totalWeight = 0.0;

    validateLDM = false;
    validateWeight = false;
    validateDate = false;
    validateAdr = false;

    carType = CarTypeModel.carTypes.firstWhere(
          (type) => type.name == widget.orderGroup.orders.first.carTypeName,
      orElse: () => CarTypeModel.carTypes.first,
    );

    _initializeData();
  }

  void _initializeData() {
    if (widget.orderGroup.orders.length > 1) {
      optimizedRoute = RouteOptimizer.optimizeRoute(widget.orderGroup.orders);

      for (var order in widget.orderGroup.orders) {
        orderIdNamesList.add(order.orderID);
      }

      for (int index in optimizedRoute) {
        if (index < widget.orderGroup.orders.length) {
          postalCodeNamesList.add(
              '${widget.orderGroup.orders[index].pickupPlace.postalCode} ${widget.orderGroup.orders[index].pickupPlace.countryCode} ${widget.orderGroup.orders[index].pickupPlace.name}');
          postalCodeNamesList.add(
              '${widget.orderGroup.orders[index].deliveryPlace.postalCode} ${widget.orderGroup.orders[index].deliveryPlace.countryCode} ${widget.orderGroup.orders[index].deliveryPlace.name}');
        }
      }
    } else {
      final order = widget.orderGroup.orders.first;
      orderIdNamesList.add(order.orderID);
      postalCodeNamesList.add(
          '${order.pickupPlace.postalCode} ${order.pickupPlace.countryCode} ${order.pickupPlace.name}');
      postalCodeNamesList.add(
          '${order.deliveryPlace.postalCode} ${order.deliveryPlace.countryCode} ${order.deliveryPlace.name}');
    }

    if (widget.orderGroup.orders.length == 1) {
      final order = widget.orderGroup.orders.first;
      totalPrice = order.price;
      totalDistance = ClusteringDBSCANService.calculateDistance(
        order.pickupPlace.latitude,
        order.pickupPlace.longitude,
        order.deliveryPlace.latitude,
        order.deliveryPlace.longitude,
      );
      pricePerKm = ClusteringDBSCANService.calculateOrderPricePerKm(order);
      totalLDM = order.ldm;
      totalWeight = order.weight;
      validateLDM = totalLDM <= carType.length;
      validateWeight = totalWeight <= carType.maxWeight;
      validateDate = true;
      validateAdr = adrValidatorService.canGroupOrders(widget.orderGroup.orders);
    } else {
      List<int> optimizedGroup =
      RouteOptimizer.optimizeRoute(widget.orderGroup.orders);
      totalDistance = ClusteringDBSCANService.calculateRouteDistance(
        widget.orderGroup.orders,
        optimizedGroup,
      );
      totalPrice = widget.orderGroup.orders.fold(0, (sum, o) => sum + o.price);
      pricePerKm = totalDistance > 0 ? totalPrice / totalDistance : 0.0;
      totalWeight =
          widget.orderGroup.orders.fold(0, (sum, o) => sum + o.weight);
      totalLDM = widget.orderGroup.orders.fold(0, (sum, o) => sum + o.ldm);
      validateLDM = totalLDM <= carType.length;
      validateWeight = totalWeight <= carType.maxWeight;
      validateDate = TimeManager.validateTimeWindows(widget.orderGroup.orders, optimizedGroup);
      validateAdr = adrValidatorService.canGroupOrders(widget.orderGroup.orders);
    }
  }

  Future<void> _confirmOrder(BuildContext context) async {
    try {
      // Step 1: Fetch the global filter
      await context.read<FilterCubit>().fetchFilter();
      final filterState = context.read<FilterCubit>().state;

      if (filterState is FilterLoaded) {
        final filter = filterState.filter;

        // Step 2: Validate the group order against the filter criteria
        final isWithinRadius = widget.orderGroup.totalDistance <= filter.maxRadius;
        final meetsPricePerKmThreshold = widget.orderGroup.pricePerKm >= filter.pricePerKmThreshold;

        if (isWithinRadius && meetsPricePerKmThreshold) {
          // Criteria met: Add order directly
          var result = await context
              .read<UserProfileCubit>()
              .checkIfUserProfileActive(context);
          if (result) {
            final user = context
                .read<UserProfileCubit>()
                .state
            as UserProfileLoaded;

            if(user.user.userRole == UserRoles.teamLead) {
              context
                  .read<GroupOrderListCubit>()
                  .addOrderGroup(
                  widget.orderGroup,
                  user.user.userID,
                  user.user.name);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                      'You are not eligible to group this orders please contact Team Lead or Admin'),
                ),
              );
            }
          } else {
            showErrorNotification(context,
                'Sorry your connection is lost, try login again.');
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
                    child: const Text('Confirm'),
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

              if(user.user.userRole == UserRoles.teamLead) {
                context
                    .read<GroupOrderListCubit>()
                    .addOrderGroup(
                    widget.orderGroup,
                    user.user.userID,
                    user.user.name);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                        'You are not eligible to group this orders please contact Team Lead or Admin'),
                  ),
                );
              }
            } else {
              showErrorNotification(context,
                  'Sorry your connection is lost, try login again.');
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
        showErrorNotification(context, 'Failed to validate filter criteria. Please try again.');
      }
    } catch (e) {
      // Handle any other errors
      showErrorNotification(context, 'Error fetching filter: ${e.toString()}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Group ID
            SelectableText.rich(
              TextSpan(
                style: const TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),
                children: [
                  TextSpan(text: "Group ID: "),
                  TextSpan(text: widget.orderGroup.groupID, style: const TextStyle(fontWeight: FontWeight.w900)),
                ],
              ),
            ),
            const SizedBox(height: 4),

            // Order ID
            SelectableText(
              "Orders ID: ${orderIdNamesList.join('-')}",
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 5),

            // Route Information
            _buildSectionTitle("Route Information"),
            _buildRouteInfo(postalCodeNamesList),

            const SizedBox(height: 5),

            // Total Distance & Price per km
            Row(
              children: [
                _buildInfoBox(Icons.directions_car, "Total Distance", "${totalDistance.toStringAsFixed(2)} km"),
              ],
            ),
            Row(
              children: [
                _buildInfoBox(Icons.euro, "Total Price", "${widget.orderGroup.totalPrice} km"),
                const SizedBox(width: 10),
                _buildInfoBox(Icons.euro, "Price per km", "${widget.orderGroup.pricePerKm.toStringAsFixed(2)} EUR/km"),
                // const SizedBox(width: 10),
                // _buildConfirmButton("Confirm Group"),
              ],
            ),
            const SizedBox(height: 5),
            Row(
              children: [
                _buildInfoBox(Icons.inventory, "Total LDM", "${totalLDM.toStringAsFixed(1)}"),
                const SizedBox(width: 10),
                _buildInfoBox(Icons.scale, "Total Weight", "${totalWeight.toStringAsFixed(1)} tons"),
              ],
            ),
            const SizedBox(height: 5),
            // Validations
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildValidationBox("LDM Valid", validateLDM),
                _buildValidationBox("Weight Valid", validateWeight),
              ],
            ),
            const SizedBox(height: 5),
            // Validations
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildValidationBox("Dates Valid", validateDate),
                _buildValidationBox("ADR Valid", validateAdr),
              ],
            ),

            // Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                _buildOutlinedButton("View Details", widget.orderGroup),
                // const SizedBox(width: 10),
                // _buildConfirmButton("Confirm Group"),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16));
  }

  Widget _buildRouteInfo(List<String> routes) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.place, color: Colors.black54, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              routes.join(" → "),
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoBox(IconData icon, String title, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.black54, size: 20),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildValidationBox(String title, bool isValid) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(5),
        margin: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: isValid ? AppColors.green.withOpacity(0.1) : AppColors.red.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isValid ? Icons.check_circle : Icons.cancel,
              color: isValid ? AppColors.green : AppColors.red,
              size: 16,
            ),
            const SizedBox(width: 4),
            Text(
              title,
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: isValid ? AppColors.green : AppColors.red),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOutlinedButton(String text, OrderGroupModel group,) {
    return OutlinedButton(
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
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.black,
        side: const BorderSide(color: Colors.black),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      ),
      child: Text(text),
    );
  }

  Widget _buildConfirmButton(String text, OrderGroupModel group,) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        BlocConsumer<GroupOrderListCubit, GroupOrderListState>(
            listener: (context, state) {
              if (state is GroupOrderListActionSuccess) {
                context.pop();
                showTopSnackbarInfo(context, 'Group Order Confirmed');
              }
            },
            builder: (context, state) {
              var isLoading = state is GroupOrderListActionLoading;
              return isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                ),
                onPressed: () async {
                  var isTeamLead = context.read<UserProfileCubit>().state is UserProfileLoaded? (context.read<UserProfileCubit>().state as UserProfileLoaded).user.userRole == UserRoles.allRoles[1]: false;
                  if(isTeamLead == false) {
                    showTopSnackbarInfo(context, 'You do not have access');
                    return;
                  } else {
                    _confirmOrder(context);
                  }
                },
                child: Text("Confirm Group", style: AppTextStyles.body17RobotoMedium.copyWith(color: AppColors.white),),
              );
            }),
      ],
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
              child: Column(
                children: [
                  Expanded(
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
                              Container(
                                padding: const EdgeInsets.all(8.0),
                                decoration: BoxDecoration(
                                  border: Border.all(color: AppColors.grey),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Column(
                                  children: [
                                    buildDetailRow('Total Orders:', '${group.orders.length}'),
                                    buildDetailRow('Total Weight:',
                                        '${group.totalWeight.toStringAsFixed(2)} tons'),
                                    buildDetailRow(
                                        'Total LDM:', '${group.totalLDM.toStringAsFixed(2)}'),
                                    buildDetailRow('Total Distance:',
                                        '${totalDistance.toStringAsFixed(2)} km'),
                                    buildDetailRow(
                                        'Total Price:', '€${group.totalPrice.toStringAsFixed(2)}'),
                                    buildDetailRow(
                                        'Price Per Km:', '€${group.pricePerKm.toStringAsFixed(2)}'),
                                    buildDetailRow('Status:', group.status.name),
                                  ],
                                ),
                              ),
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
                  _buildConfirmButton('CONFIRM GROUPING', group),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

}