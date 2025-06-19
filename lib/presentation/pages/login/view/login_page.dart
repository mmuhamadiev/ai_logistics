import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ai_logistics_management_order_automation/config/app_colors.dart';
import 'package:ai_logistics_management_order_automation/config/app_text_styles.dart';
import 'package:ai_logistics_management_order_automation/config/constants.dart';
import 'package:ai_logistics_management_order_automation/config/screen_size.dart';
import 'package:ai_logistics_management_order_automation/generated/assets.dart';
import 'package:ai_logistics_management_order_automation/presentation/manager/session/session_cubit.dart';
import 'package:ai_logistics_management_order_automation/presentation/manager/user_profile_cubit/user_profile_cubit.dart';
import 'package:ai_logistics_management_order_automation/presentation/widgets/notifications/error_notification.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  ResponsiveScreenSize responsiveScreenSize = ResponsiveScreenSize();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void initState() {
    if (kDebugMode) {
      _passwordController.text = '12345678';
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SessionCubit, SessionState>(
      listener: (context, state) {
        if (state is SessionError) {
          // Display error message
          showErrorNotification(context, state.message);
        }

        if (state is SessionAuthenticated) {
          // User is authenticated, navigate based on role

          context.read<UserProfileCubit>().fetchUserDetails(state.user.userID);
          final user = state.user;
          if (user.userRole == UserRoles.admin) {
            context.pushReplacementNamed('/admin_dashboard');
          } else {
            context.pushReplacementNamed('/user_dashboard');
          }
        }
      },
      child: LayoutBuilder(
        builder: (context, constraints) {
          if(responsiveScreenSize.isDesktopScreen(context)) {
            return Scaffold(
              body: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 100, vertical: 20),
                child: Row(
                  children: [
                    // Left Side: Login Form
                    Expanded(
                      flex: 1,
                      child: Form(
                        key: _formKey,
                        child:  BlocBuilder<SessionCubit, SessionState>(
                            builder: (context, state) {
                              final isLoading = state is SessionLoading;
                              return IgnorePointer(
                                ignoring: isLoading,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("Welcome", style: AppTextStyles.head42RobotoMedium),
                                    const SizedBox(height: 10),
                                    Text(
                                      "Login to access your account",
                                      style: AppTextStyles.head30RobotoMedium
                                          .copyWith(color: AppColors.grey),
                                    ),
                                    const SizedBox(height: 20),
                                    // Email Field
                                    _buildInputField(
                                      label: 'Username',
                                      hintText: 'Enter your username',
                                      controller: _usernameController,
                                      isUsername: true,
                                      validator: (value) {
                                        if (value == null || value.trim().isEmpty) {
                                          return "Username is required";
                                        }
                                        return null;
                                      },
                                    ),
                                    const SizedBox(height: 15),
                                    // Password Field
                                    _buildInputField(
                                      label: 'Password',
                                      hintText: 'Enter your password',
                                      controller: _passwordController,
                                      obscureText: _obscurePassword,
                                      isUsername: false,
                                      suffixIcon: IconButton(
                                        icon: Icon(
                                          _obscurePassword ? Icons.visibility_off : Icons.visibility,
                                          color: Colors.grey,
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            _obscurePassword = !_obscurePassword;
                                          });
                                        },
                                      ),
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Please enter your password';
                                        }
                                        return null;
                                      },
                                    ),

                                    const SizedBox(height: 20),

                                    // Login Button
                                    Material(
                                      borderRadius: BorderRadius.circular(8),
                                      child: InkWell(
                                        onTap: () {
                                          if (_formKey.currentState?.validate() ?? false) {
                                            context.read<SessionCubit>().login(
                                              username: _usernameController.text,
                                              password: _passwordController.text,
                                            );
                                          }
                                        },
                                        borderRadius: BorderRadius.circular(8),
                                        splashColor: Colors.blue[200], // Splash effect color
                                        highlightColor: Colors.blue[100], // Highlight effect color
                                        child: Container(
                                          width: double.infinity,
                                          height: 50,
                                          decoration: BoxDecoration(
                                            gradient: AppColors.lineLoginGradient,
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Center(
                                            child: isLoading
                                                ? const SizedBox(
                                              width: 20,
                                              height: 20,
                                              child: CircularProgressIndicator(
                                                color: AppColors.white,
                                                strokeWidth: 2,
                                              ),
                                            )
                                                : Text(
                                              "Login",
                                              style: AppTextStyles.head22RobotoMedium.copyWith(
                                                color: AppColors.white,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 20),
                                  ],
                                ),
                              );
                            }
                        ),
                      ),
                    ),
                    const SizedBox(width: 50),
                    // Right Side: Image
                    Expanded(
                      flex: 1,
                      child: SizedBox(
                        height: 600,
                        child: Image.asset(Assets.imagesLoginUnlocked),
                      ),
                    ),
                  ],
                ),
              ),
            );
          } else if(responsiveScreenSize.isTabletScreen(context)) {
            return Scaffold(
              body: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 100, vertical: 20),
                child: Row(
                  children: [
                    // Left Side: Login Form
                    Expanded(
                      flex: 1,
                      child: Form(
                        key: _formKey,
                        child:  BlocBuilder<SessionCubit, SessionState>(
                            builder: (context, state) {
                              final isLoading = state is SessionLoading;
                              return IgnorePointer(
                                ignoring: isLoading,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("Welcome", style: AppTextStyles.head42RobotoMedium),
                                    const SizedBox(height: 10),
                                    Text(
                                      "Login to access your account",
                                      style: AppTextStyles.head30RobotoMedium
                                          .copyWith(color: AppColors.grey),
                                    ),
                                    const SizedBox(height: 20),
                                    // Email Field
                                    _buildInputField(
                                      label: 'Username',
                                      hintText: 'Enter your username',
                                      controller: _usernameController,
                                      isUsername: true,
                                      validator: (value) {
                                        if (value == null || value.trim().isEmpty) {
                                          return "Username is required";
                                        }
                                        return null;
                                      },
                                    ),
                                    const SizedBox(height: 15),
                                    // Password Field
                                    _buildInputField(
                                      label: 'Password',
                                      hintText: 'Enter your password',
                                      controller: _passwordController,
                                      obscureText: _obscurePassword,
                                      isUsername: false,
                                      suffixIcon: IconButton(
                                        icon: Icon(
                                          _obscurePassword ? Icons.visibility_off : Icons.visibility,
                                          color: Colors.grey,
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            _obscurePassword = !_obscurePassword;
                                          });
                                        },
                                      ),
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Please enter your password';
                                        }
                                        return null;
                                      },
                                    ),

                                    const SizedBox(height: 20),

                                    // Login Button
                                    Material(
                                      borderRadius: BorderRadius.circular(8),
                                      child: InkWell(
                                        onTap: () {
                                          if (_formKey.currentState?.validate() ?? false) {
                                            context.read<SessionCubit>().login(
                                              username: _usernameController.text,
                                              password: _passwordController.text,
                                            );
                                          }
                                        },
                                        borderRadius: BorderRadius.circular(8),
                                        splashColor: Colors.blue[200], // Splash effect color
                                        highlightColor: Colors.blue[100], // Highlight effect color
                                        child: Container(
                                          width: double.infinity,
                                          height: 50,
                                          decoration: BoxDecoration(
                                            gradient: AppColors.lineLoginGradient,
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Center(
                                            child: isLoading
                                                ? const SizedBox(
                                              width: 20,
                                              height: 20,
                                              child: CircularProgressIndicator(
                                                color: AppColors.white,
                                                strokeWidth: 2,
                                              ),
                                            )
                                                : Text(
                                              "Login",
                                              style: AppTextStyles.head22RobotoMedium.copyWith(
                                                color: AppColors.white,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 20),
                                  ],
                                ),
                              );
                            }
                        ),
                      ),
                    ),
                    const SizedBox(width: 50),
                    // Right Side: Image
                    Expanded(
                      flex: 1,
                      child: SizedBox(
                        height: 600,
                        child: Image.asset(Assets.imagesLoginUnlocked),
                      ),
                    ),
                  ],
                ),
              ),
            );
          } else {
            return Scaffold(
              body: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Welcome", style: AppTextStyles.head42RobotoMedium),
                      const SizedBox(height: 10),
                      Text(
                        "Login to access your account",
                        style: AppTextStyles.head30RobotoMedium
                            .copyWith(color: AppColors.grey),
                      ),
                      const SizedBox(height: 60),
                      Form(
                        key: _formKey,
                        child:  BlocBuilder<SessionCubit, SessionState>(
                            builder: (context, state) {
                              final isLoading = state is SessionLoading;
                              return IgnorePointer(
                                ignoring: isLoading,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Username Field
                                    _buildInputField(
                                      label: 'Username',
                                      hintText: 'Enter your username',
                                      controller: _usernameController,
                                      isUsername: true,
                                      validator: (value) {
                                        if (value == null || value.trim().isEmpty) {
                                          return "Username is required";
                                        }
                                        return null;
                                      },
                                    ),
                                    const SizedBox(height: 15),
                                    // Password Field
                                    _buildInputField(
                                      label: 'Password',
                                      hintText: 'Enter your password',
                                      controller: _passwordController,
                                      obscureText: _obscurePassword,
                                      isUsername: false,
                                      suffixIcon: IconButton(
                                        icon: Icon(
                                          _obscurePassword ? Icons.visibility_off : Icons.visibility,
                                          color: Colors.grey,
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            _obscurePassword = !_obscurePassword;
                                          });
                                        },
                                      ),
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Please enter your password';
                                        }
                                        return null;
                                      },
                                      onFormSubmit: (value) {
                                        if (_formKey.currentState?.validate() ?? false) {
                                          _formKey.currentState!.save();
                                        print('submitted');
                                          context.read<SessionCubit>().login(
                                            username: _usernameController.text,
                                            password: _passwordController.text,
                                          );
                                        }
                                      }
                                    ),

                                    const SizedBox(height: 20),

                                    // Login Button
                                    Material(
                                      borderRadius: BorderRadius.circular(8),
                                      child: InkWell(
                                        onTap: () {
                                          if (_formKey.currentState?.validate() ?? false) {
                                            context.read<SessionCubit>().login(
                                              username: _usernameController.text,
                                              password: _passwordController.text,
                                            );
                                          }
                                        },
                                        borderRadius: BorderRadius.circular(8),
                                        splashColor: Colors.blue[200], // Splash effect color
                                        highlightColor: Colors.blue[100], // Highlight effect color
                                        child: Container(
                                          width: double.infinity,
                                          height: 50,
                                          decoration: BoxDecoration(
                                            gradient: AppColors.lineLoginGradient,
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Center(
                                            child: isLoading
                                                ? const SizedBox(
                                              width: 20,
                                              height: 20,
                                              child: CircularProgressIndicator(
                                                color: AppColors.white,
                                                strokeWidth: 2,
                                              ),
                                            )
                                                : Text(
                                              "Login",
                                              style: AppTextStyles.head22RobotoMedium.copyWith(
                                                color: AppColors.white,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 20),
                                  ],
                                ),
                              );
                            }
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }
        }
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required String hintText,
    required bool isUsername,
    required TextEditingController controller,
    bool obscureText = false,
    Widget? suffixIcon,
    String? Function(String?)? validator,
    Function(String)? onFormSubmit,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.body14RobotoRegular,
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          validator: validator,
          textInputAction: TextInputAction.send,
          onFieldSubmitted: (value) {
            if(onFormSubmit != null) {
              onFormSubmit(value);
            }
          },
          decoration: InputDecoration(
            hintText: hintText,
            suffixIcon: suffixIcon,
            prefixIcon: isUsername? Icon(Icons.email, color: AppColors.grey,): Icon(Icons.lock, color: AppColors.grey,),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: AppColors.grey),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: AppColors.black),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
        ),
      ],
    );
  }
}
