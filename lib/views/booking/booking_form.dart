import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../services/booking_service.dart';
import '../../models/booking_model.dart';
import '../../services/shared_prefs_service.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_colors.dart';
import '../../services/notification_service.dart';

class BookingForm extends StatefulWidget {
  final String branchName;
  const BookingForm({super.key, required this.branchName});

  @override
  State<BookingForm> createState() => _BookingFormState();
}

class _BookingFormState extends State<BookingForm> {
  DateTime? selectedDate;
  String? selectedTimeSlot;
  final _formKey = GlobalKey<FormState>();
  String? userName;
  String? email;
  String? phone;
  bool isLoading = false;
  List<String> bookedSlotsForDate = [];

  List<String> get timeSlots {
    List<String> slots = [];
    for (int hour = 9; hour < 24; hour++) {
      final start = TimeOfDay(hour: hour, minute: 0);
      final end = TimeOfDay(hour: hour + 1, minute: 0);
      slots.add('${_formatTime(start)} - ${_formatTime(end)}');
    }
    return slots;
  }

  String _formatTime(TimeOfDay t) {
    final dt = DateTime(0, 0, 0, t.hour, t.minute);
    return DateFormat('hh:mm a').format(dt);
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 6)),
    );
    if (picked != null) {
      setState(() {
        selectedDate = picked;
        selectedTimeSlot = null;
      });
      await _fetchBookedSlotsForDate(picked);
    }
  }

  Future<void> _fetchBookedSlotsForDate(DateTime date) async {
    final allBookings = await BookingService().getAllBookingRequests();
    final dateStr = DateFormat('yyyy-MM-dd').format(date);
    setState(() {
      bookedSlotsForDate =
          allBookings
              .where(
                (b) =>
                    b.date == dateStr &&
                    b.branch == widget.branchName &&
                    (b.status == 'booked' || b.status == 'pending'),
              )
              .map((b) => b.timeSlot)
              .toList();
    });
  }

  Future<void> _loadUserInfo() async {
    userName = await SharedPrefsService.getUserName();
    email = await SharedPrefsService.getUserEmail();
    phone = await SharedPrefsService.getUserPhone();
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
    if (selectedDate != null) {
      _fetchBookedSlotsForDate(selectedDate!);
    }
  }

  Future<void> _submitBooking() async {
    if (!_formKey.currentState!.validate() ||
        selectedDate == null ||
        selectedTimeSlot == null)
      return;
    setState(() {
      isLoading = true;
    });
    final userId = await SharedPrefsService.getUserId();
    final booking = BookingRequest(
      id: '',
      userId: userId ?? '',
      userName: userName ?? '',
      email: email ?? '',
      phone: phone ?? '',
      branch: widget.branchName,
      date: DateFormat('yyyy-MM-dd').format(selectedDate!),
      timeSlot: selectedTimeSlot!,
      status: 'pending',
    );
    try {
      print('Saving booking: \\${booking.toMap()}');
      await BookingService().createBookingRequest(booking);
      // Notify admin after booking request is created
      await NotificationService.notifyAdminOnBooking(
        userName: booking.userName,
        branch: booking.branch,
        timeSlot: booking.timeSlot,
      );
      final all = await BookingService().getAllBookingRequests();
      print('All bookings in Hive:');
      for (var b in all) {
        print(b.toMap());
      }
      setState(() {
        selectedDate = null;
        selectedTimeSlot = null;
      });
      if (selectedDate != null) {
        await _fetchBookedSlotsForDate(selectedDate!);
      }
      await showDialog(
        context: context,
        barrierDismissible: true,
        builder:
            (context) => Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.r),
              ),
              backgroundColor: Colors.white,
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 32.h, horizontal: 24.w),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.check_circle_rounded,
                      size: 64.sp,
                      color: const Color.fromARGB(255, 22, 209, 53),
                    ),
                    SizedBox(height: 18.h),
                    Text(
                      'Request sent successfully!',
                      style: AppTextStyles.h2.copyWith(
                        color: AppColors.info,
                        fontWeight: FontWeight.bold,
                        fontSize: 20.sp,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 18.h),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(
                            255,
                            33,
                            175,
                            40,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          padding: EdgeInsets.symmetric(vertical: 12.h),
                        ),
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text(
                          'OK',
                          style: AppTextStyles.h3.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16.sp,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to send request: $e')));
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: AppTextStyles.h1.copyWith(
                    fontSize: 22.sp,
                    color: Colors.black,
                    letterSpacing: 1.1,
                    shadows: [
                      Shadow(
                        color: Colors.black12,
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  children: [
                    const TextSpan(text: 'Book a Meeting Room at\n'),
                    TextSpan(
                      text: 'Ignition ',
                      style: AppTextStyles.h1.copyWith(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 22.sp,
                      ),
                    ),
                    TextSpan(
                      text: widget.branchName,
                      style: AppTextStyles.h1.copyWith(
                        color: const Color.fromARGB(255, 191, 38, 0),
                        fontWeight: FontWeight.w900,
                        fontSize: 25.sp,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 24.h),
              Text(
                'Select Date',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16.sp),
              ),
              SizedBox(height: 8.h),
              ElevatedButton(
                onPressed: _pickDate,
                child: Text(
                  selectedDate == null
                      ? 'Choose Date'
                      : DateFormat('dd-MM-yyyy').format(selectedDate!),
                ),
              ),
              SizedBox(height: 24.h),
              if (selectedDate != null) ...[
                Text(
                  'Select Time Slot',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16.sp,
                  ),
                ),
                SizedBox(height: 8.h),
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  childAspectRatio: 3.5,
                  mainAxisSpacing: 8.h,
                  crossAxisSpacing: 2.w,
                  children:
                      timeSlots
                          .where((slot) {
                            bool isBooked = bookedSlotsForDate.contains(slot);
                            bool isPast = false;
                            if (selectedDate != null) {
                              final now = DateTime.now();
                              final todayStr = DateFormat(
                                'yyyy-MM-dd',
                              ).format(now);
                              if (DateFormat(
                                    'yyyy-MM-dd',
                                  ).format(selectedDate!) ==
                                  todayStr) {
                                final slotStart = slot.split(' - ')[0];
                                final slotTime = DateFormat(
                                  'hh:mm a',
                                ).parse(slotStart);
                                final slotDateTime = DateTime(
                                  now.year,
                                  now.month,
                                  now.day,
                                  slotTime.hour,
                                  slotTime.minute,
                                );
                                if (slotDateTime.isBefore(now)) {
                                  isPast = true;
                                }
                              }
                            }
                            return !isBooked && !isPast;
                          })
                          .map((slot) {
                            return ChoiceChip(
                              label: Text(
                                slot,
                                style: TextStyle(
                                  fontSize: 10.sp,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black,
                                ),
                              ),
                              selected: selectedTimeSlot == slot,
                              onSelected: (selected) {
                                setState(() {
                                  selectedTimeSlot = selected ? slot : null;
                                });
                              },
                              selectedColor: Colors.green,
                              backgroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(
                                horizontal: 16.w,
                                vertical: 10.h,
                              ),
                            );
                          })
                          .toList(),
                ),
                SizedBox(height: 24.h),
              ],
              // Only show fields if info is missing
              if (userName == null || email == null || phone == null) ...[
                TextFormField(
                  decoration: InputDecoration(labelText: 'Name'),
                  validator:
                      (v) => v == null || v.isEmpty ? 'Enter your name' : null,
                  onChanged: (v) => userName = v,
                ),
                SizedBox(height: 12.h),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Email'),
                  validator:
                      (v) => v == null || v.isEmpty ? 'Enter your email' : null,
                  onChanged: (v) => email = v,
                ),
                SizedBox(height: 12.h),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Phone'),
                  validator:
                      (v) => v == null || v.isEmpty ? 'Enter your phone' : null,
                  onChanged: (v) => phone = v,
                ),
                SizedBox(height: 24.h),
              ],
              ElevatedButton(
                onPressed: isLoading ? null : _submitBooking,
                child: isLoading ? CircularProgressIndicator() : Text('Book'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
