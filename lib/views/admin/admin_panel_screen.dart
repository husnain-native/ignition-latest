import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../services/booking_service.dart';
import '../../models/booking_model.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:convert';
import 'package:hive/hive.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart' as share;
import '../../constants/app_constants.dart';

class AdminPanelScreen extends StatefulWidget {
  final String? branchName;
  const AdminPanelScreen({Key? key, this.branchName}) : super(key: key);

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
    final String? selectedBranch =
        ModalRoute.of(context)?.settings.arguments as String? ??
        widget.branchName;
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushReplacementNamed(
          context,
          AppConstants.adminBranchSelectionRoute,
        );
        return false;
      },
      child: DefaultTabController(
        length: 5,
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: AppColors.info,
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: AppColors.warning),
              onPressed: () {
                Navigator.pushReplacementNamed(
                  context,
                  AppConstants.adminBranchSelectionRoute,
                );
              },
            ),
            title: Text(
              selectedBranch ?? '',
              style: AppTextStyles.h2.copyWith(color: AppColors.warning),
            ),
            // actions: [
            //   IconButton(
            //     icon: Icon(Icons.download, color: AppColors.primary),
            //     tooltip: 'Export as JSON',
            //     onPressed: () async {
            //       final box = await Hive.openBox<BookingRequest>('bookingsBox');
            //       final allBookings = box.values.toList();
            //       final jsonList = allBookings.map((b) => b.toMap()).toList();
            //       final jsonString = jsonEncode(jsonList);

            //       Directory? exportDir;
            //       if (Platform.isAndroid) {
            //         exportDir = await getExternalStorageDirectory();
            //       } else if (Platform.isIOS) {
            //         exportDir = await getApplicationDocumentsDirectory();
            //       }

            //       final file = File('${exportDir!.path}/bookings_export.json');
            //       await file.writeAsString(jsonString);

            //       print('Export path: ${file.path}');
            //       ScaffoldMessenger.of(context).showSnackBar(
            //         SnackBar(
            //           content: Text('Bookings exported to ${file.path}'),
            //         ),
            //       );
            //     },
            //   ),
            // ],
            bottom: PreferredSize(
              preferredSize: Size.fromHeight(48.0),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: TabBar(
                  labelColor: AppColors.primary,
                  unselectedLabelColor: AppColors.warning,
                  indicatorColor: AppColors.primary,
                  isScrollable: true,
                  tabs: [
                    Tab(text: 'All'),
                    Tab(text: 'Pending'),
                    Tab(text: 'Booked'),
                    Tab(text: 'Rejected'),
                    Tab(text: 'Cancelled'),
                  ],
                ),
              ),
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
              final filteredBookings =
                  selectedBranch == null
                      ? bookings
                      : bookings
                          .where((b) => b.branch == selectedBranch)
                          .toList();
              final sortedBookings = List<BookingRequest>.from(filteredBookings)
                ..sort((a, b) => b.id.compareTo(a.id));
              return TabBarView(
                children: [
                  // All
                  _buildBookingList(sortedBookings),
                  // Pending
                  _buildBookingList(
                    sortedBookings.where((b) => b.status == 'pending').toList(),
                  ),
                  // Booked
                  _buildBookingList(
                    sortedBookings.where((b) => b.status == 'booked').toList(),
                  ),
                  // Rejected
                  _buildBookingList(
                    sortedBookings
                        .where((b) => b.status == 'rejected')
                        .toList(),
                  ),
                  // Cancelled
                  _buildBookingList(
                    sortedBookings
                        .where((b) => b.status == 'cancelled')
                        .toList(),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildBookingList(List<BookingRequest> bookings) {
    if (bookings.isEmpty) {
      return Center(child: Text('No bookings in this category.'));
    }
    return ListView.builder(
      padding: EdgeInsets.all(16.w),
      itemCount: bookings.length,
      itemBuilder: (context, index) {
        final booking = bookings[index];
        return Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
          margin: EdgeInsets.only(bottom: 20.h),
          child:
              booking.status == 'booked'
                  ? InkWell(
                    borderRadius: BorderRadius.circular(16.r),
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return Dialog(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            elevation: 8,
                            backgroundColor: Colors.white,
                            child: Padding(
                              padding: EdgeInsets.all(24),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.warning_amber_rounded,
                                    color: AppColors.error,
                                    size: 48,
                                  ),
                                  SizedBox(height: 16),
                                  Text(
                                    'Reject Booking?',
                                    style: AppTextStyles.h2.copyWith(
                                      color: AppColors.error,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 22,
                                    ),
                                  ),
                                  SizedBox(height: 12),
                                  Text(
                                    'Are you sure you want to reject this booking? This action cannot be undone.',
                                    style: AppTextStyles.body2.copyWith(
                                      fontSize: 16,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  SizedBox(height: 24),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: AppColors.error,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 24,
                                            vertical: 12,
                                          ),
                                        ),
                                        onPressed: () async {
                                          await _updateStatus(
                                            booking.id,
                                            'rejected',
                                          );
                                          Navigator.of(context).pop();
                                        },
                                        child: Text(
                                          'Reject',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      OutlinedButton(
                                        style: OutlinedButton.styleFrom(
                                          side: BorderSide(
                                            color: AppColors.primaryDark,
                                            width: 2,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 24,
                                            vertical: 12,
                                          ),
                                        ),
                                        onPressed:
                                            () => Navigator.of(context).pop(),
                                        child: Text(
                                          'No',
                                          style: TextStyle(
                                            color: AppColors.primaryDark,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
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
                    child: _buildBookingCardContent(booking),
                  )
                  : booking.status == 'rejected'
                  ? InkWell(
                    borderRadius: BorderRadius.circular(16.r),
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return Dialog(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            elevation: 8,
                            backgroundColor: Colors.white,
                            child: Padding(
                              padding: EdgeInsets.all(24),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.info_outline,
                                    color: AppColors.primary,
                                    size: 48,
                                  ),
                                  SizedBox(height: 16),
                                  Text(
                                    'Approve Booking?',
                                    style: AppTextStyles.h2.copyWith(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 22,
                                    ),
                                  ),
                                  SizedBox(height: 12),
                                  Text(
                                    'Do you want to approve this booking? This will move it to Booked.',
                                    style: AppTextStyles.body2.copyWith(
                                      fontSize: 16,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  SizedBox(height: 24),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: AppColors.primary,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 24,
                                            vertical: 12,
                                          ),
                                        ),
                                        onPressed: () async {
                                          await _updateStatus(
                                            booking.id,
                                            'booked',
                                          );
                                          Navigator.of(context).pop();
                                        },
                                        child: Text(
                                          'Approve',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      OutlinedButton(
                                        style: OutlinedButton.styleFrom(
                                          side: BorderSide(
                                            color: AppColors.primaryDark,
                                            width: 2,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 24,
                                            vertical: 12,
                                          ),
                                        ),
                                        onPressed:
                                            () => Navigator.of(context).pop(),
                                        child: Text(
                                          'No',
                                          style: TextStyle(
                                            color: AppColors.primaryDark,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
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
                    child: _buildBookingCardContent(booking),
                  )
                  : Column(
                    children: [
                      _buildBookingCardContent(booking),
                      if (booking.status == 'pending') ...[
                        SizedBox(height: 5.h),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            children: [
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed:
                                      () => _updateStatus(booking.id, 'booked'),
                                  icon: Icon(
                                    Icons.check,
                                    color: Colors.white,
                                    size: 18.sp,
                                  ),
                                  label: Text(
                                    'Approve',
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      color: Colors.white,
                                    ),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8.r),
                                    ),
                                    padding: EdgeInsets.symmetric(
                                      vertical: 12.h,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(width: 16.w),
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed:
                                      () =>
                                          _updateStatus(booking.id, 'rejected'),
                                  icon: Icon(
                                    Icons.close,
                                    color: Colors.white,
                                    size: 18.sp,
                                  ),
                                  label: Text(
                                    'Reject',
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      color: Colors.white,
                                    ),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8.r),
                                    ),
                                    padding: EdgeInsets.symmetric(
                                      vertical: 12.h,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
        );
      },
    );
  }

  Widget _buildBookingCardContent(BookingRequest booking) {
    return Padding(
      padding: EdgeInsets.all(20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.meeting_room, color: AppColors.primary, size: 28.sp),
              SizedBox(width: 10.w),
              Expanded(
                child: Text(
                  booking.branch,
                  style: AppTextStyles.h2.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 20.sp,
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color:
                      booking.status == 'pending'
                          ? Colors.orange.shade100
                          : booking.status == 'booked'
                          ? Colors.green.shade100
                          : Colors.red.shade100,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Text(
                  booking.status.toUpperCase(),
                  style: TextStyle(
                    color:
                        booking.status == 'pending'
                            ? Colors.orange
                            : booking.status == 'booked'
                            ? Colors.green
                            : Colors.red,
                    fontWeight: FontWeight.bold,
                    fontSize: 14.sp,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Row(
            children: [
              Icon(Icons.person, color: AppColors.info, size: 20.sp),
              SizedBox(width: 8.w),
              Text(
                booking.userName,
                style: AppTextStyles.body1.copyWith(fontSize: 14.sp),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Row(
            children: [
              Icon(Icons.email, color: AppColors.info, size: 20.sp),
              SizedBox(width: 8.w),
              Text(
                booking.email,
                style: AppTextStyles.body1.copyWith(fontSize: 14.sp),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Row(
            children: [
              Icon(Icons.phone, color: AppColors.info, size: 20.sp),
              SizedBox(width: 8.w),
              Text(
                booking.phone,
                style: AppTextStyles.body1.copyWith(fontSize: 14.sp),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Row(
            children: [
              Icon(Icons.calendar_today, color: AppColors.warning, size: 20.sp),
              SizedBox(width: 8.w),
              Text(
                booking.date,
                style: AppTextStyles.body1.copyWith(fontSize: 14.sp),
              ),
              SizedBox(width: 16.w),
              Icon(Icons.access_time, color: AppColors.warning, size: 20.sp),
              SizedBox(width: 8.w),
              Text(
                booking.timeSlot,
                style: AppTextStyles.body1.copyWith(fontSize: 14.sp),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

Future<String> exportBookingsBoxAsJson() async {
  final box = await Hive.openBox('bookingsBox');
  final allBookings = box.values.toList();
  // If your objects are HiveType, convert them to Map
  final jsonList = allBookings.map((b) => b.toMap()).toList();
  return jsonEncode(jsonList);
}
