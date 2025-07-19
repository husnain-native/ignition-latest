import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../services/booking_service.dart';
import '../../models/booking_model.dart';
import '../../services/shared_prefs_service.dart';
import '../../services/notification_service.dart';

class BookingScreen extends StatefulWidget {
  final String branchName;
  const BookingScreen({super.key, required this.branchName});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  String? userId;
  String _selectedFilter = 'all';

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
        body: Column(
          children: [
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Padding(
                  padding: EdgeInsets.only(right: 16, top: 4, bottom: 4),
                  child: IconButton(
                    icon: Icon(Icons.filter_list, color: AppColors.info),
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(20),
                          ),
                        ),
                        builder: (context) {
                          return Padding(
                            padding: const EdgeInsets.all(24.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Center(
                                  child: Text(
                                    'Filter Bookings',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20,
                                    ),
                                  ),
                                ),
                                SizedBox(height: 16),
                                ListTile(
                                  leading: Icon(
                                    Icons.list,
                                    color: Colors.deepPurple,
                                  ),
                                  title: Text('All (Most Recent First)'),
                                  selected: _selectedFilter == 'all',
                                  onTap: () {
                                    setState(() {
                                      _selectedFilter = 'all';
                                    });
                                    Navigator.pop(context);
                                  },
                                ),
                                Divider(),
                                ListTile(
                                  leading: Icon(
                                    Icons.today,
                                    color: Colors.teal,
                                  ),
                                  title: Text('Closest to Today'),
                                  selected:
                                      _selectedFilter == 'closest_to_today',
                                  onTap: () {
                                    setState(() {
                                      _selectedFilter = 'closest_to_today';
                                    });
                                    Navigator.pop(context);
                                  },
                                ),
                                ListTile(
                                  leading: Icon(
                                    Icons.check_circle,
                                    color: Colors.green,
                                  ),
                                  title: Text('Show only Booked'),
                                  selected: _selectedFilter == 'booked',
                                  onTap: () {
                                    setState(() {
                                      _selectedFilter = 'booked';
                                    });
                                    Navigator.pop(context);
                                  },
                                ),
                                ListTile(
                                  leading: Icon(
                                    Icons.pending,
                                    color: Colors.orange,
                                  ),
                                  title: Text('Show only Pending'),
                                  selected: _selectedFilter == 'pending',
                                  onTap: () {
                                    setState(() {
                                      _selectedFilter = 'pending';
                                    });
                                    Navigator.pop(context);
                                  },
                                ),
                                ListTile(
                                  leading: Icon(
                                    Icons.cancel,
                                    color: Colors.red,
                                  ),
                                  title: Text('Show only Cancelled'),
                                  selected: _selectedFilter == 'cancelled',
                                  onTap: () {
                                    setState(() {
                                      _selectedFilter = 'cancelled';
                                    });
                                    Navigator.pop(context);
                                  },
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 10),
                                  child: ListTile(
                                    leading: Icon(
                                      Icons.block,
                                      color: Colors.grey,
                                    ),
                                    title: Text('Show only Rejected'),
                                    selected: _selectedFilter == 'rejected',
                                    onTap: () {
                                      setState(() {
                                        _selectedFilter = 'rejected';
                                      });
                                      Navigator.pop(context);
                                    },
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
            Expanded(
              child:
                  userId == null
                      ? Center(child: CircularProgressIndicator())
                      : StreamBuilder<List<BookingRequest>>(
                        stream: BookingService().userBookingRequestsStream(
                          userId!,
                        ),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Center(child: CircularProgressIndicator());
                          }
                          if (!snapshot.hasData || snapshot.data!.isEmpty) {
                            return Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Image.asset(
                                    'assets/images/nothing.png',
                                    width: 180,
                                    height: 180,
                                  ),
                                  SizedBox(height: 16),
                                  Text('No bookings found.'),
                                ],
                              ),
                            );
                          }
                          final bookings = snapshot.data!;
                          final now = DateTime.now();
                          List<BookingRequest> sortedBookings = [];
                          if (_selectedFilter == 'all') {
                            sortedBookings = List.from(bookings)..sort((a, b) {
                              if (a.createdAt != null && b.createdAt != null) {
                                return b.createdAt!.compareTo(a.createdAt!);
                              } else {
                                return b.id.compareTo(a.id);
                              }
                            });
                          } else if (_selectedFilter == 'closest_to_today') {
                            sortedBookings =
                                bookings.where((b) {
                                  final bDate = DateTime.tryParse(b.date);
                                  return bDate != null && bDate.isAfter(now);
                                }).toList();
                            sortedBookings.sort((a, b) {
                              final aDate = DateTime.tryParse(a.date) ?? now;
                              final bDate = DateTime.tryParse(b.date) ?? now;
                              return aDate
                                  .difference(now)
                                  .compareTo(bDate.difference(now));
                            });
                          } else if (_selectedFilter == 'booked') {
                            sortedBookings =
                                bookings
                                    .where((b) => b.status == 'booked')
                                    .toList();
                          } else if (_selectedFilter == 'pending') {
                            sortedBookings =
                                bookings
                                    .where((b) => b.status == 'pending')
                                    .toList();
                          } else if (_selectedFilter == 'cancelled') {
                            sortedBookings =
                                bookings
                                    .where((b) => b.status == 'cancelled')
                                    .toList();
                          } else if (_selectedFilter == 'rejected') {
                            sortedBookings =
                                bookings
                                    .where((b) => b.status == 'rejected')
                                    .toList();
                          }
                          return ListView.builder(
                            padding: EdgeInsets.all(16.w),
                            itemCount: sortedBookings.length,
                            itemBuilder: (context, index) {
                              final booking = sortedBookings[index];
                              return Card(
                                elevation: 2,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5),
                                  side: BorderSide(
                                    color: AppColors.info,
                                    width: 1,
                                  ),
                                ),
                                color: AppColors.booked,
                                margin: EdgeInsets.only(bottom: 20.h),
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(16),
                                  onTap:
                                      booking.status == 'booked' ||
                                              booking.status == 'pending'
                                          ? () async {
                                            if (booking.status == 'booked') {
                                              showDialog(
                                                context: context,
                                                builder: (context) {
                                                  return Dialog(
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            20,
                                                          ),
                                                    ),
                                                    elevation: 8,
                                                    backgroundColor:
                                                        Colors.white,
                                                    child: Padding(
                                                      padding: EdgeInsets.all(
                                                        24,
                                                      ),
                                                      child: Column(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        children: [
                                                          Icon(
                                                            Icons
                                                                .warning_amber_rounded,
                                                            color:
                                                                AppColors.error,
                                                            size: 48,
                                                          ),
                                                          SizedBox(height: 16),
                                                          Text(
                                                            'Cancel Booking?',
                                                            style: AppTextStyles
                                                                .h2
                                                                .copyWith(
                                                                  color:
                                                                      AppColors
                                                                          .error,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  fontSize: 22,
                                                                ),
                                                          ),
                                                          SizedBox(height: 12),
                                                          Text(
                                                            'Are you sure you want to cancel this booking? This action cannot be undone.',
                                                            style: AppTextStyles
                                                                .body2
                                                                .copyWith(
                                                                  fontSize: 16,
                                                                ),
                                                            textAlign:
                                                                TextAlign
                                                                    .center,
                                                          ),
                                                          SizedBox(height: 24),
                                                          Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .spaceEvenly,
                                                            children: [
                                                              ElevatedButton(
                                                                style: ElevatedButton.styleFrom(
                                                                  backgroundColor:
                                                                      AppColors
                                                                          .error,
                                                                  shape: RoundedRectangleBorder(
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                          12,
                                                                        ),
                                                                  ),
                                                                  padding:
                                                                      EdgeInsets.symmetric(
                                                                        horizontal:
                                                                            24,
                                                                        vertical:
                                                                            12,
                                                                      ),
                                                                ),
                                                                onPressed: () async {
                                                                  await BookingService()
                                                                      .updateBookingRequestStatus(
                                                                        booking
                                                                            .id,
                                                                        'cancelled',
                                                                      );
                                                                  print(
                                                                    'Calling notifyAdminOnCancellation for booked cancellation',
                                                                  );
                                                                  NotificationService.notifyAdminOnCancellation(
                                                                    userName:
                                                                        booking
                                                                            .userName,
                                                                    branch:
                                                                        booking
                                                                            .branch,
                                                                    timeSlot:
                                                                        booking
                                                                            .timeSlot,
                                                                    date:
                                                                        booking
                                                                            .date,
                                                                  );
                                                                  Navigator.of(
                                                                    context,
                                                                  ).pop();
                                                                  setState(
                                                                    () {},
                                                                  );
                                                                },
                                                                child: Text(
                                                                  'Yes, Cancel',
                                                                  style: TextStyle(
                                                                    color:
                                                                        Colors
                                                                            .white,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                  ),
                                                                ),
                                                              ),
                                                              OutlinedButton(
                                                                style: OutlinedButton.styleFrom(
                                                                  side: BorderSide(
                                                                    color:
                                                                        AppColors
                                                                            .primaryDark,
                                                                    width: 2,
                                                                  ),
                                                                  shape: RoundedRectangleBorder(
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                          12,
                                                                        ),
                                                                  ),
                                                                  padding:
                                                                      EdgeInsets.symmetric(
                                                                        horizontal:
                                                                            24,
                                                                        vertical:
                                                                            12,
                                                                      ),
                                                                ),
                                                                onPressed:
                                                                    () =>
                                                                        Navigator.of(
                                                                          context,
                                                                        ).pop(),
                                                                child: Text(
                                                                  'No',
                                                                  style: TextStyle(
                                                                    color:
                                                                        AppColors
                                                                            .primaryDark,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
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
                                            } else if (booking.status ==
                                                'pending') {
                                              showDialog(
                                                context: context,
                                                builder: (context) {
                                                  return Dialog(
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            20,
                                                          ),
                                                    ),
                                                    elevation: 8,
                                                    backgroundColor:
                                                        Colors.white,
                                                    child: Padding(
                                                      padding: EdgeInsets.all(
                                                        24,
                                                      ),
                                                      child: Column(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        children: [
                                                          Icon(
                                                            Icons
                                                                .warning_amber_rounded,
                                                            color:
                                                                AppColors.error,
                                                            size: 48,
                                                          ),
                                                          SizedBox(height: 16),
                                                          Text(
                                                            'Cancel Booking Request?',
                                                            style: AppTextStyles
                                                                .h2
                                                                .copyWith(
                                                                  color:
                                                                      AppColors
                                                                          .error,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  fontSize: 22,
                                                                ),
                                                          ),
                                                          SizedBox(height: 12),
                                                          Text(
                                                            'Are you sure you want to cancel this booking request? This action cannot be undone.',
                                                            style: AppTextStyles
                                                                .body2
                                                                .copyWith(
                                                                  fontSize: 16,
                                                                ),
                                                            textAlign:
                                                                TextAlign
                                                                    .center,
                                                          ),
                                                          SizedBox(height: 24),
                                                          Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .spaceEvenly,
                                                            children: [
                                                              ElevatedButton(
                                                                style: ElevatedButton.styleFrom(
                                                                  backgroundColor:
                                                                      AppColors
                                                                          .error,
                                                                  shape: RoundedRectangleBorder(
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                          12,
                                                                        ),
                                                                  ),
                                                                  padding:
                                                                      EdgeInsets.symmetric(
                                                                        horizontal:
                                                                            24,
                                                                        vertical:
                                                                            12,
                                                                      ),
                                                                ),
                                                                onPressed: () async {
                                                                  await BookingService()
                                                                      .updateBookingRequestStatus(
                                                                        booking
                                                                            .id,
                                                                        'cancelled',
                                                                      );
                                                                  print(
                                                                    'Calling notifyAdminOnCancellation for pending cancellation',
                                                                  );
                                                                  NotificationService.notifyAdminOnCancellation(
                                                                    userName:
                                                                        booking
                                                                            .userName,
                                                                    branch:
                                                                        booking
                                                                            .branch,
                                                                    timeSlot:
                                                                        booking
                                                                            .timeSlot,
                                                                    date:
                                                                        booking
                                                                            .date,
                                                                  );
                                                                  Navigator.of(
                                                                    context,
                                                                  ).pop();
                                                                  setState(
                                                                    () {},
                                                                  );
                                                                },
                                                                child: Text(
                                                                  'Yes, Cancel',
                                                                  style: TextStyle(
                                                                    color:
                                                                        Colors
                                                                            .white,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                  ),
                                                                ),
                                                              ),
                                                              OutlinedButton(
                                                                style: OutlinedButton.styleFrom(
                                                                  side: BorderSide(
                                                                    color:
                                                                        AppColors
                                                                            .primaryDark,
                                                                    width: 2,
                                                                  ),
                                                                  shape: RoundedRectangleBorder(
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                          12,
                                                                        ),
                                                                  ),
                                                                  padding:
                                                                      EdgeInsets.symmetric(
                                                                        horizontal:
                                                                            24,
                                                                        vertical:
                                                                            12,
                                                                      ),
                                                                ),
                                                                onPressed:
                                                                    () =>
                                                                        Navigator.of(
                                                                          context,
                                                                        ).pop(),
                                                                child: Text(
                                                                  'No',
                                                                  style: TextStyle(
                                                                    color:
                                                                        AppColors
                                                                            .primaryDark,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
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
                                            }
                                          }
                                          : null,
                                  child: Padding(
                                    padding: EdgeInsets.all(18),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.meeting_room,
                                              color: AppColors.info,
                                              size: 28,
                                            ),
                                            SizedBox(width: 10),
                                            Expanded(
                                              child: Text(
                                                booking.branch,
                                                style: AppTextStyles.h2
                                                    .copyWith(
                                                      color: AppColors.info,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 20,
                                                    ),
                                              ),
                                            ),
                                            Container(
                                              padding: EdgeInsets.symmetric(
                                                horizontal: 5,
                                                vertical: 3,
                                              ),
                                              decoration: BoxDecoration(
                                                color:
                                                    booking.status == 'pending'
                                                        ? Colors.orange.shade100
                                                        : booking.status ==
                                                            'booked'
                                                        ? AppColors.success
                                                            .withOpacity(0.15)
                                                        : Colors.red.shade100,
                                                borderRadius:
                                                    BorderRadius.circular(6),
                                              ),
                                              child: Text(
                                                booking.status == 'booked'
                                                    ? 'BOOKED'
                                                    : booking.status ==
                                                        'pending'
                                                    ? 'PENDING'
                                                    : booking.status
                                                        .toUpperCase(),
                                                style: TextStyle(
                                                  color:
                                                      booking.status ==
                                                              'pending'
                                                          ? Colors.orange
                                                          : booking.status ==
                                                              'booked'
                                                          ? AppColors.success
                                                          : Colors.red,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 8),
                                        // Date row styled
                                        Container(
                                          margin: EdgeInsets.symmetric(
                                            vertical: 4,
                                          ),
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 10,
                                          ),
                                          decoration: BoxDecoration(
                                            color: AppColors.booked,
                                            borderRadius: BorderRadius.circular(
                                              0,
                                            ),
                                            border: Border.all(
                                              color: AppColors.secondaryDark,
                                              width: 2,
                                            ),
                                          ),
                                          child: Row(
                                            children: [
                                              Icon(
                                                Icons.calendar_today_outlined,
                                                color: AppColors.info,
                                                size: 22,
                                              ),
                                              SizedBox(width: 12),
                                              Text(
                                                'Date',
                                                style: TextStyle(
                                                  color: AppColors.info,
                                                  fontSize: 16,
                                                ),
                                              ),
                                              Spacer(),
                                              Text(
                                                booking.date,
                                                style: TextStyle(
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 16,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        // Time row styled
                                        Container(
                                          // margin: EdgeInsets.symmetric(vertical: 0),
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 10,
                                          ),
                                          decoration: BoxDecoration(
                                            color: AppColors.booked,
                                            borderRadius: BorderRadius.circular(
                                              0,
                                            ),
                                            border: Border.all(
                                              color: AppColors.secondaryDark,
                                              width: 2,
                                            ),
                                          ),
                                          child: Row(
                                            children: [
                                              Icon(
                                                Icons.access_time,
                                                color: AppColors.info,
                                                size: 22,
                                              ),
                                              SizedBox(width: 12),
                                              Text(
                                                'Time',
                                                style: TextStyle(
                                                  color: AppColors.info,
                                                  fontSize: 16,
                                                ),
                                              ),
                                              Spacer(),
                                              Text(
                                                booking.timeSlot,
                                                style: TextStyle(
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 16,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
            ),
          ],
        ),
      ),
    );
  }
}
