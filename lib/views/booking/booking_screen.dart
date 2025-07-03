import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../services/booking_service.dart';
import '../../models/booking_model.dart';
import '../../services/shared_prefs_service.dart';

class BookingScreen extends StatefulWidget {
  final String branchName;
  const BookingScreen({super.key, required this.branchName});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  String? userId;

  @override
  void initState() {
    super.initState();
    _loadUserId();
  }

  Future<void> _loadUserId() async {
    userId = await SharedPrefsService.getUserId();
    print('BookingScreen: Current userId: ' + (userId ?? 'null'));
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushReplacementNamed(
          context,
          '/home',
          arguments: widget.branchName,
        );
        return false;
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body:
            userId == null
                ? Center(child: CircularProgressIndicator())
                : StreamBuilder<List<BookingRequest>>(
                  stream: BookingService().userBookingRequestsStream(userId!),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    }
                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Center(child: Text('No bookings found.'));
                    }
                    final bookings = snapshot.data!;
                    return ListView.builder(
                      padding: EdgeInsets.all(16.w),
                      itemCount: bookings.length,
                      itemBuilder: (context, index) {
                        final booking = bookings[index];
                        return Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          margin: EdgeInsets.only(bottom: 20.h),
                          child: Padding(
                            padding: EdgeInsets.all(15),
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
                                    Icon(
                                      Icons.calendar_today,
                                      color: AppColors.warning,
                                      size: 20,
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      booking.date,
                                      style: AppTextStyles.body1,
                                    ),
                                    SizedBox(width: 16),
                                    Icon(
                                      Icons.access_time,
                                      color: AppColors.warning,
                                      size: 20,
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      booking.timeSlot,
                                      style: AppTextStyles.body1,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
      ),
    );
  }
}
