import 'package:chillfi/core/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class HelpBannerWidget extends StatelessWidget {
  const HelpBannerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: const Color(0xFFF9F5FF), // Soft purple background
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.secondaryPurple.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          // Icon/Illustration
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 45.w,
                height: 45.h,
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
              ),
              Icon(Icons.search_rounded, color: AppColors.secondaryPurple, size: 28.sp),
              Positioned(
                top: 0,
                right: 0,
                child: Icon(Icons.star_rounded, color: AppColors.secondaryPurple.withOpacity(0.4), size: 12.sp),
              )
            ],
          ),
          SizedBox(width: 16.w),
          // Text Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Can't find what you're looking for?",
                  style: GoogleFonts.poppins(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.darkText,
                  ),
                ),
                Text(
                  "We'll help you find it.",
                  style: GoogleFonts.poppins(
                    fontSize: 11.sp,
                    color: AppColors.greyText,
                  ),
                ),
              ],
            ),
          ),
          // CTA Button
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20.r),
              border: Border.all(color: AppColors.secondaryPurple.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Text(
                  "Search Anyway",
                  style: GoogleFonts.poppins(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.secondaryPurple,
                  ),
                ),
                SizedBox(width: 4.w),
                Icon(Icons.chevron_right_rounded, color: AppColors.secondaryPurple, size: 16.sp),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
