import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ignition/theme/app_colors.dart';
import '../constants/app_constants.dart';
import '../theme/app_text_styles.dart';

class BranchSelectionScreen extends StatelessWidget {
  const BranchSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushReplacementNamed(context, '/login');
        return false;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: AppColors.info,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: AppColors.secondaryDark),
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ),
        body: Center(
          child: Padding(
            padding: EdgeInsets.all(24.w),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // SizedBox(height: 14.h),
                Center(
                  child: SizedBox(
                    height: 120.w,
                    width: 120.w,
                    child: Image.asset(
                      'assets/icons/ignition.jpeg',
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                SizedBox(height: 24.h),
                Text(
                  'Choose the branch',
                  style: TextStyle(
                    fontSize: 28.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 40.h),
                _AdminBlockButton(
                  label: 'Johar Town',
                  icon: Icons.location_city,
                  onTap: () {
                    Navigator.pushReplacementNamed(
                      context,
                      AppConstants.homeRoute,
                      arguments: 'Johar Town',
                    );
                  },
                ),
                SizedBox(height: 24.h),
                _AdminBlockButton(
                  label: 'Bahria Orchard',
                  icon: Icons.location_city,
                  onTap: () {
                    Navigator.pushReplacementNamed(
                      context,
                      AppConstants.homeRoute,
                      arguments: 'Bahria Orchard',
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AdminBlockButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  const _AdminBlockButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 8,
      color: const Color.fromARGB(255, 241, 240, 240),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18.r)),
      child: InkWell(
        borderRadius: BorderRadius.circular(18.r),
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 12.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: EdgeInsets.only(top: 8.h, left: 4.w, right: 4.w),
                child: Text(
                  label,
                  style: AppTextStyles.h2.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 19.sp,
                    color: AppColors.text,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(height: 12.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Icon(icon, size: 32.sp, color: AppColors.primaryDark),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 22.sp,
                    color: AppColors.secondaryDark,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
