import 'package:chillfi/core/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class RecentlyViewedProductCard extends StatelessWidget {
  final String title;
  final String variant;
  final String price;
  final double rating;
  final String reviews;
  final String timestamp;
  final String? imageUrl;
  final VoidCallback? onTap;
  final VoidCallback? onRemove;
  final VoidCallback? onAddToCart;

  const RecentlyViewedProductCard({
    super.key,
    required this.title,
    required this.variant,
    required this.price,
    required this.rating,
    required this.reviews,
    this.timestamp = '',
    this.imageUrl,
    this.onTap,
    this.onRemove,
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
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: SizedBox(
          width: 160.w, // Provide a stable width for scaling
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
                    child: imageUrl != null && imageUrl!.isNotEmpty
                        ? ClipRRect(
                            borderRadius: BorderRadius.only(topLeft: Radius.circular(16.r), topRight: Radius.circular(16.r)),
                            child: Image.network(imageUrl!, fit: BoxFit.cover, width: double.infinity, height: 120.h,
                                errorBuilder: (_, _, _) => Center(child: Icon(Icons.shopping_bag_rounded, size: 50.sp, color: Colors.grey[300]))),
                          )
                        : Center(
                            child: Icon(Icons.shopping_bag_rounded, size: 50.sp, color: Colors.grey[300]),
                          ),
                  ),
                  Positioned(
                    top: 8.h,
                    right: 8.w,
                    child: GestureDetector(
                      onTap: onRemove,
                      child: Container(
                        padding: EdgeInsets.all(4.r),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(color: Colors.black12, blurRadius: 4),
                          ],
                        ),
                        child: Icon(Icons.close_rounded, size: 14.sp, color: AppColors.greyText),
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
                        Text(
                          '₹$price',
                          style: GoogleFonts.poppins(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w700,
                            color: AppColors.darkText,
                          ),
                        ),
                        const Spacer(),
                        GestureDetector(
                          onTap: onAddToCart,
                          child: Container(
                            width: 28.r,
                            height: 28.r,
                            decoration: BoxDecoration(
                              color: AppColors.secondaryPurple,
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            child: Icon(Icons.add_shopping_cart_rounded, color: Colors.white, size: 14.sp),
                          ),
                        ),
                      ],
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
                    if (timestamp.isNotEmpty) ...[
                      SizedBox(height: 8.h),
                      Text(
                        timestamp,
                        style: GoogleFonts.poppins(
                          fontSize: 9.sp,
                          color: AppColors.greyText.withOpacity(0.8),
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      ),
    );
  }
}
