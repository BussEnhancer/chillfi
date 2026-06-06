import 'package:chillfi/core/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class CountdownTimer extends StatelessWidget {
  const CountdownTimer({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _buildTimerBlock("02", "Days"),
        _buildDivider(),
        _buildTimerBlock("45", "Hours"),
        _buildDivider(),
        _buildTimerBlock("30", "Mins"),
        _buildDivider(),
        _buildTimerBlock("12", "Secs"),
      ],
    );
  }

  Widget _buildTimerBlock(String value, String label) {
    return Column(
      children: [
        Container(
          width: 45.w,
          height: 40.h,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 18.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.primaryOrange,
            ),
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 10.sp,
            color: Colors.white.withOpacity(0.8),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 10.h),
      child: Text(
        ":",
        style: TextStyle(
          color: Colors.white.withOpacity(0.5),
          fontWeight: FontWeight.bold,
          fontSize: 16.sp,
        ),
      ),
    );
  }
}
