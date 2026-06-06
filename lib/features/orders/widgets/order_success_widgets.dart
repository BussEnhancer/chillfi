import 'package:chillfi/core/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class OrderSuccessAnimationHeader extends StatelessWidget {
  const OrderSuccessAnimationHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 30.h),
      child: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 100.r,
              height: 100.r,
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
            ),
            Container(
              width: 80.r,
              height: 80.r,
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
            ),
            Container(
              width: 60.r,
              height: 60.r,
              decoration: const BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.check_rounded, color: Colors.white, size: 40.sp),
            ),
            // Confetti particles placeholder
            ...List.generate(6, (index) {
              return Positioned(
                top: (index % 2 == 0) ? 10.h : 70.h,
                left: (index % 3 == 0) ? 10.w : 80.w,
                child: Transform.rotate(
                  angle: index * 0.5,
                  child: Container(
                    width: 6.r,
                    height: 6.r,
                    decoration: BoxDecoration(
                      color: index % 2 == 0 ? Colors.purple : Colors.orange,
                      borderRadius: BorderRadius.circular(2.r),
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

class OrderIdCard extends StatelessWidget {
  const OrderIdCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.lightGrey.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(10.r),
                decoration: BoxDecoration(
                  color: AppColors.secondaryPurple.withValues(alpha: 0.05),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.description_outlined, color: AppColors.secondaryPurple, size: 20.sp),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Order ID",
                      style: GoogleFonts.poppins(fontSize: 11.sp, color: AppColors.greyText),
                    ),
                    Text(
                      "#CHILLFI125678",
                      style: GoogleFonts.poppins(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.darkText,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6.r),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.check_circle_rounded, color: Colors.green, size: 12.sp),
                        SizedBox(width: 4.w),
                        Text(
                          "Confirmed",
                          style: GoogleFonts.poppins(
                            fontSize: 9.sp,
                            fontWeight: FontWeight.w700,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    "May 21, 2025  •  09:41 AM",
                    style: GoogleFonts.poppins(fontSize: 9.sp, color: AppColors.greyText),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Text(
            "We have sent the order details to rahul.sharma@example.com",
            style: GoogleFonts.poppins(fontSize: 11.sp, color: AppColors.greyText),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class DeliveryEstimateCard extends StatelessWidget {
  const DeliveryEstimateCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.green.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.green.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10.r),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.local_shipping_rounded, color: Colors.green, size: 24.sp),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Estimated Delivery",
                  style: GoogleFonts.poppins(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.green[800],
                  ),
                ),
                Text(
                  "Fri, 24 May – Tue, 27 May",
                  style: GoogleFonts.poppins(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.darkText,
                  ),
                ),
                Text(
                  "We will keep you updated on your order status.",
                  style: GoogleFonts.poppins(
                    fontSize: 10.sp,
                    color: Colors.green[700],
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right_rounded, color: Colors.green, size: 24.sp),
        ],
      ),
    );
  }
}

class OrderTrackingTimeline extends StatelessWidget {
  const OrderTrackingTimeline({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.lightGrey.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStep(1, "Order Confirmed", true, "21 May, 09:41 AM"),
              _buildDivider(true),
              _buildStep(2, "Packed", false, ""),
              _buildDivider(false),
              _buildStep(3, "Shipped", false, ""),
              _buildDivider(false),
              _buildStep(4, "Out for Delivery", false, ""),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStep(int step, String label, bool isActive, String subLabel) {
    return Column(
      children: [
        Container(
          width: 24.r,
          height: 24.r,
          decoration: BoxDecoration(
            color: isActive ? AppColors.secondaryPurple : Colors.white,
            shape: BoxShape.circle,
            border: Border.all(
              color: isActive ? AppColors.secondaryPurple : AppColors.lightGrey,
              width: 1.5,
            ),
          ),
          child: isActive ? Icon(Icons.check, color: Colors.white, size: 14.sp) : null,
        ),
        SizedBox(height: 8.h),
        SizedBox(
          width: 60.w,
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 8.sp,
              fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
              color: isActive ? AppColors.secondaryPurple : AppColors.greyText,
            ),
          ),
        ),
        if (subLabel.isNotEmpty)
          Text(
            subLabel,
            style: GoogleFonts.poppins(fontSize: 7.sp, color: AppColors.greyText),
          ),
      ],
    );
  }

  Widget _buildDivider(bool isActive) {
    return Container(
      width: 30.w,
      height: 1,
      margin: EdgeInsets.only(bottom: 30.h),
      color: isActive ? AppColors.secondaryPurple : AppColors.lightGrey,
    );
  }
}

class QuickActionsGrid extends StatelessWidget {
  const QuickActionsGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildAction(Icons.local_shipping_outlined, "Track Order"),
        _buildAction(Icons.inventory_2_outlined, "My Orders"),
        _buildAction(Icons.file_download_outlined, "Download Invoice"),
        _buildAction(Icons.shopping_bag_outlined, "Continue Shopping"),
      ],
    );
  }

  Widget _buildAction(IconData icon, String label) {
    return Column(
      children: [
        Container(
          width: 70.w,
          height: 70.w,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: AppColors.lightGrey.withValues(alpha: 0.3)),
          ),
          child: Icon(icon, color: AppColors.secondaryPurple, size: 24.sp),
        ),
        SizedBox(height: 8.h),
        SizedBox(
          width: 70.w,
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 10.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.darkText,
            ),
          ),
        ),
      ],
    );
  }
}

class SuccessRecommendedCard extends StatelessWidget {
  final String title;
  final String price;
  const SuccessRecommendedCard({super.key, required this.title, required this.price});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 140.w,
      margin: EdgeInsets.only(right: 16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.lightGrey.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 100.h,
            decoration: BoxDecoration(
              color: const Color(0xFFF8F8F8),
              borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
            ),
            child: Center(
              child: Icon(Icons.shopping_bag_outlined, size: 40.sp, color: Colors.grey[300]),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(10.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.darkText,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  "₹$price",
                  style: GoogleFonts.poppins(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.darkText,
                  ),
                ),
                SizedBox(height: 8.h),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: 6.h),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.secondaryPurple),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    "Add to Cart",
                    style: GoogleFonts.poppins(
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.secondaryPurple,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
