import 'package:chillfi/core/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class CartItemCard extends StatelessWidget {
  final String image;
  final String name;
  final String variant;
  final String storage;
  final String price;
  final String oldPrice;
  final String discount;
  final String savings;
  final String deliveryDate;

  const CartItemCard({
    super.key,
    required this.image,
    required this.name,
    required this.variant,
    required this.storage,
    required this.price,
    required this.oldPrice,
    required this.discount,
    required this.savings,
    required this.deliveryDate,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
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
        children: [
          Padding(
            padding: EdgeInsets.all(12.w),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product Image
                Container(
                  width: 90.w,
                  height: 90.w,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8F8F8),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Center(
                    child: Icon(Icons.smartphone_rounded, size: 50.sp, color: Colors.grey[300]),
                  ),
                ),
                SizedBox(width: 12.w),
                // Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              name,
                              style: GoogleFonts.poppins(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w700,
                                color: AppColors.darkText,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Icon(Icons.delete_outline_rounded, size: 18.sp, color: AppColors.greyText),
                        ],
                      ),
                      Text(
                        "$variant  •  $storage",
                        style: GoogleFonts.poppins(
                          fontSize: 11.sp,
                          color: AppColors.greyText,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Row(
                        children: [
                          Text(
                            "₹$price",
                            style: GoogleFonts.poppins(
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w700,
                              color: AppColors.darkText,
                            ),
                          ),
                          SizedBox(width: 6.w),
                          Text(
                            "₹$oldPrice",
                            style: TextStyle(
                              fontSize: 11.sp,
                              color: AppColors.greyText,
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                          SizedBox(width: 8.w),
                          Text(
                            "$discount OFF",
                            style: GoogleFonts.poppins(
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w700,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        "You Save ₹$savings",
                        style: GoogleFonts.poppins(
                          fontSize: 10.sp,
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
          
          // Stepper and Quick Actions
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildActionItem(Icons.delete_outline_rounded, "Remove"),
                _buildActionItem(Icons.favorite_border_rounded, "Move to Wishlist"),
                _buildActionItem(Icons.bookmark_border_rounded, "Save for Later"),
                _buildQuantityStepper(),
              ],
            ),
          ),
          
          // Delivery Strip
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F8E9),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(16.r),
                bottomRight: Radius.circular(16.r),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.local_shipping_outlined, color: Colors.green, size: 16.sp),
                SizedBox(width: 8.w),
                Text(
                  "Delivery by $deliveryDate",
                  style: GoogleFonts.poppins(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.green[800],
                  ),
                ),
                const Spacer(),
                Text(
                  "FREE Delivery",
                  style: GoogleFonts.poppins(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.green[800],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionItem(IconData icon, String label) {
    return Column(
      children: [
        Icon(icon, size: 16.sp, color: AppColors.greyText),
        SizedBox(height: 2.h),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 8.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.greyText,
          ),
        ),
      ],
    );
  }

  Widget _buildQuantityStepper() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: AppColors.secondaryPurple.withOpacity(0.5)),
      ),
      child: Row(
        children: [
          _buildStepButton(Icons.remove),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.w),
            child: Text(
              "1",
              style: GoogleFonts.poppins(
                fontSize: 13.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.darkText,
              ),
            ),
          ),
          _buildStepButton(Icons.add),
        ],
      ),
    );
  }

  Widget _buildStepButton(IconData icon) {
    return Container(
      padding: EdgeInsets.all(4.r),
      child: Icon(icon, size: 16.sp, color: AppColors.secondaryPurple),
    );
  }
}
