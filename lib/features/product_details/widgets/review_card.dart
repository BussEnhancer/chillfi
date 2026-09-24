import 'package:chillfi/core/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class ReviewCard extends StatelessWidget {
  final String userName;
  final String userInitial;
  final String date;
  final String title;
  final String description;
  final int rating;
  final int helpfulCount;
  final bool isVerified;

  const ReviewCard({
    super.key,
    required this.userName,
    required this.userInitial,
    required this.date,
    required this.title,
    required this.description,
    required this.rating,
    required this.helpfulCount,
    this.isVerified = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
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
          // User Info Header
          Row(
            children: [
              CircleAvatar(
                radius: 20.r,
                backgroundColor: AppColors.secondaryPurple.withValues(alpha: 0.1),
                child: Text(
                  userInitial,
                  style: GoogleFonts.poppins(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.secondaryPurple,
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          userName,
                          style: GoogleFonts.poppins(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w700,
                            color: AppColors.darkText,
                          ),
                        ),
                        if (isVerified) ...[
                          SizedBox(width: 8.w),
                          _buildBadge("Verified Purchase", Colors.green),
                        ],
                      ],
                    ),
                    Row(
                      children: [
                        const Spacer(),
                        Text(
                          date,
                          style: GoogleFonts.poppins(
                            fontSize: 11.sp,
                            color: AppColors.greyText,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          SizedBox(height: 16.h),
          
          // Rating and Title
          Row(
            children: List.generate(
              5,
              (index) => Icon(
                index < rating ? Icons.star_rounded : Icons.star_outline_rounded,
                color: Colors.orange,
                size: 16.sp,
              ),
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 15.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.darkText,
            ),
          ),
          
          SizedBox(height: 8.h),
          
          // Description
          Text(
            description,
            style: GoogleFonts.poppins(
              fontSize: 13.sp,
              color: AppColors.greyText,
              height: 1.5,
            ),
          ),
          
          SizedBox(height: 16.h),
          
        ],
      ),
    );
  }

  Widget _buildBadge(String label, Color color) {
    return Container(
      margin: EdgeInsets.only(top: 2.h),
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(4.r),
      ),
      child: Text(
        label,
        style: GoogleFonts.poppins(
          fontSize: 8.sp,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

}
