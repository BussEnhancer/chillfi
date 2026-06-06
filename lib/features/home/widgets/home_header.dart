import 'package:chillfi/core/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // 1. DELIVERY LOCATION
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.r),
                decoration: BoxDecoration(
                  color: AppColors.primaryOrange.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.location_on_rounded, color: AppColors.primaryOrange, size: 18.sp),
              ),
              SizedBox(width: 8.w),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Deliver to',
                    style: GoogleFonts.poppins(
                      fontSize: 10.sp,
                      color: AppColors.greyText,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Row(
                    children: [
                      Text(
                        'Home - 123456',
                        style: GoogleFonts.poppins(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.darkText,
                        ),
                      ),
                      Icon(Icons.keyboard_arrow_down_rounded, size: 16.sp, color: AppColors.darkText),
                    ],
                  ),
                ],
              ),
            ],
          ),

          // 2. LOGO
          Image.asset(
            'assets/images/logo.png',
            width: 70.w,
            height: 35.h,
            fit: BoxFit.contain,
          ),

          // 3. ACTIONS
          Row(
            children: [
              _buildBadgeIcon(Icons.notifications_none_rounded, 3),
              SizedBox(width: 12.w),
              _buildBadgeIcon(Icons.shopping_cart_outlined, 2),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBadgeIcon(IconData icon, int count) {
    return Stack(
      alignment: Alignment.topRight,
      children: [
        Container(
          padding: EdgeInsets.all(8.r),
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Icon(icon, color: AppColors.darkText, size: 22.sp),
        ),
        Positioned(
          top: 0,
          right: 0,
          child: Container(
            padding: EdgeInsets.all(4.r),
            decoration: const BoxDecoration(
              color: AppColors.secondaryPurple,
              shape: BoxShape.circle,
            ),
            child: Text(
              count.toString(),
              style: TextStyle(
                color: Colors.white,
                fontSize: 8.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
