import 'package:flutter/material.dart';

class AppConstants {
  // App Name
  static const String appName = "Ignition Coworking Space";
  static const String appNameShort = "Ignition";
  static const String appTagline = "Your Perfect Workspace Solution";

  // Firebase Collections
  static const String usersCollection = "users";
  static const String bookingsCollection = "bookings";
  static const String spacesCollection = "spaces";

  // Routes
  static const String splashRoute = "/splash";
  static const String loginRoute = "/login";
  static const String signupRoute = "/signup";
  static const String homeRoute = "/home";
  static const String bookingRoute = "/booking";
  static const String spaceDetailsRoute = "/space-details";

  // Shared Preferences Keys
  static const String userKey = "user_key";
  static const String tokenKey = "token_key";

  // Animation Durations
  static const Duration splashDuration = Duration(seconds: 3);
  static const Duration animationDuration = Duration(milliseconds: 300);

  // Sizes
  static const double defaultPadding = 16.0;
  static const double defaultRadius = 8.0;

  // Messages
  static const String networkError = "Please check your internet connection";
  static const String somethingWentWrong = "Something went wrong";

  // Space Types
  static const String meetingRoom = "Meeting Room";
  static const String conferenceRoom = "Conference Room";

  // Time Slots
  static const int startHour = 9; // 9 AM
  static const int endHour = 21; // 9 PM
  static const int slotDuration = 60; // 60 minutes per slot

  // Booking Status
  static const String available = "Available";
  static const String unavailable = "Unavailable";
  static const String pending = "Pending";
  static const String confirmed = "Confirmed";
  static const String cancelled = "Cancelled";
  static const String completed = "Completed";
}
