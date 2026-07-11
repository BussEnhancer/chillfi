import 'package:chillfi/core/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class MoreTrendingCard extends StatelessWidget {
  final String title;
  final String variant;
  final String price;
  final String oldPrice;
  final String discount;
  final double rating;
  final String reviews;
  final String? imageUrl;
  final VoidCallback? onTap;
  final bool isWishlisted;
  final VoidCallback? onWishlistToggle;
  final VoidCallback? onAddToCart;

  const MoreTrendingCard({
    super.key,
    required this.title,
    required this.variant,
    required this.price,
    required this.oldPrice,
    required this.discount,
    required this.rating,
    required this.reviews,
    this.imageUrl,
    this.onTap,
    this.isWishlisted = false,
    this.onWishlistToggle,
    this.onAddToCart,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
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
                child: ClipRRect(
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(16.r), topRight: Radius.circular(16.r)),
                  child: imageUrl != null && imageUrl!.isNotEmpty
                      ? Image.network(imageUrl!, height: 120.h, width: double.infinity, fit: BoxFit.cover,
                          errorBuilder: (c, e, s) => Center(child: Icon(Icons.shopping_bag_rounded, size: 50.sp, color: Colors.grey[300])))
                      : Center(child: Icon(Icons.shopping_bag_rounded, size: 50.sp, color: Colors.grey[300])),
                ),
              ),
              Positioned(
                top: 8.h,
                left: 8.w,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF5E5E),
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                  child: Text(
                    '-$discount',
                    style: TextStyle(color: Colors.white, fontSize: 8.sp, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              Positioned(
                top: 8.h,
                right: 8.w,
                child: GestureDetector(
                  onTap: onWishlistToggle,
                  child: Icon(
                    isWishlisted ? Icons.favorite_rounded : Icons.favorite_outline_rounded,
                    color: isWishlisted ? Colors.red : AppColors.greyText,
                    size: 18.sp,
                  ),
                ),
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
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '₹$price',
                          style: GoogleFonts.poppins(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w700,
                            color: AppColors.darkText,
                          ),
                        ),
                        Text(
                          '₹$oldPrice',
                          style: TextStyle(
                            fontSize: 10.sp,
                            color: AppColors.greyText,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                      ],
                    ),
                    GestureDetector(
                      onTap: onAddToCart,
                      child: Container(
                        width: 32.r,
                        height: 32.r,
                        decoration: BoxDecoration(
                          color: AppColors.secondaryPurple,
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        child: Icon(Icons.add_shopping_cart_rounded, color: Colors.white, size: 16.sp),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 4.h),
                Text(
                  "$discount OFF",
                  style: GoogleFonts.poppins(
                    fontSize: 9.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      ),
    );
  }
}
