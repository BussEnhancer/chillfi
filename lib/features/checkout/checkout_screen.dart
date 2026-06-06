import 'package:chillfi/core/app_colors.dart';
import 'package:chillfi/features/checkout/widgets/checkout_widgets.dart';
import 'package:chillfi/features/payment/payment_method_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class CheckoutScreen extends StatelessWidget {
  const CheckoutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Padding(
          padding: EdgeInsets.all(8.r),
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Icon(Icons.arrow_back_rounded, color: AppColors.darkText, size: 22.sp),
            ),
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Checkout",
              style: GoogleFonts.poppins(
                fontSize: 16.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.darkText,
              ),
            ),
            Text(
              "Review your order and place order",
              style: GoogleFonts.poppins(
                fontSize: 11.sp,
                color: AppColors.greyText,
              ),
            ),
          ],
        ),
        actions: [
          Row(
            children: [
              Icon(Icons.verified_user_rounded, color: AppColors.secondaryPurple, size: 16.sp),
              SizedBox(width: 4.w),
              Text(
                "100% Secure",
                style: GoogleFonts.poppins(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.secondaryPurple,
                ),
              ),
              SizedBox(width: 16.w),
            ],
          ),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CheckoutProgressStepper(currentStep: 1),
                const CheckoutAddressCard(),
                
                SizedBox(height: 24.h),
                _buildSectionHeader(context, "Order Items (3)", "View Cart"),
                const CheckoutOrderItemCard(),

                SizedBox(height: 24.h),
                Text(
                  "Delivery Option",
                  style: GoogleFonts.poppins(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.darkText,
                  ),
                ),
                SizedBox(height: 12.h),
                const DeliveryOptionCard(
                  title: "Standard Delivery",
                  date: "Fri, 24 May",
                  price: "0",
                  isSelected: true,
                  isFree: true,
                ),
                const DeliveryOptionCard(
                  title: "Express Delivery",
                  date: "Tomorrow, 23 May",
                  price: "99",
                  isSelected: false,
                ),

                SizedBox(height: 24.h),
                _buildSectionHeader(context, "Payment Method", "Change"),
                const PaymentMethodCard(),

                SizedBox(height: 24.h),
                _buildSectionHeader(context, "Apply Offer", "View All Offers"),
                const AppliedOfferCard(),

                SizedBox(height: 24.h),
                Text(
                  "Price Details",
                  style: GoogleFonts.poppins(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.darkText,
                  ),
                ),
                SizedBox(height: 12.h),
                const PriceDetailsCard(),
                
                SizedBox(height: 150.h), // Footer space
              ],
            ),
          ),
          
          const Align(
            alignment: Alignment.bottomCenter,
            child: CheckoutBottomBar(),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, String action) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(
                title.contains("Item") ? Icons.shopping_bag_outlined : 
                title.contains("Payment") ? Icons.payment_rounded : Icons.local_offer_outlined,
                size: 18.sp,
                color: AppColors.secondaryPurple,
              ),
              SizedBox(width: 8.w),
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.darkText,
                ),
              ),
            ],
          ),
          GestureDetector(
            onTap: () {
              if (title.contains("Payment")) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const PaymentMethodScreen()),
                );
              }
            },
            child: Row(
              children: [
                Text(
                  action,
                  style: GoogleFonts.poppins(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.secondaryPurple,
                  ),
                ),
                Icon(Icons.chevron_right_rounded, color: AppColors.secondaryPurple, size: 18.sp),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
