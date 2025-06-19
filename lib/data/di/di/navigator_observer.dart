import 'package:flutter/material.dart';
import 'package:ai_logistics_management_order_automation/presentation/manager/navigation/navigation_cubit.dart';

class CustomNavigatorObserver extends NavigatorObserver {
  final NavigationCubit navigationCubit;

  CustomNavigatorObserver(this.navigationCubit);

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    navigationCubit.updateCurrentPageName(route.settings.name ?? route.settings.name?? '');
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    navigationCubit.updateCurrentPageName(route.settings.name ?? route.settings.name?? '');
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    navigationCubit.updateCurrentPageName(newRoute?.settings.name ?? newRoute?.settings.name?? '');
  }
}
