import 'package:chillfi/core/app_colors.dart';
import 'package:chillfi/core/models/cart_model.dart';
import 'package:chillfi/features/orders/my_orders_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class OrderSuccessScreen extends StatelessWidget {
  final OrderModel order;
  const OrderSuccessScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Success icon
              Container(
                width: 120.w,
                height: 120.w,
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.check_circle_rounded, color: Colors.green, size: 70.sp),
              ),
              SizedBox(height: 28.h),

              Text('Order Placed!', style: GoogleFonts.poppins(fontSize: 26.sp, fontWeight: FontWeight.w800, color: AppColors.darkText)),
              SizedBox(height: 8.h),
              Text('Your order has been successfully placed.', style: GoogleFonts.poppins(fontSize: 14.sp, color: AppColors.greyText), textAlign: TextAlign.center),
              SizedBox(height: 32.h),

              // Order details card
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(20.r),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Column(
                  children: [
                    _infoRow('Order Number', order.orderNumber),
                    _infoRow('Total Amount', '₹${order.total.toStringAsFixed(0)}'),
                    _infoRow('Payment', order.paymentMethod),
                    _infoRow('Status', order.status),
                  ],
                ),
              ),
              SizedBox(height: 40.h),

              // Track order button
              SizedBox(
                width: double.infinity,
                height: 54.h,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.popUntil(context, (route) => route.isFirst);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.secondaryPurple,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
                  ),
                  child: Text('Continue Shopping', style: GoogleFonts.poppins(fontSize: 15.sp, fontWeight: FontWeight.w700, color: Colors.white)),
                ),
              ),
              SizedBox(height: 12.h),
              TextButton(
                onPressed: () {
                  // Capture the navigator first: this screen's context is gone after popUntil.
                  final nav = Navigator.of(context);
                  nav.popUntil((route) => route.isFirst);
                  nav.push(MaterialPageRoute(builder: (_) => const MyOrdersScreen()));
                },
                child: Text('View My Orders', style: GoogleFonts.poppins(fontSize: 14.sp, fontWeight: FontWeight.w600, color: AppColors.secondaryPurple)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.poppins(fontSize: 12.sp, color: AppColors.greyText)),
          Text(value, style: GoogleFonts.poppins(fontSize: 13.sp, fontWeight: FontWeight.w600, color: AppColors.darkText)),
        ],
      ),
    );
  }
}
