import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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

    return WillPopScope(
      onWillPop: () async {
        Navigator.pushReplacementNamed(context, '/branch-selection');
        return false;
      },
      child: Scaffold(
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
        bottomNavigationBar: SafeArea(
          child: customBottomNavBar(_selectedIndex, (index) {
            setState(() {
              _selectedIndex = index;
            });
          }),
        ),
      ),
    );
  }

  Widget customBottomNavBar(int selectedIndex, Function(int) onTap) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.info,
        borderRadius: BorderRadius.vertical(top: Radius.circular(14)),
        boxShadow: [
          BoxShadow(
            color: const Color.fromARGB(31, 2, 49, 204),
            blurRadius: 20,
            offset: Offset(0, -2),
          ),
        ],
      ),
      padding: EdgeInsets.symmetric(vertical: 20, horizontal: 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Meetings (Home)
          GestureDetector(
            onTap: () => onTap(0),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 18, vertical: 8),
              decoration: BoxDecoration(
                color:
                    selectedIndex == 0 ?Color(0xFFE6F0FF) : Colors.transparent,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.home_filled,
                    color:
                        selectedIndex == 0
                            ? Color(0xFF2563EB)
                            : Color(0xFFFFFFFF),
                  ),
                  SizedBox(width: 6),
                  Text(
                    "Home",
                    style: TextStyle(
                      color:
                          selectedIndex == 0
                              ? Color(0xFF2563EB)
                              : Color(0xFFFFFFFF),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Bookings
          GestureDetector(
            onTap: () => onTap(1),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 18, vertical: 8),
              decoration: BoxDecoration(
                color:
                    selectedIndex == 1 ? Color(0xFFE6F0FF) : Colors.transparent,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.list_alt,
                    color:
                        selectedIndex == 1
                            ? Color(0xFF2563EB)
                            : Color(0xFFFFFFFF),
                  ),
                  SizedBox(width: 6),
                  Text(
                    "Bookings",
                    style: TextStyle(
                      color:
                          selectedIndex == 1
                              ? Color(0xFF2563EB)
                              : Color(0xFFFFFFFF),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
