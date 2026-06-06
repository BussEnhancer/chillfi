import 'package:chillfi/core/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class SubCategoriesHeader extends StatelessWidget {
  final String title;
  final String subtitle;

  const SubCategoriesHeader({
    super.key,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
      color: Colors.white,
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(Icons.arrow_back_rounded, color: AppColors.darkText, size: 24.sp),
          ),
          Container(
            width: 40.r,
            height: 40.r,
            decoration: BoxDecoration(
              color: AppColors.lightBackground,
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(color: AppColors.lightGrey.withOpacity(0.5)),
            ),
            child: Icon(Icons.smartphone_rounded, color: AppColors.primaryOrange, size: 24.sp),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.darkText,
                  ),
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.poppins(
                    fontSize: 11.sp,
                    color: AppColors.greyText,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.search_rounded, color: AppColors.darkText, size: 24.sp),
          ),
          Stack(
            alignment: Alignment.topRight,
            children: [
              IconButton(
                onPressed: () {},
                icon: Icon(Icons.shopping_cart_outlined, color: AppColors.darkText, size: 24.sp),
              ),
              Positioned(
                right: 8.w,
                top: 8.h,
                child: Container(
                  padding: EdgeInsets.all(4.r),
                  decoration: const BoxDecoration(
                    color: AppColors.secondaryPurple,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '2',
                    style: TextStyle(color: Colors.white, fontSize: 8.sp, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
