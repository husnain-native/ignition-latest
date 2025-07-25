import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_constants.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../view_models/auth_view_model.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../admin/admin_panel_screen.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _togglePasswordVisibility() {
    setState(() {
      _isPasswordVisible = !_isPasswordVisible;
    });
  }

  Future<void> _handleLogin() async {
    if (_formKey.currentState?.validate() ?? false) {
      final authViewModel = context.read<AuthViewModel>();
      final success = await authViewModel.signIn(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      if (success && mounted) {
        Navigator.pushReplacementNamed(context, '/branch-selection');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(AppConstants.defaultPadding.w),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: 20.h),
                Container(
                  width: 150.w,
                  height: 150.h,
                  margin: EdgeInsets.only(bottom: 24.h),
                  child: Image.asset(
                    'assets/icons/ignition.png',
                    fit: BoxFit.contain,
                  ),
                ),
                Text(
                  'Welcome Back!',
                  style: AppTextStyles.h1.copyWith(
                    color: AppColors.info,
                    fontSize: 32.sp,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 8.h),
                Text(
                  'Sign in to continue',
                  style: AppTextStyles.body1.copyWith(
                    color: AppColors.secondary,
                    fontSize: 16.sp,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 48.h),
                CustomTextField(
                  controller: _emailController,
                  hintText: 'Email',
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    if (!value.contains('@')) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16.h),
                CustomTextField(
                  controller: _passwordController,
                  hintText: 'Password',
                  obscureText: !_isPasswordVisible,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isPasswordVisible
                          ? Icons.visibility_off
                          : Icons.visibility,
                      color: AppColors.textSecondary,
                    ),
                    onPressed: _togglePasswordVisibility,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    if (value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 24.h),
                Consumer<AuthViewModel>(
                  builder: (context, authViewModel, child) {
                    return CustomButton(
                      onPressed:
                          authViewModel.status == AuthStatus.loading
                              ? null
                              : _handleLogin,
                      text: 'Sign In',
                      isLoading: authViewModel.status == AuthStatus.loading,
                    );
                  },
                ),
                if (context.watch<AuthViewModel>().error != null)
                  Padding(
                    padding: EdgeInsets.only(top: 16.h),
                    child: Text(
                      context.watch<AuthViewModel>().error!,
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.error,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                const Spacer(),
               
                SizedBox(height: 16),
              ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(
                          255,
                          242,
                          246,
                          247,
                        ),
                        foregroundColor: AppColors.info,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                          side: BorderSide(
                            color: AppColors.primaryLight,
                            width: 1,
                          ),
                        ),
                      ),
                      onPressed: () async {
                        String username = '';
                        String password = '';
                        final _formKey = GlobalKey<FormState>();
                        bool? result = await showDialog<bool>(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              backgroundColor: Colors.grey[100],
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              title: Column(
                                children: [
                                  Image.asset(
                                    'assets/icons/ignition.png', // Use your logo path
                                    height: 48,
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'Admin Login',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              content: Form(
                                key: _formKey,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    TextFormField(
                                      decoration: InputDecoration(
                                        labelText: 'Username',
                                      ),
                                      onChanged: (value) => username = value,
                                      validator:
                                          (value) =>
                                              value == null || value.isEmpty
                                                  ? 'Enter username'
                                                  : null,
                                    ),
                                    TextFormField(
                                      obscureText: true,
                                      decoration: InputDecoration(
                                        labelText: 'Password',
                                      ),
                                      onChanged: (value) => password = value,
                                      validator:
                                          (value) =>
                                              value == null || value.isEmpty
                                                  ? 'Enter password'
                                                  : null,
                                    ),
                                  ],
                                ),
                              ),
                              actions: [
                                TextButton(
                                  onPressed:
                                      () => Navigator.pop(context, false),
                                  child: Text('Cancel'),
                                ),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.deepPurple,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  onPressed: () {
                                    if ((_formKey.currentState?.validate() ??
                                        false)) {
                                      Navigator.pop(context, true);
                                    }
                                  },
                                  child: Text('Login'),
                                ),
                              ],
                            );
                          },
                        );
                        if (result == true &&
                            username == 'admin' &&
                            password == 'admin123') {
                          final fcmToken =
                              await FirebaseMessaging.instance.getToken();
                          if (fcmToken != null) {
                            await FirebaseFirestore.instance
                                .collection('admin_devices')
                                .doc(fcmToken)
                                .set({
                                  'role': 'admin',
                                  'fcmToken': fcmToken,
                                  'username': username,
                                  'createdAt': FieldValue.serverTimestamp(),
                                }, SetOptions(merge: true));
                          }
                          Navigator.pushReplacementNamed(
                            context,
                            AppConstants.adminBranchSelectionRoute,
                          );
                        } else if (result == true) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Incorrect admin username or password',
                              ),
                            ),
                          );
                        }
                      },
                      child: Text('Admin'),
                    ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}