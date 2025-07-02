import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../services/booking_service.dart';
import '../../models/booking_model.dart';

class AdminPanelScreen extends StatefulWidget {
  const AdminPanelScreen({Key? key}) : super(key: key);

  @override
  State<AdminPanelScreen> createState() => _AdminPanelScreenState();
}

class _AdminPanelScreenState extends State<AdminPanelScreen> {
  late Future<List<BookingRequest>> _futureBookings;

  @override
  void initState() {
    super.initState();
    _futureBookings = BookingService().getAllBookingRequests();
  }

  Future<void> _updateStatus(String bookingId, String status) async {
    await BookingService().updateBookingRequestStatus(bookingId, status);
    setState(() {
      _futureBookings = BookingService().getAllBookingRequests();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.info,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.warning),
          onPressed: () {
            Navigator.pushReplacementNamed(context, '/login');
          },
        ),
        title: Text(
          'Admin Panel',
          style: AppTextStyles.h2.copyWith(color: AppColors.warning),
        ),
      ),
      body: FutureBuilder<List<BookingRequest>>(
        future: _futureBookings,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No booking requests.'));
          }
          final bookings = snapshot.data!;
          return ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: bookings.length,
            itemBuilder: (context, index) {
              final booking = bookings[index];
              return Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                margin: EdgeInsets.only(bottom: 20),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.meeting_room,
                            color: AppColors.primary,
                            size: 28,
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              booking.branch,
                              style: AppTextStyles.h2.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color:
                                  booking.status == 'pending'
                                      ? Colors.orange.shade100
                                      : booking.status == 'accepted'
                                      ? Colors.green.shade100
                                      : Colors.red.shade100,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              booking.status.toUpperCase(),
                              style: TextStyle(
                                color:
                                    booking.status == 'pending'
                                        ? Colors.orange
                                        : booking.status == 'accepted'
                                        ? Colors.green
                                        : Colors.red,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                      Row(
                        children: [
                          Icon(Icons.person, color: AppColors.info, size: 20),
                          SizedBox(width: 8),
                          Text(booking.userName, style: AppTextStyles.body1),
                        ],
                      ),
                      SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.email, color: AppColors.info, size: 20),
                          SizedBox(width: 8),
                          Text(booking.email, style: AppTextStyles.body1),
                        ],
                      ),
                      SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.phone, color: AppColors.info, size: 20),
                          SizedBox(width: 8),
                          Text(booking.phone, style: AppTextStyles.body1),
                        ],
                      ),
                      SizedBox(height: 16),
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today,
                            color: AppColors.warning,
                            size: 20,
                          ),
                          SizedBox(width: 8),
                          Text(booking.date, style: AppTextStyles.body1),
                          SizedBox(width: 16),
                          Icon(
                            Icons.access_time,
                            color: AppColors.warning,
                            size: 20,
                          ),
                          SizedBox(width: 8),
                          Text(booking.timeSlot, style: AppTextStyles.body1),
                        ],
                      ),
                      if (booking.status == 'pending') ...[
                        SizedBox(height: 20),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed:
                                    () => _updateStatus(booking.id, 'accepted'),
                                icon: Icon(Icons.check, color: Colors.white),
                                label: Text('Accept'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  padding: EdgeInsets.symmetric(vertical: 12),
                                ),
                              ),
                            ),
                            SizedBox(width: 16),
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed:
                                    () => _updateStatus(booking.id, 'denied'),
                                icon: Icon(Icons.close, color: Colors.white),
                                label: Text('Deny'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  padding: EdgeInsets.symmetric(vertical: 12),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
