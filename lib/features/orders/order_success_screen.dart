import 'package:chillfi/core/app_colors.dart';
import 'package:chillfi/features/checkout/widgets/checkout_widgets.dart';
import 'package:chillfi/features/orders/widgets/order_success_widgets.dart';
import 'package:chillfi/features/payment/widgets/payment_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class OrderSuccessScreen extends StatelessWidget {
  const OrderSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Column(
              children: [
                SizedBox(height: 50.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.share_outlined, color: AppColors.secondaryPurple, size: 18.sp),
                        SizedBox(width: 4.w),
                        Text(
                          "Share",
                          style: GoogleFonts.poppins(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.secondaryPurple,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const OrderSuccessAnimationHeader(),
                Text(
                  "Order Placed Successfully!",
                  style: GoogleFonts.poppins(
                    fontSize: 22.sp,
                    fontWeight: FontWeight.w800,
                    color: AppColors.darkText,
                  ),
                ),
                Text(
                  "Thank you for shopping with CHILLFI 💜",
                  style: GoogleFonts.poppins(
                    fontSize: 13.sp,
                    color: AppColors.greyText,
                  ),
                ),
                SizedBox(height: 24.h),
                const OrderIdCard(),
                SizedBox(height: 16.h),
                const DeliveryEstimateCard(),
                
                const PaymentSectionHeader(title: "Order Summary"),
                const CheckoutOrderItemCard(),
                SizedBox(height: 12.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Total Amount",
                      style: GoogleFonts.poppins(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.darkText,
                      ),
                    ),
                    Text(
                      "₹1,36,897",
                      style: GoogleFonts.poppins(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w800,
                        color: AppColors.darkText,
                      ),
                    ),
                  ],
                ),

                const PaymentSectionHeader(title: "Order Tracking"),
                const OrderTrackingTimeline(),

                SizedBox(height: 24.h),
                const QuickActionsGrid(),

                SizedBox(height: 32.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "You Might Also Like",
                      style: GoogleFonts.poppins(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.darkText,
                      ),
                    ),
                    Text(
                      "View All >",
                      style: GoogleFonts.poppins(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.secondaryPurple,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16.h),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  child: Row(
                    children: const [
                      SuccessRecommendedCard(title: "Apple AirPods 4", price: "12,999"),
                      SuccessRecommendedCard(title: "Samsung Galaxy Watch 6", price: "24,999"),
                      SuccessRecommendedCard(title: "iPad Air M2", price: "54,900"),
                    ],
                  ),
                ),
                SizedBox(height: 120.h),
              ],
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              padding: EdgeInsets.all(20.w),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: SafeArea(
                top: false,
                child: Container(
                  width: double.infinity,
                  height: 56.h,
                  decoration: BoxDecoration(
                    gradient: AppColors.purpleGradient,
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  alignment: Alignment.center,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.shopping_bag_rounded, color: Colors.white, size: 20.sp),
                      SizedBox(width: 10.w),
                      Text(
                        "Continue Shopping",
                        style: GoogleFonts.poppins(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
