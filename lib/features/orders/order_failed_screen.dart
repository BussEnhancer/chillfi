import 'package:chillfi/core/app_colors.dart';
import 'package:chillfi/features/orders/widgets/order_failed_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class OrderFailedScreen extends StatelessWidget {
  const OrderFailedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Main Content
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  // Header with Support Action
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Back Button (Optional but good for UX, though not explicitly in failures)
                        // In the reference, there's just time on the left and support on the right.
                        const SizedBox.shrink(),
                        Row(
                          children: [
                            Icon(Icons.headset_mic_outlined, 
                              color: AppColors.secondaryPurple, size: 18.sp),
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
                      ],
                    ),
                  ),

                  const OrderFailedHeader(),
                  const FailureMessageSection(),
                  const OrderInfoCard(),
                  const FailureReasonCard(),
                  const ActionOptionsCard(),
                  const SupportCard(),
                  
                  // Bottom Spacing for fixed buttons
                  SizedBox(height: 180.h),
                ],
              ),
            ),
          ),

          // Sticky Bottom Buttons
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
                    const RetryButton(),
                    SizedBox(height: 12.h),
                    const BackToShoppingButton(),
                    SizedBox(height: 16.h),
                    const SecurityFooter(),
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
