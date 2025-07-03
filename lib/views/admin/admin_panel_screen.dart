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
        length: 4,
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
            actions: [
              IconButton(
                icon: Icon(Icons.download, color: AppColors.primary),
                tooltip: 'Export as JSON',
                onPressed: () async {
                  final box = await Hive.openBox<BookingRequest>('bookingsBox');
                  final allBookings = box.values.toList();
                  final jsonList = allBookings.map((b) => b.toMap()).toList();
                  final jsonString = jsonEncode(jsonList);

                  Directory? exportDir;
                  if (Platform.isAndroid) {
                    exportDir = await getExternalStorageDirectory();
                  } else if (Platform.isIOS) {
                    exportDir = await getApplicationDocumentsDirectory();
                  }

                  final file = File('${exportDir!.path}/bookings_export.json');
                  await file.writeAsString(jsonString);

                  print('Export path: ${file.path}');
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Bookings exported to ${file.path}'),
                    ),
                  );
                },
              ),
            ],
            bottom: TabBar(
              labelColor: AppColors.primary,
              unselectedLabelColor: AppColors.warning,
              indicatorColor: AppColors.primary,
              tabs: [
                Tab(text: 'All'),
                Tab(text: 'Pending'),
                Tab(text: 'Accepted'),
                Tab(text: 'Denied'),
              ],
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
                  // Accepted
                  _buildBookingList(
                    sortedBookings
                        .where((b) => b.status == 'accepted')
                        .toList(),
                  ),
                  // Denied
                  _buildBookingList(
                    sortedBookings.where((b) => b.status == 'denied').toList(),
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
          child: Padding(
            padding: EdgeInsets.all(20.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.meeting_room,
                      color: AppColors.primary,
                      size: 28.sp,
                    ),
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
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 6.h,
                      ),
                      decoration: BoxDecoration(
                        color:
                            booking.status == 'pending'
                                ? Colors.orange.shade100
                                : booking.status == 'accepted'
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
                                  : booking.status == 'accepted'
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
                    Icon(
                      Icons.calendar_today,
                      color: AppColors.warning,
                      size: 20.sp,
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      booking.date,
                      style: AppTextStyles.body1.copyWith(fontSize: 14.sp),
                    ),
                    SizedBox(width: 16.w),
                    Icon(
                      Icons.access_time,
                      color: AppColors.warning,
                      size: 20.sp,
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      booking.timeSlot,
                      style: AppTextStyles.body1.copyWith(fontSize: 14.sp),
                    ),
                  ],
                ),
                if (booking.status == 'pending') ...[
                  SizedBox(height: 20.h),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed:
                              () => _updateStatus(booking.id, 'accepted'),
                          icon: Icon(
                            Icons.check,
                            color: Colors.white,
                            size: 18.sp,
                          ),
                          label: Text(
                            'Accept',
                            style: TextStyle(fontSize: 14.sp),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            padding: EdgeInsets.symmetric(vertical: 12.h),
                          ),
                        ),
                      ),
                      SizedBox(width: 16.w),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _updateStatus(booking.id, 'denied'),
                          icon: Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 18.sp,
                          ),
                          label: Text(
                            'Deny',
                            style: TextStyle(fontSize: 14.sp),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            padding: EdgeInsets.symmetric(vertical: 12.h),
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
  }
}

Future<String> exportBookingsBoxAsJson() async {
  final box = await Hive.openBox('bookingsBox');
  final allBookings = box.values.toList();
  // If your objects are HiveType, convert them to Map
  final jsonList = allBookings.map((b) => b.toMap()).toList();
  return jsonEncode(jsonList);
}
