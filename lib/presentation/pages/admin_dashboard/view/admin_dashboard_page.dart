import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:ai_logistics_management_order_automation/config/app_colors.dart';
import 'package:ai_logistics_management_order_automation/config/app_text_styles.dart';
import 'package:ai_logistics_management_order_automation/config/constants.dart';
import 'package:ai_logistics_management_order_automation/config/screen_size.dart';
import 'package:ai_logistics_management_order_automation/generated/assets.dart';
import 'package:ai_logistics_management_order_automation/presentation/manager/group_order_list/group_order_list_cubit.dart';
import 'package:ai_logistics_management_order_automation/presentation/manager/order_list/order_list_cubit.dart';
import 'package:ai_logistics_management_order_automation/presentation/manager/session/session_cubit.dart';
import 'package:ai_logistics_management_order_automation/presentation/manager/user_profile_cubit/user_profile_cubit.dart';
import 'package:ai_logistics_management_order_automation/presentation/manager/version/app_version_cubit.dart';
import 'package:ai_logistics_management_order_automation/presentation/pages/admin_dashboard/manager/users_management_cubit/users_management_cubit.dart';
import 'package:ai_logistics_management_order_automation/presentation/pages/admin_dashboard/view/admin_dashboard_view.dart';
import 'package:ai_logistics_management_order_automation/presentation/pages/admin_dashboard/view/admin_settings_view.dart';
import 'package:ai_logistics_management_order_automation/presentation/pages/admin_dashboard/view/user_management_view.dart';

// New Admin Dashboard Shell widget
class AdminDashboardShell extends StatefulWidget {
  final StatefulNavigationShell navigationShell;

  const AdminDashboardShell({required this.navigationShell, super.key});

  @override
  State<AdminDashboardShell> createState() => _AdminDashboardShellState();
}

class _AdminDashboardShellState extends State<AdminDashboardShell> {
  ResponsiveScreenSize responsiveScreenSize = ResponsiveScreenSize();

  void _onItemTapped(int index) async {
    if (index == 3) {
      final sessionCubit = context.read<SessionCubit>();
      context.read<OrderListCubit>().closeSubscription();
      context.read<GroupOrderListCubit>().closeSubscription();
      await sessionCubit.logout();
    } else {
      widget.navigationShell.goBranch(index);
    }
  }

  @override
  void initState() {
    context.read<AppVersionCubit>().checkAppVersion();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AppVersionCubit, AppVersionState>(
      listener: (context, state) {
        if (state.isOutdated) {
          _showClearCacheDialog(context);
        } else if (!state.isOutdated) {
          context.read<SessionCubit>().checkSession();
        }
      },
      child: BlocListener<SessionCubit, SessionState>(
        listener: (context, state) {
          if (state is SessionUnauthenticated || state is SessionError) {
            context.pushReplacementNamed('/');
          }
          if (state is SessionAuthenticated) {
            context.read<UserProfileCubit>().fetchUserDetails(state.user.userID, needLoading: false);
            final user = state.user;
            if (user.userRole == UserRoles.user || user.userRole == UserRoles.teamLead) {
              context.pushReplacementNamed('/user_dashboard');
            }
          }
        },
        child: LayoutBuilder(
          builder: (context, constraints) {
            if (responsiveScreenSize.isDesktopScreen(context) ||
                responsiveScreenSize.isTabletScreen(context)) {
              return _buildWideScreenLayout();
            } else {
              return _buildNarrowScreenLayout();
            }
          },
        ),
      ),
    );
  }

  Widget _buildWideScreenLayout() {
    return Material(
      child: Row(
        children: [
          SizedBox(
            width: 90.w,
            height: MediaQuery.sizeOf(context).height,
            child: Column(
              children: [
                SizedBox(height: 15),
                Image.asset(Assets.imagesLogo, width: 60, fit: BoxFit.fitWidth),
                SizedBox(height: 20),
                navButtons(0, Icons.dashboard, 'Dashboard', _onItemTapped),
                SizedBox(height: 5),
                navButtons(1, Icons.person, 'Users', _onItemTapped),
                SizedBox(height: 5),
                navButtons(2, Icons.settings, 'Settings', _onItemTapped),
                Spacer(),
                navButtons(3, Icons.logout, 'Logout', _onItemTapped),
                SizedBox(height: 20),
              ],
            ),
          ),
          VerticalDivider(thickness: 1, width: 1),
          Expanded(child: widget.navigationShell),
        ],
      ),
    );
  }

  InkWell navButtons(int index, IconData icon, String title, Function(int index) onTap) {
    return InkWell(
      onTap: () => onTap(index),
      borderRadius: BorderRadius.circular(10),
      highlightColor: AppColors.lightGray,
      hoverColor: AppColors.lightGray,
      child: Container(
        width: 70,
        padding: EdgeInsets.symmetric(vertical: 5),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 20,
              color: widget.navigationShell.currentIndex == index
                  ? AppColors.lightBlue
                  : Colors.black,
            ),
            SizedBox(height: 2),
            Text(
              title,
              textAlign: TextAlign.center,
              style: AppTextStyles.body13RobotoMedium.copyWith(
                color: widget.navigationShell.currentIndex == index
                    ? AppColors.lightBlue
                    : Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNarrowScreenLayout() {
    return Scaffold(
      body: widget.navigationShell,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: widget.navigationShell.currentIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: "Dashboard",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: "Users",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: "Settings",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.logout),
            label: "Logout",
          ),
        ],
      ),
    );
  }

  void _showClearCacheDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => WillPopScope(
        onWillPop: () async => false,
        child: AlertDialog(
          title: Text("Update Required"),
          content: Text(
            "Your app version is outdated. Please clear the website cache.\nYou need to tap f12, then right click mouse on refresh button and do clean cache and reset.",
          ),
        ),
      ),
    );
  }
}
