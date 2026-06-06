import 'package:chillfi/core/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class CODStatusBanner extends StatelessWidget {
  const CODStatusBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.green.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.green.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8.r),
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.payments_rounded, color: Colors.green, size: 20.sp),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Cash on Delivery Selected",
                  style: GoogleFonts.poppins(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.green[800],
                  ),
                ),
                Text(
                  "Pay in cash when your order is delivered to your doorstep.",
                  style: GoogleFonts.poppins(
                    fontSize: 10.sp,
                    color: Colors.green[700],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class CODInfoCard extends StatelessWidget {
  const CODInfoCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.secondaryPurple.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.secondaryPurple.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.money_rounded, color: AppColors.secondaryPurple, size: 18.sp),
                    SizedBox(width: 8.w),
                    Text(
                      "Cash on Delivery",
                      style: GoogleFonts.poppins(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.darkText,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12.h),
                _buildBulletPoint("Pay in cash when your order is delivered."),
                _buildBulletPoint("Keep exact change ready for faster delivery."),
                _buildBulletPoint("Our delivery partner will collect the payment."),
              ],
            ),
          ),
          SizedBox(width: 12.w),
          Container(
            width: 80.w,
            height: 60.h,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                ),
              ],
            ),
            child: Icon(Icons.wallet_rounded, color: AppColors.secondaryPurple, size: 40.sp),
          ),
        ],
      ),
    );
  }

  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 6.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.check_circle_rounded, color: Colors.green, size: 14.sp),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.poppins(
                fontSize: 10.sp,
                color: AppColors.greyText,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
