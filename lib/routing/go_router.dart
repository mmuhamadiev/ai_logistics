import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hegelmann_order_automation/presentation/pages/admin_dashboard/view/admin_dashboard_page.dart';
import 'package:hegelmann_order_automation/presentation/pages/admin_dashboard/view/admin_dashboard_view.dart';
import 'package:hegelmann_order_automation/presentation/pages/admin_dashboard/view/admin_settings_view.dart';
import 'package:hegelmann_order_automation/presentation/pages/admin_dashboard/view/user_management_view.dart';
import 'package:hegelmann_order_automation/presentation/pages/dashboard/components/create_order_dialog.dart';
import 'package:hegelmann_order_automation/presentation/pages/dashboard/view/all_orders_view.dart';
import 'package:hegelmann_order_automation/presentation/pages/dashboard/view/auto_order_view.dart';
import 'package:hegelmann_order_automation/presentation/pages/dashboard/view/group_order_view.dart';
import 'package:hegelmann_order_automation/presentation/pages/dashboard/view/user_dashboard_overview.dart';
import 'package:hegelmann_order_automation/presentation/pages/dashboard/view/user_dashboard_page.dart';
import 'package:hegelmann_order_automation/presentation/pages/login/view/login_page.dart';
import 'package:hegelmann_order_automation/presentation/pages/splash/view/splash_page.dart';

// final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();
final router  = GoRouter(
    // navigatorKey: rootNavigatorKey,
    // initialLocation: '/',
    routes: [
      GoRoute(
          name: '/',
          path: '/',
          builder: (context, state) => const SplashPage(),
      ),
      GoRoute(
        name: '/login',
        path: '/login',
        builder: (context, state) => const LoginPage(),
      ),
      // GoRoute(
      //   name: '/admin_dashboard',
      //   path: '/admin_dashboard',
      //   builder: (context, state) => AdminDashboardPage(),
      // ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return UserDashboardShell(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                name: '/user_dashboard',
                path: '/user_dashboard',
                builder: (context, state) => const UserDashboardOverview(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/user_orders',
                builder: (context, state) => const AllOrdersListView(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/user_autogroup',
                builder: (context, state) => AutoOrderView(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/user_confirmed',
                builder: (context, state) => const ConfirmedGroupsView(),
              ),
            ],
          ),
        ],
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return AdminDashboardShell(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                name: '/admin_dashboard',
                path: '/admin_dashboard',
                builder: (context, state) => AdminDashboardView(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/admin_users',
                builder: (context, state) => UserManagementView(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/admin_settings',
                builder: (context, state) => AdminDashboardSettingsView(),
              ),
            ],
          ),
        ],
      ),
      // GoRoute(
      //   name: '/user_dashboard',
      //   path: '/user_dashboard',
      //   builder: (context, state) => UserDashboardPage(),
      // ),
      // GoRoute(
      //   name: '/create_oder',
      //   path: '/create_oder',
      //   builder: (context, state) => CreateOrderView(),
      // ),

    ]);