import 'package:flutter/material.dart';
import '../../models/workspace_item_model.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../constants/app_constants.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../models/space_model.dart';
import '../booking/booking_screen.dart';
import '../booking/booking_form.dart';

class HomeScreen extends StatefulWidget {
  final String branchName;
  const HomeScreen({super.key, required this.branchName});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    Widget body;
    if (_selectedIndex == 0) {
      body = Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: 24.h),
            Expanded(child: BookingForm(branchName: widget.branchName)),
          ],
        ),
      );
    } else if (_selectedIndex == 1) {
      body = BookingScreen(branchName: widget.branchName);
    } else {
      body = Center(child: Text('Coming soon...'));
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.info,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.warning),
          onPressed: () {
            Navigator.pushReplacementNamed(context, '/branch-selection');
          },
        ),
        title: Text(
          widget.branchName,
          style: AppTextStyles.h2.copyWith(
            color: AppColors.warning,
            fontSize: 22.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: body,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: [
          NavigationDestination(
            icon: Icon(Icons.home_outlined, color: AppColors.primary),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_today_outlined, color: AppColors.text),
            label: 'Bookings',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined, color: AppColors.text),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
