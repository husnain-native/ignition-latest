import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import '../views/splash/splash_screen.dart';
import '../views/auth/login_screen.dart';
import '../views/auth/signup_screen.dart';
import '../views/home/home_screen.dart';
import '../views/booking/booking_screen.dart';
import '../views/booking/space_details_screen.dart';
import '../models/space_model.dart';
import '../views/branch_selection_screen.dart';
import '../views/admin/admin_panel_screen.dart';
import '../views/admin/admin_branch_selection_screen.dart';
import '../views/admin/booking_details_screen.dart';

class AppRoutes {
  static Map<String, WidgetBuilder> get routes => {
    AppConstants.splashRoute: (context) => const SplashScreen(),
    AppConstants.loginRoute: (context) => const LoginScreen(),
    AppConstants.signupRoute: (context) => const SignupScreen(),
    '/branch-selection': (context) => const BranchSelectionScreen(),
    '/admin-panel': (context) => const AdminPanelScreen(),
    AppConstants.adminBranchSelectionRoute:
        (context) => const AdminBranchSelectionScreen(),
    '/booking-details': (context) => const BookingDetailsScreen(),
  };

  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    if (settings.name == AppConstants.spaceDetailsRoute) {
      final space = settings.arguments as SpaceModel;
      return MaterialPageRoute(
        builder: (_) => SpaceDetailsScreen(space: space),
      );
    }
    if (settings.name == AppConstants.homeRoute) {
      final branchName = settings.arguments as String;
      return MaterialPageRoute(
        builder: (_) => HomeScreen(branchName: branchName),
      );
    }
    return MaterialPageRoute(
      builder:
          (_) => Scaffold(
            body: Center(child: Text('Route ${settings.name} not found')),
          ),
    );
  }

  static Route<dynamic>? onUnknownRoute(RouteSettings settings) {
    return MaterialPageRoute(
      builder:
          (_) => Scaffold(
            body: Center(child: Text('Unknown route: ${settings.name}')),
          ),
    );
  }
}
