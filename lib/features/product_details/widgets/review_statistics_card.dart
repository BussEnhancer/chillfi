import 'package:chillfi/core/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class ReviewStatisticsCard extends StatelessWidget {
  const ReviewStatisticsCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 10.w),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.lightGrey.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(Icons.rate_review_rounded, "2,436", "Total Reviews", Colors.purple),
          _buildStatItem(Icons.verified_user_rounded, "2,412", "Verified Buyers", Colors.green),
          _buildStatItem(Icons.recommend_rounded, "90%", "Recommend", Colors.blue),
          _buildStatItem(Icons.photo_library_rounded, "2,102", "With Photos", Colors.orange),
        ],
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String value, String label, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24.sp),
        SizedBox(height: 8.h),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 14.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.darkText,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 8.sp,
            color: AppColors.greyText,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
