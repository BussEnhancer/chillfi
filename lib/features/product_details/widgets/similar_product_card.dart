import 'package:chillfi/core/app_colors.dart';
import 'package:chillfi/features/product_details/widgets/components/product_card_components.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class SimilarProductCard extends StatelessWidget {
  final String title;
  final String variant;
  final String price;
  final String oldPrice;
  final String discount;
  final String savings;
  final double rating;
  final String reviews;
  final bool isWishlisted;

  const SimilarProductCard({
    super.key,
    required this.title,
    required this.variant,
    required this.price,
    required this.oldPrice,
    required this.discount,
    required this.savings,
    required this.rating,
    required this.reviews,
    this.isWishlisted = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 170.w,
      margin: EdgeInsets.only(right: 16.w, bottom: 10.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
        border: Border.all(color: AppColors.lightGrey.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Section: Image, Badge, Wishlist
          Stack(
            children: [
              Container(
                height: 130.h,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFFF9FAFB),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20.r),
                    topRight: Radius.circular(20.r),
                  ),
                ),
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.all(12.r),
                    child: Icon(
                      Icons.smartphone_rounded,
                      size: 60.sp,
                      color: AppColors.primaryOrange.withOpacity(0.2),
                    ),
                  ),
                ),
              ),
              // Discount Badge
              Positioned(
                top: 10.h,
                left: 10.w,
                child: DiscountBadge(discount: discount),
              ),
              // Wishlist Button
              Positioned(
                top: 10.h,
                right: 10.w,
                child: WishlistButton(isSelected: isWishlisted),
              ),
            ],
          ),

          // Details Section
          Padding(
            padding: EdgeInsets.all(12.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF111827),
                  ),
                  maxLines: 2,
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
                // Ratings
                RatingWidget(rating: rating, reviews: reviews),
                SizedBox(height: 10.h),
                // Pricing
                Row(
                  children: [
                    Text(
                      '₹$price',
                      style: GoogleFonts.poppins(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF111827),
                      ),
                    ),
                    SizedBox(width: 6.w),
                    Text(
                      '₹$oldPrice',
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: AppColors.greyText,
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 4.h),
                // Savings & Add to Cart
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "You Save ₹$savings",
                      style: GoogleFonts.poppins(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF22C55E), // Success Green
                      ),
                    ),
                    const AddToCartButton(),
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
