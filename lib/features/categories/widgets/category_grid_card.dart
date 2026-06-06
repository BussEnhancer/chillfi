import 'package:chillfi/core/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class CategoryGridCard extends StatelessWidget {
  final String title;
  final String itemCount;
  final IconData icon;

  const CategoryGridCard({
    super.key,
    required this.title,
    required this.itemCount,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: AppColors.lightGrey.withOpacity(0.5)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(12.r),
            decoration: BoxDecoration(
              color: AppColors.primaryOrange.withOpacity(0.05),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 24.sp,
              color: AppColors.primaryOrange,
            ),
          ),
          SizedBox(height: 10.h),
          Text(
            title,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 11.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.darkText,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 4.h),
          Text(
            itemCount,
            style: GoogleFonts.poppins(
              fontSize: 9.sp,
              color: AppColors.greyText,
            ),
          ),
        ],
      ),
    );
  }
}
