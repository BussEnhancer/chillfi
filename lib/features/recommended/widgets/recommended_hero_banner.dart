import 'package:chillfi/core/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class RecommendedHeroBanner extends StatelessWidget {
  const RecommendedHeroBanner({super.key});

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
            padding: EdgeInsets.all(20.w),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "We think you'll love these!",
                        style: GoogleFonts.poppins(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.w800,
                          color: AppColors.secondaryPurple,
                          height: 1.2,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        "Based on your views, likes and recent activity.",
                        style: GoogleFonts.poppins(
                          fontSize: 12.sp,
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
                      Icon(Icons.shopping_bag_rounded, size: 100.sp, color: AppColors.secondaryPurple.withValues(alpha: 0.8)),
                      Positioned(
                        child: Icon(Icons.favorite_rounded, color: Colors.white, size: 40.sp),
                      ),
                      Positioned(
                        top: 10.h,
                        right: 0,
                        child: Icon(Icons.star_rounded, color: Colors.amber, size: 24.sp),
                      ),
                      Positioned(
                        bottom: 10.h,
                        left: 0,
                        child: Icon(Icons.park_rounded, color: Colors.green.withValues(alpha: 0.6), size: 24.sp),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 12.h,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
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
      margin: EdgeInsets.symmetric(horizontal: 2.w),
      width: isActive ? 12.w : 4.w,
      height: 4.h,
      decoration: BoxDecoration(
        color: isActive ? AppColors.secondaryPurple : AppColors.secondaryPurple.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(2.r),
      ),
    );
  }
}
