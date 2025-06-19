import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ai_logistics_management_order_automation/config/app_colors.dart';
import 'package:ai_logistics_management_order_automation/config/app_text_styles.dart';
import 'package:ai_logistics_management_order_automation/config/constants.dart';
import 'package:ai_logistics_management_order_automation/presentation/manager/session/session_cubit.dart';
import 'package:ai_logistics_management_order_automation/presentation/widgets/notifications/error_notification.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {

  @override
  void initState() {
    super.initState();
    // After a short delay, check the session
    Future.delayed(const Duration(milliseconds: 2000), () {
      context.read<SessionCubit>().checkSession();
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SessionCubit, SessionState>(
        listener: (context, state) {
          if (state is SessionUnauthenticated) {
            // No session and no remember-me auto login chosen
            context.pushReplacementNamed('/login');
          }
          if (state is SessionError) {
            showErrorNotification(context, state.message);
            context.pushReplacementNamed('/login');
          }
          if (state is SessionAuthenticated) {

            final user = state.user;
            if (user.userRole == UserRoles.user || user.userRole == UserRoles.teamLead) {
              context.pushReplacementNamed('/user_dashboard');
            } else {
              context.pushReplacementNamed('/admin_dashboard');
            }
          }
        },
        child: Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate('HEGELMANN'.length, (index) {
                    return Text(
                      'HEGELMANN'[index],
                      style: AppTextStyles.head24RobotoMedium.copyWith(color: Theme.of(context).primaryColor),
                    )
                        .animate()
                        .fadeIn(delay: Duration(milliseconds: index * 100))
                        .slide(begin: const Offset(-0.5, 0), duration: 400.ms);
                  }),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate('GROUP'.length, (index) {
                    return Text(
                      'GROUP'[index],
                      style: AppTextStyles.body16RobotoRegular.copyWith(color: Theme.of(context).primaryColor),
                    )
                        .animate()
                        .fadeIn(delay: Duration(milliseconds: (index * 100) + 500))
                        .slide(begin: const Offset(-0.5, 0), duration: 400.ms);
                  }),
                ),
              ],
            ),
          ),
        ),
      );
  }

}
