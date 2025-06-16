import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hegelmann_order_automation/config/app_colors.dart';
import 'package:hegelmann_order_automation/config/app_text_styles.dart';
import 'package:hegelmann_order_automation/domain/models/commnet_model.dart';
import 'package:hegelmann_order_automation/domain/models/driver_info_model.dart';
import 'package:hegelmann_order_automation/domain/models/order_model.dart';
import 'package:hegelmann_order_automation/presentation/manager/order_list/order_list_cubit.dart';
import 'package:hegelmann_order_automation/presentation/manager/user_profile_cubit/user_profile_cubit.dart';
import 'package:hegelmann_order_automation/presentation/widgets/map_view_widget.dart';
import 'package:hegelmann_order_automation/presentation/widgets/notifications/error_notification.dart';
import 'package:hegelmann_order_automation/presentation/widgets/notifications/top_snackbar_info.dart';

// Placeholder for Map
Widget buildMapPlaceholder(OrderModel order) {
  return Container(
    height: 300,
    clipBehavior: Clip.hardEdge,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(8),
      color: AppColors.grey,
    ),
    child: Center(
      child: OrderMapView(orders: [order]),
    ),
  );
}

// Timeline Section
Widget buildTimelineSection(OrderModel order) {
  return Row(
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
              const SizedBox(width: 10),
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
              const SizedBox(width: 10),
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
  );
}

// Order Details Section
Widget buildOrderDetails(OrderModel order) {
  return Row(
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
              buildDetailRow(
                  'Weight:', '${order.weight.toStringAsFixed(1)} tons'),
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
            ],
          ),
        ),
      ),
    ],
  );
}

// Order Details Section
Widget buildOrderDriverDetails(DriverInfo? driverInfo) {
  return Row(
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
              buildDetailRow('Driver Name:', driverInfo?.driverName?? 'N/A'),
              buildDetailRow('Driver Car:', driverInfo?.driverCar?? 'N/A'),
              buildDetailRow('Car Type:', driverInfo?.carTypeName?? 'N/A'),
            ],
          ),
        ),
      ),
    ],
  );
}

// Order Creator Section
Widget buildOrderCreator(OrderModel order) {
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
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${order.creatorName}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.body17RobotoMedium,
              ),
              Text(
                '${order.createdAt.toLocal()}',
                style: AppTextStyles.body17RobotoMedium
                    .copyWith(color: AppColors.grey),
              )
            ],
          ),
        ),
      ],
    ),
  );
}

// Comments Section
Widget buildCommentsSection(BuildContext context, OrderModel order, bool canComment) {
  final TextEditingController _commentController = TextEditingController();
  return Container(
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
            if (context.read<UserProfileCubit>().state
            is UserProfileLoaded && canComment) ...[
              if (comment.userID ==
                  (context.read<UserProfileCubit>().state
                  as UserProfileLoaded)
                      .user
                      .userID) ...[
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    confirmDeleteComment(context, order, comment);
                  },
                )
              ]
            ],
          ],
        )),
        const SizedBox(height: 16),
        // Input Field for New Comment
        if(canComment)...[
          BlocListener<OrderListCubit, OrderListState>(
            listener: (context, state) {
              if (state is OrderListActionSuccess) {
                showTopSnackbarInfo(context, state.message);
                if(state.message == 'Comment added successfully.') {
                  context.pop();
                } else if(state.message == 'Comment deleted successfully.'){
                  context.pop();
                  context.pop();
                }
              } else if (state is OrderListActionError) {
                showErrorNotification(context, state.message);
                context.pop();
              }
            },
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    decoration: InputDecoration(
                      labelText: 'Add Comment',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8)
                      ),
                    ),
                    onSubmitted: (value) async {
                      if (value.trim().isNotEmpty) {
                        var result = await context
                            .read<UserProfileCubit>()
                            .checkIfUserProfileActive(context);
                        if (result) {
                          final user = context.read<UserProfileCubit>().state
                          as UserProfileLoaded;

                          final newComment = Comment(
                            content: value.trim(),
                            userID: user.user.userID,
                            timestamp: DateTime.now(),
                            commenterName: user.user.username,
                          );

                          context.read<OrderListCubit>().addOrderComment(
                              order.orderID,
                              newComment,
                              user.user.userID,
                              user.user.username);
                          _commentController.clear();
                        } else {
                          showErrorNotification(
                              context, 'Sorry action your connection is lost');
                        }
                      }
                    },
                  ),
                ),
                SizedBox(
                  width: 10,
                ),
                sendMessageButton(order, _commentController),
              ],
            ),
          ),
        ]
      ],
    ),
  );
}

BlocBuilder<OrderListCubit, OrderListState> sendMessageButton(OrderModel order, TextEditingController _commentController) {
  return BlocBuilder<OrderListCubit, OrderListState>(
              builder: (context, state) {
                final isLoading = context.read<OrderListCubit>().state is OrderListAddingActionLoading;
                return SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.black),
                    child: isLoading
                        ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        color: AppColors.white,
                      ),
                    ): Icon(
                      Icons.send,
                      color: AppColors.white,
                    ),
                    onPressed: () async{
                      if (_commentController.text.trim().isNotEmpty) {
                        var result = await context
                            .read<UserProfileCubit>()
                            .checkIfUserProfileActive(context);
                        if (result) {
                          final user = context.read<UserProfileCubit>().state as UserProfileLoaded;

                          final newComment = Comment(
                            content: _commentController.text.trim(),
                            userID: user.user.userID,
                            timestamp: DateTime.now(),
                            commenterName: user.user.username,
                          );

                          context.read<OrderListCubit>().addOrderComment(
                              order.orderID,
                              newComment,
                              user.user.userID,
                              user.user.username);
                          _commentController.clear();

                        } else {
                          showErrorNotification(
                              context, 'Sorry action your connection is lost');
                        }
                      }
                    },
                  ),
                );
              },
            );
}

 void confirmDeleteComment(
    BuildContext context, OrderModel order, Comment comment) {
  showDialog(
    context: context,
    builder: (_) => StatefulBuilder(
      builder: (context, setState) {
        return AlertDialog(
          title: const Text('Delete Comment'),
          content: Text('Are you sure you want to delete this comment?'),
          actions: [
            OutlinedButton.icon(
              onPressed: () {
                context.pop();
              },
              label: Text('Cancel'),
            ),
            BlocBuilder<OrderListCubit, OrderListState>(
              builder: (context, state) {
                final isLoading = context.read<OrderListCubit>().state is OrderListActionLoading;
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
                      final user =
                      context.read<UserProfileCubit>().state as UserProfileLoaded;

                      context.read<OrderListCubit>().deleteOrderComment(order.orderID,
                          comment, user.user.userID, user.user.username);
                      setState(() {

                      });
                    } else {
                      showErrorNotification(
                          context, 'Sorry action your connection is lost');
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
        );
      }
    ),
  );
}

// Logs Section
Widget buildLogsSection(OrderModel order) {
  return Container(
    padding: const EdgeInsets.all(8.0),
    decoration: BoxDecoration(
      border: Border.all(color: AppColors.grey),
      borderRadius: BorderRadius.circular(8),
    ),
    child: Column(
      children: order.orderLogs.map((log) {
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

// Helper: Build a Detail Row
Widget buildDetailRow(String title, String value) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 4.0),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: AppTextStyles.body17RobotoMedium),
        Flexible(
          child: Text(value,
              maxLines: 1,
              softWrap: true,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.body17RobotoMedium
                  .copyWith(color: AppColors.grey)),
        ),
      ],
    ),
  );
}

// Section Title
Widget buildSectionTitle(String title) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8.0),
    child: Text(
      title,
      style: AppTextStyles.head22RobotoMedium,
    ),
  );
}