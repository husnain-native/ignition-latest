import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationService {
  static Future<void> sendNotificationToBackend({
    required String serverUrl,
    required String targetFcmToken,
    required String title,
    required String body,
  }) async {
    final response = await http.post(
      Uri.parse('$serverUrl/send-notification'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'token': targetFcmToken, 'title': title, 'body': body}),
    );
    print('Notification response: \\${response.body}');
  }

  // Call this after a user books a slot
  static Future<void> notifyAdminOnBooking({
    required String userName,
    required String branch,
    required String timeSlot,
  }) async {
    final adminDoc =
        await FirebaseFirestore.instance.collection('users').doc('admin').get();
    final adminFcmToken = adminDoc.data()?['fcmToken'];
    if (adminFcmToken != null) {
      await sendNotificationToBackend(
        serverUrl: 'https://fcm-backend-2.onrender.com',
        targetFcmToken: adminFcmToken,
        title: 'New Booking Request',
        body: 'Branch: $branch, Name: $userName, Slot: $timeSlot',
      );
    }
  }

  // Call this after admin approves/rejects a booking
  static Future<void> notifyUserOnStatusChange({
    required String userId,
    required String branch,
    required String timeSlot,
    required String status,
  }) async {
    final userDoc =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();
    final userFcmToken = userDoc.data()?['fcmToken'];
    if (userFcmToken != null) {
      await sendNotificationToBackend(
        serverUrl: 'https://fcm-backend-2.onrender.com',
        targetFcmToken: userFcmToken,
        title: 'Booking Status Updated',
        body: 'Your booking at $branch is now $status. Slot: $timeSlot',
      );
    }
  }
}
