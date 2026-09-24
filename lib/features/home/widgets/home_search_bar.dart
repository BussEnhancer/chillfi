import 'package:chillfi/core/app_colors.dart';
import 'package:chillfi/features/search/search_screen.dart';
import 'package:chillfi/features/search/voice_search_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeSearchBar extends StatelessWidget {
  const HomeSearchBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const SearchScreen()),
          );
        },
        child: Container(
          height: 54.h,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
            border: Border.all(color: AppColors.fieldBorder.withValues(alpha: 0.5)),
          ),
          child: Row(
            children: [
              SizedBox(width: 16.w),
              Icon(Icons.search_rounded, color: AppColors.greyText, size: 22.sp),
              SizedBox(width: 12.w),
              Expanded(
                child: AbsorbPointer(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search for products, brands and more...',
                      hintStyle: GoogleFonts.poppins(
                        fontSize: 13.sp,
                        color: AppColors.greyText.withValues(alpha: 0.6),
                      ),
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ),
              Container(height: 24.h, width: 1, color: AppColors.fieldBorder),
              SizedBox(width: 12.w),
              GestureDetector(
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const VoiceSearchScreen())),
                child: Icon(Icons.mic_rounded, color: AppColors.secondaryPurple, size: 22.sp),
              ),
              SizedBox(width: 12.w),
              Container(height: 24.h, width: 1, color: AppColors.fieldBorder),
              SizedBox(width: 12.w),
              Icon(Icons.qr_code_scanner_rounded, color: AppColors.primaryOrange, size: 22.sp),
              SizedBox(width: 16.w),
            ],
          ),
        ),
      ),
    );
  }
}
