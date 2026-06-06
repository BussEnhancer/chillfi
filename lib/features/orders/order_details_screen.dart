import 'package:chillfi/core/app_colors.dart';
import 'package:chillfi/features/orders/widgets/order_details_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class OrderDetailsScreen extends StatelessWidget {
  const OrderDetailsScreen({super.key});

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
              "Order Details",
              style: GoogleFonts.poppins(
                fontSize: 22.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.darkText,
              ),
            ),
            Text(
              "View and manage your order",
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
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Column(
                children: [
                  SizedBox(height: 20.h),
                  const OrderSummaryCard(),
                  SizedBox(height: 16.h),
                  const OrderStatusTimeline(),
                  SizedBox(height: 16.h),
                  const OrderAddressCard(),
                  SizedBox(height: 16.h),
                  const OrderItemsCard(),
                  SizedBox(height: 16.h),
                  const OrderPriceDetailsCard(),
                  SizedBox(height: 16.h),
                  const OrderPaymentMethodCard(),
                  SizedBox(height: 24.h),
                  const QuickActionsSection(),
                  SizedBox(height: 32.h),
                ],
              ),
            ),
          ),
          const OrderBottomActions(),
        ],
      ),
    );
  }
}
