import 'package:chillfi/core/app_colors.dart';
import 'package:chillfi/features/cart/apply_coupon_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class CartPromotionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color bgColor;
  final Color iconColor;
  final bool isCoupon;

  const CartPromotionCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.bgColor,
    required this.iconColor,
    this.isCoupon = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (isCoupon) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ApplyCouponScreen()),
          );
        }
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(10.r),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Icon(icon, color: iconColor, size: 20.sp),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.darkText,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: GoogleFonts.poppins(
                      fontSize: 11.sp,
                      color: AppColors.greyText,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: AppColors.greyText, size: 24.sp),
          ],
        ),
      ),
    );
  }
}
