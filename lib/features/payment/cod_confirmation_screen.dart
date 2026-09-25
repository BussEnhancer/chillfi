import 'package:chillfi/core/app_colors.dart';
import 'package:chillfi/core/providers/cart_provider.dart';
import 'package:chillfi/features/checkout/widgets/checkout_widgets.dart';
import 'package:chillfi/features/orders/order_success_screen.dart';
import 'package:chillfi/features/payment/widgets/payment_widgets.dart';
import 'package:chillfi/features/payment/widgets/cod_widgets.dart';
import 'package:chillfi/core/widgets/app_back_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class CODConfirmationScreen extends StatefulWidget {
  const CODConfirmationScreen({super.key});

  @override
  State<CODConfirmationScreen> createState() => _CODConfirmationScreenState();
}

class _CODConfirmationScreenState extends State<CODConfirmationScreen> {
  bool _confirmed = true;
  bool _placing = false;
  String? _error;

  Future<void> _confirmOrder() async {
    if (!_confirmed) {
      setState(() => _error = 'Please confirm your order details first');
      return;
    }
    setState(() { _placing = true; _error = null; });
    final cart = context.read<CartProvider>();
    final order = await cart.placeOrder(paymentMethod: 'COD');
    if (!mounted) return;
    if (order != null) {
      await cart.confirmCOD(order.id);
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => OrderSuccessScreen(order: order)),
        (route) => route.isFirst,
      );
    } else {
      setState(() { _placing = false; _error = 'Failed to place order. Please try again.'; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leadingWidth: 60.w,
        leading: Padding(padding: EdgeInsets.only(left: 16.w), child: const AppBackButton()),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Cash on Delivery",
              style: GoogleFonts.poppins(
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.darkText,
              ),
            ),
            Text(
              "Confirm your order",
              style: GoogleFonts.poppins(
                fontSize: 12.sp,
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
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 16.h),
            const CODStatusBanner(),
            
            const PaymentSectionHeader(title: "Delivery Address"),
            const CheckoutAddressCard(),

            SizedBox(height: 24.h),
            _buildSectionHeader("Order Items (3)", "View Details"),
            const CheckoutOrderItemCard(),

            const PaymentSectionHeader(title: "Order Summary"),
            const PriceDetailsCard(),

            SizedBox(height: 24.h),
            const CODInfoCard(),

            SizedBox(height: 24.h),
            GestureDetector(
              onTap: () => setState(() => _confirmed = !_confirmed),
              child: Row(
                children: [
                  Container(
                    width: 20.r,
                    height: 20.r,
                    decoration: BoxDecoration(
                      color: _confirmed ? AppColors.secondaryPurple : Colors.white,
                      border: Border.all(color: AppColors.secondaryPurple, width: 1.5),
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                    child: _confirmed ? Icon(Icons.check, color: Colors.white, size: 14.sp) : null,
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Text(
                      "I confirm my order details are correct and I want to place this order.",
                      style: GoogleFonts.poppins(
                        fontSize: 11.sp,
                        color: AppColors.darkText,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            if (_error != null)
              Padding(
                padding: EdgeInsets.only(top: 12.h),
                child: Text(_error!, style: GoogleFonts.poppins(fontSize: 12.sp, color: Colors.red, fontWeight: FontWeight.w600)),
              ),

            SizedBox(height: 24.h),
            GestureDetector(
              onTap: _placing ? null : _confirmOrder,
              child: Container(
                width: double.infinity,
                height: 60.h,
                decoration: BoxDecoration(
                  gradient: AppColors.purpleGradient,
                  borderRadius: BorderRadius.circular(16.r),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.secondaryPurple.withValues(alpha: 0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: _placing
                    ? SizedBox(width: 24.w, height: 24.w, child: const CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.payments_outlined, color: Colors.white, size: 22.sp),
                          SizedBox(width: 10.w),
                          Text(
                            "Confirm Order",
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

            SizedBox(height: 16.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.lock_rounded, color: AppColors.greyText, size: 14.sp),
                SizedBox(width: 6.w),
                Text(
                  "Your order is safe and secure",
                  style: GoogleFonts.poppins(
                    fontSize: 11.sp,
                    color: AppColors.greyText,
                  ),
                ),
              ],
            ),
            SizedBox(height: 40.h),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, String action) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(Icons.shopping_bag_outlined, size: 18.sp, color: AppColors.secondaryPurple),
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
          Row(
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
        ],
      ),
    );
  }
}
