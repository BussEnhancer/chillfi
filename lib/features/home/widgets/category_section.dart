import 'package:chillfi/core/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class CategorySection extends StatelessWidget {
  const CategorySection({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> categories = [
      {'name': 'Mobiles', 'icon': Icons.smartphone_rounded},
      {'name': 'Laptops', 'icon': Icons.laptop_mac_rounded},
      {'name': 'Audio', 'icon': Icons.headphones_rounded},
      {'name': 'Wearables', 'icon': Icons.watch_rounded},
      {'name': 'Cameras', 'icon': Icons.camera_alt_rounded},
      {'name': 'Appliances', 'icon': Icons.kitchen_rounded},
    ];

    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Shop by Category',
                style: GoogleFonts.poppins(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.darkText,
                ),
              ),
              Text(
                'View All >',
                style: GoogleFonts.poppins(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.secondaryPurple,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 15.h),
        SizedBox(
          height: 100.h,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 15.w),
            physics: const BouncingScrollPhysics(),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: EdgeInsets.symmetric(horizontal: 5.w),
                child: Column(
                  children: [
                    Container(
                      width: 70.w,
                      height: 70.h,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16.r),
                        border: Border.all(color: AppColors.fieldBorder.withOpacity(0.5)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.02),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Icon(
                          categories[index]['icon'],
                          color: AppColors.darkText.withOpacity(0.8),
                          size: 30.sp,
                        ),
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      categories[index]['name'],
                      style: GoogleFonts.poppins(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w500,
                        color: AppColors.greyText,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
