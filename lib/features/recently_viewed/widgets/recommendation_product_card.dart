import 'package:chillfi/core/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class RecommendationProductCard extends StatelessWidget {
  final String title;
  final String price;
  final double rating;

  const RecommendationProductCard({
    super.key,
    required this.title,
    required this.price,
    required this.rating,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 140.w,
      margin: EdgeInsets.only(right: 12.w),
      padding: EdgeInsets.all(10.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.lightGrey.withOpacity(0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              Container(
                height: 100.h,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFFF8F8F8),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Center(
                  child: Icon(Icons.shopping_bag_rounded, size: 40.sp, color: Colors.grey[300]),
                ),
              ),
              Positioned(
                top: 4.h,
                right: 4.w,
                child: Icon(Icons.favorite_outline_rounded, color: AppColors.greyText, size: 16.sp),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 11.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.darkText,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 4.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '₹$price',
                    style: GoogleFonts.poppins(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.darkText,
                    ),
                  ),
                  Row(
                    children: [
                      Icon(Icons.star_rounded, color: Colors.orange, size: 10.sp),
                      SizedBox(width: 2.w),
                      Text(
                        rating.toString(),
                        style: TextStyle(fontSize: 9.sp, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                width: 28.r,
                height: 28.r,
                decoration: BoxDecoration(
                  color: AppColors.secondaryPurple,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(Icons.add_shopping_cart_rounded, color: Colors.white, size: 14.sp),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
