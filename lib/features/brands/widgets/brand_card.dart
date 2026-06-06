import 'package:chillfi/core/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class BrandCard extends StatelessWidget {
  final String name;
  final IconData logo;
  final String productCount;

  const BrandCard({
    super.key,
    required this.name,
    required this.logo,
    required this.productCount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10.w),
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
        border: Border.all(color: AppColors.lightGrey.withOpacity(0.4)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: Container(
              padding: EdgeInsets.all(8.r),
              decoration: BoxDecoration(
                color: const Color(0xFFF8F8F8),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(logo, size: 30.sp, color: AppColors.darkText),
            ),
          ),
          SizedBox(height: 8.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: Text(
                  name,
                  style: GoogleFonts.poppins(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.darkText,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(width: 4.w),
              Icon(Icons.verified_rounded, color: AppColors.secondaryPurple, size: 12.sp),
            ],
          ),
          SizedBox(height: 2.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                productCount,
                style: GoogleFonts.poppins(
                  fontSize: 9.sp,
                  color: AppColors.greyText,
                ),
              ),
              SizedBox(width: 2.w),
              Icon(Icons.chevron_right_rounded, size: 10.sp, color: AppColors.lightGrey),
            ],
          ),
        ],
      ),
    );
  }
}
