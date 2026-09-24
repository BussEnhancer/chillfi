import 'package:chillfi/core/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class ReviewFilterChips extends StatefulWidget {
  final Map<String, dynamic>? stats;
  const ReviewFilterChips({super.key, this.stats});

  @override
  State<ReviewFilterChips> createState() => _ReviewFilterChipsState();
}

class _ReviewFilterChipsState extends State<ReviewFilterChips> {
  int _selectedIndex = 0;

  List<String> _buildFilters() {
    final s = widget.stats ?? {};
    final total = s['total']?.toString() ?? '0';
    final five = s['five_star']?.toString() ?? '0';
    final four = s['four_star']?.toString() ?? '0';
    final three = s['three_star']?.toString() ?? '0';
    final two = s['two_star']?.toString() ?? '0';
    final one = s['one_star']?.toString() ?? '0';
    return [
      'All Reviews ($total)',
      '5 ★ ($five)',
      '4 ★ ($four)',
      '3 ★ ($three)',
      '2 ★ ($two)',
      '1 ★ ($one)',
    ];
  }

  @override
  Widget build(BuildContext context) {
    final filters = _buildFilters();
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: List.generate(
          filters.length,
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
                  color: _selectedIndex == index ? AppColors.secondaryPurple : AppColors.lightGrey.withValues(alpha: 0.5),
                ),
              ),
              child: Text(
                filters[index],
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
