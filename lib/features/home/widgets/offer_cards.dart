import 'package:chillfi/core/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class OfferCardsSection extends StatelessWidget {
  const OfferCardsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 15.h),
      child: Row(
        children: [
          // Welcome Cashback Card
          Expanded(
            child: Container(
              height: 120.h,
              decoration: BoxDecoration(
                gradient: AppColors.purpleGradient,
                borderRadius: BorderRadius.circular(20.r),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.secondaryPurple.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  Positioned(
                    right: -10.w,
                    bottom: -10.h,
                    child: Icon(Icons.stars_rounded, size: 80.sp, color: Colors.white.withOpacity(0.1)),
                  ),
                  Padding(
                    padding: EdgeInsets.all(16.r),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Hey, John! 👋',
                          style: GoogleFonts.poppins(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          'Welcome back',
                          style: GoogleFonts.poppins(
                            fontSize: 10.sp,
                            color: Colors.white.withOpacity(0.8),
                          ),
                        ),
                        const Spacer(),
                        Row(
                          children: [
                            Icon(Icons.monetization_on_rounded, color: Colors.amber, size: 20.sp),
                            SizedBox(width: 4.w),
                            Text(
                              '250',
                              style: GoogleFonts.poppins(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                            const Spacer(),
                            Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 16.sp),
                          ],
                        ),
                        Text(
                          'CHILLFI Cash',
                          style: GoogleFonts.poppins(
                            fontSize: 9.sp,
                            color: Colors.white.withOpacity(0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(width: 15.w),
          // Exclusive Offer Card
          Expanded(
            child: Container(
              height: 120.h,
              decoration: BoxDecoration(
                color: const Color(0xFFFFF5F0),
                borderRadius: BorderRadius.circular(20.r),
                border: Border.all(color: AppColors.primaryOrange.withOpacity(0.1)),
              ),
              child: Stack(
                children: [
                  Positioned(
                    right: 10.w,
                    top: 20.h,
                    child: Icon(Icons.confirmation_num_rounded, size: 60.sp, color: AppColors.primaryOrange.withOpacity(0.2)),
                  ),
                  Padding(
                    padding: EdgeInsets.all(16.r),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Exclusive Offer',
                          style: GoogleFonts.poppins(
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primaryOrange,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          'Extra 10% OFF',
                          style: GoogleFonts.poppins(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w700,
                            color: AppColors.darkText,
                          ),
                        ),
                        Text(
                          'On all prepaid orders',
                          style: GoogleFonts.poppins(
                            fontSize: 9.sp,
                            color: AppColors.greyText,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                          decoration: BoxDecoration(
                            color: AppColors.primaryOrange.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8.r),
                            border: Border.all(color: AppColors.primaryOrange.withOpacity(0.2), style: BorderStyle.solid),
                          ),
                          child: Text(
                            'Code: CHILL10',
                            style: GoogleFonts.poppins(
                              fontSize: 9.sp,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primaryOrange,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
