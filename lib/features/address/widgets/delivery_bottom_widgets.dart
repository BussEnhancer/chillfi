import 'package:chillfi/core/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class DeliveryInfoCard extends StatelessWidget {
  const DeliveryInfoCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: const Color(0xFFF9F5FF),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8.r),
            decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
            child: Icon(Icons.location_on_rounded, color: AppColors.secondaryPurple, size: 16.sp),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Deliver to 226010",
                  style: GoogleFonts.poppins(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.darkText,
                  ),
                ),
                Text(
                  "Delivery in 24 - 48 hours",
                  style: GoogleFonts.poppins(
                    fontSize: 10.sp,
                    color: AppColors.greyText,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () {},
            child: Row(
              children: [
                Text(
                  "Change Pincode",
                  style: GoogleFonts.poppins(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.secondaryPurple,
                  ),
                ),
                Icon(Icons.chevron_right_rounded, color: AppColors.secondaryPurple, size: 18.sp),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class SecureDeliveryCard extends StatelessWidget {
  const SecureDeliveryCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 16.h),
      child: Row(
        children: [
          Icon(Icons.verified_user_outlined, color: Colors.green, size: 20.sp),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "100% Safe & Secure Delivery",
                  style: GoogleFonts.poppins(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.green[800],
                  ),
                ),
                Text(
                  "Your location is safe with us",
                  style: GoogleFonts.poppins(
                    fontSize: 9.sp,
                    color: Colors.green[700],
                  ),
                ),
              ],
            ),
          ),
          Text(
            "Learn More",
            style: GoogleFonts.poppins(
              fontSize: 11.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.secondaryPurple,
            ),
          ),
          Icon(Icons.chevron_right_rounded, color: AppColors.secondaryPurple, size: 18.sp),
        ],
      ),
    );
  }
}
