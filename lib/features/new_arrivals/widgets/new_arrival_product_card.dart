import 'package:chillfi/core/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class NewArrivalProductCard extends StatelessWidget {
  final String title;
  final String variant;
  final String price;
  final double rating;
  final String reviews;

  const NewArrivalProductCard({
    super.key,
    required this.title,
    required this.variant,
    required this.price,
    required this.rating,
    required this.reviews,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: AppColors.lightGrey.withOpacity(0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              Container(
                height: 120.h,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFFF8F8F8),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16.r),
                    topRight: Radius.circular(16.r),
                  ),
                ),
                child: Center(
                  child: Icon(Icons.shopping_bag_rounded, size: 50.sp, color: Colors.grey[300]),
                ),
              ),
              Positioned(
                top: 8.h,
                left: 8.w,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: AppColors.secondaryPurple,
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                  child: Text(
                    'NEW',
                    style: TextStyle(color: Colors.white, fontSize: 8.sp, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              Positioned(
                top: 8.h,
                right: 8.w,
                child: Icon(Icons.favorite_outline_rounded, color: AppColors.greyText, size: 18.sp),
              ),
            ],
          ),
          Padding(
            padding: EdgeInsets.all(10.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.darkText,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  variant,
                  style: GoogleFonts.poppins(
                    fontSize: 10.sp,
                    color: AppColors.greyText,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 6.h),
                Row(
                  children: [
                    Icon(Icons.star_rounded, color: Colors.orange, size: 12.sp),
                    SizedBox(width: 2.w),
                    Text(
                      '$rating ($reviews)',
                      style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.w500, color: AppColors.greyText),
                    ),
                  ],
                ),
                SizedBox(height: 8.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '₹$price',
                      style: GoogleFonts.poppins(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.darkText,
                      ),
                    ),
                    Container(
                      width: 32.r,
                      height: 32.r,
                      decoration: BoxDecoration(
                        color: AppColors.secondaryPurple,
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      child: Icon(Icons.add_shopping_cart_rounded, color: Colors.white, size: 16.sp),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
