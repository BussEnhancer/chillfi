import 'package:chillfi/core/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class ReviewFilterChips extends StatefulWidget {
  const ReviewFilterChips({super.key});

  @override
  State<ReviewFilterChips> createState() => _ReviewFilterChipsState();
}

class _ReviewFilterChipsState extends State<ReviewFilterChips> {
  int _selectedIndex = 0;

  final List<String> _filters = [
    "All Reviews (2,436)",
    "5 ★ (1,542)",
    "4 ★ (623)",
    "3 ★ (162)",
    "2 ★ (56)",
    "1 ★ (53)",
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: List.generate(
          _filters.length,
          (index) => GestureDetector(
            onTap: () => setState(() => _selectedIndex = index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: EdgeInsets.only(right: 12.w),
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
              decoration: BoxDecoration(
                color: _selectedIndex == index ? const Color(0xFFF5EDFF) : Colors.white,
                borderRadius: BorderRadius.circular(20.r),
                border: Border.all(
                  color: _selectedIndex == index ? AppColors.secondaryPurple : AppColors.lightGrey.withOpacity(0.5),
                ),
              ),
              child: Text(
                _filters[index],
                style: GoogleFonts.poppins(
                  fontSize: 12.sp,
                  fontWeight: _selectedIndex == index ? FontWeight.w600 : FontWeight.w500,
                  color: _selectedIndex == index ? AppColors.secondaryPurple : AppColors.darkText,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
