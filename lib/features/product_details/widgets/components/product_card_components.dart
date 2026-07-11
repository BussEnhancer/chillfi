import 'package:chillfi/core/app_colors.dart';
import 'package:chillfi/features/product_listing/product_listing_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class DiscountBadge extends StatelessWidget {
  final String discount;
  const DiscountBadge({super.key, required this.discount});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: const Color(0xFFFF5A1F),
        borderRadius: BorderRadius.circular(6.r),
      ),
      child: Text(
        '-$discount',
        style: TextStyle(
          color: Colors.white,
          fontSize: 10.sp,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class WishlistButton extends StatelessWidget {
  final bool isSelected;
  final VoidCallback? onTap;
  const WishlistButton({super.key, this.isSelected = false, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(6.r),
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 6,
            ),
          ],
        ),
        child: Icon(
          isSelected ? Icons.favorite_rounded : Icons.favorite_border_rounded,
          color: isSelected ? AppColors.secondaryPurple : AppColors.greyText,
          size: 18.sp,
        ),
      ),
    );
  }
}

class RatingWidget extends StatelessWidget {
  final double rating;
  final String reviews;
  const RatingWidget({super.key, required this.rating, required this.reviews});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Row(
          children: List.generate(
            5,
            (index) => Icon(
              Icons.star_rounded,
              color: index < rating.floor() ? Colors.orange : Colors.grey[300],
              size: 14.sp,
            ),
          ),
        ),
        SizedBox(width: 4.w),
        Text(
          "$rating ($reviews)",
          style: GoogleFonts.poppins(
            fontSize: 10.sp,
            fontWeight: FontWeight.w500,
            color: AppColors.greyText,
          ),
        ),
      ],
    );
  }
}

class AddToCartButton extends StatelessWidget {
  final VoidCallback? onTap;
  const AddToCartButton({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 34.r,
        height: 34.r,
        decoration: BoxDecoration(
          color: AppColors.secondaryPurple,
          borderRadius: BorderRadius.circular(10.r),
          boxShadow: [
            BoxShadow(
              color: AppColors.secondaryPurple.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(Icons.add_shopping_cart_rounded, color: Colors.white, size: 18.sp),
      ),
    );
  }
}

class EmptyProductsWidget extends StatelessWidget {
  const EmptyProductsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off_rounded, size: 80.sp, color: AppColors.lightGrey),
          SizedBox(height: 16.h),
          Text(
            "No Similar Products Found",
            style: GoogleFonts.poppins(
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.darkText,
            ),
          ),
          Text(
            "Try exploring other categories",
            style: GoogleFonts.poppins(
              fontSize: 12.sp,
              color: AppColors.greyText,
            ),
          ),
          SizedBox(height: 20.h),
          ElevatedButton(
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProductListingScreen())),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.secondaryPurple,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
            ),
            child: const Text("Explore Products"),
          ),
        ],
      ),
    );
  }
}

class ShimmerProductCard extends StatelessWidget {
  const ShimmerProductCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 170.w,
      margin: EdgeInsets.only(right: 16.w, bottom: 10.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: AppColors.lightGrey.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 130.h,
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.lightBackground,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(12.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(height: 14.h, width: 100.w, color: AppColors.lightBackground),
                SizedBox(height: 8.h),
                Container(height: 10.h, width: 60.w, color: AppColors.lightBackground),
                SizedBox(height: 12.h),
                Container(height: 16.h, width: 80.w, color: AppColors.lightBackground),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
