import 'package:chillfi/core/app_colors.dart';
import 'package:chillfi/features/deals/flash_deals_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class DealOfTheDaySection extends StatelessWidget {
  const DealOfTheDaySection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
          child: Row(
            children: [
              Text(
                'Deal of the Day',
                style: GoogleFonts.poppins(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.darkText,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const FlashDealsScreen()),
                  );
                },
                child: Text(
                  'View All >',
                  style: GoogleFonts.poppins(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.secondaryPurple,
                  ),
                ),
              ),
            ],
          ),
        ),
        _buildProductCard(),
      ],
    );
  }

  Widget _buildProductCard() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
      child: Container(
        padding: EdgeInsets.all(12.r),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(color: AppColors.fieldBorder.withOpacity(0.5)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            // Product Image Container
            Stack(
              children: [
                Container(
                  width: 100.w,
                  height: 100.h,
                  decoration: BoxDecoration(
                    color: AppColors.lightBackground,
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  child: Center(
                    child: Icon(Icons.earbuds_rounded, size: 50.sp, color: AppColors.darkText.withOpacity(0.2)),
                  ),
                ),
                Positioned(
                  top: 8.h,
                  left: 8.w,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                    decoration: BoxDecoration(
                      color: AppColors.secondaryPurple,
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                    child: Text(
                      '-40%',
                      style: TextStyle(color: Colors.white, fontSize: 8.sp, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(width: 15.w),
            // Product Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'CHILLFI AirPods Pro',
                    style: GoogleFonts.poppins(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.darkText,
                    ),
                  ),
                  Text(
                    'Wireless Earbuds',
                    style: GoogleFonts.poppins(
                      fontSize: 11.sp,
                      color: AppColors.greyText,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Row(
                    children: [
                      ...List.generate(4, (index) => Icon(Icons.star_rounded, color: Colors.amber, size: 14.sp)),
                      Icon(Icons.star_half_rounded, color: Colors.amber, size: 14.sp),
                      SizedBox(width: 4.w),
                      Text('(4.5)', style: TextStyle(fontSize: 10.sp, color: AppColors.greyText)),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  Row(
                    children: [
                      Text(
                        '₹2,999',
                        style: GoogleFonts.poppins(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w800,
                          color: AppColors.darkText,
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        '₹4,999',
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: AppColors.greyText,
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Add to Cart Button
            Column(
              children: [
                Container(
                  padding: EdgeInsets.all(10.r),
                  decoration: BoxDecoration(
                    color: AppColors.secondaryPurple.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Icon(Icons.add_shopping_cart_rounded, color: AppColors.secondaryPurple, size: 20.sp),
                ),
                SizedBox(height: 4.h),
                Text(
                  'Add',
                  style: GoogleFonts.poppins(fontSize: 9.sp, fontWeight: FontWeight.w600, color: AppColors.secondaryPurple),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
