import 'package:chillfi/core/app_colors.dart';
import 'package:chillfi/features/orders/widgets/cancel_order_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class CancelOrderScreen extends StatelessWidget {
  const CancelOrderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leadingWidth: 70.w,
        leading: Padding(
          padding: EdgeInsets.only(left: 20.w),
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.lightGrey.withValues(alpha: 0.5)),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: Icon(Icons.arrow_back_rounded, color: AppColors.darkText, size: 20.sp),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Cancel Order",
              style: GoogleFonts.poppins(
                fontSize: 22.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.darkText,
              ),
            ),
            Text(
              "We're sorry to see you go",
              style: GoogleFonts.poppins(
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
                color: AppColors.greyText,
              ),
            ),
          ],
        ),
        actions: [
          Row(
            children: [
              Icon(Icons.headset_mic_outlined, color: AppColors.secondaryPurple, size: 18.sp),
              SizedBox(width: 6.w),
              Text(
                "Support",
                style: GoogleFonts.poppins(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.secondaryPurple,
                ),
              ),
            ],
          ),
          SizedBox(width: 20.w),
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
                SizedBox(height: 20.h),
                const CancellationOrderCard(),
                SizedBox(height: 16.h),
                const CancellationWarningCard(),
                SizedBox(height: 24.h),
                Text(
                  "Why do you want to cancel this order?",
                  style: GoogleFonts.poppins(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w800,
                    color: AppColors.darkText,
                  ),
                ),
                Text(
                  "Please help us with your feedback",
                  style: GoogleFonts.poppins(fontSize: 12.sp, color: AppColors.greyText),
                ),
                SizedBox(height: 16.h),
                const ReasonRadioList(),
                SizedBox(height: 24.h),
                const AdditionalCommentsBox(),
                SizedBox(height: 16.h),
                const RefundInfoCard(),
                SizedBox(height: 16.h),
                const CancellationHelpCard(),
                SizedBox(height: 160.h), // Space for sticky CTA
              ],
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 0),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 20,
                    offset: const Offset(0, -5),
                  ),
                ],
                borderRadius: BorderRadius.vertical(top: Radius.circular(30.r)),
              ),
              child: SafeArea(
                top: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: double.infinity,
                      height: 60.h,
                      decoration: BoxDecoration(
                        gradient: AppColors.purpleGradient,
                        borderRadius: BorderRadius.circular(16.r),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.secondaryPurple.withValues(alpha: 0.3),
                            blurRadius: 15,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.delete_outline_rounded, color: Colors.white, size: 22.sp),
                          SizedBox(width: 12.w),
                          Text(
                            "Cancel Order",
                            style: GoogleFonts.poppins(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 16.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.lock_outline_rounded, color: AppColors.greyText, size: 14.sp),
                        SizedBox(width: 6.w),
                        Text(
                          "Your data is safe and secure",
                          style: GoogleFonts.poppins(
                            fontSize: 11.sp,
                            color: AppColors.greyText,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10.h),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
