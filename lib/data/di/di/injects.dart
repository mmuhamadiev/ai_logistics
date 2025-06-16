import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/instance_manager.dart';
import 'package:hegelmann_order_automation/data/repositories/app_version_repository.dart';
import 'package:hegelmann_order_automation/data/repositories/auth_repository.dart';
import 'package:hegelmann_order_automation/data/repositories/filter_repository.dart';
import 'package:hegelmann_order_automation/data/repositories/group_order_repository.dart';
import 'package:hegelmann_order_automation/data/repositories/order_repository.dart';
import 'package:hegelmann_order_automation/data/repositories/users_management_repository.dart';
import 'package:hegelmann_order_automation/data/repositories/users_repository.dart';
import 'package:hegelmann_order_automation/data/services/firebase_filter_helper.dart';
import 'package:hegelmann_order_automation/data/services/firebase_helper.dart';
import 'package:hegelmann_order_automation/data/services/group_order_firebase_service.dart';
import 'package:hegelmann_order_automation/data/services/multi_storage.dart';
import 'package:hegelmann_order_automation/data/services/order_firebase_service.dart';
import 'package:hegelmann_order_automation/presentation/manager/filter/filter_cubit.dart';
import 'package:hegelmann_order_automation/presentation/manager/firebase_auth/firebase_auth_cubit.dart';
import 'package:hegelmann_order_automation/presentation/manager/group_order_list/group_order_list_cubit.dart';
import 'package:hegelmann_order_automation/presentation/manager/internet_connection_cubit/internet_connection_cubit.dart';
import 'package:hegelmann_order_automation/presentation/manager/navigation/navigation_cubit.dart';
import 'package:hegelmann_order_automation/presentation/manager/order_list/order_list_cubit.dart';
import 'package:hegelmann_order_automation/presentation/manager/postalcode/postcode_cubit.dart';
import 'package:hegelmann_order_automation/presentation/manager/session/session_cubit.dart';
import 'package:hegelmann_order_automation/presentation/manager/user_profile_cubit/user_profile_cubit.dart';
import 'package:hegelmann_order_automation/presentation/manager/version/app_version_cubit.dart';
import 'package:hegelmann_order_automation/presentation/pages/admin_dashboard/manager/admin_users_cubit/admin_users_cubit.dart';
import 'package:hegelmann_order_automation/presentation/pages/admin_dashboard/manager/users_management_cubit/users_management_cubit.dart';
import 'package:public_ip_address/public_ip_address.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:talker_bloc_logger/talker_bloc_logger_observer.dart';
import 'package:talker_bloc_logger/talker_bloc_logger_settings.dart';
import 'package:talker_flutter/talker_flutter.dart';

/// внедряем зависимости, чтобы можно было вызвать в любом месте приложения
Future initMain() async {

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final SharedPreferences _sharedPrefs = await SharedPreferences.getInstance();

  final storage = FlutterSecureStorage();

  final talker = Talker();

  IpAddress ipAddress = IpAddress();

  final Connectivity connectivity = Connectivity();

  //зависимости
  Get.put<Connectivity>(connectivity);
  Get.put<FirebaseFirestore>(_firestore);
  Get.put<SharedPreferences>(_sharedPrefs);
  Get.put<FlutterSecureStorage>(storage);
  Get.put<IpAddress>(ipAddress);

  final firebaseHelper = FirebaseHelper(
    Get.find<FirebaseFirestore>(),
    Get.find<IpAddress>(),
  );
  final firebaseFilterHelper = FirebaseFilterHelper(
    Get.find<FirebaseFirestore>(),
  );
  final orderService = OrderService(
    Get.find<FirebaseFirestore>(),
  );
  final groupOrderService = GroupOrderService(
    Get.find<FirebaseFirestore>(),
  );
  Get.put<FirebaseHelper>(firebaseHelper);
  Get.put<FirebaseFilterHelper>(firebaseFilterHelper);
  Get.put<OrderService>(orderService);
  Get.put<GroupOrderService>(groupOrderService);
  Get.put<MultiStorageHandler>(MultiStorageHandler(
      Get.find<FlutterSecureStorage>(),
    ),
  );

  Bloc.observer = TalkerBlocObserver(
      talker: talker,
    settings: const TalkerBlocLoggerSettings(
      enabled: true,
      printEventFullData: true,
      printStateFullData: true,
      printChanges: true,
      printClosings: true,
      printCreations: true,
      printEvents: true,
      printTransitions: true,
      // // If you want log only AuthBloc transitions
      // transitionFilter: (bloc, transition) =>
      // bloc.runtimeType.toString() == 'AuthBloc',
      // // If you want log only AuthBloc events
      // eventFilter: (bloc, event) => bloc.runtimeType.toString() == 'AuthBloc',
    ),
  );

  //Репозитории
  Get.put<AuthRepositoryImpl>(AuthRepositoryImpl(
      Get.find<FirebaseHelper>(),
  ));
  Get.put<UsersRepositoryImpl>(UsersRepositoryImpl(
      Get.find<FirebaseHelper>(),
  ));
  Get.put<UsersManagementRepositoryImpl>(UsersManagementRepositoryImpl(
      Get.find<FirebaseHelper>(),
  ));
  Get.put<OrderRepositoryImpl>(OrderRepositoryImpl(
      Get.find<OrderService>(),
  ));
  Get.put<GroupOrderRepositoryImpl>(GroupOrderRepositoryImpl(
    Get.find<GroupOrderService>(),
  ));
  Get.put<FilterRepositoryImpl>(FilterRepositoryImpl(
    Get.find<FirebaseFilterHelper>(),
  ));
  Get.put<AppVersionRepository>(AppVersionRepository(
    Get.find<FirebaseHelper>(),
  ));

  //Менеджер состояния
  Get.put<NavigationCubit>(NavigationCubit());
  Get.put<InternetConnectionCubit>(InternetConnectionCubit(
      Get.find<Connectivity>()
  ));
  Get.put<FirebaseAuthCubit>(FirebaseAuthCubit(
      Get.find<AuthRepositoryImpl>(),
      Get.find<FlutterSecureStorage>(),
  ));
  Get.put<AdminUsersCubit>(AdminUsersCubit(
      Get.find<UsersRepositoryImpl>(),
  ));
  Get.put<UserProfileCubit>(UserProfileCubit(
      Get.find<UsersManagementRepositoryImpl>(),
  ));
  Get.put<UsersManagementCubit>(UsersManagementCubit(
      Get.find<UsersManagementRepositoryImpl>(),
  ));
  Get.put<SessionCubit>(SessionCubit(
    Get.find<AuthRepositoryImpl>(),
    Get.find<UsersManagementRepositoryImpl>(),
    Get.find<MultiStorageHandler>(),
  ));
  Get.put<OrderListCubit>(OrderListCubit(
    Get.find<OrderRepositoryImpl>(),
  ));
  Get.put<GroupOrderListCubit>(GroupOrderListCubit(
    Get.find<GroupOrderRepositoryImpl>(),
  ));
  Get.put<PostcodeCubit>(PostcodeCubit());
  Get.put<FilterCubit>(FilterCubit(
    Get.find<FilterRepositoryImpl>(),
  ));
  Get.put<AppVersionCubit>(AppVersionCubit(
    Get.find<AppVersionRepository>(),
  ));

}