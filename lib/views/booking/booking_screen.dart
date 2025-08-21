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

  Future<void> _showCancelDialog(BookingRequest booking) async {
    final bookingDate = DateTime.tryParse(booking.date);
    final now = DateTime.now();
    bool canCancel = false;

    if (bookingDate != null) {
      final today = DateTime(now.year, now.month, now.day);
      if (bookingDate.isAfter(today)) {
        canCancel = true;
      } else if (bookingDate.isAtSameMomentAs(today)) {
        String endTimeStr = '';
        if (booking.timeSlot.contains('-')) {
          endTimeStr = booking.timeSlot.split('-').last.trim();
        }
        DateTime? bookingEndDateTime;
        try {
          bookingEndDateTime = DateTime.parse(
            '${booking.date}T${endTimeStr.length <= 5 ? endTimeStr : endTimeStr.substring(0, 5)}:00',
          );
        } catch (_) {
          try {
            final time = TimeOfDay(
              hour: int.parse(endTimeStr.split(':')[0]),
              minute: int.parse(
                endTimeStr.split(':')[1].replaceAll(RegExp(r'[^0-9]'), ''),
              ),
            );
            bookingEndDateTime = DateTime(
              bookingDate.year,
              bookingDate.month,
              bookingDate.day,
              time.hour,
              time.minute,
            );
          } catch (_) {}
        }
        if (bookingEndDateTime != null && now.isBefore(bookingEndDateTime)) {
          canCancel = true;
        }
      }
    }

    if (!canCancel) return;

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
                  booking.status == 'booked'
                      ? 'Cancel Booking?'
                      : 'Cancel Booking Request?',
                  style: AppTextStyles.h2.copyWith(
                    color: AppColors.error,
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                  ),
                ),
                SizedBox(height: 12),
                Text(
                  booking.status == 'booked'
                      ? 'Are you sure you want to cancel this booking? This action cannot be undone.'
                      : 'Are you sure you want to cancel this booking request? This action cannot be undone.',
                  style: AppTextStyles.body2.copyWith(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.error,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                      onPressed: () async {
                        await BookingService().updateBookingRequestStatus(
                          booking.id,
                          'cancelled',
                        );
                        print('Calling notifyAdminOnCancellation');
                        NotificationService.notifyAdminOnCancellation(
                          userName: booking.userName,
                          branch: booking.branch,
                          timeSlot: booking.timeSlot,
                          date: booking.date,
                        );
                        Navigator.of(context).pop();
                        setState(() {});
                      },
                      child: Text(
                        'Yes, Cancel',
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
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                      onPressed: () => Navigator.of(context).pop(),
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
                          // Filter out bookings where slot end time is more than a week in the past
                          final filteredBookings =
                              bookings.where((booking) {
                                final bookingDate = DateTime.tryParse(
                                  booking.date,
                                );
                                if (bookingDate != null &&
                                    booking.timeSlot.contains('-')) {
                                  String endTimeStr =
                                      booking.timeSlot.split('-').last.trim();
                                  DateTime? bookingEndDateTime;
                                  try {
                                    bookingEndDateTime = DateTime.parse(
                                      '${booking.date}T${endTimeStr.length <= 5 ? endTimeStr : endTimeStr.substring(0, 5)}:00',
                                    );
                                  } catch (_) {
                                    try {
                                      final time = TimeOfDay(
                                        hour: int.parse(
                                          endTimeStr.split(':')[0],
                                        ),
                                        minute: int.parse(
                                          endTimeStr
                                              .split(':')[1]
                                              .replaceAll(
                                                RegExp(r'[^0-9]'),
                                                '',
                                              ),
                                        ),
                                      );
                                      bookingEndDateTime = DateTime(
                                        bookingDate.year,
                                        bookingDate.month,
                                        bookingDate.day,
                                        time.hour,
                                        time.minute,
                                      );
                                    } catch (_) {}
                                  }
                                  if (bookingEndDateTime != null) {
                                    return bookingEndDateTime.isAfter(
                                      now.subtract(Duration(days: 7)),
                                    );
                                  }
                                }
                                return true; // If can't parse, keep it
                              }).toList();
                          List<BookingRequest> sortedBookings = [];
                          if (_selectedFilter == 'all') {
                            // Split into future and past bookings
                            final futureBookings =
                                filteredBookings.where((b) {
                                  final bDate = DateTime.tryParse(b.date);
                                  if (bDate == null) return false;
                                  // Use slot end time if possible
                                  if (b.timeSlot.contains('-')) {
                                    String endTimeStr =
                                        b.timeSlot.split('-').last.trim();
                                    DateTime? bookingEndDateTime;
                                    try {
                                      bookingEndDateTime = DateTime.parse(
                                        '${b.date}T${endTimeStr.length <= 5 ? endTimeStr : endTimeStr.substring(0, 5)}:00',
                                      );
                                    } catch (_) {
                                      try {
                                        final time = TimeOfDay(
                                          hour: int.parse(
                                            endTimeStr.split(':')[0],
                                          ),
                                          minute: int.parse(
                                            endTimeStr
                                                .split(':')[1]
                                                .replaceAll(
                                                  RegExp(r'[^0-9]'),
                                                  '',
                                                ),
                                          ),
                                        );
                                        bookingEndDateTime = DateTime(
                                          bDate.year,
                                          bDate.month,
                                          bDate.day,
                                          time.hour,
                                          time.minute,
                                        );
                                      } catch (_) {}
                                    }
                                    if (bookingEndDateTime != null) {
                                      return bookingEndDateTime.isAfter(now);
                                    }
                                  }
                                  return bDate.isAfter(now);
                                }).toList();
                            final pastBookings =
                                filteredBookings.where((b) {
                                  final bDate = DateTime.tryParse(b.date);
                                  if (bDate == null) return false;
                                  if (b.timeSlot.contains('-')) {
                                    String endTimeStr =
                                        b.timeSlot.split('-').last.trim();
                                    DateTime? bookingEndDateTime;
                                    try {
                                      bookingEndDateTime = DateTime.parse(
                                        '${b.date}T${endTimeStr.length <= 5 ? endTimeStr : endTimeStr.substring(0, 5)}:00',
                                      );
                                    } catch (_) {
                                      try {
                                        final time = TimeOfDay(
                                          hour: int.parse(
                                            endTimeStr.split(':')[0],
                                          ),
                                          minute: int.parse(
                                            endTimeStr
                                                .split(':')[1]
                                                .replaceAll(
                                                  RegExp(r'[^0-9]'),
                                                  '',
                                                ),
                                          ),
                                        );
                                        bookingEndDateTime = DateTime(
                                          bDate.year,
                                          bDate.month,
                                          bDate.day,
                                          time.hour,
                                          time.minute,
                                        );
                                      } catch (_) {}
                                    }
                                    if (bookingEndDateTime != null) {
                                      return bookingEndDateTime.isBefore(now);
                                    }
                                  }
                                  return bDate.isBefore(now);
                                }).toList();
                            // Sort future bookings: soonest first
                            futureBookings.sort((a, b) {
                              final aDate = DateTime.tryParse(a.date) ?? now;
                              final bDate = DateTime.tryParse(b.date) ?? now;
                              // Use slot end time if possible
                              DateTime aEnd = aDate;
                              DateTime bEnd = bDate;
                              if (a.timeSlot.contains('-')) {
                                String endTimeStr =
                                    a.timeSlot.split('-').last.trim();
                                try {
                                  aEnd = DateTime.parse(
                                    '${a.date}T${endTimeStr.length <= 5 ? endTimeStr : endTimeStr.substring(0, 5)}:00',
                                  );
                                } catch (_) {
                                  try {
                                    final time = TimeOfDay(
                                      hour: int.parse(endTimeStr.split(':')[0]),
                                      minute: int.parse(
                                        endTimeStr
                                            .split(':')[1]
                                            .replaceAll(RegExp(r'[^0-9]'), ''),
                                      ),
                                    );
                                    aEnd = DateTime(
                                      aDate.year,
                                      aDate.month,
                                      aDate.day,
                                      time.hour,
                                      time.minute,
                                    );
                                  } catch (_) {}
                                }
                              }
                              if (b.timeSlot.contains('-')) {
                                String endTimeStr =
                                    b.timeSlot.split('-').last.trim();
                                try {
                                  bEnd = DateTime.parse(
                                    '${b.date}T${endTimeStr.length <= 5 ? endTimeStr : endTimeStr.substring(0, 5)}:00',
                                  );
                                } catch (_) {
                                  try {
                                    final time = TimeOfDay(
                                      hour: int.parse(endTimeStr.split(':')[0]),
                                      minute: int.parse(
                                        endTimeStr
                                            .split(':')[1]
                                            .replaceAll(RegExp(r'[^0-9]'), ''),
                                      ),
                                    );
                                    bEnd = DateTime(
                                      bDate.year,
                                      bDate.month,
                                      bDate.day,
                                      time.hour,
                                      time.minute,
                                    );
                                  } catch (_) {}
                                }
                              }
                              return aEnd.compareTo(bEnd);
                            });
                            // Sort past bookings: most recent past first
                            pastBookings.sort((a, b) {
                              final aDate = DateTime.tryParse(a.date) ?? now;
                              final bDate = DateTime.tryParse(b.date) ?? now;
                              DateTime aEnd = aDate;
                              DateTime bEnd = bDate;
                              if (a.timeSlot.contains('-')) {
                                String endTimeStr =
                                    a.timeSlot.split('-').last.trim();
                                try {
                                  aEnd = DateTime.parse(
                                    '${a.date}T${endTimeStr.length <= 5 ? endTimeStr : endTimeStr.substring(0, 5)}:00',
                                  );
                                } catch (_) {
                                  try {
                                    final time = TimeOfDay(
                                      hour: int.parse(endTimeStr.split(':')[0]),
                                      minute: int.parse(
                                        endTimeStr
                                            .split(':')[1]
                                            .replaceAll(RegExp(r'[^0-9]'), ''),
                                      ),
                                    );
                                    aEnd = DateTime(
                                      aDate.year,
                                      aDate.month,
                                      aDate.day,
                                      time.hour,
                                      time.minute,
                                    );
                                  } catch (_) {}
                                }
                              }
                              if (b.timeSlot.contains('-')) {
                                String endTimeStr =
                                    b.timeSlot.split('-').last.trim();
                                try {
                                  bEnd = DateTime.parse(
                                    '${b.date}T${endTimeStr.length <= 5 ? endTimeStr : endTimeStr.substring(0, 5)}:00',
                                  );
                                } catch (_) {
                                  try {
                                    final time = TimeOfDay(
                                      hour: int.parse(endTimeStr.split(':')[0]),
                                      minute: int.parse(
                                        endTimeStr
                                            .split(':')[1]
                                            .replaceAll(RegExp(r'[^0-9]'), ''),
                                      ),
                                    );
                                    bEnd = DateTime(
                                      bDate.year,
                                      bDate.month,
                                      bDate.day,
                                      time.hour,
                                      time.minute,
                                    );
                                  } catch (_) {}
                                }
                              }
                              return bEnd.compareTo(
                                aEnd,
                              ); // Most recent past first
                            });
                            sortedBookings = [
                              ...futureBookings,
                              ...pastBookings,
                            ];
                          } else if (_selectedFilter == 'closest_to_today') {
                            sortedBookings =
                                filteredBookings.where((b) {
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
                                filteredBookings
                                    .where((b) => b.status == 'booked')
                                    .toList();
                          } else if (_selectedFilter == 'pending') {
                            sortedBookings =
                                filteredBookings
                                    .where((b) => b.status == 'pending')
                                    .toList();
                          } else if (_selectedFilter == 'cancelled') {
                            sortedBookings =
                                filteredBookings
                                    .where((b) => b.status == 'cancelled')
                                    .toList();
                          } else if (_selectedFilter == 'rejected') {
                            sortedBookings =
                                filteredBookings
                                    .where((b) => b.status == 'rejected')
                                    .toList();
                          }
                          if (sortedBookings.isEmpty) {
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
                          return ListView.builder(
                            padding: EdgeInsets.all(16.w),
                            itemCount: sortedBookings.length,
                            itemBuilder: (context, index) {
                              final booking = sortedBookings[index];
                              // Calculate if Cancel button should be shown
                              final now = DateTime.now();
                              bool canShowCancel = false;
                              if (booking.status == 'pending' ||
                                  booking.status == 'booked') {
                                final bookingDate = DateTime.tryParse(
                                  booking.date,
                                );
                                if (bookingDate != null &&
                                    booking.timeSlot.contains('-')) {
                                  String endTimeStr =
                                      booking.timeSlot.split('-').last.trim();
                                  DateTime? bookingEndDateTime;
                                  try {
                                    bookingEndDateTime = DateTime.parse(
                                      '${booking.date}T${endTimeStr.length <= 5 ? endTimeStr : endTimeStr.substring(0, 5)}:00',
                                    );
                                  } catch (_) {
                                    try {
                                      final time = TimeOfDay(
                                        hour: int.parse(
                                          endTimeStr.split(':')[0],
                                        ),
                                        minute: int.parse(
                                          endTimeStr
                                              .split(':')[1]
                                              .replaceAll(
                                                RegExp(r'[^0-9]'),
                                                '',
                                              ),
                                        ),
                                      );
                                      bookingEndDateTime = DateTime(
                                        bookingDate.year,
                                        bookingDate.month,
                                        bookingDate.day,
                                        time.hour,
                                        time.minute,
                                      );
                                    } catch (_) {}
                                  }
                                  if (bookingEndDateTime != null &&
                                      now.isBefore(bookingEndDateTime)) {
                                    canShowCancel = true;
                                  }
                                }
                              }
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
                                child: Padding(
                                  padding: EdgeInsets.fromLTRB(18, 18, 18, 10),
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
                                              style: AppTextStyles.h2.copyWith(
                                                color: AppColors.info,
                                                fontWeight: FontWeight.bold,
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
                                                  : booking.status == 'pending'
                                                  ? 'PENDING'
                                                  : booking.status
                                                      .toUpperCase(),
                                              style: TextStyle(
                                                color:
                                                    booking.status == 'pending'
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
                                      // Add Cancel button only for pending or booked status and if slot end time is in the future
                                      if (canShowCancel)
                                        Align(
                                          alignment: Alignment.bottomRight,
                                          child: Container(
                                            margin: EdgeInsets.only(top: 4),
                                            child: TextButton(
                                              style: TextButton.styleFrom(
                                                backgroundColor:
                                                    const Color.fromARGB(
                                                      255,
                                                      161,
                                                      24,
                                                      6,
                                                    ),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(4),
                                                ),
                                                padding: EdgeInsets.symmetric(
                                                  horizontal: 12,
                                                  vertical: 4,
                                                ),
                                                minimumSize: Size(0, 0),
                                                tapTargetSize:
                                                    MaterialTapTargetSize
                                                        .shrinkWrap,
                                              ),
                                              onPressed:
                                                  () => _showCancelDialog(
                                                    booking,
                                                  ),
                                              child: Text(
                                                'Cancel?',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ),
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
          ],
        ),
      ),
    );
  }
}
