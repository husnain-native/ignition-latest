import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_constants.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../view_models/auth_view_model.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

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
      await authViewModel.signIn(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (mounted) {
        if (authViewModel.status == AuthStatus.loading) {
          // Show loading indicator
        } else if (authViewModel.status == AuthStatus.authenticated) {
          Navigator.pushReplacementNamed(context, AppConstants.homeRoute);
        } else if (authViewModel.status == AuthStatus.error) {
          print('Login Screen Error: ${authViewModel.error}');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(Icons.error_outline, color: Colors.white),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      authViewModel.error!,
                      style: AppTextStyles.body2.copyWith(color: Colors.white),
                    ),
                  ),
                ],
              ),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
              margin: const EdgeInsets.all(16),
              duration: const Duration(seconds: 4),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        }
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
                const Spacer(flex: 1),
                Container(
                  width: 120.w,
                  height: 120.w,
                  margin: EdgeInsets.only(bottom: 24.h),
                  child: Image.asset(
                    'assets/icons/ignition.jpeg',
                    fit: BoxFit.contain,
                  ),
                ),
                Text(
                  'Welcome Back!',
                  style: AppTextStyles.h1.copyWith(
                    color: AppColors.primary,
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Don't have an account? ", style: AppTextStyles.body2),
                    TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, AppConstants.signupRoute);
                      },
                      child: Text(
                        'Sign Up',
                        style: AppTextStyles.body2.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
