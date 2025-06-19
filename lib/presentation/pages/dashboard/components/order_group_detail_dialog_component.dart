// Placeholder for Map
import 'package:flutter/material.dart';
import 'package:ai_logistics_management_order_automation/domain/models/order_group_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ai_logistics_management_order_automation/config/app_colors.dart';
import 'package:ai_logistics_management_order_automation/config/app_text_styles.dart';
import 'package:ai_logistics_management_order_automation/domain/models/commnet_model.dart';
import 'package:ai_logistics_management_order_automation/domain/models/order_model.dart';
import 'package:ai_logistics_management_order_automation/presentation/manager/group_order_list/group_order_list_cubit.dart';
import 'package:ai_logistics_management_order_automation/presentation/manager/order_list/order_list_cubit.dart';
import 'package:ai_logistics_management_order_automation/presentation/manager/user_profile_cubit/user_profile_cubit.dart';
import 'package:ai_logistics_management_order_automation/presentation/widgets/map_view_widget.dart';
import 'package:ai_logistics_management_order_automation/presentation/widgets/notifications/error_notification.dart';
import 'package:ai_logistics_management_order_automation/utils/route_optimizer.dart';

import 'order_details_dialog_components.dart';

Widget buildGroupMapPlaceholder(OrderGroupModel group) {
  return Container(
    height: 300,
    clipBehavior: Clip.hardEdge,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(8),
      color: AppColors.grey,
    ),
    child: Center(
      child: OrderMapView(orders: group.orders),
    ),
  );
}

// Timeline Section
Widget buildGroupTimelineSection(OrderGroupModel group) {
  return Column(
    children: group.orders.asMap().entries.map((entry) {
      int index = entry.key; // Get the index (0, 1, 2, ...)
      OrderModel order = entry.value;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Divider(),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Pickup Information
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.grey),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 10,
                        ),
                        const Icon(Icons.location_on, color: Colors.green),
                        const SizedBox(width: 2),
                        Text(
                          maxLines: 1,
                          softWrap: true,
                          overflow: TextOverflow.ellipsis,
                          '[${index * 2}]',
                          style: AppTextStyles.body17RobotoMedium,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                maxLines: 1,
                                softWrap: true,
                                overflow: TextOverflow.ellipsis,
                                'Pickup: ${order.pickupPlace.countryCode}, ${order.pickupPlace.postalCode}, ${order.pickupPlace.name}',
                                style: AppTextStyles.body17RobotoMedium,
                              ),
                              Text(
                                maxLines: 1,
                                softWrap: true,
                                overflow: TextOverflow.ellipsis,
                                'Start: ${order.pickupTimeWindow.start.toString().split(' ')[0]} ${order.pickupTimeWindow.start?.hour}:${order.pickupTimeWindow.start?.minute.toString().padLeft(2, '0')}',
                                style: AppTextStyles.body15RobotoRegular
                                    .copyWith(color: AppColors.grey),
                              ),
                              Text(
                                maxLines: 1,
                                softWrap: true,
                                overflow: TextOverflow.ellipsis,
                                'End: ${order.pickupTimeWindow.end.toString().split(' ')[0]} ${order.pickupTimeWindow.end.hour}:${order.pickupTimeWindow.end.minute.toString().padLeft(2, '0')}',
                                style: AppTextStyles.body15RobotoRegular
                                    .copyWith(color: AppColors.grey),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  width: 10,
                ),
                // Delivery Information
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.grey),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 10,
                        ),
                        const Icon(Icons.flag, color: Colors.red),
                        const SizedBox(width: 2),
                        Text(
                          maxLines: 1,
                          softWrap: true,
                          overflow: TextOverflow.ellipsis,
                          '[${index * 2 + 1}]',
                          style: AppTextStyles.body17RobotoMedium,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                maxLines: 1,
                                softWrap: true,
                                overflow: TextOverflow.ellipsis,
                                'Delivery: ${order.deliveryPlace.countryCode}, ${order.deliveryPlace.postalCode}, ${order.deliveryPlace.name}',
                                style: AppTextStyles.body17RobotoMedium,
                              ),
                              Text(
                                maxLines: 1,
                                softWrap: true,
                                overflow: TextOverflow.ellipsis,
                                'Start: ${order.deliveryTimeWindow.start.toString().split(' ')[0]} ${order.deliveryTimeWindow.start?.hour}:${order.deliveryTimeWindow.start?.minute.toString().padLeft(2, '0')}',
                                style: AppTextStyles.body15RobotoRegular
                                    .copyWith(color: AppColors.grey),
                              ),
                              Text(
                                maxLines: 1,
                                softWrap: true,
                                overflow: TextOverflow.ellipsis,
                                'End: ${order.deliveryTimeWindow.end.toString().split(' ')[0]} ${order.deliveryTimeWindow.end.hour}:${order.deliveryTimeWindow.end.minute.toString().padLeft(2, '0')}',
                                style: AppTextStyles.body15RobotoRegular
                                    .copyWith(color: AppColors.grey),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
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
          Container(
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.grey),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                // Existing Comments
                if(order.comments.isEmpty)...[
                  Row(
                    children: [
                      Text(
                        'No comments yet',
                        style: AppTextStyles.body16RobotoMedium.copyWith(color: AppColors.lightBlue),
                      ),
                    ],
                  ),
                ],
                ...order.comments.map((comment) => Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.grey,
                      ),
                      child: Icon(
                        Icons.person,
                        color: AppColors.black,
                        size: 10,
                      ),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.lightGray,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: EdgeInsets.all(8),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(comment.content, style: AppTextStyles.body17RobotoMedium,),
                            Text('By ${comment.commenterName}', style: AppTextStyles.body16RobotoMedium.copyWith(color: AppColors.grey),)
                          ],
                        ),
                      ),
                    ),
                  ],
                )),
                const SizedBox(height: 16),
                // Input Field for New Comment
              ],
            ),
          ),
          Divider()
        ],
      );
    },
    ).toList(),
  );
}

// New Widget: Displays the full route without postal codes
Widget buildFullRouteWidget(OrderGroupModel group) {
  List<int> optimizedGroup = RouteOptimizer.optimizeRoute(group.orders);
  String fullRoute = group.orders
      .asMap()
      .entries
      .expand((entry) {
    int orderIndex = entry.key;

    return [
      '[${optimizedGroup[orderIndex * 2]}]',  // Pickup (even index)
      '[${optimizedGroup[orderIndex * 2 + 1]}]', // Delivery (odd index)
    ];
  }).join(' → ');

  return Container(
    padding: const EdgeInsets.all(10),
    decoration: BoxDecoration(
      color: AppColors.lightGray,
      borderRadius: BorderRadius.circular(8),
    ),
    child: Row(
      children: [
        Icon(Icons.route, color: AppColors.lightBlue),
        const SizedBox(width: 10),
        Text('Route: ', style: AppTextStyles.body17RobotoMedium,),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            fullRoute,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.body17RobotoMedium,
          ),
        ),
      ],
    ),
  );
}

// Order Details Section
Widget buildGroupDetails(OrderGroupModel group) {
  return Container(
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
            '${group.totalDistance.toStringAsFixed(2)} km'),
        buildDetailRow(
            'Total Price:', '€${group.totalPrice.toStringAsFixed(2)}'),
        buildDetailRow(
            'Price Per Km:', '€${group.pricePerKm.toStringAsFixed(2)}'),
        buildDetailRow('Status:', group.status.name),
      ],
    ),
  );
}

// Order Creator Section
Widget buildGroupCreator(OrderGroupModel group) {
  return Container(
    padding: const EdgeInsets.all(8.0),
    decoration: BoxDecoration(
      border: Border.all(color: AppColors.grey),
      borderRadius: BorderRadius.circular(8),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.grey,
          ),
          child: Icon(
            Icons.person,
            color: AppColors.black,
            size: 20,
          ),
        ),
        SizedBox(
          width: 10,
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${group.creatorName}',
              style: AppTextStyles.body17RobotoMedium,
            ),
            Text(
              '${group.createdAt.toLocal()}',
              style: AppTextStyles.body17RobotoMedium
                  .copyWith(color: AppColors.grey),
            )
          ],
        ),
      ],
    ),
  );
}

// Comments Section
Widget buildGroupCommentsSection(OrderGroupModel group, bool canComment, BuildContext context) {
  final TextEditingController _commentController = TextEditingController();
  return BlocListener<GroupOrderListCubit, GroupOrderListState>(
    listener: (context, state) {
      if (state is GroupOrderListActionLoading) {
        // Optional: Show a loading indicator if needed
      }
      if (state is GroupOrderListActionSuccess) {
        context.pop();
      }
      if (state is GroupOrderListActionError) {
        showErrorNotification(context, state.message);
      }
    },
    child: Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.grey),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if(group.comments.isNotEmpty)...[
            // Existing Comments
            Text(
              'Group Order Comments',
              style: AppTextStyles.body16RobotoMedium,
            ),
            ...group.comments.map(
                    (comment) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.grey,
                        ),
                        child: Icon(
                          Icons.person,
                          color: AppColors.black,
                          size: 10,
                        ),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppColors.lightGray,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: EdgeInsets.all(8),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(comment.content, style: AppTextStyles.body17RobotoMedium,),
                              Text('By ${comment.commenterName}', style: AppTextStyles.body16RobotoMedium.copyWith(color: AppColors.grey),)
                            ],
                          ),
                        ),
                      ),
                      if(context.read<UserProfileCubit>().state
                      is UserProfileLoaded && canComment)...[
                        if(comment.userID == (context.read<UserProfileCubit>().state as UserProfileLoaded).user.userID && canComment)...[
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              _confirmDeleteComment(context, group, comment);
                            },
                          )
                        ]
                      ]
                    ],
                  );
                }
            ),
          ] else...[
            Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Group Order Comments',
                      style: AppTextStyles.body16RobotoMedium,
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Text(
                      'No comments yet',
                      style: AppTextStyles.body16RobotoMedium.copyWith(color: AppColors.lightBlue),
                    ),
                  ],
                )
              ],
            )
          ],
          const SizedBox(height: 8),
          // Input Field for New Comment
          if(canComment)...[
            TextField(
              controller: _commentController,
              decoration: InputDecoration(
                labelText: 'Add Group Comment',
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8)
                ),
                suffixIcon: IconButton(icon: Icon(Icons.send), onPressed: () async{
                  if (_commentController.text.trim().isNotEmpty) {
                    var result = await context.read<UserProfileCubit>().checkIfUserProfileActive(context);
                    if(result) {
                      final user = context.read<UserProfileCubit>().state as UserProfileLoaded;

                      final newComment = Comment(
                        content: _commentController.text.trim(),
                        userID: user.user.userID,
                        timestamp: DateTime.now(), commenterName: user.user.username,
                      );

                      context.read<GroupOrderListCubit>().addGroupComment(group.groupID, newComment,
                          user.user.userID,
                          user.user.username);
                      _commentController.clear();
                    } else {
                      showErrorNotification(context, 'Sorry action your connection is lost');
                    }
                  }
                }),
              ),
              onSubmitted: (value) async{
                if (value.trim().isNotEmpty) {
                  var result = await context.read<UserProfileCubit>().checkIfUserProfileActive(context);
                  if(result) {
                    final user = context.read<UserProfileCubit>().state as UserProfileLoaded;

                    final newComment = Comment(
                      content: value.trim(),
                      userID: user.user.userID,
                      timestamp: DateTime.now(), commenterName: user.user.username,
                    );

                    context.read<GroupOrderListCubit>().addGroupComment(group.groupID, newComment,
                        user.user.userID,
                        user.user.username);
                    _commentController.clear();
                  } else {
                    showErrorNotification(context, 'Sorry action your connection is lost');
                  }
                }
              },
            ),
          ]
        ],
      ),
    ),
  );
}

void _confirmDeleteComment(BuildContext context, OrderGroupModel group, Comment comment) {
  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text('Delete Comment'),
      content: Text('Are you sure you want to delete this comment?'),
      actions: [
        TextButton(
          onPressed: () => context.pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () async{
            var result = await context.read<UserProfileCubit>().checkIfUserProfileActive(context);
            if(result) {
              final user = context.read<UserProfileCubit>().state as UserProfileLoaded;

              context.read<GroupOrderListCubit>().deleteGroupComment(group.groupID, comment,
                  user.user.userID,
                  user.user.username);
              context.pop();
            } else {
              showErrorNotification(context, 'Sorry action your connection is lost');
            }
          },
          child: const Text('Delete'),
        ),
      ],
    ),
  );
}

// Logs Section
Widget buildGroupLogsSection(OrderGroupModel group) {
  if(group.logs.isEmpty) {
    return Text('No Logs', style: AppTextStyles.body16RobotoMedium.copyWith(color: AppColors.lightBlue));
  }
  return Container(
    padding: const EdgeInsets.all(8.0),
    decoration: BoxDecoration(
      border: Border.all(color: AppColors.grey),
      borderRadius: BorderRadius.circular(8),
    ),
    child: Column(
      children: group.logs.map((log) {
        return Container(
          child: Row(
            children: [
              Icon(Icons.history, color: AppColors.grey,),
              SizedBox(
                width: 10,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(log.action, style: AppTextStyles.body17RobotoMedium),
                  Text('At: ${log.timestamp.toLocal()}', style: AppTextStyles.body15RobotoMedium.copyWith(color: AppColors.grey),)
                ],
              ),
            ],
          ),
        );
      }).toList(),
    ),
  );
}

Widget buildPanelSection({
  required String title,
  required int itemCount,
  required Widget Function(BuildContext, int) itemBuilder,
}) {
  return Expanded(
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
                  title,
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
              child: ListView.builder(
                itemCount: itemCount,
                itemBuilder: itemBuilder,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}