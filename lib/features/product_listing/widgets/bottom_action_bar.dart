import 'package:chillfi/core/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class BottomActionBar extends StatelessWidget {
  const BottomActionBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 0.8.sw,
      height: 54.h,
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
        border: Border.all(color: AppColors.lightGrey.withOpacity(0.5)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildItem(Icons.swap_vert_rounded, "Sort"),
          Container(height: 24.h, width: 1, color: AppColors.lightGrey),
          _buildFilterItem("Filter", 2),
          Container(height: 24.h, width: 1, color: AppColors.lightGrey),
          _buildItem(Icons.grid_view_rounded, "Grid"),
        ],
      ),
    );
  }

  Widget _buildItem(IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, size: 20.sp, color: AppColors.darkText),
        SizedBox(width: 8.w),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 13.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.darkText,
          ),
        ),
      ],
    );
  }

  Widget _buildFilterItem(String label, int badgeCount) {
    return Row(
      children: [
        Icon(Icons.tune_rounded, size: 20.sp, color: AppColors.darkText),
        SizedBox(width: 8.w),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 13.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.darkText,
          ),
        ),
        SizedBox(width: 6.w),
        Container(
          padding: EdgeInsets.all(4.r),
          decoration: const BoxDecoration(
            color: AppColors.secondaryPurple,
            shape: BoxShape.circle,
          ),
          child: Text(
            badgeCount.toString(),
            style: TextStyle(color: Colors.white, fontSize: 8.sp, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}
