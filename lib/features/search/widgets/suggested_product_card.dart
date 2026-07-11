import 'package:chillfi/core/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class SuggestedProductCard extends StatelessWidget {
  final String title;
  final String variant;
  final double rating;
  final String reviewCount;
  final String currentPrice;
  final String oldPrice;
  final String discount;
  final String imageUrl;

  const SuggestedProductCard({
    super.key,
    required this.title,
    required this.variant,
    required this.rating,
    required this.reviewCount,
    required this.currentPrice,
    required this.oldPrice,
    required this.discount,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product Image Placeholder
          Container(
            width: 100.w,
            height: 100.h,
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(Icons.smartphone_rounded, size: 50.sp, color: Colors.grey[300]),
          ),
          SizedBox(width: 16.w),
          // Product Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.darkText,
                  ),
                ),
                Text(
                  variant,
                  style: GoogleFonts.poppins(
                    fontSize: 12.sp,
                    color: AppColors.greyText,
                  ),
                ),
                SizedBox(height: 6.h),
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: List.generate(
                        5,
                        (index) => Icon(
                          index < rating.floor() ? Icons.star_rounded : Icons.star_outline_rounded,
                          color: Colors.orange,
                          size: 16.sp,
                        ),
                      ),
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      '$rating ($reviewCount)',
                      style: GoogleFonts.poppins(
                        fontSize: 11.sp,
                        color: AppColors.greyText,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8.h),
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 6.w,
                  children: [
                    Text(
                      '₹$currentPrice',
                      style: GoogleFonts.poppins(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.darkText,
                      ),
                    ),
                    Text(
                      '₹$oldPrice',
                      style: GoogleFonts.poppins(
                        fontSize: 12.sp,
                        decoration: TextDecoration.lineThrough,
                        color: AppColors.greyText,
                      ),
                    ),
                    Text(
                      '$discount OFF',
                      style: GoogleFonts.poppins(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Add to Cart Button
          Container(
            width: 36.w,
            height: 36.h,
            decoration: BoxDecoration(
              color: AppColors.secondaryPurple,
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(Icons.shopping_cart_outlined, color: Colors.white, size: 18.sp),
          ),
        ],
      ),
    );
  }
}
