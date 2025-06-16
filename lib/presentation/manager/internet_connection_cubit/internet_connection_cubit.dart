import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class InternetConnectionCubit extends Cubit<ConnectivityResult> {
  final Connectivity _connectivity;
  late StreamSubscription<ConnectivityResult> _connectivitySubscription;

  InternetConnectionCubit(this._connectivity) : super(ConnectivityResult.none) {
    _connectivity.onConnectivityChanged.listen((ConnectivityResult result) {
      emit(result);
    });
  }

  void recheckConnection() async{
    final ConnectivityResult connectivityResult = await (_connectivity.checkConnectivity());

    // This condition is for demo purposes only to explain every connection type.
    // Use conditions which work for your requirements.
    if (connectivityResult == ConnectivityResult.mobile) {
      emit(connectivityResult);
    } else if (connectivityResult ==  ConnectivityResult.wifi) {
      // Wi-fi is available.
      // Note for Android:
      // When both mobile and Wi-Fi are turned on system will return Wi-Fi only as active network type
      emit(connectivityResult);
    } else if (connectivityResult == ConnectivityResult.ethernet) {
      // Ethernet connection available.
    } else if (connectivityResult == ConnectivityResult.vpn) {
      // Vpn connection active.
      // Note for iOS and macOS:
      // There is no separate network interface type for [vpn].
      // It returns [other] on any device (also simulator)
    } else if (connectivityResult == ConnectivityResult.bluetooth) {
      // Bluetooth connection available.
    } else if (connectivityResult == ConnectivityResult.other) {
      // Connected to a network which is not in the above mentioned networks.
    } else if (connectivityResult == ConnectivityResult.none) {
      // No available network types
    }
  }

  @override
  Future<void> close() {
    _connectivitySubscription.cancel();
    return super.close();
  }
}