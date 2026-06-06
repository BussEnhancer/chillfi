import 'package:chillfi/core/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class FeatureItem extends StatelessWidget {
  final Widget icon;
  final String label;
  final bool showDivider;

  const FeatureItem({
    super.key,
    required this.icon,
    required this.label,
    this.showDivider = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 55.w,
              height: 55.w,
              alignment: Alignment.center,
              child: icon,
            ),
            SizedBox(height: 4.h),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 10.sp,
                fontWeight: FontWeight.w500,
                color: AppColors.darkText,
              ),
            ),
          ],
        ),
        if (showDivider) ...[
          SizedBox(width: 15.w),
          Container(
            height: 40.h,
            width: 1,
            color: Colors.grey.withOpacity(0.2),
          ),
          SizedBox(width: 15.w),
        ],
      ],
    );
  }
}
