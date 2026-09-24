import 'package:chillfi/core/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class TrendingHeroBanner extends StatelessWidget {
  const TrendingHeroBanner({super.key});

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
          // Decorative floating particles (simplified as Icons for the UI task)
          Positioned(
            top: 20.h,
            right: 40.w,
            child: Icon(Icons.star_rounded, color: Colors.white.withValues(alpha: 0.5), size: 12.sp),
          ),
          Positioned(
            bottom: 30.h,
            right: 80.w,
            child: Icon(Icons.circle, color: Colors.white.withValues(alpha: 0.3), size: 8.sp),
          ),
          
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
                      Text(
                        "Hot Right Now!",
                        style: GoogleFonts.poppins(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.w800,
                          color: AppColors.secondaryPurple,
                        ),
                      ),
                      Text(
                        "Top picks loved by everyone",
                        style: GoogleFonts.poppins(
                          fontSize: 12.sp,
                          color: AppColors.greyText,
                        ),
                      ),
                      SizedBox(height: 16.h),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _buildMiniCard(Icons.trending_up_rounded, "Most Popular", Colors.purple),
                            SizedBox(width: 8.w),
                            _buildMiniCard(Icons.favorite_rounded, "Most Loved", Colors.orange),
                            SizedBox(width: 8.w),
                            _buildMiniCard(Icons.bolt_rounded, "Hot Selling", Colors.blue),
                          ],
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
                      // Large growth icon/bag illustration placeholder
                      Icon(
                        Icons.shopping_bag_rounded,
                        size: 90.sp,
                        color: AppColors.secondaryPurple.withValues(alpha: 0.8),
                      ),
                      Positioned(
                        top: 20.h,
                        right: 0,
                        child: Container(
                          padding: EdgeInsets.all(8.r),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(color: Colors.black12, blurRadius: 10),
                            ],
                          ),
                          child: Icon(Icons.show_chart_rounded, color: Colors.green, size: 20.sp),
                        ),
                      ),
                      Positioned(
                        bottom: 10.h,
                        left: 0,
                        child: Container(
                          padding: EdgeInsets.all(6.r),
                          decoration: BoxDecoration(
                            color: Colors.orange,
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: Icon(Icons.whatshot_rounded, color: Colors.white, size: 16.sp),
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniCard(IconData icon, String label, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.r),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 5),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 14.sp),
          SizedBox(width: 4.w),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 9.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.darkText,
            ),
          ),
        ],
      ),
    );
  }
}
