import 'package:chillfi/core/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class NotifyCard extends StatelessWidget {
  const NotifyCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: const Color(0xFFF9F5FF),
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.secondaryPurple.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12.r),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.secondaryPurple.withOpacity(0.1),
                  blurRadius: 10,
                ),
              ],
            ),
            child: Icon(Icons.percent_rounded, color: AppColors.secondaryPurple, size: 24.sp),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Don't miss out!",
                  style: GoogleFonts.poppins(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.darkText,
                  ),
                ),
                Text(
                  "New deals every day. Stay tuned!",
                  style: GoogleFonts.poppins(
                    fontSize: 11.sp,
                    color: AppColors.greyText,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: AppColors.secondaryPurple.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Icon(Icons.notifications_none_rounded, color: AppColors.secondaryPurple, size: 16.sp),
                SizedBox(width: 6.w),
                Text(
                  "Notify Me",
                  style: GoogleFonts.poppins(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.secondaryPurple,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
