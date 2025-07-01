import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../constants/app_constants.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _checkAuthState();
  }

  Future<void> _checkAuthState() async {
    try {
      // Add a small delay to show splash screen
      await Future.delayed(const Duration(seconds: 2));

      if (!mounted) return;

      // Check if user is logged in
      final isLoggedIn = await _authService.isUserLoggedIn();

      if (!mounted) return;

      // Navigate based on auth state
      if (isLoggedIn) {
        Navigator.pushReplacementNamed(context, AppConstants.homeRoute);
      } else {
        Navigator.pushReplacementNamed(context, AppConstants.loginRoute);
      }
    } catch (e) {
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, AppConstants.loginRoute);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/icons/ignition.jpeg', height: 120.h),
            SizedBox(height: 24.h),
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
