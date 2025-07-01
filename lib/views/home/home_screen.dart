import 'package:flutter/material.dart';
import '../../models/workspace_item_model.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../constants/app_constants.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../models/space_model.dart';
import '../booking/booking_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<WorkspaceItem> _items = WorkspaceItem.getDummyItems();
  String _selectedType = 'all';
  int _selectedIndex = 0;
  int _selectedBranchIndex = 0;

  List<WorkspaceItem> get _filteredItems {
    if (_selectedType == 'all') return _items;
    return _items.where((item) => item.type == _selectedType).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          AppConstants.appName,
          style: AppTextStyles.h2.copyWith(
            color: AppColors.text,
            fontSize: 20.sp,
          ),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Text(
            //   'Welcome to Ignition',
            //   style: TextStyle(
            //     color: AppColors.text,
            //     fontWeight: FontWeight.w900,
            //     fontSize: 24.sp,
            //   ),
            //   textAlign: TextAlign.start,
            // ),
            // SizedBox(height: 24.h),
            Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 218, 241, 207),
                // borderRadius: BorderRadius.circular(20.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedBranchIndex = 0;
                        });
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 18.h),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(6.r),
                          color:
                              _selectedBranchIndex == 0
                                  ? Color.fromARGB(255, 13, 54, 15)
                                  : Colors.grey.shade200,
                          border: Border.all(
                            color:
                                _selectedBranchIndex == 0
                                    ? Color.fromARGB(255, 13, 54, 15)
                                    : Colors.grey.shade400,
                            width: 1,
                          ),
                          boxShadow:
                              _selectedBranchIndex == 0
                                  ? [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.08),
                                      blurRadius: 8,
                                      offset: Offset(0, 2),
                                    ),
                                  ]
                                  : [],
                        ),
                        child: Center(
                          child: Text(
                            'Johar Town',
                            style: TextStyle(
                              color:
                                  _selectedBranchIndex == 0
                                      ? Colors.white
                                      : AppColors.text,
                              fontWeight: FontWeight.w900,
                              fontSize: 18.sp,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedBranchIndex = 1;
                        });
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 18.h),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(6.r),
                          color:
                              _selectedBranchIndex == 1
                                  ? Color.fromARGB(255, 13, 54, 15)
                                  : Colors.grey.shade200,
                          border: Border.all(
                            color:
                                _selectedBranchIndex == 1
                                    ? Color.fromARGB(255, 13, 54, 15)
                                    : Colors.grey.shade400,
                            width: 1,
                          ),
                          boxShadow:
                              _selectedBranchIndex == 1
                                  ? [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.08),
                                      blurRadius: 8,
                                      offset: Offset(0, 2),
                                    ),
                                  ]
                                  : [],
                        ),
                        child: Center(
                          child: Text(
                            'Bahria Orchard',
                            style: TextStyle(
                              color:
                                  _selectedBranchIndex == 1
                                      ? Colors.white
                                      : AppColors.text,
                              fontWeight: FontWeight.w900,
                              fontSize: 18.sp,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 22.h),
            Expanded(
              child:
                  _selectedBranchIndex == 0
                      ? BookingScreen(branchName: 'Johar Town')
                      : BookingScreen(branchName: 'Bahria Orchard'),
            ),
          ],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: [
          NavigationDestination(
            icon: Icon(
              Icons.home_outlined,
              color: _selectedIndex == 0 ? AppColors.primary : AppColors.text,
            ),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(
              Icons.space_dashboard_outlined,
              color: _selectedIndex == 1 ? AppColors.primary : AppColors.text,
            ),
            label: 'Spaces',
          ),
          NavigationDestination(
            icon: Icon(
              Icons.calendar_today_outlined,
              color: _selectedIndex == 2 ? AppColors.primary : AppColors.text,
            ),
            label: 'Bookings',
          ),
          NavigationDestination(
            icon: Icon(
              Icons.settings_outlined,
              color: _selectedIndex == 3 ? AppColors.primary : AppColors.text,
            ),
            label: 'Settings',
          ),
        ],
      ),
    );
  }

  Widget _buildBranchContent(String branchName) {
    return Center(
      child: Text(
        branchName,
        style: TextStyle(
          color: AppColors.text,
          fontWeight: FontWeight.w700,
          fontSize: 20.sp,
        ),
      ),
    );
  }
}
