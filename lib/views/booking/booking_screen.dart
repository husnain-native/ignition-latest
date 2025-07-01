import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../constants/app_constants.dart';
import '../../services/shared_prefs_service.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class BookingScreen extends StatefulWidget {
  final String branchName;
  const BookingScreen({super.key, required this.branchName});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  DateTime _selectedDate = DateTime.now();
  String? _userEmail;
  String _selectedView = 'day';
  CalendarFormat _calendarFormat = CalendarFormat.month;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final email = await SharedPrefsService.getUserEmail();
    setState(() {
      _userEmail = email;
    });
  }

  Future<void> _handleLogout() async {
    await SharedPrefsService.clearSession();
    if (mounted) {
      Navigator.pushReplacementNamed(context, AppConstants.loginRoute);
    }
  }

  final List<String> _timeSlots = [
    '12:00 AM',
    '1:00 AM',
    '2:00 AM',
    '3:00 AM',
    '4:00 AM',
    '5:00 AM',
    '6:00 AM',
    '7:00 AM',
    '8:00 AM',
    '9:00 AM',
    '10:00 AM',
    '11:00 AM',
    '12:00 PM',
    '1:00 PM',
    '2:00 PM',
    '3:00 PM',
    '4:00 PM',
    '5:00 PM',
    '6:00 PM',
    '7:00 PM',
    '8:00 PM',
    '9:00 PM',
    '10:00 PM',
    '11:00 PM',
  ];

  Widget _buildCalendarView() {
    switch (_selectedView) {
      case 'month':
        return Expanded(
          child: SingleChildScrollView(
            child: TableCalendar(
              firstDay: DateTime.now(),
              lastDay: DateTime.now().add(const Duration(days: 365)),
              focusedDay: _selectedDate,
              calendarFormat: _calendarFormat,
              selectedDayPredicate: (day) {
                return isSameDay(_selectedDate, day);
              },
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDate = selectedDay;
                });
              },
              headerVisible: false,
              calendarStyle: CalendarStyle(
                selectedDecoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                todayDecoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
        );
      case 'grid':
        return Expanded(
          child: GridView.builder(
            padding: EdgeInsets.all(16.w),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 1.5,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemCount: 30,
            itemBuilder: (context, index) {
              final date = DateTime.now().add(Duration(days: index));
              return Card(
                color:
                    isSameDay(date, _selectedDate)
                        ? AppColors.primary
                        : Colors.white,
                child: InkWell(
                  onTap: () {
                    setState(() {
                      _selectedDate = date;
                    });
                  },
                  child: Center(
                    child: Text(
                      DateFormat('MMM d').format(date),
                      style: TextStyle(
                        color:
                            isSameDay(date, _selectedDate)
                                ? Colors.white
                                : AppColors.text,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        );
      case 'list':
        return Expanded(
          child: ListView.builder(
            padding: EdgeInsets.symmetric(vertical: 8.h),
            itemCount: 30,
            itemBuilder: (context, index) {
              final date = DateTime.now().add(Duration(days: index));
              return ListTile(
                selected: isSameDay(date, _selectedDate),
                selectedTileColor: AppColors.primary.withOpacity(0.1),
                onTap: () {
                  setState(() {
                    _selectedDate = date;
                  });
                },
                title: Text(
                  DateFormat('EEEE, MMMM d, y').format(date),
                  style: AppTextStyles.body1,
                ),
              );
            },
          ),
        );
      case 'day':
      default:
        return Expanded(
          child: ListView.builder(
            itemCount: _timeSlots.length,
            itemBuilder: (context, index) {
              final timeSlot = _timeSlots[index];
              return _buildTimeSlot(timeSlot);
            },
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(56),
        child: AppBar(
          backgroundColor: const Color.fromARGB(255, 21, 71, 9),
          elevation: 0,
          automaticallyImplyLeading: false,
          centerTitle: true,
          title: Text(
            widget.branchName,
            style: AppTextStyles.h3.copyWith(
              color: const Color.fromARGB(255, 255, 255, 255),
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          Container(
            color: AppColors.surface,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
            child: Column(
              children: [
                Container(
                  height: 36,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: SegmentedButton<String>(
                    segments: const [
                      ButtonSegment(value: 'day', label: Text('DAY')),
                      ButtonSegment(value: 'month', label: Text('MONTH')),
                      ButtonSegment(value: 'grid', label: Text('GRID')),
                      ButtonSegment(value: 'list', label: Text('LIST')),
                    ],
                    selected: {_selectedView},
                    onSelectionChanged: (Set<String> newSelection) {
                      setState(() {
                        _selectedView = newSelection.first;
                      });
                    },
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.resolveWith<Color>(
                        (Set<MaterialState> states) {
                          if (states.contains(MaterialState.selected)) {
                            return Colors.green;
                          }
                          return Colors.transparent;
                        },
                      ),
                      foregroundColor: MaterialStateProperty.resolveWith<Color>(
                        (Set<MaterialState> states) {
                          if (states.contains(MaterialState.selected)) {
                            return Colors.white;
                          }
                          return Colors.black87;
                        },
                      ),
                      side: MaterialStateProperty.all(BorderSide.none),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      visualDensity: VisualDensity.compact,
                      padding: MaterialStateProperty.all(
                        const EdgeInsets.symmetric(horizontal: 8),
                      ),
                    ),
                    showSelectedIcon: false,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.chevron_left, size: 20),
                      onPressed: () {
                        setState(() {
                          _selectedDate = _selectedDate.subtract(
                            const Duration(days: 1),
                          );
                        });
                      },
                      padding: EdgeInsets.zero,
                      visualDensity: VisualDensity.compact,
                      constraints: const BoxConstraints(
                        minWidth: 32,
                        minHeight: 32,
                      ),
                    ),
                    Expanded(
                      child: TextButton(
                        onPressed: () async {
                          final DateTime? picked = await showDatePicker(
                            context: context,
                            initialDate: _selectedDate,
                            firstDate: DateTime.now(),
                            lastDate: DateTime.now().add(
                              const Duration(days: 90),
                            ),
                          );
                          if (picked != null) {
                            setState(() {
                              _selectedDate = picked;
                            });
                          }
                        },
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          DateFormat(
                            'EEE, MMM d',
                          ).format(_selectedDate).toUpperCase(),
                          style: AppTextStyles.body1.copyWith(
                            color: AppColors.text,
                            fontWeight: FontWeight.w500,
                            fontSize: 12,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.chevron_right, size: 20),
                      onPressed: () {
                        setState(() {
                          _selectedDate = _selectedDate.add(
                            const Duration(days: 1),
                          );
                        });
                      },
                      padding: EdgeInsets.zero,
                      visualDensity: VisualDensity.compact,
                      constraints: const BoxConstraints(
                        minWidth: 32,
                        minHeight: 32,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (_selectedView == 'day')
            Container(
              color: AppColors.surface,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Text(
                    'Meeting Room',
                    style: AppTextStyles.h2.copyWith(color: AppColors.text),
                  ),
                ],
              ),
            ),
          _buildCalendarView(),
        ],
      ),
    );
  }

  Widget _buildTimeSlot(String time) {
    bool isAvailable = true;

    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: isAvailable ? AppColors.available : AppColors.booked,
        border: Border(bottom: BorderSide(color: AppColors.divider)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Padding(
              padding: const EdgeInsets.only(left: 16),
              child: Text(
                time,
                style: AppTextStyles.body2.copyWith(color: AppColors.text),
              ),
            ),
          ),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(left: BorderSide(color: AppColors.divider)),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: isAvailable ? () => _showBookingDialog(time) : null,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    alignment: Alignment.centerLeft,
                    child: Text(
                      isAvailable ? 'Available' : 'Booked',
                      style: TextStyle(
                        color:
                            isAvailable
                                ? AppColors.availableText
                                : AppColors.bookedText,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showBookingDialog(String time) async {
    return showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(
              'Confirm Booking',
              style: AppTextStyles.h2.copyWith(color: AppColors.text),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Date: ${DateFormat('EEEE, MMMM d, y').format(_selectedDate)}',
                  style: AppTextStyles.body1,
                ),
                Text('Time: $time', style: AppTextStyles.body1),
                Text('Space: Meeting Room', style: AppTextStyles.body1),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Cancel',
                  style: AppTextStyles.button.copyWith(color: AppColors.text),
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                ),
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Booking confirmed!')),
                  );
                },
                child: const Text('Confirm'),
              ),
            ],
          ),
    );
  }
}
