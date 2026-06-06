import 'package:chillfi/core/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class BrandChip extends StatelessWidget {
  final String label;
  final IconData? icon;
  final bool isSelected;
  final VoidCallback onTap;

  const BrandChip({
    super.key,
    required this.label,
    this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.secondaryPurple : Colors.white,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: isSelected ? AppColors.secondaryPurple : AppColors.lightGrey.withOpacity(0.5),
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.secondaryPurple.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 16.sp,
                color: isSelected ? Colors.white : AppColors.greyText,
              ),
              SizedBox(width: 6.w),
            ],
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 12.sp,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? Colors.white : AppColors.greyText,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
