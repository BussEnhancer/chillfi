import 'package:chillfi/core/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class ReviewSummaryCard extends StatelessWidget {
  const ReviewSummaryCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          // Left Section: Average Rating
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "4.5",
                  style: GoogleFonts.poppins(
                    fontSize: 48.sp,
                    fontWeight: FontWeight.w800,
                    color: AppColors.darkText,
                  ),
                ),
                Row(
                  children: List.generate(
                    5,
                    (index) => Icon(
                      index < 4 ? Icons.star_rounded : Icons.star_half_rounded,
                      color: Colors.orange,
                      size: 20.sp,
                    ),
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  "2,436 reviews",
                  style: GoogleFonts.poppins(
                    fontSize: 13.sp,
                    color: AppColors.greyText,
                  ),
                ),
                SizedBox(height: 12.h),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5E9),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.verified_rounded, color: Colors.green, size: 14.sp),
                      SizedBox(width: 4.w),
                      Text(
                        "Verified Purchases",
                        style: GoogleFonts.poppins(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w700,
                          color: Colors.green[700],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Vertical Divider
          Container(
            height: 100.h,
            width: 1,
            color: AppColors.lightGrey.withOpacity(0.5),
            margin: EdgeInsets.symmetric(horizontal: 20.w),
          ),

          // Right Section: Rating Breakdown
          Expanded(
            flex: 3,
            child: Column(
              children: [
                _buildRatingRow("5", 0.8, "1,542"),
                _buildRatingRow("4", 0.4, "623"),
                _buildRatingRow("3", 0.2, "162"),
                _buildRatingRow("2", 0.1, "56"),
                _buildRatingRow("1", 0.05, "53"),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingRow(String label, double progress, String count) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 11.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.darkText,
            ),
          ),
          SizedBox(width: 4.w),
          Icon(Icons.star_rounded, color: AppColors.greyText, size: 10.sp),
          SizedBox(width: 8.w),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: AppColors.lightGrey.withOpacity(0.3),
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.orange),
                minHeight: 6.h,
              ),
            ),
          ),
          SizedBox(width: 8.w),
          Text(
            count,
            style: GoogleFonts.poppins(
              fontSize: 10.sp,
              color: AppColors.greyText,
            ),
          ),
        ],
      ),
    );
  }
}
