import 'package:chillfi/core/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class NewArrivalsFeatureHighlights extends StatelessWidget {
  const NewArrivalsFeatureHighlights({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
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
        border: Border.all(color: AppColors.lightGrey.withOpacity(0.4)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildItem(Icons.new_releases_rounded, "Latest Products", "Just added", Colors.purple),
          _buildItem(Icons.verified_user_rounded, "100% Original", "Genuine Products", Colors.blue),
          _buildItem(Icons.update_rounded, "New Daily", "Fresh arrivals", Colors.orange),
          _buildItem(Icons.sync_rounded, "Easy Returns", "Hassle free", Colors.green),
        ],
      ),
    );
  }

  Widget _buildItem(IconData icon, String title, String sub, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20.sp),
        SizedBox(height: 6.h),
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 8.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.darkText,
          ),
        ),
        Text(
          sub,
          style: GoogleFonts.poppins(
            fontSize: 7.sp,
            color: AppColors.greyText,
          ),
        ),
      ],
    );
  }
}
