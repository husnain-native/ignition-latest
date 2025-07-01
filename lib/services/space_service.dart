import 'package:firebase_database/firebase_database.dart';
import '../models/space_model.dart';
import '../constants/app_constants.dart';

class SpaceService {
  final DatabaseReference _database = FirebaseDatabase.instance.ref();

  // Get all available spaces
  Future<List<SpaceModel>> getSpaces() async {
    try {
      final DataSnapshot snapshot =
          await _database.child(AppConstants.spacesCollection).get();

      if (!snapshot.exists) return [];

      final data = snapshot.value as Map<dynamic, dynamic>;
      return data.values
          .map(
            (space) =>
                SpaceModel.fromJson(Map<String, dynamic>.from(space as Map)),
          )
          .toList();
    } catch (e) {
      print('Error fetching spaces: $e');
      return [];
    }
  }

  // Get space by ID
  Future<SpaceModel?> getSpaceById(String spaceId) async {
    try {
      final DataSnapshot snapshot =
          await _database
              .child(AppConstants.spacesCollection)
              .child(spaceId)
              .get();

      if (!snapshot.exists) return null;

      final data = snapshot.value as Map<dynamic, dynamic>;
      return SpaceModel.fromJson(Map<String, dynamic>.from(data));
    } catch (e) {
      print('Error fetching space: $e');
      return null;
    }
  }

  // Check space availability for a time slot
  Future<bool> checkAvailability(
    String spaceId,
    DateTime start,
    DateTime end,
  ) async {
    try {
      final DataSnapshot snapshot =
          await _database
              .child(AppConstants.bookingsCollection)
              .orderByChild('spaceId')
              .equalTo(spaceId)
              .get();

      if (!snapshot.exists) return true;

      final bookings = snapshot.value as Map<dynamic, dynamic>;

      // Check if there are any overlapping bookings
      return !bookings.values.any((booking) {
        final bookingStart = DateTime.parse(booking['startTime'] as String);
        final bookingEnd = DateTime.parse(booking['endTime'] as String);

        return (start.isBefore(bookingEnd) && end.isAfter(bookingStart)) ||
            (bookingStart.isBefore(end) && bookingEnd.isAfter(start));
      });
    } catch (e) {
      print('Error checking availability: $e');
      return false;
    }
  }

  // Get available time slots for a space
  Future<List<DateTime>> getAvailableSlots(
    String spaceId,
    DateTime date,
  ) async {
    try {
      final List<DateTime> allSlots = [];
      final startHour = 9; // 9 AM
      final endHour = 21; // 9 PM

      // Generate all possible slots for the day
      for (int hour = startHour; hour < endHour; hour++) {
        allSlots.add(DateTime(date.year, date.month, date.day, hour));
      }

      // Get booked slots
      final DataSnapshot snapshot =
          await _database
              .child(AppConstants.bookingsCollection)
              .orderByChild('spaceId')
              .equalTo(spaceId)
              .get();

      if (!snapshot.exists || snapshot.value == null) return allSlots;

      final bookingsRaw = snapshot.value;
      if (bookingsRaw is! Map) return allSlots;

      final bookings = bookingsRaw as Map<dynamic, dynamic>;
      final bookedSlots =
          bookings.values
              .where((booking) {
                final bookingDate = DateTime.parse(
                  booking['startTime'] as String,
                );
                return bookingDate.year == date.year &&
                    bookingDate.month == date.month &&
                    bookingDate.day == date.day;
              })
              .map((booking) => DateTime.parse(booking['startTime'] as String))
              .toList();

      // Remove booked slots
      return allSlots.where((slot) => !bookedSlots.contains(slot)).toList();
    } catch (e) {
      print('Error getting available slots: $e');
      return [];
    }
  }
}
