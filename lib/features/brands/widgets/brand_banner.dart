import 'package:chillfi/core/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class BrandBanner extends StatelessWidget {
  const BrandBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFF9F5FF),
            Color(0xFFF3E8FF),
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
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10.r),
            decoration: BoxDecoration(
              color: AppColors.secondaryPurple.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.verified_user_rounded, color: AppColors.secondaryPurple, size: 24.sp),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    style: GoogleFonts.poppins(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.darkText,
                    ),
                    children: [
                      const TextSpan(text: "Top Brands, "),
                      TextSpan(
                        text: "Best Quality",
                        style: TextStyle(color: AppColors.secondaryPurple),
                      ),
                    ],
                  ),
                ),
                Text(
                  "100% Original products from trusted brands",
                  style: GoogleFonts.poppins(
                    fontSize: 10.sp,
                    color: AppColors.greyText,
                  ),
                ),
              ],
            ),
          ),
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 50.r,
                height: 50.r,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
              ),
              Icon(Icons.shopping_bag_rounded, color: AppColors.secondaryPurple.withOpacity(0.8), size: 30.sp),
              Positioned(
                top: 10.h,
                right: 10.w,
                child: Icon(Icons.star_rounded, color: Colors.amber, size: 12.sp),
              )
            ],
          ),
        ],
      ),
    );
  }
}
