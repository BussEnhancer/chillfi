import 'package:chillfi/core/app_colors.dart';
import 'package:chillfi/features/cart/widgets/cart_address_card.dart';
import 'package:chillfi/features/cart/widgets/cart_item_card.dart';
import 'package:chillfi/features/cart/widgets/cart_price_summary.dart';
import 'package:chillfi/features/cart/widgets/cart_promotion_card.dart';
import 'package:chillfi/features/checkout/checkout_screen.dart';
import 'package:chillfi/features/home/widgets/bottom_nav.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

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
                    color: Colors.black.withOpacity(0.05),
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
              "Cart",
              style: GoogleFonts.poppins(
                fontSize: 16.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.darkText,
              ),
            ),
            Text(
              "3 Items in Cart",
              style: GoogleFonts.poppins(
                fontSize: 11.sp,
                color: AppColors.greyText,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.favorite_border_rounded, color: AppColors.darkText, size: 24.sp),
          ),
          Stack(
            alignment: Alignment.topRight,
            children: [
              IconButton(
                onPressed: () {},
                icon: Icon(Icons.notifications_none_rounded, color: AppColors.darkText, size: 24.sp),
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
                    '2',
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
                const CartAddressCard(),
                SizedBox(height: 20.h),
                const CartItemCard(
                  image: "",
                  name: "Apple iPhone 15 (128GB)",
                  variant: "Pink",
                  storage: "128GB",
                  price: "69,999",
                  oldPrice: "79,999",
                  discount: "12%",
                  savings: "10,000",
                  deliveryDate: "Fri, 24 May",
                ),
                const CartItemCard(
                  image: "",
                  name: "Samsung Galaxy S23 (256GB)",
                  variant: "Phantom Black",
                  storage: "256GB",
                  price: "49,999",
                  oldPrice: "63,999",
                  discount: "22%",
                  savings: "14,000",
                  deliveryDate: "Sat, 25 May",
                ),
                const CartItemCard(
                  image: "",
                  name: "Apple AirPods Pro (2nd Gen)",
                  variant: "White",
                  storage: "",
                  price: "18,999",
                  oldPrice: "26,999",
                  discount: "30%",
                  savings: "8,000",
                  deliveryDate: "Wed, 22 May",
                ),
                SizedBox(height: 12.h),
                const CartPromotionCard(
                  icon: Icons.local_offer_outlined,
                  title: "Apply Coupon or Offers",
                  subtitle: "Save extra with best offers",
                  bgColor: Color(0xFFF3E5F5),
                  iconColor: AppColors.secondaryPurple,
                  isCoupon: true,
                ),
                const CartPromotionCard(
                  icon: Icons.shield_outlined,
                  title: "Secure Payment",
                  subtitle: "100% Secure Payments",
                  bgColor: Color(0xFFE8F5E9),
                  iconColor: Colors.green,
                ),
                SizedBox(height: 20.h),
                const CartPriceSummary(),
                SizedBox(height: 150.h), // Footer space
              ],
            ),
          ),
          
          // Sticky Bottom Checkout Bar
          Align(
            alignment: Alignment.bottomCenter,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildStickyCheckoutBar(context),
                const CustomBottomNavBar(selectedIndex: 3), // Highlighted Orders for context
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStickyCheckoutBar(BuildContext ctx) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
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
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Total Amount",
                  style: GoogleFonts.poppins(
                    fontSize: 11.sp,
                    color: AppColors.greyText,
                  ),
                ),
                Row(
                  children: [
                    Text(
                      "₹1,06,997",
                      style: GoogleFonts.poppins(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w800,
                        color: AppColors.darkText,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      "Saved ₹32,000",
                      style: GoogleFonts.poppins(
                        fontSize: 9.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(width: 20.w),
            Expanded(
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    ctx,
                    MaterialPageRoute(builder: (context) => const CheckoutScreen()),
                  );
                },
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
                      Text(
                        "Proceed to Checkout",
                        style: GoogleFonts.poppins(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 18.sp),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
