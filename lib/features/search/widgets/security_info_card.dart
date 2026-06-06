import 'package:chillfi/core/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class SecurityInfoCard extends StatelessWidget {
  const SecurityInfoCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: const Color(0xFFF9F5FF),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Row(
        children: [
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              Container(
                width: 48.r,
                height: 48.r,
                decoration: const BoxDecoration(
                  color: AppColors.secondaryPurple,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.mic_none_rounded, color: Colors.white, size: 24.sp),
              ),
              Container(
                padding: EdgeInsets.all(2.r),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.verified_user_rounded, color: Colors.orange, size: 16.sp),
              ),
            ],
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Voice search is secure",
                  style: GoogleFonts.poppins(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.darkText,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  "Your voice is used only to improve your search experience and is never stored.",
                  style: GoogleFonts.poppins(
                    fontSize: 11.sp,
                    color: AppColors.greyText,
                    height: 1.4,
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
