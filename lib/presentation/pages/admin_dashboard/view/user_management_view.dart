import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:ai_logistics_management_order_automation/config/app_colors.dart';
import 'package:ai_logistics_management_order_automation/config/app_text_styles.dart';
import 'package:ai_logistics_management_order_automation/config/constants.dart';
import 'package:ai_logistics_management_order_automation/config/screen_size.dart';
import 'package:ai_logistics_management_order_automation/domain/models/filter_model.dart';
import 'package:ai_logistics_management_order_automation/domain/models/user_model.dart';
import 'package:ai_logistics_management_order_automation/presentation/manager/user_profile_cubit/user_profile_cubit.dart';
import 'package:ai_logistics_management_order_automation/presentation/pages/admin_dashboard/components/user_management_header.dart';
import 'package:ai_logistics_management_order_automation/presentation/pages/admin_dashboard/manager/admin_users_cubit/admin_users_cubit.dart';
import 'package:ai_logistics_management_order_automation/presentation/pages/admin_dashboard/manager/users_management_cubit/users_management_cubit.dart';
import 'package:ai_logistics_management_order_automation/presentation/widgets/clock.dart';
import 'package:ai_logistics_management_order_automation/presentation/widgets/notifications/error_notification.dart';
import 'package:intl/intl.dart';

class UserManagementView extends StatefulWidget {
  @override
  _UserManagementViewState createState() => _UserManagementViewState();
}

class _UserManagementViewState extends State<UserManagementView> {

  ResponsiveScreenSize responsiveScreenSize = ResponsiveScreenSize();

  ScrollController _horizontalScrollController = ScrollController();
  ScrollController _verticalScrollController = ScrollController();

  String sortColumn = "name";
  bool isAscending = true;

  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    context.read<AdminUsersCubit>().streamUsers();
    searchController.addListener(() {
      context.read<AdminUsersCubit>().searchUsers(searchController.text);
    });
    super.initState();
  }

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
                        "User Management",
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
                  child: BlocBuilder<AdminUsersCubit, AdminUsersState>(
                    builder: (context, state) {
                      if (state.isLoading) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (state.error != null) {
                        return Center(child: Text('Error: ${state.error}'));
                      } else if (state.users != null && state.users!.isNotEmpty) {
                        var usersFiltered = state.users!.where((u) => u.userRole != UserRoles.admin).toList();

                        return Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Search and Header
                              UserManagementSearchBar(
                                searchController: searchController,
                                onAddUser: () {
                                  showAddUserDialog(context, (user) async{
                                    var result = await context.read<UserProfileCubit>().checkIfUserProfileActive(context);
                                    if(result) {
                                      context.read<UsersManagementCubit>().addUser(
                                        adminID: (context.read<UserProfileCubit>().state as UserProfileLoaded).user.userID,
                                        username: user.username,
                                        password: user.password,
                                        name: user.name,
                                        userRole: user.userRole,
                                      );
                                    } else {
                                      showErrorNotification(context, 'Sorry action your connection is lost');
                                    }
                                  });
                                },
                                onSearch: (String query) {},
                              ),
                              const SizedBox(height: 10),
                              // Infographics Section
                              Row(
                                children: [
                                  _buildMetricCard("Total Users", '${usersFiltered.length}',
                                      AppColors.grey.withOpacity(0.6),
                                      AppColors.black, Icons.person, responsiveScreenSize.isMobileScreen(context)),
                                  _buildMetricCard(
                                      "Active Users(Test)",
                                      "${usersFiltered.where((user) => user.currentLoginStatus).length}",
                                      AppColors.lightGreen,
                                      AppColors.green,
                                      Icons.check_circle, responsiveScreenSize.isMobileScreen(context)),
                                  _buildMetricCard(
                                      "Inactive Users(Test)",
                                      "${usersFiltered.where((user) => !user.currentLoginStatus).length}",
                                      AppColors.red.withOpacity(0.6),
                                      AppColors.red,
                                      Icons.remove_circle, responsiveScreenSize.isMobileScreen(context)),
                                ],
                              ),
                              const SizedBox(height: 20),

                              // Full-Width Data Table with Action Menu
                              Expanded(
                                child: Card(
                                  color: AppColors.white,
                                  elevation: 2,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
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
                                            width: MediaQuery.sizeOf(context).width - 170.w,
                                            child: DataTable(
                                              columnSpacing: 20,
                                              sortColumnIndex: _getSortColumnIndex(),
                                              sortAscending: isAscending,
                                              showCheckboxColumn: true,
                                              columns: [
                                                _buildDataColumn("Name", "name", usersFiltered),
                                                _buildDataColumn("Username", "username", usersFiltered),
                                                const DataColumn(label: Text("Created Date")),
                                                const DataColumn(label: Text("Last Login Time")),
                                                const DataColumn(label: Text("Status")),
                                                const DataColumn(
                                                  label: Text("Actions"),
                                                  headingRowAlignment: MainAxisAlignment.end,
                                                ),
                                              ],
                                              rows: usersFiltered.map((user) {
                                                return DataRow(
                                                  cells: [
                                                    DataCell(
                                                      Opacity(
                                                        opacity: user.isEditing && !(user.lastStartEditTime != null && DateTime.now().difference(user.lastStartEditTime!).inMinutes > 3) ? 0.6 : 1.0,
                                                        child: IgnorePointer(
                                                          ignoring: user.isEditing && !(user.lastStartEditTime != null && DateTime.now().difference(user.lastStartEditTime!).inMinutes > 3),
                                                          child: Text(user.name),
                                                        ),
                                                      ),
                                                    ),
                                                    DataCell(
                                                      Opacity(
                                                        opacity: user.isEditing && !(user.lastStartEditTime != null && DateTime.now().difference(user.lastStartEditTime!).inMinutes > 3) ? 0.6 : 1.0,
                                                        child: IgnorePointer(
                                                          ignoring: user.isEditing && !(user.lastStartEditTime != null && DateTime.now().difference(user.lastStartEditTime!).inMinutes > 3),
                                                          child: Text(user.username),
                                                        ),
                                                      ),
                                                    ),
                                                    DataCell(
                                                      Opacity(
                                                        opacity: user.isEditing && !(user.lastStartEditTime != null && DateTime.now().difference(user.lastStartEditTime!).inMinutes > 3) ? 0.6 : 1.0,
                                                        child: IgnorePointer(
                                                          ignoring: user.isEditing && !(user.lastStartEditTime != null && DateTime.now().difference(user.lastStartEditTime!).inMinutes > 3),
                                                          child: Text(
                                                            user.createdDate.toIso8601String().split("T")[0],
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    DataCell(
                                                      Opacity(
                                                        opacity: user.isEditing && !(user.lastStartEditTime != null && DateTime.now().difference(user.lastStartEditTime!).inMinutes > 3) ? 0.6 : 1.0,
                                                        child: IgnorePointer(
                                                          ignoring: user.isEditing && !(user.lastStartEditTime != null && DateTime.now().difference(user.lastStartEditTime!).inMinutes > 3),
                                                          child: Text(
                                                            user.lastLoginTime != null
                                                                ? user.lastLoginTime!.toIso8601String().split("T")[0]
                                                                : "",
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    DataCell(
                                                      Opacity(
                                                        opacity: user.isEditing && !(user.lastStartEditTime != null && DateTime.now().difference(user.lastStartEditTime!).inMinutes > 3) ? 0.6 : 1.0,
                                                        child: IgnorePointer(
                                                          ignoring: user.isEditing && !(user.lastStartEditTime != null && DateTime.now().difference(user.lastStartEditTime!).inMinutes > 3),
                                                          child: Container(
                                                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                                            decoration: BoxDecoration(
                                                              color: user.currentLoginStatus
                                                                  ? Colors.green.withOpacity(0.2)
                                                                  : Colors.red.withOpacity(0.2),
                                                              borderRadius: BorderRadius.circular(8),
                                                            ),
                                                            child: Text(
                                                              user.currentLoginStatus ? "Active" : "Inactive",
                                                              style: TextStyle(
                                                                color: user.currentLoginStatus ? Colors.green : Colors.red,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    DataCell(
                                                      Opacity(
                                                        opacity: user.isEditing &&
                                                            !(user.lastStartEditTime != null && DateTime.now().difference(user.lastStartEditTime!).inMinutes > 3)
                                                            ? 1.0
                                                            : 0.6,
                                                        child: IgnorePointer(
                                                          ignoring: user.isEditing && !(user.lastStartEditTime != null && DateTime.now().difference(user.lastStartEditTime!).inMinutes > 3),
                                                          child: Align(
                                                            alignment: Alignment.centerRight,
                                                            child: _buildActionMenu(context, user),
                                                          ),
                                                        ),
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
                              )
                            ],
                          ),
                        );
                      } else {
                        return const Center(child: Text('No users available.'));
                      }
                    },
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
                        "User Management",
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
                  child: BlocBuilder<AdminUsersCubit, AdminUsersState>(
                    builder: (context, state) {
                      if (state.isLoading) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (state.error != null) {
                        return Center(child: Text('Error: ${state.error}'));
                      } else if (state.users != null && state.users!.isNotEmpty) {
                        var usersFiltered = state.users!.where((u) => u.userRole != UserRoles.admin).toList();

                        return Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Search and Header
                              UserManagementSearchBar(
                                searchController: searchController,
                                onAddUser: () {
                                  showAddUserDialog(context, (user) async{
                                    var result = await context.read<UserProfileCubit>().checkIfUserProfileActive(context);
                                    if(result) {
                                      context.read<UsersManagementCubit>().addUser(
                                        adminID: (context.read<UserProfileCubit>().state as UserProfileLoaded).user.userID,
                                        username: user.username,
                                        password: user.password,
                                        name: user.name,
                                        userRole: user.userRole,
                                      );
                                    } else {
                                      showErrorNotification(context, 'Sorry action your connection is lost');
                                    }
                                  });
                                },
                                onSearch: (String query) {},
                              ),
                              const SizedBox(height: 10),
                              // Infographics Section
                              Row(
                                children: [
                                  _buildMetricCard("Total Users", '${usersFiltered.length}',
                                      AppColors.grey.withOpacity(0.6),
                                      AppColors.black, Icons.person, responsiveScreenSize.isMobileScreen(context)),
                                  _buildMetricCard(
                                      "Active Users(Test)",
                                      "${usersFiltered.where((user) => user.currentLoginStatus).length}",
                                      AppColors.lightGreen,
                                      AppColors.green,
                                      Icons.check_circle, responsiveScreenSize.isMobileScreen(context)),
                                  _buildMetricCard(
                                      "Inactive Users(Test)",
                                      "${usersFiltered.where((user) => !user.currentLoginStatus).length}",
                                      AppColors.red.withOpacity(0.6),
                                      AppColors.red,
                                      Icons.remove_circle, responsiveScreenSize.isMobileScreen(context)),
                                ],
                              ),
                              const SizedBox(height: 20),

                              // Full-Width Data Table with Action Menu
                              Expanded(
                                child: Card(
                                  color: AppColors.white,
                                  elevation: 2,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
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
                                            width: MediaQuery.sizeOf(context).width - 50.w,
                                            child: DataTable(
                                              columnSpacing: 20,
                                              sortColumnIndex: _getSortColumnIndex(),
                                              sortAscending: isAscending,
                                              showCheckboxColumn: true,
                                              columns: [
                                                _buildDataColumn("Name", "name", usersFiltered),
                                                _buildDataColumn("Username", "username", usersFiltered),
                                                const DataColumn(label: Text("Created Date")),
                                                const DataColumn(label: Text("Last Login Time")),
                                                const DataColumn(label: Text("Status")),
                                                const DataColumn(
                                                  label: Text("Actions"),
                                                  headingRowAlignment: MainAxisAlignment.end,
                                                ),
                                              ],
                                              rows: usersFiltered.map((user) {
                                                return DataRow(
                                                  cells: [
                                                    DataCell(
                                                      Opacity(
                                                        opacity: user.isEditing && !(user.lastStartEditTime != null && DateTime.now().difference(user.lastStartEditTime!).inMinutes > 3) ? 0.6 : 1.0,
                                                        child: IgnorePointer(
                                                          ignoring: user.isEditing && !(user.lastStartEditTime != null && DateTime.now().difference(user.lastStartEditTime!).inMinutes > 3),
                                                          child: Text(user.name),
                                                        ),
                                                      ),
                                                    ),
                                                    DataCell(
                                                      Opacity(
                                                        opacity: user.isEditing && !(user.lastStartEditTime != null && DateTime.now().difference(user.lastStartEditTime!).inMinutes > 3) ? 0.6 : 1.0,
                                                        child: IgnorePointer(
                                                          ignoring: user.isEditing && !(user.lastStartEditTime != null && DateTime.now().difference(user.lastStartEditTime!).inMinutes > 3),
                                                          child: Text(user.username),
                                                        ),
                                                      ),
                                                    ),
                                                    DataCell(
                                                      Opacity(
                                                        opacity: user.isEditing && !(user.lastStartEditTime != null && DateTime.now().difference(user.lastStartEditTime!).inMinutes > 3) ? 0.6 : 1.0,
                                                        child: IgnorePointer(
                                                          ignoring: user.isEditing && !(user.lastStartEditTime != null && DateTime.now().difference(user.lastStartEditTime!).inMinutes > 3),
                                                          child: Text(
                                                            user.createdDate.toIso8601String().split("T")[0],
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    DataCell(
                                                      Opacity(
                                                        opacity: user.isEditing && !(user.lastStartEditTime != null && DateTime.now().difference(user.lastStartEditTime!).inMinutes > 3) ? 0.6 : 1.0,
                                                        child: IgnorePointer(
                                                          ignoring: user.isEditing && !(user.lastStartEditTime != null && DateTime.now().difference(user.lastStartEditTime!).inMinutes > 3),
                                                          child: Text(
                                                            user.lastLoginTime != null
                                                                ? user.lastLoginTime!.toIso8601String().split("T")[0]
                                                                : "",
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    DataCell(
                                                      Opacity(
                                                        opacity: user.isEditing && !(user.lastStartEditTime != null && DateTime.now().difference(user.lastStartEditTime!).inMinutes > 3) ? 0.6 : 1.0,
                                                        child: IgnorePointer(
                                                          ignoring: user.isEditing && !(user.lastStartEditTime != null && DateTime.now().difference(user.lastStartEditTime!).inMinutes > 3),
                                                          child: Container(
                                                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                                            decoration: BoxDecoration(
                                                              color: user.currentLoginStatus
                                                                  ? Colors.green.withOpacity(0.2)
                                                                  : Colors.red.withOpacity(0.2),
                                                              borderRadius: BorderRadius.circular(8),
                                                            ),
                                                            child: Text(
                                                              user.currentLoginStatus ? "Active" : "Inactive",
                                                              style: TextStyle(
                                                                color: user.currentLoginStatus ? Colors.green : Colors.red,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    DataCell(
                                                      Opacity(
                                                        opacity: user.isEditing &&
                                                            !(user.lastStartEditTime != null && DateTime.now().difference(user.lastStartEditTime!).inMinutes > 3)
                                                            ? 1.0
                                                            : 0.6,
                                                        child: IgnorePointer(
                                                          ignoring: user.isEditing && !(user.lastStartEditTime != null && DateTime.now().difference(user.lastStartEditTime!).inMinutes > 3),
                                                          child: Align(
                                                            alignment: Alignment.centerRight,
                                                            child: _buildActionMenu(context, user),
                                                          ),
                                                        ),
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
                              )
                            ],
                          ),
                        );
                      } else {
                        return const Center(child: Text('No users available.'));
                      }
                    },
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
                        "User Management",
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
                // Search and Header
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: UserManagementSearchBar(
                    searchController: searchController,
                    onAddUser: () {
                      showAddUserDialog(context, (user) async{
                        var result = await context.read<UserProfileCubit>().checkIfUserProfileActive(context);
                        if(result) {
                          context.read<UsersManagementCubit>().addUser(
                            adminID: (context.read<UserProfileCubit>().state as UserProfileLoaded).user.userID,
                            username: user.username,
                            password: user.password,
                            name: user.name,
                            userRole: user.userRole,
                          );
                        } else {
                          showErrorNotification(context, 'Sorry action your connection is lost');
                        }
                      });
                    },
                    onSearch: (String query) {},
                  ),
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: BlocBuilder<AdminUsersCubit, AdminUsersState>(
                    builder: (context, state) {
                      if (state.isLoading) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (state.error != null) {
                        return Center(child: Text('Error: ${state.error}'));
                      } else if (state.users != null && state.users!.isNotEmpty) {
                        var usersFiltered = state.users!.where((u) => u.userRole != UserRoles.admin).toList();

                        return Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Infographics Section
                              if(!responsiveScreenSize.isMobileScreen(context))...[
                                Row(
                                  children: [
                                    _buildMetricCard("Total Users", '${usersFiltered.length}',
                                        AppColors.grey.withOpacity(0.6),
                                        AppColors.black, Icons.person, responsiveScreenSize.isMobileScreen(context)),
                                    _buildMetricCard(
                                        "Active Users(Test)",
                                        "${usersFiltered.where((user) => user.currentLoginStatus).length}",
                                        AppColors.lightGreen,
                                        AppColors.green,
                                        Icons.check_circle, responsiveScreenSize.isMobileScreen(context)),
                                    _buildMetricCard(
                                        "Inactive Users(Test)",
                                        "${usersFiltered.where((user) => !user.currentLoginStatus).length}",
                                        AppColors.red.withOpacity(0.6),
                                        AppColors.red,
                                        Icons.remove_circle, responsiveScreenSize.isMobileScreen(context)),
                                  ],
                                ),
                                const SizedBox(height: 20),
                              ],

                              // Full-Width Data Table with Action Menu
                              Expanded(
                                child: Card(
                                  color: AppColors.white,
                                  elevation: 2,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
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
                                          child: DataTable(
                                            columnSpacing: 20,
                                            sortColumnIndex: _getSortColumnIndex(),
                                            sortAscending: isAscending,
                                            showCheckboxColumn: true,
                                            columns: [
                                              _buildDataColumn("Name", "name", usersFiltered),
                                              _buildDataColumn("Username", "username", usersFiltered),
                                              const DataColumn(label: Text("Created Date")),
                                              const DataColumn(label: Text("Last Login Time")),
                                              const DataColumn(label: Text("Status")),
                                              const DataColumn(
                                                label: Text("Actions"),
                                                headingRowAlignment: MainAxisAlignment.end,
                                              ),
                                            ],
                                            rows: usersFiltered.map((user) {
                                              return DataRow(
                                                cells: [
                                                  DataCell(
                                                    Opacity(
                                                      opacity: user.isEditing && !(user.lastStartEditTime != null && DateTime.now().difference(user.lastStartEditTime!).inMinutes > 3) ? 0.6 : 1.0,
                                                      child: IgnorePointer(
                                                        ignoring: user.isEditing && !(user.lastStartEditTime != null && DateTime.now().difference(user.lastStartEditTime!).inMinutes > 3),
                                                        child: Text(user.name),
                                                      ),
                                                    ),
                                                  ),
                                                  DataCell(
                                                    Opacity(
                                                      opacity: user.isEditing && !(user.lastStartEditTime != null && DateTime.now().difference(user.lastStartEditTime!).inMinutes > 3) ? 0.6 : 1.0,
                                                      child: IgnorePointer(
                                                        ignoring: user.isEditing && !(user.lastStartEditTime != null && DateTime.now().difference(user.lastStartEditTime!).inMinutes > 3),
                                                        child: Text(user.username),
                                                      ),
                                                    ),
                                                  ),
                                                  DataCell(
                                                    Opacity(
                                                      opacity: user.isEditing && !(user.lastStartEditTime != null && DateTime.now().difference(user.lastStartEditTime!).inMinutes > 3) ? 0.6 : 1.0,
                                                      child: IgnorePointer(
                                                        ignoring: user.isEditing && !(user.lastStartEditTime != null && DateTime.now().difference(user.lastStartEditTime!).inMinutes > 3),
                                                        child: Text(
                                                          user.createdDate.toIso8601String().split("T")[0],
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  DataCell(
                                                    Opacity(
                                                      opacity: user.isEditing && !(user.lastStartEditTime != null && DateTime.now().difference(user.lastStartEditTime!).inMinutes > 3) ? 0.6 : 1.0,
                                                      child: IgnorePointer(
                                                        ignoring: user.isEditing && !(user.lastStartEditTime != null && DateTime.now().difference(user.lastStartEditTime!).inMinutes > 3),
                                                        child: Text(
                                                          user.lastLoginTime != null
                                                              ? user.lastLoginTime!.toIso8601String().split("T")[0]
                                                              : "",
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  DataCell(
                                                    Opacity(
                                                      opacity: user.isEditing && !(user.lastStartEditTime != null && DateTime.now().difference(user.lastStartEditTime!).inMinutes > 3) ? 0.6 : 1.0,
                                                      child: IgnorePointer(
                                                        ignoring: user.isEditing && !(user.lastStartEditTime != null && DateTime.now().difference(user.lastStartEditTime!).inMinutes > 3),
                                                        child: Container(
                                                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                                          decoration: BoxDecoration(
                                                            color: user.currentLoginStatus
                                                                ? Colors.green.withOpacity(0.2)
                                                                : Colors.red.withOpacity(0.2),
                                                            borderRadius: BorderRadius.circular(8),
                                                          ),
                                                          child: Text(
                                                            user.currentLoginStatus ? "Active" : "Inactive",
                                                            style: TextStyle(
                                                              color: user.currentLoginStatus ? Colors.green : Colors.red,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  DataCell(
                                                    Opacity(
                                                      opacity: user.isEditing &&
                                                          !(user.lastStartEditTime != null && DateTime.now().difference(user.lastStartEditTime!).inMinutes > 3)
                                                          ? 1.0
                                                          : 0.6,
                                                      child: IgnorePointer(
                                                        ignoring: user.isEditing && !(user.lastStartEditTime != null && DateTime.now().difference(user.lastStartEditTime!).inMinutes > 3),
                                                        child: Align(
                                                          alignment: Alignment.centerRight,
                                                          child: _buildActionMenu(context, user),
                                                        ),
                                                      ),
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
                              )
                            ],
                          ),
                        );
                      } else {
                        return const Center(child: Text('No users available.'));
                      }
                    },
                  ),
                ),
              ],
            ),
          );
        }
      },
    );
  }

  // Builds a sortable data column
  DataColumn _buildDataColumn(String label, String field, List<UserModel> users) {
    return DataColumn(
      label: Text(label),
    );
  }

  // Returns the index of the column to sort
  int? _getSortColumnIndex() {
    switch (sortColumn) {
      case "name":
        return 0;
      case "username":
        return 1;
      default:
        return null;
    }
  }

  // Builds the Action Menu
  Widget _buildActionMenu(BuildContext context, UserModel user) {
    // final isOnline = user.currentLoginStatus;

    return PopupMenuButton<String>(
      color: AppColors.white,
      icon: const Icon(Icons.more_vert),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      onSelected: (value) async {
        switch (value) {
          case 'View Profile':
            showUserDetailDialog(context, user);
            break;
          case 'Edit Details':
          // Normal logic, user must be offline to reach here interactively
            final canEdit = await context.read<UsersManagementCubit>().canUserEdit(user.userID);
            if (!canEdit) {
              showErrorNotification(context, "Another user is currently editing this profile. Please try later.");
              return;
            }

            await context.read<UsersManagementCubit>().startEditing(user.userID);
            final freshUser = await context.read<UsersManagementCubit>().userRepository.getUserDetails(user.userID);
            final oldLastStartEditTime = freshUser?.lastStartEditTime;

            showEditUserDialog(context, user, oldLastStartEditTime, (updatedName, updatedPassword) async {
              if (oldLastStartEditTime != null) {
                final changed = await context.read<UsersManagementCubit>().isLastStartEditTimeChanged(
                  user.userID, oldLastStartEditTime,
                );
                if (changed) {
                  showErrorNotification(context, "Someone else took over editing. Please reopen editing.");
                  context.read<UsersManagementCubit>().stopEditing(user.userID);
                  context.pop(); // Close dialog
                  return;
                }
              }

              context.read<UsersManagementCubit>().editUser(
                adminID: (context.read<UserProfileCubit>().state as UserProfileLoaded).user.userID,
                userID: user.userID,
                name: updatedName,
                username: user.username,
                password: updatedPassword,
              );
            });
            break;
          case 'Change Permission':
            final canEditPerm = await context.read<UsersManagementCubit>().canUserEdit(user.userID);
            if (!canEditPerm) {
              showErrorNotification(context, "Another user is currently editing this profile. Please try later.");
              return;
            }

            await context.read<UsersManagementCubit>().startEditing(user.userID);
            final freshUserPerm = await context.read<UsersManagementCubit>().userRepository.getUserDetails(user.userID);
            final oldLastStartEditTimePerm = freshUserPerm?.lastStartEditTime;

            showChangePermissionDialog(context, user, oldLastStartEditTimePerm, (updatedUserRole) async {
              if (oldLastStartEditTimePerm != null) {
                final changed = await context.read<UsersManagementCubit>().isLastStartEditTimeChanged(
                  user.userID, oldLastStartEditTimePerm,
                );
                if (changed) {
                  showErrorNotification(context, "Someone else took over editing. Please reopen editing.");
                  context.read<UsersManagementCubit>().stopEditing(user.userID);
                  context.pop();
                  return;
                }
              }

              context.read<UsersManagementCubit>().editUserRole(
                adminID: (context.read<UserProfileCubit>().state as UserProfileLoaded).user.userID,
                userID: user.userID,
                username: user.username,
                userRole: updatedUserRole,
              );
            });
            break;
          case 'Reset IP':
            final canEditPerm = await context.read<UsersManagementCubit>().canUserEdit(user.userID);
            if (!canEditPerm) {
              showErrorNotification(context, "Another user is currently editing this profile. Please try later.");
              return;
            }

            await context.read<UsersManagementCubit>().startEditing(user.userID);
            final freshUserPerm = await context.read<UsersManagementCubit>().userRepository.getUserDetails(user.userID);
            final oldLastStartEditTimePerm = freshUserPerm?.lastStartEditTime;

            showResetIPDialog(context, user, () async {
              if (oldLastStartEditTimePerm != null) {
                final changed = await context.read<UsersManagementCubit>().isLastStartEditTimeChanged(
                  user.userID, oldLastStartEditTimePerm,
                );
                if (changed) {
                  showErrorNotification(context, "Someone else took over editing. Please reopen editing.");
                  context.read<UsersManagementCubit>().stopEditing(user.userID);
                  context.pop();
                  return;
                }
              }

              context.read<UsersManagementCubit>().editUserIP(
                adminID: (context.read<UserProfileCubit>().state as UserProfileLoaded).user.userID,
                userID: user.userID,
                username: user.username,
              );
            });
            break;
          case 'Delete User':
            showDeleteUserDialog(context, user, (userID) {
              context.read<UsersManagementCubit>().deleteUser((context.read<UserProfileCubit>().state as UserProfileLoaded).user.userID, userID);
            });
            break;
        }
      },
      itemBuilder: (context) {
        return [
          // View Profile (always enabled)
          PopupMenuItem(
            value: 'View Profile',
            child: Row(
              children: const [
                Icon(Icons.person, color: Colors.black54),
                SizedBox(width: 8),
                Text("View profile"),
              ],
            ),
          ),
          // Edit Details (disabled if user online)
          PopupMenuItem(
            value: 'Edit Details',
            enabled: true, // This controls menu item greyed out state as well
            // enabled: !isOnline, // This controls menu item greyed out state as well
            child: Opacity(
              opacity: 1.0,
              // opacity: isOnline ? 0.5 : 1.0,
              child: IgnorePointer(
                ignoring: false,
                // ignoring: isOnline,
                child: Row(
                  children: const [
                    Icon(Icons.edit, color: Colors.black54),
                    SizedBox(width: 8),
                    Text("Edit details"),
                  ],
                ),
              ),
            ),
          ),
          // Change Permission (disabled if user online)
          PopupMenuItem(
            value: 'Change Permission',
            enabled: true,
            // enabled: !isOnline,
            child: Opacity(
              opacity: 1.0,
              // opacity: isOnline ? 0.5 : 1.0,
              child: IgnorePointer(
                ignoring: false,
                // ignoring: isOnline,
                child: Row(
                  children: const [
                    Icon(Icons.lock_open, color: Colors.black54),
                    SizedBox(width: 8),
                    Text("Change permission"),
                  ],
                ),
              ),
            ),
          ),
          PopupMenuItem(
            value: 'Reset IP',
            enabled: true,
            // enabled: !isOnline,
            child: Opacity(
              opacity: 1.0,
              // opacity: isOnline ? 0.5 : 1.0,
              child: IgnorePointer(
                ignoring: false,
                // ignoring: isOnline,
                child: Row(
                  children: const [
                    Icon(Icons.lock_open, color: Colors.black54),
                    SizedBox(width: 8),
                    Text("Reset IP"),
                  ],
                ),
              ),
            ),
          ),
          // Delete User (disabled if user online)
          PopupMenuItem(
            value: 'Delete User',
            enabled: true,
            // enabled: !isOnline,
            child: Opacity(
              opacity: 1.0,
              // opacity: isOnline ? 0.5 : 1.0,
              child: IgnorePointer(
                ignoring: false,
                // ignoring: isOnline,
                child: Row(
                  children: const [
                    Icon(Icons.delete, color: Colors.red),
                    SizedBox(width: 8),
                    Text(
                      "Delete user",
                      style: TextStyle(color: Colors.red),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ];
      },
    );
  }

  void showAddUserDialog(BuildContext context, Function(UserModel) onSave) {
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();
    final TextEditingController nameController = TextEditingController();
    final TextEditingController usernameController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();
    String selectedRole = UserRoles.user; // Default to USER

    bool obscureText = true;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return BlocConsumer<UsersManagementCubit, UsersManagementState>(
              listener: (context, state) {
                if (state is UsersManagementError) {
                  context.pop();
                  showErrorNotification(context, state.message);
                }
                if (state is UsersManagementSuccess) {
                  context.pop();
                }
              },
              builder: (context, state) {
                return Dialog(
                  backgroundColor: AppColors.white,
                  insetPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
                  child: Container(
                    padding: const EdgeInsets.all(24.0),
                    width: 400,
                    child: Form(
                      key: formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Title and Close Button
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Add New User",
                                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                              IconButton(
                                icon: Icon(Icons.close, color: Theme.of(context).colorScheme.secondary),
                                onPressed: () => context.pop(),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Name Input
                          TextFormField(
                            controller: nameController,
                            decoration: InputDecoration(
                              labelText: "Name",
                              labelStyle: AppTextStyles.head20RobotoRegular,
                              fillColor: Theme.of(context).colorScheme.surfaceVariant,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              filled: true,
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return "Name is required";
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // Username Input
                          TextFormField(
                            controller: usernameController,
                            decoration: InputDecoration(
                              labelText: "Username",
                              labelStyle: AppTextStyles.head20RobotoRegular,
                              fillColor: Theme.of(context).colorScheme.surfaceVariant,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              filled: true,
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return "Username is required";
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // Password Input
                          TextFormField(
                            controller: passwordController,
                            obscureText: obscureText,
                            decoration: InputDecoration(
                              labelStyle: AppTextStyles.head20RobotoRegular,
                              fillColor: Theme.of(context).colorScheme.surfaceVariant,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              filled: true,
                              labelText: "Password",
                              suffixIcon: IconButton(
                                icon: Icon(
                                  obscureText ? Icons.visibility_off : Icons.visibility,
                                ),
                                onPressed: () {
                                  setState(() {
                                    obscureText = !obscureText;
                                  });
                                },
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
                          const SizedBox(height: 16),

                          // User Role Dropdown
                          const Text("User Role", style: TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          DropdownButtonFormField<String>(
                            value: selectedRole,
                            borderRadius: BorderRadius.circular(8),
                            items: UserRoles.allRoles
                                .map((role) => DropdownMenuItem(
                              value: role,
                              child: Text(
                                role,
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ))
                                .toList(),
                            onChanged: (value) {
                              if (value != null) {
                                setState(() {
                                  selectedRole = value;
                                });
                              }
                            },
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Theme.of(context).colorScheme.surfaceVariant,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8.0),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Action Buttons
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton(
                                onPressed: () => context.pop(),
                                child: const Text("Cancel"),
                              ),
                              const SizedBox(width: 16),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.black,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                                ),
                                onPressed: () {
                                  if (formKey.currentState?.validate() ?? false) {
                                    final newUser = UserModel(
                                      userID: DateTime.now().toIso8601String(),
                                      name: nameController.text,
                                      password: passwordController.text,
                                      username: usernameController.text,
                                      currentLoginStatus: false,
                                      ordersCreatedCount: 0,
                                      ordersAcceptedCount: 0,
                                      ordersDeletedCount: 0,
                                      actionsLog: [],
                                      userRole: selectedRole,
                                      myOrdersIdList: [],
                                      createdDate: DateTime.now(),
                                      filterModel: FilterModel.defaultFilters()
                                    );
                                    onSave(newUser);
                                  } else {}
                                },
                                child: state is UsersManagementLoading
                                    ? SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: const CircularProgressIndicator(),
                                )
                                    : const Text("Add User"),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  void showEditUserDialog(
      BuildContext context,
      UserModel user,
      DateTime? oldLastStartEditTime,
      Function(String updatedName, String updatedPassword) onSave,
      ) {
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();
    final TextEditingController nameController = TextEditingController(text: user.name);
    final TextEditingController passwordController = TextEditingController(text: user.password);

    bool obscureText = true;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return BlocConsumer<UsersManagementCubit, UsersManagementState>(
              listener: (context, state) {
                if (state is UsersManagementSuccess) {
                  context.read<UsersManagementCubit>().stopEditing(user.userID);
                  context.pop();
                }
                if (state is UsersManagementError) {
                  context.read<UsersManagementCubit>().stopEditing(user.userID);
                  context.pop();
                  showErrorNotification(context, state.message);
                }
              },
              builder: (context, state) {
                return Dialog(
                  backgroundColor: AppColors.white,
                  insetPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
                  child: Container(
                    padding: const EdgeInsets.all(24.0),
                    width: 400,
                    child: Form(
                      key: formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Title and Close Button
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Edit User",
                                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                              IconButton(
                                icon: Icon(Icons.close, color: Theme.of(context).colorScheme.secondary),
                                onPressed: () {
                                  context.read<UsersManagementCubit>().stopEditing(user.userID);
                                  context.pop();
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Name Input
                          TextFormField(
                            controller: nameController,
                            decoration: InputDecoration(
                              labelText: "Name",
                              labelStyle: AppTextStyles.head20RobotoRegular,
                              fillColor: Theme.of(context).colorScheme.surfaceVariant,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              filled: true,
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return "Name is required";
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // Password Input
                          TextFormField(
                            controller: passwordController,
                            obscureText: obscureText,
                            decoration: InputDecoration(
                              labelText: "Password",
                              filled: true,
                              fillColor: Theme.of(context).colorScheme.surfaceVariant,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8.0),
                                borderSide: BorderSide.none,
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  obscureText ? Icons.visibility_off : Icons.visibility,
                                ),
                                onPressed: () {
                                  setState(() {
                                    obscureText = !obscureText;
                                  });
                                },
                              ),
                            ),
                            validator: (value) {
                              if (value != null && value.isNotEmpty && value.length < 6) {
                                return "Password must be at least 6 characters long";
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 24),

                          // Action Buttons
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton(
                                onPressed: () {
                                  context.read<UsersManagementCubit>().stopEditing(user.userID);
                                  context.pop();
                                },
                                child: const Text("Cancel"),
                              ),
                              const SizedBox(width: 16),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.black,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                                ),
                                onPressed: () async {
                                  if (formKey.currentState?.validate() ?? false) {
                                    // Check if lastStartEditTime changed before saving
                                    if (oldLastStartEditTime != null) {
                                      final changed = await context.read<UsersManagementCubit>().isLastStartEditTimeChanged(
                                        user.userID, oldLastStartEditTime,
                                      );
                                      if (changed) {
                                        showErrorNotification(context, "Another user took over editing. Please reopen editing.");
                                        context.read<UsersManagementCubit>().stopEditing(user.userID);
                                        context.pop();
                                        return;
                                      }
                                    }

                                    onSave(
                                      nameController.text,
                                      passwordController.text,
                                    );
                                  }
                                },
                                child: state is UsersManagementLoading
                                    ? SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: const CircularProgressIndicator(),
                                )
                                    : const Text("Save"),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  void showChangePermissionDialog(
      BuildContext context,
      UserModel user,
      DateTime? oldLastStartEditTime,
      Function(String updatedUserRole) onSave,
      ) {
    String selectedRole = user.userRole;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return BlocConsumer<UsersManagementCubit, UsersManagementState>(
              listener: (context, state) {
                if (state is UsersManagementSuccess) {
                  context.read<UsersManagementCubit>().stopEditing(user.userID);
                  context.pop();
                }
                if (state is UsersManagementError) {
                  context.pop();
                  context.read<UsersManagementCubit>().stopEditing(user.userID);
                  showErrorNotification(context, state.message);
                }
              },
              builder: (context, state) {
                return Dialog(
                  insetPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
                  backgroundColor: AppColors.white,
                  child: Container(
                    padding: const EdgeInsets.all(24.0),
                    width: 400,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title and Close Button
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Change Permission",
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.close, color: Theme.of(context).colorScheme.secondary),
                              onPressed: () {
                                context.read<UsersManagementCubit>().stopEditing(user.userID);
                                context.pop();
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // User Role Dropdown
                        const Text("User Role", style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<String>(
                          value: selectedRole,
                          borderRadius: BorderRadius.circular(8),
                          items: UserRoles.allRoles
                              .map((role) => DropdownMenuItem(
                            value: role,
                            child: Text(
                              role,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ))
                              .toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setState(() {
                                selectedRole = value;
                              });
                            }
                          },
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Theme.of(context).colorScheme.surfaceVariant,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Action Buttons
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: () {
                                context.read<UsersManagementCubit>().stopEditing(user.userID);
                                context.pop();
                              },
                              child: const Text("Cancel"),
                            ),
                            const SizedBox(width: 16),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.black,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                              ),
                              onPressed: () async {
                                // Check if lastStartEditTime changed before saving
                                if (oldLastStartEditTime != null) {
                                  final changed = await context.read<UsersManagementCubit>().isLastStartEditTimeChanged(
                                    user.userID, oldLastStartEditTime,
                                  );
                                  if (changed) {
                                    showErrorNotification(context, "Another user took over editing. Please reopen editing.");
                                    context.read<UsersManagementCubit>().stopEditing(user.userID);
                                    context.pop();
                                    return;
                                  }
                                }

                                onSave(selectedRole);
                              },
                              child: state is UsersManagementLoading
                                  ? SizedBox(
                                width: 20,
                                height: 20,
                                child: const CircularProgressIndicator(),
                              )
                                  : const Text("Save"),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  void showResetIPDialog(
      BuildContext context,
      UserModel user,
      Function() onSave,
      ) {

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return BlocConsumer<UsersManagementCubit, UsersManagementState>(
              listener: (context, state) {
                if (state is UsersManagementSuccess) {
                  context.read<UsersManagementCubit>().stopEditing(user.userID);
                  context.pop();
                }
                if (state is UsersManagementError) {
                  context.pop();
                  context.read<UsersManagementCubit>().stopEditing(user.userID);
                  showErrorNotification(context, state.message);
                }
              },
              builder: (context, state) {
                return Dialog(
                  backgroundColor: AppColors.white,
                  insetPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
                  child: Container(
                    padding: const EdgeInsets.all(24.0),
                    width: 400,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title and Close Button
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Reset User IP",
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.close, color: Theme.of(context).colorScheme.secondary),
                              onPressed: () {
                                context.read<UsersManagementCubit>().stopEditing(user.userID);
                                context.pop();
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // Action Buttons
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: () {
                                context.read<UsersManagementCubit>().stopEditing(user.userID);
                                context.pop();
                              },
                              child: const Text("Cancel"),
                            ),
                            const SizedBox(width: 16),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.black,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                              ),
                              onPressed: () async {

                                onSave();
                              },
                              child: state is UsersManagementLoading
                                  ? SizedBox(
                                width: 20,
                                height: 20,
                                child: const CircularProgressIndicator(),
                              )
                                  : const Text("Reset"),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  void showDeleteUserDialog(BuildContext context, UserModel user, Function(String) onDelete,) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return BlocConsumer<UsersManagementCubit, UsersManagementState>(
              listener: (context, state) {
                if (state is UsersManagementSuccess) {
                  context.pop();
                }
                if (state is UsersManagementError) {
                  context.pop();
                  showErrorNotification(context, state.message);
                }
              },
              builder: (context, state) {
                return Dialog(
                  backgroundColor: AppColors.white,
                  insetPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
                  child: Container(
                    padding: const EdgeInsets.all(24.0),
                    width: 400,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Delete User",
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.close, color: Theme.of(context).colorScheme.secondary),
                              onPressed: () => context.pop(),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Content
                        RichText(
                          text: TextSpan(
                              text: 'Are you sure you want to delete ',
                              style: Theme.of(context).textTheme.bodyMedium,
                              children: [
                                TextSpan(
                                    text: '${user.name}',
                                    style: Theme.of(context).textTheme.bodyLarge!.copyWith(fontWeight: FontWeight.bold)
                                ),
                                TextSpan(
                                    text: '? This action cannot be undone.',
                                    style: Theme.of(context).textTheme.bodyMedium
                                ),
                              ]
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Action Buttons
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: () => context.pop(),
                              child: const Text("Cancel"),
                            ),
                            const SizedBox(width: 16),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(backgroundColor: AppColors.red),
                              onPressed: () {
                                onDelete(user.userID); // Pass the user ID to delete
                              },
                              child: state is UsersManagementLoading
                                  ? SizedBox(
                                width: 20,
                                height: 20,
                                child: const CircularProgressIndicator(),
                              )
                                  : Text("Delete", style: AppTextStyles.body17RobotoMedium.copyWith(color: AppColors.white),),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  void showUserDetailDialog(BuildContext context, UserModel user) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          backgroundColor: AppColors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
          child: Container(
            width: MediaQuery.of(context).size.width > 800
                ? MediaQuery.of(context).size.width * 0.5
                : MediaQuery.of(context).size.width * 0.8,
            padding: const EdgeInsets.all(24.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "User Details",
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, size: 24),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Profile Section
                  Center(
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: Colors.blueGrey,
                          child: Text(
                            user.name[0].toUpperCase(),
                            style: const TextStyle(fontSize: 40, color: Colors.white),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          user.name,
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          user.username,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // User Information Section
                  const Text(
                    "User Information",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Divider(thickness: 1),
                  _buildDetailRow("User Role", user.userRole),
                  _buildDetailRow(
                    "Last Login",
                    user.lastLoginTime != null
                        ? DateFormat('dd-MM-yyyy HH:mm').format(user.lastLoginTime!)
                        : "Never",
                  ),
                  _buildDetailRow(
                    "Account Status",
                    user.currentLoginStatus ? "Active" : "Inactive",
                  ),
                  const SizedBox(height: 16),

                  // Filters Section
                  const Text(
                    "Filters",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Divider(thickness: 1),
                  _buildDetailRow("Max Radius", "${user.filterModel.maxRadius} km"),
                  _buildDetailRow("Min Price Per Km", "${user.filterModel.pricePerKmThreshold} EUR/km"),
                  const SizedBox(height: 16),

                  // Orders Section with Infographics
                  const Text(
                    "Orders Overview",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Divider(thickness: 1),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildInfoCard(
                        icon: Icons.create_outlined,
                        label: "Created",
                        value: "${user.ordersCreatedCount}",
                        color: Colors.blue,
                      ),
                      _buildInfoCard(
                        icon: Icons.check_circle_outline,
                        label: "Accepted",
                        value: "${user.ordersAcceptedCount}",
                        color: Colors.green,
                      ),
                      _buildInfoCard(
                        icon: Icons.delete_outline,
                        label: "Deleted",
                        value: "${user.ordersDeletedCount}",
                        color: Colors.red,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Logs Section
                  const Text(
                    "Activity Logs",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Divider(thickness: 1),
                  user.actionsLog.isEmpty
                      ? const Text(
                    "No activity logs available.",
                    style: TextStyle(color: Colors.grey),
                  )
                      : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: user.actionsLog.length,
                    itemBuilder: (context, index) {
                      final log = user.actionsLog[index];
                      return ListTile(
                        leading: const Icon(Icons.history, color: Colors.blue),
                        title: Text(log.action),
                        subtitle: Text(
                          DateFormat('dd-MM-yyyy HH:mm').format(log.timestamp),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 32, color: color),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 14, color: Colors.black54),
          ),
        ],
      ),
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
