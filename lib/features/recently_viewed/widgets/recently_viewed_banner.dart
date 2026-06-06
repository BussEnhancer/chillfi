import 'package:chillfi/core/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class RecentlyViewedBanner extends StatelessWidget {
  const RecentlyViewedBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 120.h,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFFF9F5FF),
            const Color(0xFFF3E8FF),
          ],
        ),
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.secondaryPurple.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(10.r),
                  decoration: BoxDecoration(
                    color: AppColors.secondaryPurple.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.history_rounded, color: AppColors.secondaryPurple, size: 24.sp),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Keep exploring!",
                        style: GoogleFonts.poppins(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.darkText,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        "Items you viewed are saved here for your convenience.",
                        style: GoogleFonts.poppins(
                          fontSize: 10.sp,
                          color: AppColors.greyText,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 80.w), // Space for illustration
              ],
            ),
          ),
          Positioned(
            right: 10.w,
            bottom: 0,
            child: Stack(
              alignment: Alignment.bottomRight,
              children: [
                Icon(Icons.shopping_bag_rounded, size: 80.sp, color: AppColors.secondaryPurple.withOpacity(0.8)),
                Positioned(
                  left: 0,
                  bottom: 10.h,
                  child: Icon(Icons.park_rounded, size: 20.sp, color: Colors.green.withOpacity(0.6)),
                ),
                Positioned(
                  top: 10.h,
                  right: 10.w,
                  child: Icon(Icons.history_rounded, size: 24.sp, color: Colors.white.withOpacity(0.5)),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
