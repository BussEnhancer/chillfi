import 'package:chillfi/core/app_colors.dart';
import 'package:chillfi/features/search/voice_search_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomSearchHeader extends StatelessWidget {
  const CustomSearchHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: 10.h,
        bottom: 10.h,
        left: 10.w,
        right: 20.w,
      ),
      color: Colors.white,
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(Icons.arrow_back_rounded, color: AppColors.darkText, size: 24.sp),
          ),
          Expanded(
            child: Container(
              height: 48.h,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24.r),
                border: Border.all(color: AppColors.fieldBorder),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: TextField(
                autofocus: true,
                controller: TextEditingController(text: "iphone 15"),
                style: GoogleFonts.poppins(
                  fontSize: 14.sp,
                  color: AppColors.darkText,
                ),
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.search_rounded, color: AppColors.greyText, size: 20.sp),
                  suffixIcon: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const VoiceSearchScreen()),
                          );
                        },
                        child: Icon(Icons.mic_rounded, color: AppColors.secondaryPurple, size: 20.sp),
                      ),
                      SizedBox(width: 8.w),
                      Icon(Icons.cancel_rounded, color: AppColors.lightGrey, size: 20.sp),
                      SizedBox(width: 12.w),
                    ],
                  ),
                  contentPadding: EdgeInsets.symmetric(vertical: 12.h),
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          SizedBox(width: 15.w),
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Text(
              "Cancel",
              style: GoogleFonts.poppins(
                fontSize: 15.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.secondaryPurple,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
