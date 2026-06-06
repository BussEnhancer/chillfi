import 'package:chillfi/core/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class SubCategoryBanner extends StatelessWidget {
  const SubCategoryBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 150.h,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFFFAF5FF),
            const Color(0xFFF3E8FF),
          ],
        ),
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
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
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Latest Smartphones',
                        style: GoogleFonts.poppins(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.darkText,
                        ),
                      ),
                      Text(
                        'Top Brands | Best Prices',
                        style: GoogleFonts.poppins(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.secondaryPurple,
                        ),
                      ),
                      SizedBox(height: 6.h),
                      Text(
                        'Up to 40% OFF on Premium Smartphones',
                        style: GoogleFonts.poppins(
                          fontSize: 10.sp,
                          color: AppColors.greyText,
                        ),
                      ),
                      SizedBox(height: 12.h),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                        decoration: BoxDecoration(
                          gradient: AppColors.purpleGradient,
                          borderRadius: BorderRadius.circular(20.r),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Shop Now',
                              style: GoogleFonts.poppins(
                                fontSize: 11.sp,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(width: 4.w),
                            Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 12.sp),
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
                      Icon(Icons.smartphone_rounded, size: 80.sp, color: AppColors.secondaryPurple.withOpacity(0.1)),
                      Positioned(
                        right: 0,
                        child: Icon(Icons.phone_iphone_rounded, size: 60.sp, color: AppColors.primaryOrange.withOpacity(0.8)),
                      ),
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
                _buildIndicator(true),
                _buildIndicator(false),
                _buildIndicator(false),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIndicator(bool isActive) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 2.w),
      width: isActive ? 12.w : 4.w,
      height: 4.h,
      decoration: BoxDecoration(
        color: isActive ? AppColors.secondaryPurple : AppColors.secondaryPurple.withOpacity(0.2),
        borderRadius: BorderRadius.circular(2.r),
      ),
    );
  }
}
