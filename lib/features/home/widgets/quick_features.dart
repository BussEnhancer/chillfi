import 'package:chillfi/core/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class QuickFeatureSection extends StatelessWidget {
  const QuickFeatureSection({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> features = [
      {'icon': Icons.delivery_dining_rounded, 'label': 'Fast\nDelivery', 'color': AppColors.secondaryPurple},
      {'icon': Icons.percent_rounded, 'label': 'Best\nDeals', 'color': AppColors.primaryOrange},
      {'icon': Icons.verified_user_rounded, 'label': '100%\nOriginal', 'color': AppColors.secondaryPurple},
      {'icon': Icons.workspace_premium_rounded, 'label': 'Top\nBrands', 'color': AppColors.primaryOrange},
      {'icon': Icons.headset_mic_rounded, 'label': '24x7\nSupport', 'color': AppColors.secondaryPurple},
      {'icon': Icons.grid_view_rounded, 'label': 'Categories', 'color': AppColors.primaryOrange},
    ];

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: features.map((f) => _buildFeatureItem(f)).toList(),
      ),
    );
  }

  Widget _buildFeatureItem(Map<String, dynamic> feature) {
    return Column(
      children: [
        Container(
          width: 54.r,
          height: 54.r,
          decoration: BoxDecoration(
            color: (feature['color'] as Color).withOpacity(0.08),
            shape: BoxShape.circle,
          ),
          child: Icon(feature['icon'], color: feature['color'], size: 24.sp),
        ),
        SizedBox(height: 8.h),
        Text(
          feature['label'],
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
            fontSize: 10.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.darkText,
            height: 1.2,
          ),
        ),
      ],
    );
  }
}
