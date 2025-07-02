import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../services/booking_service.dart';
import '../../models/booking_model.dart';
import '../../services/shared_prefs_service.dart';

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
    }
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
      final all = await BookingService().getAllBookingRequests();
      print('All bookings in Hive:');
      for (var b in all) {
        print(b.toMap());
      }
      setState(() {
        selectedDate = null;
        selectedTimeSlot = null;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Request successfully sent')));
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
              Text(
                'Book a Meeting Room at \n Ignition ${widget.branchName}',
                style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
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
                Wrap(
                  spacing: 8.w,
                  runSpacing: 8.h,
                  children:
                      timeSlots.map((slot) {
                        return ChoiceChip(
                          label: Text(slot),
                          selected: selectedTimeSlot == slot,
                          onSelected: (selected) {
                            setState(() {
                              selectedTimeSlot = selected ? slot : null;
                            });
                          },
                          selectedColor: Colors.green,
                        );
                      }).toList(),
                ),
                SizedBox(height: 24.h),
              ],
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
