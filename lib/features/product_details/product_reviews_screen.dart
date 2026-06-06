import 'package:chillfi/core/app_colors.dart';
import 'package:chillfi/features/product_details/widgets/review_card.dart';
import 'package:chillfi/features/product_details/widgets/review_filter_chips.dart';
import 'package:chillfi/features/product_details/widgets/review_statistics_card.dart';
import 'package:chillfi/features/product_details/widgets/review_summary_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class ProductReviewsScreen extends StatelessWidget {
  const ProductReviewsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back_rounded, color: AppColors.darkText, size: 24.sp),
        ),
        title: Row(
          children: [
            Container(
              width: 40.r,
              height: 40.r,
              decoration: BoxDecoration(
                color: const Color(0xFFF8F8F8),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Icon(Icons.smartphone_rounded, color: AppColors.primaryOrange, size: 24.sp),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Product Reviews",
                    style: GoogleFonts.poppins(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.darkText,
                    ),
                  ),
                  Text(
                    "Apple iPhone 15 (128GB) - Pink",
                    style: GoogleFonts.poppins(
                      fontSize: 11.sp,
                      color: AppColors.greyText,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.search_rounded, color: AppColors.darkText, size: 24.sp),
          ),
          Stack(
            alignment: Alignment.topRight,
            children: [
              IconButton(
                onPressed: () {},
                icon: Icon(Icons.shopping_cart_outlined, color: AppColors.darkText, size: 24.sp),
              ),
              Positioned(
                right: 8.w,
                top: 8.h,
                child: Container(
                  padding: EdgeInsets.all(4.r),
                  decoration: const BoxDecoration(
                    color: AppColors.secondaryPurple,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '3',
                    style: TextStyle(color: Colors.white, fontSize: 8.sp, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(width: 8.w),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Column(
              children: [
                SizedBox(height: 16.h),
                const ReviewSummaryCard(),
                SizedBox(height: 24.h),
                const ReviewFilterChips(),
                SizedBox(height: 24.h),
                
                // Sort and Write Review Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Text(
                          "Most Helpful",
                          style: GoogleFonts.poppins(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.darkText,
                          ),
                        ),
                        Icon(Icons.keyboard_arrow_down_rounded, size: 20.sp, color: AppColors.darkText),
                      ],
                    ),
                    GestureDetector(
                      onTap: () {},
                      child: Row(
                        children: [
                          Text(
                            "Write a Review",
                            style: GoogleFonts.poppins(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w600,
                              color: AppColors.secondaryPurple,
                            ),
                          ),
                          SizedBox(width: 4.w),
                          Icon(Icons.edit_note_rounded, color: AppColors.secondaryPurple, size: 20.sp),
                        ],
                      ),
                    ),
                  ],
                ),
                
                SizedBox(height: 20.h),
                
                // Review List
                const ReviewCard(
                  userName: "Rahul Agarwal",
                  userInitial: "RA",
                  date: "2 days ago",
                  title: "Excellent Camera & Performance!",
                  description: "The camera quality is awesome, especially in low light. A16 Bionic chip makes it super fast and smooth. Battery backup is also really good.",
                  rating: 5,
                  helpfulCount: 125,
                ),
                const ReviewCard(
                  userName: "Priya Sharma",
                  userInitial: "PS",
                  date: "5 days ago",
                  title: "Great Phone with Premium Feel",
                  description: "Superb display and performance. iOS is very smooth and secure. Overall a great experience.",
                  rating: 5,
                  helpfulCount: 98,
                ),
                const ReviewCard(
                  userName: "Amit Kumar",
                  userInitial: "AK",
                  date: "1 week ago",
                  title: "Good but Could Be Better",
                  description: "Phone is good but gets a little warm while gaming. Charging speed could have been better.",
                  rating: 4,
                  helpfulCount: 45,
                ),
                const ReviewCard(
                  userName: "Sneha Nair",
                  userInitial: "SN",
                  date: "2 weeks ago",
                  title: "Best iPhone in This Range",
                  description: "Loving the new design and colors. Camera is fantastic and the overall performance is top-notch.",
                  rating: 5,
                  helpfulCount: 76,
                ),
                
                SizedBox(height: 24.h),
                const ReviewStatisticsCard(),
                SizedBox(height: 120.h), // Space for sticky bottom bar
              ],
            ),
          ),
          
          // Sticky Bottom Bar
          Align(
            alignment: Alignment.bottomCenter,
            child: _buildBottomPurchaseBar(),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomPurchaseBar() {
    return Container(
      padding: EdgeInsets.only(left: 20.w, right: 20.w, top: 15.h, bottom: 25.h),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30.r),
          topRight: Radius.circular(30.r),
        ),
      ),
      child: Row(
        children: [
          // Cart with badge
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                alignment: Alignment.topRight,
                children: [
                  Icon(Icons.shopping_cart_outlined, color: AppColors.darkText, size: 24.sp),
                  Positioned(
                    right: -2,
                    top: -2,
                    child: Container(
                      padding: EdgeInsets.all(4.r),
                      decoration: const BoxDecoration(
                        color: AppColors.secondaryPurple,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '3',
                        style: TextStyle(color: Colors.white, fontSize: 8.sp, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
              Text(
                "Cart",
                style: GoogleFonts.poppins(
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.darkText,
                ),
              ),
            ],
          ),
          SizedBox(width: 20.w),
          // Add to Cart
          Expanded(
            child: Container(
              height: 54.h,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(color: AppColors.secondaryPurple, width: 2),
              ),
              alignment: Alignment.center,
              child: Text(
                "Add to Cart",
                style: GoogleFonts.poppins(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.secondaryPurple,
                ),
              ),
            ),
          ),
          SizedBox(width: 12.w),
          // Buy Now
          Expanded(
            child: Container(
              height: 54.h,
              decoration: BoxDecoration(
                gradient: AppColors.purpleGradient,
                borderRadius: BorderRadius.circular(16.r),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.secondaryPurple.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.bolt_rounded, color: Colors.white, size: 18.sp),
                  SizedBox(width: 4.w),
                  Text(
                    "Buy Now",
                    style: GoogleFonts.poppins(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
