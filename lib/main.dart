import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'constants/app_constants.dart';
import 'firebase_options.dart';
import 'theme/app_colors.dart';
import 'view_models/auth_view_model.dart';
import 'routes/app_routes.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'models/booking_model.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/services.dart';

Future<void> main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();
    await Hive.initFlutter();
    Hive.registerAdapter(BookingRequestAdapter());
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // Set system navigation bar color
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        systemNavigationBarColor: Colors.black,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
    );

    // Initialize flutter_local_notifications
    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);
    await flutterLocalNotificationsPlugin.initialize(initializationSettings);

    // Request notification permissions (especially for Android 13+ and iOS)
    await FirebaseMessaging.instance.requestPermission();

    // Listen for foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      print('Received a message while in the foreground!');
      print('Message data: \\${message.data}');
      if (message.notification != null) {
        print(
          'Message also contained a notification: \\${message.notification}',
        );
        // Show local notification
        RemoteNotification? notification = message.notification;
        AndroidNotification? android = message.notification?.android;
        if (notification != null && android != null) {
          await flutterLocalNotificationsPlugin.show(
            notification.hashCode,
            notification.title,
            notification.body,
            const NotificationDetails(
              android: AndroidNotificationDetails(
                'fcm_default_channel',
                'FCM Notifications',
                importance: Importance.max,
                priority: Priority.high,
                icon: '@mipmap/ic_launcher',
              ),
            ),
          );
        }
      }
    });

    // Print the FCM token
    String? token = await FirebaseMessaging.instance.getToken();
    print('FCM Token: $token');

    runApp(const MyApp());
  } catch (e) {
    print('Error initializing app: $e');
    runApp(const ErrorApp());
  }
}

class ErrorApp extends StatelessWidget {
  const ErrorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Center(
          child: Text(
            'Failed to initialize app. Please check your internet connection and try again.',
            style: TextStyle(color: Colors.red),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812), // Set to your design's base size
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MultiProvider(
          providers: [ChangeNotifierProvider(create: (_) => AuthViewModel())],
          child: Builder(
            builder: (context) {
              // Listen for FCM token refresh after the first frame
              WidgetsBinding.instance.addPostFrameCallback((_) {
                final authViewModel = Provider.of<AuthViewModel>(
                  context,
                  listen: false,
                );
                authViewModel.listenForFcmTokenRefresh();
              });
              return MaterialApp(
                debugShowCheckedModeBanner: false,
                title: AppConstants.appName,
                theme: ThemeData(
                  colorScheme: ColorScheme.fromSeed(
                    seedColor: AppColors.primary,
                  ),
                  useMaterial3: true,
                ),
                initialRoute: AppConstants.splashRoute,
                routes: AppRoutes.routes,
                onGenerateRoute: AppRoutes.onGenerateRoute,
                onUnknownRoute: AppRoutes.onUnknownRoute,
              );
            },
          ),
        );
      },
      child: const SizedBox.shrink(), // Placeholder child, not used
    );
  }
}
