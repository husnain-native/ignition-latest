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
    required String date,
  }) async {
    // Fetch all admin FCM tokens from admin_devices collection
    final adminTokensSnapshot =
        await FirebaseFirestore.instance.collection('admin_devices').get();
    final adminFcmTokens =
        adminTokensSnapshot.docs
            .map((doc) => doc.data()['fcmToken'])
            .where((token) => token != null)
            .toList();
    for (final adminFcmToken in adminFcmTokens) {
      await sendNotificationToBackend(
        serverUrl: 'https://fcm-backend-2.onrender.com',
        targetFcmToken: adminFcmToken,
        title: '[$branch] 🆕 New Booking Request',
        body: 'User: $userName\nTime Slot: $timeSlot\nDate: $date',
      );
    }
  }

  // Call this after admin approves/rejects/cancels a booking
  static Future<void> notifyUserOnStatusChange({
    required String userId,
    required String branch,
    required String timeSlot,
    required String date,
    required String status,
  }) async {
    final userDoc =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();
    final userFcmToken = userDoc.data()?['fcmToken'];
    if (userFcmToken != null) {
      // Choose emoji and status text
      String emoji = '';
      String statusText = '';
      switch (status.toLowerCase()) {
        case 'approved':
        case 'confirmed':
          emoji = '✅';
          statusText = 'Approved';
          break;
        case 'rejected':
          emoji = '❌';
          statusText = 'Rejected';
          break;
        case 'cancelled':
        case 'canceled':
          emoji = '⚠️';
          statusText = 'Cancelled';
          break;
        default:
          emoji = 'ℹ️';
          statusText = status;
      }
      await sendNotificationToBackend(
        serverUrl: 'https://fcm-backend-2.onrender.com',
        targetFcmToken: userFcmToken,
        title: '[$branch] $emoji $statusText',
        body:
            'User: ${userDoc.data()?['fullName'] ?? ''}\nTime Slot: $timeSlot\nDate: $date',
      );
    }
  }
}
