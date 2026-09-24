import 'package:chillfi/core/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class GalleryHeader extends StatelessWidget {
  final int currentIndex;
  final int totalImages;

  const GalleryHeader({
    super.key,
    required this.currentIndex,
    required this.totalImages,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: EdgeInsets.all(10.r),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Icon(Icons.close_rounded, size: 24.sp, color: AppColors.darkText),
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Product Image Gallery",
                  style: GoogleFonts.poppins(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.darkText,
                  ),
                ),
                Text(
                  "Swipe or tap to view more images",
                  style: GoogleFonts.poppins(
                    fontSize: 12.sp,
                    color: AppColors.greyText,
                  ),
                ),
              ],
            ),
          ),
          Text(
            "${currentIndex + 1} / $totalImages",
            style: GoogleFonts.poppins(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.secondaryPurple,
            ),
          ),
        ],
      ),
    );
  }
}

class GalleryFeatureStrip extends StatelessWidget {
  const GalleryFeatureStrip({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: const Color(0xFFF9F5FF),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildItem(Icons.camera_alt_outlined, "48MP + 12MP", "Dual Camera"),
          _buildItem(Icons.battery_charging_full_outlined, "Up to 20hrs", "Video Playback"),
          _buildItem(Icons.memory_outlined, "A16 Bionic", "Chip"),
          _buildItem(Icons.smartphone_outlined, "6.1\"", "Display"),
        ],
      ),
    );
  }

  Widget _buildItem(IconData icon, String title, String sub) {
    return Column(
      children: [
        Icon(icon, color: AppColors.secondaryPurple, size: 20.sp),
        SizedBox(height: 4.h),
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 9.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.darkText,
          ),
        ),
        Text(
          sub,
          style: GoogleFonts.poppins(
            fontSize: 8.sp,
            color: AppColors.greyText,
          ),
        ),
      ],
    );
  }
}
