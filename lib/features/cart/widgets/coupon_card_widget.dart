import 'package:chillfi/core/app_colors.dart';
import 'package:chillfi/features/cart/widgets/ticket_clipper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class CouponCardWidget extends StatelessWidget {
  final String code;
  final String title;
  final String desc;
  final String validity;
  final Color themeColor;
  final bool isSelected;
  final VoidCallback onTap;

  const CouponCardWidget({
    super.key,
    required this.code,
    required this.title,
    required this.desc,
    required this.validity,
    required this.themeColor,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: AppColors.lightGrey.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          // Left: Ticket Badge
          CustomPaint(
            painter: CouponTicketPainter(color: themeColor.withOpacity(0.1)),
            child: Container(
              width: 80.w,
              height: 70.h,
              alignment: Alignment.center,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    code,
                    style: GoogleFonts.poppins(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w800,
                      color: themeColor,
                    ),
                  ),
                  Text(
                    "CODE",
                    style: GoogleFonts.poppins(
                      fontSize: 8.sp,
                      fontWeight: FontWeight.w600,
                      color: themeColor.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(width: 16.w),
          // Center: Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.darkText,
                  ),
                ),
                Text(
                  desc,
                  style: GoogleFonts.poppins(
                    fontSize: 10.sp,
                    color: AppColors.greyText,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 6.h),
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF3E0),
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                      child: Text(
                        validity,
                        style: GoogleFonts.poppins(
                          fontSize: 8.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.orange[800],
                        ),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      "T&C Apply",
                      style: GoogleFonts.poppins(
                        fontSize: 8.sp,
                        color: AppColors.greyText,
                      ),
                    ),
                    SizedBox(width: 2.w),
                    Icon(Icons.info_outline_rounded, size: 10.sp, color: AppColors.greyText),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(width: 12.w),
          // Right: Selection & Action
          Column(
            children: [
              GestureDetector(
                onTap: onTap,
                child: Container(
                  width: 20.r,
                  height: 20.r,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected ? AppColors.secondaryPurple : AppColors.lightGrey,
                      width: isSelected ? 6.r : 1.5,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                "Apply",
                style: GoogleFonts.poppins(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.secondaryPurple,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
