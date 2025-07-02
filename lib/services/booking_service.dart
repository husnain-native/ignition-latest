import 'package:firebase_database/firebase_database.dart';
import 'package:hive/hive.dart';

import '../models/booking_model.dart';
import '../constants/app_constants.dart';

class BookingService {
  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  static const String bookingsBoxName = 'bookingsBox';

  // Create a new booking
  Future<BookingModel> createBooking(BookingModel booking) async {
    try {
      final String bookingId =
          _database.child(AppConstants.bookingsCollection).push().key!;

      final BookingModel newBooking = BookingModel(
        id: bookingId,
        userId: booking.userId,
        spaceId: booking.spaceId,
        startTime: booking.startTime,
        endTime: booking.endTime,
        totalPrice: booking.totalPrice,
        status: AppConstants.pending,
        createdAt: DateTime.now(),
        additionalServices: booking.additionalServices,
      );

      await _database
          .child(AppConstants.bookingsCollection)
          .child(bookingId)
          .set(newBooking.toJson());

      // Add booking reference to user's booking history
      await _database
          .child(AppConstants.usersCollection)
          .child(booking.userId)
          .child('bookingHistory')
          .push()
          .set(bookingId);

      return newBooking;
    } catch (e) {
      throw Exception('Failed to create booking: ${e.toString()}');
    }
  }

  // Get user's bookings
  Future<List<BookingModel>> getUserBookings(String userId) async {
    try {
      final DataSnapshot snapshot =
          await _database
              .child(AppConstants.bookingsCollection)
              .orderByChild('userId')
              .equalTo(userId)
              .get();

      if (!snapshot.exists) return [];

      final data = snapshot.value as Map<dynamic, dynamic>;
      return data.values
          .map(
            (booking) => BookingModel.fromJson(
              Map<String, dynamic>.from(booking as Map),
            ),
          )
          .toList();
    } catch (e) {
      print('Error fetching user bookings: $e');
      return [];
    }
  }

  // Update booking status
  Future<void> updateBookingStatus(String bookingId, String status) async {
    try {
      await _database
          .child(AppConstants.bookingsCollection)
          .child(bookingId)
          .update({'status': status});
    } catch (e) {
      throw Exception('Failed to update booking status: ${e.toString()}');
    }
  }

  // Cancel booking
  Future<void> cancelBooking(String bookingId) async {
    try {
      await updateBookingStatus(bookingId, AppConstants.cancelled);
    } catch (e) {
      throw Exception('Failed to cancel booking: ${e.toString()}');
    }
  }

  // Get booking by ID
  Future<BookingModel?> getBookingById(String bookingId) async {
    try {
      final DataSnapshot snapshot =
          await _database
              .child(AppConstants.bookingsCollection)
              .child(bookingId)
              .get();

      if (!snapshot.exists) return null;

      final data = snapshot.value as Map<dynamic, dynamic>;
      return BookingModel.fromJson(Map<String, dynamic>.from(data));
    } catch (e) {
      print('Error fetching booking: $e');
      return null;
    }
  }

  // Create a new booking request
  Future<void> createBookingRequest(BookingRequest booking) async {
    final box = await Hive.openBox<BookingRequest>(bookingsBoxName);
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    final bookingWithId = BookingRequest(
      id: id,
      userId: booking.userId,
      userName: booking.userName,
      email: booking.email,
      phone: booking.phone,
      branch: booking.branch,
      date: booking.date,
      timeSlot: booking.timeSlot,
      status: booking.status,
    );
    await box.put(id, bookingWithId);
  }

  // Fetch all booking requests (for admin)
  Future<List<BookingRequest>> getAllBookingRequests() async {
    final box = await Hive.openBox<BookingRequest>(bookingsBoxName);
    return box.values.toList();
  }

  // Fetch booking requests for a specific user
  Future<List<BookingRequest>> getUserBookingRequests(String userId) async {
    final box = await Hive.openBox<BookingRequest>(bookingsBoxName);
    return box.values.where((b) => b.userId == userId).toList();
  }

  // Update booking request status (accept/deny)
  Future<void> updateBookingRequestStatus(
    String bookingId,
    String status,
  ) async {
    final box = await Hive.openBox<BookingRequest>(bookingsBoxName);
    final booking = box.get(bookingId);
    if (booking != null) {
      final updated = BookingRequest(
        id: booking.id,
        userId: booking.userId,
        userName: booking.userName,
        email: booking.email,
        phone: booking.phone,
        branch: booking.branch,
        date: booking.date,
        timeSlot: booking.timeSlot,
        status: status,
      );
      await box.put(bookingId, updated);
    }
  }
}
