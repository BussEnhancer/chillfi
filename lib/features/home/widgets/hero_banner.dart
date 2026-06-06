import 'package:chillfi/core/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class HeroBannerSlider extends StatelessWidget {
  const HeroBannerSlider({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 15.h),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            height: 180.h,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFFFBF4FF),
                  AppColors.secondaryPurple.withOpacity(0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24.r),
              border: Border.all(color: AppColors.secondaryPurple.withOpacity(0.1)),
            ),
            child: Stack(
              children: [
                // Text Content
                Padding(
                  padding: EdgeInsets.all(20.r),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                        decoration: BoxDecoration(
                          color: AppColors.secondaryPurple.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Text(
                          'FESTIVE SALE',
                          style: GoogleFonts.poppins(
                            fontSize: 8.sp,
                            fontWeight: FontWeight.w700,
                            color: AppColors.secondaryPurple,
                          ),
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        'Big Deals for\nSmart Shoppers!',
                        style: GoogleFonts.poppins(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.w800,
                          color: AppColors.darkText,
                          height: 1.2,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        'Up to 60% OFF on Electronics\n& Accessories',
                        style: GoogleFonts.poppins(
                          fontSize: 10.sp,
                          color: AppColors.greyText,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 16.h),
                      GestureDetector(
                        onTap: () {},
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                          decoration: BoxDecoration(
                            gradient: AppColors.buttonGradient,
                            borderRadius: BorderRadius.circular(12.r),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primaryOrange.withOpacity(0.3),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Shop Now',
                                style: GoogleFonts.poppins(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(width: 4.w),
                              Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 14.sp),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Product Image Mockup
                Positioned(
                  right: -20.w,
                  bottom: -10.h,
                  child: Opacity(
                    opacity: 0.9,
                    child: Icon(Icons.headphones_rounded, size: 150.sp, color: AppColors.darkText.withOpacity(0.1)),
                  ),
                ),
                Positioned(
                  right: 10.w,
                  bottom: 20.h,
                  child: _buildShoppingBag(),
                ),
              ],
            ),
          ),
          SizedBox(height: 12.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(3, (index) => Container(
              width: index == 0 ? 20.w : 6.w,
              height: 6.h,
              margin: EdgeInsets.symmetric(horizontal: 3.w),
              decoration: BoxDecoration(
                color: index == 0 ? AppColors.secondaryPurple : AppColors.secondaryPurple.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10.r),
              ),
            )),
          ),
        ],
      ),
    );
  }

  Widget _buildShoppingBag() {
    return Container(
      width: 60.w,
      height: 80.h,
      decoration: BoxDecoration(
        color: AppColors.primaryOrange,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryOrange.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_bag_rounded, color: Colors.white, size: 24.sp),
          SizedBox(height: 4.h),
          Text(
            'CHILLFI',
            style: GoogleFonts.poppins(
              fontSize: 8.sp,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }
}
