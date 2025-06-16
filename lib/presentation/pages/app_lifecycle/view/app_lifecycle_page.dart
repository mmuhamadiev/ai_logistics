import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hegelmann_order_automation/presentation/manager/user_profile_cubit/user_profile_cubit.dart';

class AppLifecycleObserver extends StatefulWidget {
  final Widget child;

  const AppLifecycleObserver({Key? key, required this.child}) : super(key: key);

  @override
  _AppLifecycleObserverState createState() => _AppLifecycleObserverState();
}

class _AppLifecycleObserverState extends State<AppLifecycleObserver>
    with WidgetsBindingObserver {

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this); // Add observer
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this); // Remove observer
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    switch (state) {
      case AppLifecycleState.inactive:
        print("App is inactive");
        // Perform action when the app is inactive (e.g., when user navigates to another app)
        break;
      case AppLifecycleState.paused:
        print("App is paused");
        // Perform action when the app is paused (e.g., when the app is backgrounded)
        break;
      case AppLifecycleState.resumed:
        print("App is resumed");
        // Perform action when the app is resumed
        break;
      case AppLifecycleState.detached:
        print("App is detached");
        // Perform action when the app is closed

        break;
      case AppLifecycleState.hidden:
        // TODO: Handle this case.
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
