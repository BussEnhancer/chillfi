import 'package:chillfi/core/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class OrderFailedScreen extends StatelessWidget {
  final String? orderId;
  final String? reason;
  const OrderFailedScreen({super.key, this.orderId, this.reason});

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
              Container(
                width: 120.w,
                height: 120.w,
                decoration: BoxDecoration(color: Colors.red.shade50, shape: BoxShape.circle),
                child: Icon(Icons.cancel_rounded, color: Colors.red, size: 70.sp),
              ),
              SizedBox(height: 28.h),

              Text('Payment Failed', style: GoogleFonts.poppins(fontSize: 26.sp, fontWeight: FontWeight.w800, color: AppColors.darkText)),
              SizedBox(height: 8.h),
              Text(
                reason ?? 'Your payment could not be processed. Please try again or use a different payment method.',
                style: GoogleFonts.poppins(fontSize: 14.sp, color: AppColors.greyText),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 40.h),

              SizedBox(
                width: double.infinity,
                height: 54.h,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.secondaryPurple,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
                  ),
                  child: Text('Try Again', style: GoogleFonts.poppins(fontSize: 15.sp, fontWeight: FontWeight.w700, color: Colors.white)),
                ),
              ),
              SizedBox(height: 12.h),
              TextButton(
                onPressed: () => Navigator.popUntil(context, (route) => route.isFirst),
                child: Text('Go to Home', style: GoogleFonts.poppins(fontSize: 14.sp, fontWeight: FontWeight.w600, color: AppColors.greyText)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
