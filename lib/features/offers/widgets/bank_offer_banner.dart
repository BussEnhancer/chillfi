import 'package:chillfi/core/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class BankOfferBanner extends StatelessWidget {
  const BankOfferBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            Color(0xFFEFFFFB),
            Color(0xFFD7FFF1),
          ],
        ),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.green.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(10.r),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.account_balance_rounded, color: AppColors.secondaryPurple, size: 24.sp),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Extra Savings with Bank Offers!",
                      style: GoogleFonts.poppins(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.darkText,
                      ),
                    ),
                    Text(
                      "Get up to 10% instant discount on Credit & Debit Cards.",
                      style: GoogleFonts.poppins(
                        fontSize: 10.sp,
                        color: AppColors.greyText,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: AppColors.secondaryPurple.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Text(
                      "View Bank Offers",
                      style: GoogleFonts.poppins(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.secondaryPurple,
                      ),
                    ),
                    SizedBox(width: 4.w),
                    Icon(Icons.chevron_right_rounded, color: AppColors.secondaryPurple, size: 14.sp),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildDot(true),
              _buildDot(false),
              _buildDot(false),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDot(bool isActive) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 2.w),
      width: isActive ? 12.w : 4.w,
      height: 4.h,
      decoration: BoxDecoration(
        color: isActive ? Colors.green : Colors.green.withOpacity(0.2),
        borderRadius: BorderRadius.circular(2.r),
      ),
    );
  }
}
