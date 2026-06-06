import 'package:chillfi/core/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class FeatureHighlightsRow extends StatelessWidget {
  const FeatureHighlightsRow({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: const Color(0xFFF9F5FF),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildFeature(Icons.verified_user_rounded, '100% Original', Colors.purple),
          _buildFeature(Icons.security_rounded, 'Secure Pay', Colors.orange),
          _buildFeature(Icons.sync_rounded, 'Easy Returns', Colors.blue),
          _buildFeature(Icons.local_shipping_rounded, 'Fast Delivery', Colors.green),
        ],
      ),
    );
  }

  Widget _buildFeature(IconData icon, String label, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20.sp),
        SizedBox(height: 4.h),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 8.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.darkText,
          ),
        ),
      ],
    );
  }
}
