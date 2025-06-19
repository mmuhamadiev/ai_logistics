import 'dart:async';

import 'package:ai_logistics_management_order_automation/config/app_theme.dart';
import 'package:ai_logistics_management_order_automation/data/di/di/injects.dart';
import 'package:device_preview_plus/device_preview_plus.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ai_logistics_management_order_automation/firebase_options.dart';
import 'package:ai_logistics_management_order_automation/presentation/manager/filter/filter_cubit.dart';
import 'package:ai_logistics_management_order_automation/presentation/manager/firebase_auth/firebase_auth_cubit.dart';
import 'package:ai_logistics_management_order_automation/presentation/manager/group_order_list/group_order_list_cubit.dart';
import 'package:ai_logistics_management_order_automation/presentation/manager/internet_connection_cubit/internet_connection_cubit.dart';
import 'package:ai_logistics_management_order_automation/presentation/manager/navigation/navigation_cubit.dart';
import 'package:ai_logistics_management_order_automation/presentation/manager/order_list/order_list_cubit.dart';
import 'package:ai_logistics_management_order_automation/presentation/manager/session/session_cubit.dart';
import 'package:ai_logistics_management_order_automation/presentation/manager/user_profile_cubit/user_profile_cubit.dart';
import 'package:ai_logistics_management_order_automation/presentation/manager/version/app_version_cubit.dart';
import 'package:ai_logistics_management_order_automation/presentation/pages/admin_dashboard/manager/admin_users_cubit/admin_users_cubit.dart';
import 'package:ai_logistics_management_order_automation/presentation/pages/admin_dashboard/manager/users_management_cubit/users_management_cubit.dart';
import 'package:ai_logistics_management_order_automation/presentation/pages/app_lifecycle/view/app_lifecycle_page.dart';
import 'package:ai_logistics_management_order_automation/routing/go_router.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'dart:html' as html;
import 'package:timezone/data/latest.dart' as tz;
import 'presentation/manager/postalcode/postcode_cubit.dart';
import 'package:flutter_web_plugins/url_strategy.dart';

Future<void> main() async{
  usePathUrlStrategy();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  tz.initializeTimeZones();
  await initMain();

  runApp(MultiBlocProvider(
      providers: [
        BlocProvider(create: (context)=> Get.find<NavigationCubit>()),
        BlocProvider(create: (context)=> Get.find<AppVersionCubit>()),
        BlocProvider(create: (context)=> Get.find<SessionCubit>()),
        BlocProvider(create: (context)=> Get.find<InternetConnectionCubit>()),
        BlocProvider(create: (context)=> Get.find<FirebaseAuthCubit>()),
        BlocProvider(create: (context)=> Get.find<UserProfileCubit>()),
        BlocProvider(create: (context)=> Get.find<UsersManagementCubit>()),
        BlocProvider(create: (context)=> Get.find<AdminUsersCubit>()),
        BlocProvider(create: (context)=> Get.find<OrderListCubit>()),
        BlocProvider(create: (context)=> Get.find<GroupOrderListCubit>()),
        BlocProvider(create: (context)=> Get.find<PostcodeCubit>()),
        BlocProvider(create: (context)=> Get.find<FilterCubit>()..initializeGlobalFilter()),
      ],
      child: AppLifecycleObserver(child: DevicePreview(
          enabled: kDebugMode,
          builder: (context) => MyApp(),
          ),
      ),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  void setupVisibilityListener(SessionCubit sessionCubit) {
    html.document.onVisibilityChange.listen((event) {
      final isHidden = html.document.hidden;
      if (isHidden == false) {
        print("Tab became visible - checking session...");
        sessionCubit.checkSession();
      } else {
        print("Tab is hidden or event triggered with hidden=$isHidden");
      }
    });
  }

  void setupBeforeUnloadListener(SessionCubit sessionCubit) {
    html.window.onBeforeUnload.listen((event) {
      // Attempt best-effort cleanup before the page is unloaded
      // For example, call hardStopEditing() or logout using sendBeacon
      if (sessionCubit.state is SessionAuthenticated) {
        // Add your custom logic here if needed
        final confirmationMessage = 'Are you sure you want to leave? Unsaved changes may be lost.';

        // Show the browser default confirmation dialog
        // event.preventDefault();
        if (event is html.BeforeUnloadEvent) {
          event.returnValue = confirmationMessage; // This will trigger the browser default confirmation
        }

        // Optional: Perform cleanup tasks like logout
        sessionCubit.logout();
      }
    });
  }

  @override
  void initState() {
    setupVisibilityListener(Get.find<SessionCubit>());
    setupBeforeUnloadListener(Get.find<SessionCubit>());
    context.read<PostcodeCubit>().loadInitialPostcodesTemp();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    // ScreenUtilInit(
    //     designSize: const Size(1512, 963),
    //     minTextAdapt: true,
    //     splitScreenMode: false,

    return ScreenUtilInit(
      designSize: const Size(1920, 801),
      minTextAdapt: true,
      splitScreenMode: false,
      child: MaterialApp.router(
        builder: (context, child) => ResponsiveBreakpoints.builder(
          child: child!,
          breakpoints: [
            const Breakpoint(start: 0, end: 450, name: MOBILE),
            const Breakpoint(start: 451, end: 800, name: TABLET),
            const Breakpoint(start: 801, end: 1920, name: DESKTOP),
            const Breakpoint(start: 1921, end: double.infinity, name: '4K'),
          ],
        ),
        title: 'Order Automation',
        theme: AppTheme.light,
        locale: const Locale('en'),
        localizationsDelegates:  const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        routerConfig: router,
      ),
    );
  }
}