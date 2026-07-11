import 'package:chillfi/core/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class CategoryBannerWidget extends StatelessWidget {
  const CategoryBannerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 160.h,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFFF3E8FF),
            const Color(0xFFE9D5FF),
          ],
        ),
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.secondaryPurple.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Decorative circles
          Positioned(
            right: -20.w,
            top: -20.h,
            child: Container(
              width: 100.r,
              height: 100.r,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
            ),
          ),
          
          Padding(
            padding: EdgeInsets.all(20.w),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Explore',
                          style: GoogleFonts.poppins(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w700,
                            color: AppColors.darkText,
                          ),
                        ),
                        Text(
                          'Top Categories',
                          style: GoogleFonts.poppins(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w700,
                            color: AppColors.secondaryPurple,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          'Find everything you need in one place.',
                          style: GoogleFonts.poppins(
                            fontSize: 11.sp,
                            color: AppColors.greyText,
                          ),
                        ),
                        SizedBox(height: 12.h),
                        Row(
                          children: [
                            _buildIndicator(true),
                            _buildIndicator(false),
                            _buildIndicator(false),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Representative icons/images
                      Icon(
                        Icons.shopping_bag_rounded,
                        size: 80.sp,
                        color: AppColors.secondaryPurple.withOpacity(0.8),
                      ),
                      Positioned(
                        right: 0,
                        bottom: 10.h,
                        child: Icon(
                          Icons.headphones_rounded,
                          size: 40.sp,
                          color: AppColors.primaryOrange,
                        ),
                      ),
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

  Widget _buildIndicator(bool isActive) {
    return Container(
      margin: EdgeInsets.only(right: 4.w),
      width: isActive ? 15.w : 6.w,
      height: 6.h,
      decoration: BoxDecoration(
        color: isActive ? AppColors.secondaryPurple : AppColors.secondaryPurple.withOpacity(0.2),
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }
}
