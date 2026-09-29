import 'package:chillfi/core/app_colors.dart';
import 'package:chillfi/features/product_details/product_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class ProductListingCard extends StatelessWidget {
  final String? id;
  final String title;
  final String variant;
  final String price;
  final String oldPrice;
  final String discount;
  final String savings;
  final double rating;
  final String reviews;
  final String? imageUrl;
  final bool isWishlisted;
  final VoidCallback? onWishlistToggle;
  final VoidCallback? onAddToCart;
  final bool inStock;
  final bool isInCart;

  const ProductListingCard({
    super.key,
    this.id,
    required this.title,
    required this.variant,
    required this.price,
    required this.oldPrice,
    required this.discount,
    required this.savings,
    required this.rating,
    required this.reviews,
    this.imageUrl,
    this.isWishlisted = false,
    this.onWishlistToggle,
    this.onAddToCart,
    this.inStock = true,
    this.isInCart = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ProductDetailsScreen(productId: id)),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(color: AppColors.lightGrey.withValues(alpha: 0.4)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Area
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
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(16.r),
                      topRight: Radius.circular(16.r),
                    ),
                    child: imageUrl != null && imageUrl!.isNotEmpty
                        ? Image.network(
                            imageUrl!,
                            height: 120.h,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (c, e, s) => Center(child: Icon(Icons.shopping_bag_rounded, size: 50.sp, color: Colors.grey[300])),
                          )
                        : Center(child: Icon(Icons.shopping_bag_rounded, size: 50.sp, color: Colors.grey[300])),
                  ),
                ),
                if (!inStock)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.55),
                        borderRadius: BorderRadius.only(topLeft: Radius.circular(16.r), topRight: Radius.circular(16.r)),
                      ),
                      alignment: Alignment.center,
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                        decoration: BoxDecoration(color: AppColors.darkText, borderRadius: BorderRadius.circular(20.r)),
                        child: Text('Out of Stock', style: GoogleFonts.poppins(fontSize: 10.sp, fontWeight: FontWeight.w600, color: Colors.white)),
                      ),
                    ),
                  ),
                // Discount Badge
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
                // Wishlist Icon
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
            
            // Details Area
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
                      Icon(Icons.star_rounded, color: rating > 0 ? Colors.orange : AppColors.lightGrey, size: 12.sp),
                      SizedBox(width: 2.w),
                      Text(
                        rating > 0 ? '$rating ($reviews)' : 'No ratings yet',
                        style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.w500, color: AppColors.greyText),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  Row(
                    children: [
                      Text(
                        '₹$price',
                        style: GoogleFonts.poppins(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.darkText,
                        ),
                      ),
                      SizedBox(width: 6.w),
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
                  SizedBox(height: 4.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "You Save ₹$savings",
                        style: GoogleFonts.poppins(
                          fontSize: 9.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.green,
                        ),
                      ),
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: inStock ? onAddToCart : null,
                        child: Container(
                          width: 28.r,
                          height: 28.r,
                          decoration: BoxDecoration(
                            color: !inStock
                                ? AppColors.greyText.withValues(alpha: 0.35)
                                : isInCart
                                    ? Colors.green.shade600
                                    : AppColors.secondaryPurple,
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: Icon(
                            isInCart ? Icons.check_rounded : Icons.add_shopping_cart_rounded,
                            color: Colors.white,
                            size: 14.sp,
                          ),
                        ),
                      ),
                    ],
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
