import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import '../views/splash/splash_screen.dart';
import '../views/auth/login_screen.dart';
import '../views/auth/signup_screen.dart';
import '../views/home/home_screen.dart';
import '../views/booking/booking_screen.dart';
import '../views/booking/space_details_screen.dart';
import '../models/space_model.dart';

class AppRoutes {
  static Map<String, WidgetBuilder> get routes => {
    AppConstants.splashRoute: (context) => const SplashScreen(),
    AppConstants.loginRoute: (context) => const LoginScreen(),
    AppConstants.signupRoute: (context) => const SignupScreen(),
    AppConstants.homeRoute: (context) => const HomeScreen(),
  };

  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    // Handle unknown routes or dynamic routes here
    if (settings.name == AppConstants.spaceDetailsRoute) {
      final space = settings.arguments as SpaceModel;
      return MaterialPageRoute(
        builder: (_) => SpaceDetailsScreen(space: space),
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
