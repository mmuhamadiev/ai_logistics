import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hegelmann_order_automation/config/app_colors.dart';
import 'package:hegelmann_order_automation/config/app_text_styles.dart';
import 'package:hegelmann_order_automation/config/screen_size.dart';
import 'package:hegelmann_order_automation/domain/models/filter_model.dart';
import 'package:hegelmann_order_automation/presentation/manager/filter/filter_cubit.dart';
import 'package:hegelmann_order_automation/presentation/manager/firebase_auth/firebase_auth_cubit.dart';
import 'package:hegelmann_order_automation/presentation/manager/user_profile_cubit/user_profile_cubit.dart';
import 'package:hegelmann_order_automation/presentation/pages/admin_dashboard/manager/users_management_cubit/users_management_cubit.dart';
import 'package:hegelmann_order_automation/presentation/widgets/clock.dart';
import 'package:hegelmann_order_automation/presentation/widgets/notifications/error_notification.dart';
import 'package:hegelmann_order_automation/presentation/widgets/notifications/success_notification.dart';
import 'package:intl/intl.dart';

class AdminDashboardSettingsView extends StatefulWidget {
  @override
  _AdminDashboardSettingsViewState createState() =>
      _AdminDashboardSettingsViewState();
}

class _AdminDashboardSettingsViewState
    extends State<AdminDashboardSettingsView> {

  ResponsiveScreenSize responsiveScreenSize = ResponsiveScreenSize();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

// Inside _AdminDashboardSettingsViewState
  bool isFilterEditingEnabled = false;
  final TextEditingController nameController = TextEditingController();
  final TextEditingController radiusController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController pricePerKmController = TextEditingController();

  @override
  void initState() {
    super.initState();

    // Load filters from Firestore
    context.read<FilterCubit>().fetchFilter();

    Future.delayed(Duration(seconds: 2), () {

      if (context.read<UserProfileCubit>().state is UserProfileLoaded) {
        final user = (context.read<UserProfileCubit>().state as UserProfileLoaded).user;
        nameController.text = user.name;
        passwordController.text = user.password;
      }

      if (context.read<FilterCubit>().state is FilterLoaded) {
        final filter = (context.read<FilterCubit>().state as FilterLoaded).filter;
        radiusController.text = filter.maxRadius.toString();
        pricePerKmController.text = filter.pricePerKmThreshold.toString();
      }
    });
  }

// Main UI
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
                          "Admin Settings",
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
                      padding: EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          // Left Panel: Admin Editing
                          Expanded(
                            flex: 1,
                            child: Card(
                              elevation: 2,
                              color: AppColors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Admin Editing Section
                                    buildAdminEditingSection(),
                                    const SizedBox(height: 20),

                                    // Filter Editing Section
                                    buildFilterEditingSection(),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),

                          // Right Panel: Logs
                          Expanded(
                            flex: 1,
                            child: buildLogsSection(),
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
                          "Admin Settings",
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
                      padding: EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          // Left Panel: Admin Editing
                          Expanded(
                            flex: 1,
                            child: Card(
                              elevation: 2,
                              color: AppColors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Admin Editing Section
                                    buildAdminEditingSection(),
                                    const SizedBox(height: 20),

                                    // Filter Editing Section
                                    buildFilterEditingSection(),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),

                          // Right Panel: Logs
                          Expanded(
                            flex: 1,
                            child: buildLogsSection(),
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
                          "Admin Dashboard",
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
                      padding: EdgeInsets.all(16.0),
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            buildAdminEditingSection(),
                            const SizedBox(height: 20),
                            // Filter Editing Section
                            buildFilterEditingSection(),
                          ],
                        ),
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

// Admin Editing Section
  Widget buildAdminEditingSection() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Edit Admin Details",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: Icon(
                  isFilterEditingEnabled ? Icons.lock_open : Icons.lock,
                  color: isFilterEditingEnabled ? Colors.green : Colors.grey,
                ),
                onPressed: () {
                  setState(() {
                    isFilterEditingEnabled = !isFilterEditingEnabled;
                  });
                },
              ),
            ],
          ),
          const Divider(),
          const SizedBox(height: 20),
          TextFormField(
            controller: nameController,
            enabled: isFilterEditingEnabled,
            decoration: InputDecoration(
              labelText: "Admin Name",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return "Name is required";
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: passwordController,
            enabled: isFilterEditingEnabled,
            obscureText: true,
            decoration: InputDecoration(
              labelText: "Admin Password",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return "Password is required";
              }
              if (value.length < 6) {
                return "Password must be at least 6 characters long";
              }
              return null;
            },
          ),
      const SizedBox(height: 20),
      BlocConsumer<UsersManagementCubit, UsersManagementState>(
        listener: (context, state) {
          if (state is UsersManagementSuccess) {
            showSuccessNotification(context, 'Global filter updated successfully!');
          }
          if (state is UsersManagementError) {
            showErrorNotification(context, state.message);
          }
        },
        builder: (context, state) {
          return ElevatedButton(
            onPressed: isFilterEditingEnabled
                ? () async{
              var result = await context.read<UserProfileCubit>().checkIfUserProfileActive(context);
              if(result) {
                final user = context.read<UserProfileCubit>().state as UserProfileLoaded;
                context.read<UsersManagementCubit>().editUser(
                  adminID: user.user.userID,
                  userID: user.user.userID,
                  name: nameController.text,
                  username: user.user.username,
                  password: passwordController.text,
                );
              } else {
                showErrorNotification(context, 'Sorry action your connection is lost');
              }
            }
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 50),
            ),
            child: state is UsersManagementLoading
                ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(),
            )
                : const Text("Update Admin"),
          );
        },
      ),
        ],
      ),
    );
  }

// Filter Editing Section
  Widget buildFilterEditingSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Edit Global Filter",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

          ],
        ),
        const Divider(),
        const SizedBox(height: 20),
        TextFormField(
          controller: radiusController,
          enabled: isFilterEditingEnabled,
          decoration: InputDecoration(
            labelText: "Max Radius (km)",
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: pricePerKmController,
          enabled: isFilterEditingEnabled,
          decoration: InputDecoration(
            labelText: "Min Price per Km (€)",
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 20),
        BlocConsumer<FilterCubit, FilterState>(
          listener: (context, state) {
            if (state is FilterSuccess) {
              showSuccessNotification(context, 'Global filter updated successfully!');
            }
            if (state is FilterError) {
              showErrorNotification(context, state.message);
            }
          },
          builder: (context, state) {
            return ElevatedButton(
              onPressed: isFilterEditingEnabled
                  ? () {
                final radius = double.tryParse(radiusController.text) ?? 200.0;
                final minPricePerKm = double.tryParse(pricePerKmController.text) ?? 2.0;

                final updatedFilter = FilterModel(
                  maxRadius: radius,
                  pricePerKmThreshold: minPricePerKm,
                );

                context.read<FilterCubit>().saveFilter(updatedFilter);
              }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
              ),
              child: state is FilterLoading
                  ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(),
              )
                  : const Text("Save Filter"),
            );
          },
        ),
      ],
    );
  }

// Logs Section
  Widget buildLogsSection() {
    return Card(
      elevation: 2,
      color: AppColors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Logs",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Divider(),
            const SizedBox(height: 10),
            Expanded(
              child: BlocBuilder<UserProfileCubit, UserProfileState>(
                builder: (context, state) {
                  if (state is UserProfileLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is UserProfileLoaded) {
                    final logs = state.user.actionsLog;
                    if (logs.isEmpty) {
                      return const Center(child: Text("No logs available."));
                    }
                    return ListView.builder(
                      itemCount: logs.length,
                      itemBuilder: (context, index) {
                        final log = logs[index];
                        return Container(
                          padding: EdgeInsets.symmetric(vertical: 10),
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
                      },
                    );
                  } else if (state is UserProfileError) {
                    return Center(child: Text("Error: ${state.message}"));
                  }
                  return const Center(child: Text("No logs available."));
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

}

