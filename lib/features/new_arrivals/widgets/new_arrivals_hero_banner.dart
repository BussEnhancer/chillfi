import 'package:chillfi/core/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class NewArrivalsHeroBanner extends StatelessWidget {
  const NewArrivalsHeroBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 180.h,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFF9F5FF),
            Color(0xFFE9D5FF),
          ],
        ),
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.secondaryPurple.withValues(alpha: 0.05),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                        decoration: BoxDecoration(
                          color: AppColors.secondaryPurple,
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                        child: Text(
                          "NEW",
                          style: TextStyle(color: Colors.white, fontSize: 8.sp, fontWeight: FontWeight.bold),
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        "New Arrivals\nJust Landed!",
                        style: GoogleFonts.poppins(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.w800,
                          color: AppColors.secondaryPurple,
                          height: 1.2,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        "Discover the latest products added to our store.",
                        style: GoogleFonts.poppins(
                          fontSize: 11.sp,
                          color: AppColors.greyText,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Icon(Icons.shopping_bag_rounded, size: 90.sp, color: AppColors.secondaryPurple.withValues(alpha: 0.8)),
                      Positioned(
                        top: 20.h,
                        right: 0,
                        child: Icon(Icons.headphones_rounded, color: AppColors.primaryOrange.withValues(alpha: 0.9), size: 40.sp),
                      ),
                      Positioned(
                        bottom: 10.h,
                        left: 0,
                        child: Icon(Icons.watch_rounded, color: AppColors.secondaryPurple, size: 30.sp),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 12.h,
            left: 20.w,
            child: Row(
              children: [
                _buildDot(true),
                _buildDot(false),
                _buildDot(false),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDot(bool isActive) {
    return Container(
      margin: EdgeInsets.only(right: 4.w),
      width: isActive ? 15.w : 6.w,
      height: 4.h,
      decoration: BoxDecoration(
        color: isActive ? AppColors.secondaryPurple : AppColors.secondaryPurple.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }
}
