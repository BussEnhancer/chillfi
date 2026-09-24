import 'package:chillfi/core/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class CartPriceSummary extends StatelessWidget {
  const CartPriceSummary({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: AppColors.lightGrey.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPriceRow("Price (3 Items)", "₹1,38,997"),
          SizedBox(height: 12.h),
          _buildPriceRow("Discount", "-₹32,000", isDiscount: true),
          SizedBox(height: 12.h),
          _buildPriceRow("Delivery Charges", "₹99 FREE", isDelivery: true),
          SizedBox(height: 16.h),
          Divider(color: AppColors.lightGrey.withValues(alpha: 0.5)),
          SizedBox(height: 16.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Total Amount",
                style: GoogleFonts.poppins(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.darkText,
                ),
              ),
              Text(
                "₹1,06,997",
                style: GoogleFonts.poppins(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w800,
                  color: AppColors.darkText,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Text(
            "You will save ₹32,000 on this order",
            style: GoogleFonts.poppins(
              fontSize: 11.sp,
              fontWeight: FontWeight.w600,
              color: Colors.green[700],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceRow(String label, String value, {bool isDiscount = false, bool isDelivery = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 13.sp,
            fontWeight: FontWeight.w500,
            color: AppColors.greyText,
          ),
        ),
        RichText(
          text: TextSpan(
            children: [
              if (isDelivery)
                TextSpan(
                  text: "₹99 ",
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: AppColors.greyText,
                    decoration: TextDecoration.lineThrough,
                  ),
                ),
              TextSpan(
                text: value.contains("FREE") ? "FREE" : value,
                style: GoogleFonts.poppins(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                  color: isDiscount || value.contains("FREE") ? Colors.green : AppColors.darkText,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
