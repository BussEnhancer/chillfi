import 'package:chillfi/core/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class ContinueExploringCard extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;

  const ContinueExploringCard({
    super.key,
    required this.label,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80.w,
      margin: EdgeInsets.only(right: 12.w),
      padding: EdgeInsets.symmetric(vertical: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.lightGrey.withOpacity(0.5)),
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(8.r),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 24.sp, color: color),
          ),
          SizedBox(height: 8.h),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 10.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.darkText,
            ),
          ),
        ],
      ),
    );
  }
}
