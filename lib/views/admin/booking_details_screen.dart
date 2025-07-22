import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../services/booking_service.dart';
import '../../models/booking_model.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import 'package:intl/intl.dart';

class BookingDetailsScreen extends StatefulWidget {
  const BookingDetailsScreen({Key? key}) : super(key: key);

  @override
  State<BookingDetailsScreen> createState() => _BookingDetailsScreenState();
}

class _BookingDetailsScreenState extends State<BookingDetailsScreen>
    with SingleTickerProviderStateMixin {
  late Future<List<BookingRequest>> _futureBookings;
  final DateFormat _dateFormat = DateFormat('yyyy-MM-dd');
  AnimationController? _popupController;

  @override
  void initState() {
    super.initState();
    _futureBookings = BookingService().getAllBookingRequests();
    _popupController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
  }

  @override
  void dispose() {
    _popupController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(color: AppColors.info),
      child: Scaffold(
        backgroundColor: const Color.fromARGB(255, 202, 204, 207),
        appBar: AppBar(
          title: const Text(
            'Booking Details',
            style: TextStyle(color: AppColors.secondaryDark),
          ),
          backgroundColor: AppColors.info,
          elevation: 0,
          iconTheme: const IconThemeData(color: AppColors.secondaryDark),
        ),
        body: FutureBuilder<List<BookingRequest>>(
          future: _futureBookings,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('No bookings found.'));
            }
            final bookings = snapshot.data!;
            final now = DateTime.now();
            final last30Days = now.subtract(const Duration(days: 30));
            final recentBookings =
                bookings.where((b) {
                  final bookingDate = DateTime.tryParse(b.date) ?? now;
                  return bookingDate.isAfter(last30Days);
                }).toList();
            final userBookings = <String, List<BookingRequest>>{};
            for (var booking in recentBookings) {
              userBookings.putIfAbsent(booking.userName, () => []).add(booking);
            }
            final users = userBookings.keys.toList();
            return Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: 24.h),
                  // Text(
                  //   'User Booking Summary',
                  //   style: AppTextStyles.h1.copyWith(
                  //     color: AppColors.secondaryDark,
                  //     fontSize: 28.sp,
                  //   ),
                  // ),
                  SizedBox(height: 8.h),
                  Text(
                    'Bookings made by users in the last 30 days',
                    style: AppTextStyles.body2.copyWith(
                      fontSize: 16.sp,
                      color: const Color.fromARGB(255, 124, 122, 122),
                    ),
                  ),
                  SizedBox(height: 32.h),
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Card(
                        elevation: 10,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14.r),
                        ),
                        color: Colors.white.withOpacity(0.95),
                        child: Padding(
                          padding: EdgeInsets.all(8.w),
                          child: DataTable(
                            headingRowColor: MaterialStateProperty.all(
                              const Color.fromARGB(255, 133, 24, 10),
                            ),
                            dataRowColor: MaterialStateProperty.all(
                              const Color.fromARGB(255, 241, 234, 234),
                            ),
                            columnSpacing: 32.w,
                            columns: [
                              DataColumn(
                                label: Text(
                                  'User',
                                  style: AppTextStyles.h3.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              DataColumn(
                                label: Text(
                                  'Bookings (30 days)',
                                  style: AppTextStyles.h3.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              DataColumn(
                                label: Text(
                                  'Email',
                                  style: AppTextStyles.h3.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              DataColumn(
                                label: Text(
                                  'Mobile',
                                  style: AppTextStyles.h3.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                            rows:
                                users.map((user) {
                                  final firstBooking =
                                      userBookings[user]!.first;
                                  final bookedBookings =
                                      userBookings[user]!
                                          .where((b) => b.status == 'booked')
                                          .toList();
                                  return DataRow(
                                    cells: [
                                      DataCell(
                                        GestureDetector(
                                          onTap:
                                              () => _showUserBookingsPopup(
                                                context,
                                                user,
                                                userBookings[user]!,
                                              ),
                                          child: Text(
                                            user,
                                            style: AppTextStyles.body1.copyWith(
                                              color: AppColors.primaryDark,
                                              fontWeight: FontWeight.w600,
                                              decoration:
                                                  TextDecoration.underline,
                                            ),
                                          ),
                                        ),
                                      ),
                                      DataCell(
                                        Center(
                                          child: Container(
                                            padding: EdgeInsets.symmetric(
                                              horizontal: 16.w,
                                              vertical: 8.h,
                                            ),
                                            decoration: BoxDecoration(
                                              color: const Color.fromARGB(
                                                255,
                                                255,
                                                255,
                                                255,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(2.r),
                                            ),
                                            child: Text(
                                              bookedBookings.length.toString(),
                                              style: AppTextStyles.h3.copyWith(
                                                color: const Color.fromARGB(
                                                  255,
                                                  191,
                                                  0,
                                                  41,
                                                ),
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      DataCell(
                                        Text(
                                          firstBooking.email,
                                          style: AppTextStyles.body2,
                                        ),
                                      ),
                                      DataCell(
                                        Text(
                                          firstBooking.phone,
                                          style: AppTextStyles.body2,
                                        ),
                                      ),
                                    ],
                                  );
                                }).toList(),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 32.h),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  void _showUserBookingsPopup(
    BuildContext context,
    String user,
    List<BookingRequest> bookings,
  ) {
    _popupController?.forward(from: 0);
    // Filter bookings to only show those approved by admin (status == 'booked')
    final approvedBookings =
        bookings.where((b) => b.status == 'booked').toList();
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'User Bookings',
      transitionDuration: const Duration(milliseconds: 350),
      pageBuilder: (context, anim1, anim2) {
        return const SizedBox.shrink();
      },
      transitionBuilder: (context, anim1, anim2, child) {
        return FadeTransition(
          opacity: anim1,
          child: ScaleTransition(
            scale: CurvedAnimation(parent: anim1, curve: Curves.easeOutBack),
            child: Dialog(
              insetPadding: EdgeInsets.symmetric(
                horizontal: 16.w,
                vertical: 32.h,
              ),
              backgroundColor: Colors.white.withOpacity(0.9),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24.r),
              ),
              child: Stack(
                children: [
                  Padding(
                    padding: EdgeInsets.all(24.w),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(height: 32.h),
                        Text(
                          'Bookings for $user',
                          style: AppTextStyles.h2.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryDark,
                          ),
                        ),
                        SizedBox(height: 16.h),
                        SizedBox(
                          height: 400.h,
                          child: ListView.builder(
                            itemCount: approvedBookings.length,
                            itemBuilder: (context, index) {
                              final booking = approvedBookings[index];
                              return Container(
                                margin: EdgeInsets.only(bottom: 16.h),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16.r),
                                  color: Colors.white,
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.primaryLight.withOpacity(
                                        0.08,
                                      ),
                                      blurRadius: 8,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 8.w,
                                      height: 80.h,
                                      decoration: BoxDecoration(
                                        color: AppColors.primary,
                                        borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(16.r),
                                          bottomLeft: Radius.circular(16.r),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Padding(
                                        padding: EdgeInsets.all(16.w),
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Icon(
                                              Icons.meeting_room,
                                              color: AppColors.primary,
                                              size: 28.sp,
                                            ),
                                            SizedBox(width: 12.w),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    'Branch: ${booking.branch}',
                                                    style: AppTextStyles.body1
                                                        .copyWith(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                  ),
                                                  Text(
                                                    'Time Slot: ${booking.timeSlot}',
                                                    style: AppTextStyles.body2,
                                                  ),
                                                  Text(
                                                    'User: ${booking.userName}',
                                                    style: AppTextStyles.body2,
                                                  ),
                                                  Text(
                                                    'Day: ${booking.date}',
                                                    style: AppTextStyles.body2,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(color: Colors.black12, blurRadius: 4),
                          ],
                        ),
                        child: const Icon(
                          Icons.close,
                          size: 28,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
