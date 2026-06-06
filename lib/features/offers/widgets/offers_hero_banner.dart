import 'package:chillfi/core/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class OffersHeroBanner extends StatelessWidget {
  const OffersHeroBanner({super.key});

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
            color: AppColors.secondaryPurple.withOpacity(0.05),
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
                      Text(
                        "Exciting Offers",
                        style: GoogleFonts.poppins(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.darkText,
                        ),
                      ),
                      Text(
                        "You Don't Want to Miss!",
                        style: GoogleFonts.poppins(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w800,
                          color: AppColors.secondaryPurple,
                        ),
                      ),
                      SizedBox(height: 6.h),
                      Text(
                        "Grab the best deals on top products.",
                        style: GoogleFonts.poppins(
                          fontSize: 11.sp,
                          color: AppColors.greyText,
                        ),
                      ),
                      const Spacer(),
                      Row(
                        children: [
                          _buildMiniBadge(Icons.verified_user_rounded, "Best Prices"),
                          SizedBox(width: 8.w),
                          _buildMiniBadge(Icons.check_circle_rounded, "Original"),
                        ],
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Icon(Icons.shopping_bag_rounded, size: 80.sp, color: AppColors.secondaryPurple.withOpacity(0.7)),
                      Positioned(
                        top: 20.h,
                        right: 0,
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                          decoration: BoxDecoration(
                            color: Colors.orange,
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: Text(
                            "BIG\nSAVINGS",
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.white, fontSize: 8.sp, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 20.h,
                        left: 0,
                        child: Icon(Icons.card_giftcard_rounded, color: AppColors.secondaryPurple.withOpacity(0.5), size: 30.sp),
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

  Widget _buildMiniBadge(IconData icon, String label) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6.r),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 4),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.secondaryPurple, size: 12.sp),
          SizedBox(width: 4.w),
          Text(label, style: GoogleFonts.poppins(fontSize: 8.sp, fontWeight: FontWeight.w600)),
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
        color: isActive ? AppColors.secondaryPurple : AppColors.secondaryPurple.withOpacity(0.2),
        borderRadius: BorderRadius.circular(2.r),
      ),
    );
  }
}
